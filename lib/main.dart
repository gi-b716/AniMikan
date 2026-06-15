import 'package:animikan/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'utils/platform.dart';
import 'config.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BangumiConst.init();

  bool isMaximized = false;
  if (isDesktop()) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(400, 400));
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    isMaximized = await windowManager.isMaximized();
  }

  runApp(MainApp(isMaximized: isMaximized));
}

class MainApp extends StatelessWidget {
  final bool isMaximized;

  const MainApp({super.key, this.isMaximized = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniMikan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(Brightness.light),
      darkTheme: AppTheme.of(Brightness.dark),
      themeMode: ThemeMode.system,
      home: AppShell(initialIsMaximized: isMaximized),
    );
  }
}

class AppShellScope extends InheritedWidget {
  final void Function(String?) notifyTitle;
  final int activeIndex;

  const AppShellScope({
    super.key,
    required this.notifyTitle,
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
    final index = _TabIndexScope.of(context);
    if (index == scope.activeIndex) scope.notifyTitle(title);
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      notifyTitle != oldWidget.notifyTitle ||
      activeIndex != oldWidget.activeIndex;
}

class _TabIndexScope extends InheritedWidget {
  final int index;

  const _TabIndexScope({required this.index, required super.child});

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_TabIndexScope>();
    assert(scope != null, 'No _TabIndexScope found in context');
    return scope!.index;
  }

  @override
  bool updateShouldNotify(_TabIndexScope oldWidget) => index != oldWidget.index;
}

class AppShell extends StatefulWidget {
  final bool initialIsMaximized;

  const AppShell({super.key, this.initialIsMaximized = false});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  static const double _kTitleBarHeight = 38.0;

  int _index = 0;
  late bool _isMaximized;
  String? _customTitle;

  String get _currentTitle => _customTitle ?? _tabs[_index].label;

  void setTitle(String? title) {
    if (_customTitle == title || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_customTitle != title && mounted) {
        setState(() => _customTitle = title);
      }
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

  static const _tabs = <_TabConfig>[
    _TabConfig(
      pageBuilder: _buildCalendar,
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: '日历',
    ),
    _TabConfig(
      pageBuilder: _buildFavourites,
      icon: Icons.star_outline,
      selectedIcon: Icons.star,
      label: '收藏',
    ),
    _TabConfig(
      pageBuilder: _buildCache,
      icon: Icons.download_outlined,
      selectedIcon: Icons.download_done,
      label: '缓存',
    ),
    _TabConfig(
      pageBuilder: _buildTest,
      icon: Icons.developer_board,
      selectedIcon: Icons.developer_board_outlined,
      label: '测试',
    ),
    _TabConfig(
      pageBuilder: _buildSettings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: '设置',
    ),
  ];

  static Widget _buildCalendar(BuildContext _) =>
      const Center(child: Text('日历'));
  static Widget _buildFavourites(BuildContext _) =>
      const Center(child: Text('收藏'));
  static Widget _buildCache(BuildContext _) => const Center(child: Text('缓存'));
  static Widget _buildTest(BuildContext _) => TestPage();
  static Widget _buildSettings(BuildContext _) =>
      const Center(child: Text('设置'));

  void _onSelect(int i) => setState(() {
    _index = i;
    _customTitle = null;
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
            destinations: [for (final t in _tabs) t.rail],
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                bottomLeft: Radius.circular(16.0),
              ),
              child: ColoredBox(
                color: colors.surfaceContainer,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        if (desktop) _buildTitleBar(withButtons: true),
                        Expanded(child: _buildPage()),
                      ],
                    ),
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
          Expanded(child: _buildPage()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onSelect,
        destinations: [for (final t in _tabs) t.bar],
      ),
    );
  }

  Widget _buildTitleBar({bool withButtons = false}) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: _kTitleBarHeight,
      child: Stack(
        children: [
          Positioned.fill(
            // child: DragToMoveArea(child: Container(color: Colors.transparent)),
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentTitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
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

  Widget _buildPage() {
    return AppShellScope(
      notifyTitle: setTitle,
      activeIndex: _index,
      child: IndexedStack(
        index: _index,
        children: [
          for (int i = 0; i < _tabs.length; i++)
            _TabIndexScope(index: i, child: _tabs[i].pageBuilder(context)),
        ],
      ),
    );
  }
}

class _TabConfig {
  final WidgetBuilder pageBuilder;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _TabConfig({
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
