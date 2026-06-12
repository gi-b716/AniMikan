import 'package:flutter/material.dart';
import 'config.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BangumiConst.init();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniMikan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(Brightness.light),
      darkTheme: AppTheme.of(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

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
  static Widget _buildSettings(BuildContext _) =>
      const Center(child: Text('设置'));

  void _onSelect(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) =>
          orientation == Orientation.landscape ? _wide() : _narrow(),
    );
  }

  Widget _wide() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _onSelect,
            labelType: NavigationRailLabelType.selected,
            groupAlignment: 1.0,
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
          const VerticalDivider(width: 1),
          Expanded(child: _buildPage()),
        ],
      ),
    );
  }

  Widget _narrow() {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onSelect,
        destinations: [for (final t in _tabs) t.bar],
      ),
    );
  }

  Widget _buildPage() {
    return IndexedStack(
      index: _index,
      children: [for (final t in _tabs) t.pageBuilder(context)],
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
