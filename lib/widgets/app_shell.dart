import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:animikan/utils/platform.dart';

class TabConfig {
  final WidgetBuilder pageBuilder;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const TabConfig({
    required this.pageBuilder,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  NavigationRailDestination get rail => NavigationRailDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon),
    label: Text(label),
  );

  NavigationDestination get bar => NavigationDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon),
    label: label,
  );
}

class AppShellScope extends InheritedWidget {
  final void Function(String) notifyTitle;
  final VoidCallback? onBack;
  final void Function(VoidCallback?)? setOnBack;
  final int activeIndex;

  const AppShellScope({
    super.key,
    required this.notifyTitle,
    required this.onBack,
    required this.setOnBack,
    required this.activeIndex,
    required super.child,
  });

  static AppShellScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppShellScope>();
    assert(result != null, 'No AppShellScope found in context');
    return result!;
  }

  static void setTitle(BuildContext context, String title) {
    final scope = of(context);
    final index = TabIndexScope.of(context);
    if (index != scope.activeIndex) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    scope.notifyTitle(title);
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      notifyTitle != oldWidget.notifyTitle ||
      setOnBack != oldWidget.setOnBack ||
      onBack != oldWidget.onBack ||
      activeIndex != oldWidget.activeIndex;
}

class TabIndexScope extends InheritedWidget {
  final int index;

  const TabIndexScope({super.key, required this.index, required super.child});

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TabIndexScope>();
    assert(scope != null, 'No TabIndexScope found in context');
    return scope!.index;
  }

  @override
  bool updateShouldNotify(TabIndexScope oldWidget) => index != oldWidget.index;
}

/// Wraps a tab page in its own [Navigator] so the page can push/pop
/// sub-pages independently. Use one per tab inside the [IndexedStack].
class TabNavigator extends StatefulWidget {
  final WidgetBuilder builder;

  const TabNavigator({super.key, required this.builder});

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _syncBack() {
    if (!mounted) return;
    final scope = context.findAncestorWidgetOfExactType<AppShellScope>();
    final tabScope = context.findAncestorWidgetOfExactType<TabIndexScope>();
    if (scope == null || tabScope == null) return;
    if (tabScope.index != scope.activeIndex) return;

    final nav = _navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      scope.setOnBack?.call(() => nav.pop());
    } else {
      scope.setOnBack?.call(null);
    }
  }

  void _deferSyncBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncBack());
  }

  late final _NavObserver _observer = _NavObserver(_deferSyncBack);

  @override
  void initState() {
    super.initState();
    _deferSyncBack();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      observers: [_observer],
      onGenerateInitialRoutes: (navigator, initialRoute) => [
        MaterialPageRoute(builder: widget.builder),
      ],
    );
  }
}

class _NavObserver extends NavigatorObserver {
  final VoidCallback onChanged;

  _NavObserver(this.onChanged);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      onChanged();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();
}

class _WindowButtons extends StatelessWidget {
  final bool isMaximized;

  const _WindowButtons({required this.isMaximized});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    const double iconSize = 14.0;
    final Color iconColor = colors.onSurface;
    final Color hoverBg = colors.onSurface.withValues(alpha: 0.1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TitleBarButton(
          icon: Icons.horizontal_rule_rounded,
          size: iconSize,
          color: iconColor,
          hoverColor: hoverBg,
          onPressed: () => windowManager.minimize(),
        ),
        _TitleBarButton(
          icon: isMaximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          size: iconSize + 2,
          color: iconColor,
          hoverColor: hoverBg,
          onPressed: () {
            if (isMaximized) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        _TitleBarButton(
          icon: Icons.close_rounded,
          size: iconSize + 2,
          color: iconColor,
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: 38,
        height: 38,
        color: _isHovered ? widget.hoverColor : Colors.transparent,
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
}

class AppShell extends StatefulWidget {
  final bool initialIsMaximized;
  final List<TabConfig> tabs;

  const AppShell({
    super.key,
    this.initialIsMaximized = false,
    required this.tabs,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  static const double _kTitleBarHeight = 38.0;
  static const double _kBackButtonSize = 38.0;

  int _index = 0;
  late bool _isMaximized;
  String? _customTitle;
  VoidCallback? _onBack;

  String get _currentTitle => _customTitle ?? widget.tabs[_index].label;

  void setTitle(String title) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_customTitle != title && mounted) {
        setState(() => _customTitle = title);
      }
    });
  }

  void setOnBack(VoidCallback? cb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_onBack != cb && mounted) setState(() => _onBack = cb);
    });
  }

  @override
  void initState() {
    super.initState();
    _isMaximized = widget.initialIsMaximized;
    if (isDesktop()) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (isDesktop()) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  void _onSelect(int i) => setState(() {
    _index = i;
    _customTitle = null;
    _onBack = null;
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) =>
          orientation == Orientation.landscape ? _wide() : _narrow(),
    );
  }

  Widget _wide() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool desktop = isDesktop();

    return Scaffold(
      backgroundColor: colors.surfaceContainerHigh,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _onSelect,
            labelType: NavigationRailLabelType.selected,
            groupAlignment: 1.0,
            backgroundColor: colors.surfaceContainerHigh,
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: FloatingActionButton(
                elevation: 0,
                heroTag: 'search',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onPressed: () {},
                child: const Icon(Icons.search, size: 28),
              ),
            ),
            destinations: [for (final t in widget.tabs) t.rail],
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                bottomLeft: Radius.circular(16.0),
              ),
              child: ColoredBox(
                color: colors.surfaceContainer,
                child: Column(
                  children: [
                    if (desktop) _buildTitleBar(withButtons: true),
                    if (!desktop && _onBack != null) _buildBackBar(),
                    Expanded(child: _buildPage()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrow() {
    final bool desktop = isDesktop();

    return Scaffold(
      body: Column(
        children: [
          if (desktop) _buildTitleBar(withButtons: true),
          if (!desktop && _onBack != null) _buildBackBar(),
          Expanded(child: _buildPage()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onSelect,
        destinations: [for (final t in widget.tabs) t.bar],
      ),
    );
  }

  Widget _buildBackRow() {
    final colors = Theme.of(context).colorScheme;
    final canBack = _onBack != null;
    return Row(
      children: [
        if (canBack)
          SizedBox(
            width: _kBackButtonSize,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              onPressed: _onBack,
              padding: EdgeInsets.zero,
              splashRadius: 14,
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        SizedBox(width: canBack ? 4.0 : 16.0),
        Text(
          _currentTitle,
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBar({bool withButtons = false}) {
    return SizedBox(
      height: _kTitleBarHeight,
      child: Stack(
        children: [
          Positioned.fill(child: DragToMoveArea(child: _buildBackRow())),
          if (withButtons)
            Positioned(
              top: 0,
              right: 0,
              child: _WindowButtons(isMaximized: _isMaximized),
            ),
        ],
      ),
    );
  }

  Widget _buildBackBar() {
    return SizedBox(height: _kTitleBarHeight, child: _buildBackRow());
  }

  Widget _buildPage() {
    return AppShellScope(
      notifyTitle: setTitle,
      onBack: _onBack,
      setOnBack: setOnBack,
      activeIndex: _index,
      child: IndexedStack(
        index: _index,
        children: [
          for (final (i, tab) in widget.tabs.indexed)
            TabIndexScope(
              index: i,
              child: TabNavigator(builder: tab.pageBuilder),
            ),
        ],
      ),
    );
  }
}
