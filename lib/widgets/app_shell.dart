import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/utils/platform.dart';
import 'package:animikan/widgets/app_top_bar.dart';
import 'package:animikan/widgets/user_avatar.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

class TabConfig {
  const TabConfig({
    required this.location,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String location;
  final IconData icon;
  final IconData selectedIcon;

  /// Resolved where it is shown, so the label follows a language change.
  final String Function(AppLocalizations) label;
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
  /// The width of the resize border Windows draws around a window, in physical
  /// pixels — the same 8 that `window_manager_plugin.cpp` keeps for itself in
  /// its `WM_NCCALCSIZE` handling.
  static const _nativeBorder = 8.0;

  late bool _maximized;
  late bool _desktop;
  String? _customTitle;
  bool _canPop = false;

  int get _i => widget.navigationShell.currentIndex;
  String _currentTitle(AppLocalizations l) =>
      _customTitle ?? widget.tabs[_i].label(l);

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
    final shell = OrientationBuilder(
      builder: (_, o) =>
          o == Orientation.landscape ? _wide(body) : _narrow(body),
    );
    if (!_desktop) return shell;
    return DragToResizeArea(
      enableResizeEdges: _maximized ? const <ResizeEdge>[] : _resizeEdges,
      resizeEdgeSize: _resizeEdgeSize(context),
      child: shell,
    );
  }

  /// The window edges left for the app to hit-test, which depends on how much
  /// of the frame the platform keeps once the title bar is hidden:
  ///
  /// * Windows keeps 8px of native border on the left, right and bottom but
  ///   none at the top — `window_manager_plugin.cpp` hands back a client area
  ///   flush with the top of the window — so without a hit zone here, the top
  ///   edge cannot be dragged at all.
  /// * Linux drops the frame altogether (`gtk_window_set_decorated(false)`), so
  ///   every edge is the app's to provide.
  /// * macOS keeps its native frame, which does all of it.
  ///
  /// `DragToResizeArea` is window_manager's own widget for this, and what
  /// `VirtualWindowFrame` in that package does on each platform.
  List<ResizeEdge> get _resizeEdges => switch (defaultTargetPlatform) {
    TargetPlatform.windows => const [
      ResizeEdge.topLeft,
      ResizeEdge.top,
      ResizeEdge.topRight,
    ],
    TargetPlatform.linux => ResizeEdge.values,
    _ => const <ResizeEdge>[],
  };

  /// How thick those hit zones are, in logical pixels.
  ///
  /// Windows' border is 8 *physical* pixels, so matching it keeps this strip
  /// exactly where the native one would have been.
  double _resizeEdgeSize(BuildContext context) =>
      defaultTargetPlatform == TargetPlatform.windows
      ? _nativeBorder / MediaQuery.devicePixelRatioOf(context)
      : _nativeBorder;

  Widget _wide(Widget page) {
    final cs = Theme.of(context).colorScheme;
    // Reading the localization here is what makes the shell rebuild — and the
    // tab labels change — when the language setting does.
    final l = AppLocalizations.of(context);
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
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    elevation: 0,
                    heroTag: 'search',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onPressed: widget.onSearchPressed,
                    child: const Icon(Icons.search, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const UserAvatarButton(),
                ],
              ),
            ),
            destinations: [
              for (final t in widget.tabs)
                NavigationRailDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.selectedIcon),
                  label: Text(t.label(l)),
                ),
            ],
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

  Widget _narrow(Widget page) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          AppTopBar(
            title: _currentTitle(l),
            onBack: _canPop ? () => GoRouter.of(context).pop() : null,
            trailing: const UserAvatarButton(size: 30),
          ),
          Expanded(child: page),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: _goBranch,
        destinations: [
          for (final t in widget.tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label(l),
            ),
        ],
      ),
    );
  }

  Widget _topBar() {
    if (!_canPop && !_desktop) return const SizedBox.shrink();

    return AppTopBar(
      title: _currentTitle(AppLocalizations.of(context)),
      onBack: _canPop ? () => GoRouter.of(context).pop() : null,
    );
  }
}
