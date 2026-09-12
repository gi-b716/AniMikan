import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'package:animikan/utils/platform.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

class TabConfig {
  final String location;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final NavigationRailDestination rail;
  final NavigationDestination bar;

  TabConfig({
    required this.location,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  }) : rail = NavigationRailDestination(
         icon: Icon(icon),
         selectedIcon: Icon(selectedIcon),
         label: Text(label),
       ),
       bar = NavigationDestination(
         icon: Icon(icon),
         selectedIcon: Icon(selectedIcon),
         label: label,
       );
}

class AppShellScope extends InheritedWidget {
  final void Function(String title, bool canPop) sync;
  final String activeLocation;

  const AppShellScope({
    super.key,
    required this.sync,
    required this.activeLocation,
    required super.child,
  });

  static AppShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>();
  }

  static void setTitle(BuildContext context, String title) {
    final scope = maybeOf(context);
    if (scope == null) return;

    final location = GoRouterState.of(context).matchedLocation;
    if (location != scope.activeLocation &&
        !location.startsWith('${scope.activeLocation}/')) {
      return;
    }

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    scope.sync(title, GoRouter.of(context).canPop());
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      sync != oldWidget.sync || activeLocation != oldWidget.activeLocation;
}

class _WindowButtons extends StatelessWidget {
  final bool isMaximized;
  const _WindowButtons({required this.isMaximized});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const sz = 14.0;
    final c = cs.onSurface;
    final h = cs.onSurface.withValues(alpha: 0.1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TitleBarButton(
          icon: Icons.horizontal_rule_rounded,
          size: sz,
          color: c,
          hoverColor: h,
          onPressed: () => windowManager.minimize(),
        ),
        _TitleBarButton(
          icon: isMaximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          size: sz + 2,
          color: c,
          hoverColor: h,
          onPressed: () => isMaximized
              ? windowManager.unmaximize()
              : windowManager.maximize(),
        ),
        _TitleBarButton(
          icon: Icons.close_rounded,
          size: sz + 2,
          color: c,
          hoverColor: const Color(0xFFC42B1C),
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onPressed;
  final Color hoverColor;
  const _TitleBarButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onPressed,
    required this.hoverColor,
  });
  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit: (_) => setState(() => _h = false),
    child: Container(
      width: 38,
      height: 38,
      color: _h ? widget.hoverColor : Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: Icon(widget.icon, size: widget.size, color: widget.color),
        ),
      ),
    ),
  );
}

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<TabConfig> tabs;
  final bool initialIsMaximized;
  final VoidCallback? onSearchPressed;

  const AppShell({
    super.key,
    required this.navigationShell,
    required this.tabs,
    this.initialIsMaximized = false,
    this.onSearchPressed,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  static const _barH = 38.0;

  late bool _maximized;
  late bool _desktop;
  String? _customTitle;
  bool _canPop = false;

  int get _i => widget.navigationShell.currentIndex;
  String get _currentTitle => _customTitle ?? widget.tabs[_i].label;

  void _syncTitle(String title, bool canPop) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_customTitle == title && _canPop == canPop) return;
      setState(() {
        _customTitle = title;
        _canPop = canPop;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _maximized = widget.initialIsMaximized;
    _desktop = isDesktop();
    if (_desktop) windowManager.addListener(this);
  }

  @override
  void dispose() {
    if (_desktop) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);
  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  void _goBranch(int index) {
    if (index != _i) {
      setState(() {
        _customTitle = null;
        _canPop = false;
      });
    }
    widget.navigationShell.goBranch(index, initialLocation: index == _i);
  }

  @override
  Widget build(BuildContext context) {
    final body = AppShellScope(
      sync: _syncTitle,
      activeLocation: widget.tabs[_i].location,
      child: widget.navigationShell,
    );
    return OrientationBuilder(
      builder: (_, o) =>
          o == Orientation.landscape ? _wide(body) : _narrow(body),
    );
  }

  Widget _wide(Widget page) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerHigh,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _i,
            onDestinationSelected: _goBranch,
            labelType: NavigationRailLabelType.selected,
            groupAlignment: 1.0,
            backgroundColor: cs.surfaceContainerHigh,
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: FloatingActionButton(
                elevation: 0,
                heroTag: 'search',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onPressed: widget.onSearchPressed,
                child: const Icon(Icons.search, size: 28),
              ),
            ),
            destinations: [for (final t in widget.tabs) t.rail],
          ),
          Expanded(
            child: Material(
              color: cs.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _topBar(),
                  Expanded(child: page),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrow(Widget page) => Scaffold(
    body: Column(
      children: [
        _topBar(),
        Expanded(child: page),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _i,
      onDestinationSelected: _goBranch,
      destinations: [for (final t in widget.tabs) t.bar],
    ),
  );

  Widget _backRow() {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (_canPop)
          SizedBox(
            width: _barH,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              onPressed: () => GoRouter.of(context).pop(),
              padding: EdgeInsets.zero,
              splashRadius: 14,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        SizedBox(width: _canPop ? 4.0 : 16.0),
        Text(
          _currentTitle,
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _topBar() {
    if (!_canPop && !_desktop) return const SizedBox.shrink();

    final bar = SizedBox(height: _barH, child: _backRow());
    if (!_desktop) return bar;

    return SizedBox(
      height: _barH,
      child: Stack(
        children: [
          Positioned.fill(child: DragToMoveArea(child: bar)),
          Positioned(
            top: 0,
            right: 0,
            child: _WindowButtons(isMaximized: _maximized),
          ),
        ],
      ),
    );
  }
}
