import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:animikan/config.dart';
import 'package:animikan/pages/calendar.dart';
import 'package:animikan/pages/test.dart';
import 'package:animikan/widgets/app_shell.dart';
import 'package:animikan/theme.dart';
import 'package:animikan/utils/platform.dart';
import 'package:animikan/utils/network.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Read proxy from config
  HttpOverrides.global = ProxyOverrides('');

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

  const MainApp({super.key, required this.isMaximized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniMikan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(Brightness.light),
      darkTheme: AppTheme.of(Brightness.dark),
      themeMode: ThemeMode.system,
      home: AppShell(
        initialIsMaximized: isMaximized,
        tabs: _tabs,
        onSearchPressed: _onSearchPressed,
      ),
    );
  }
}

Widget _buildCalendar(BuildContext _) => const CalendarPage();
Widget _buildFavourites(BuildContext _) => const Center(child: Text('收藏'));
Widget _buildCache(BuildContext _) => const Center(child: Text('缓存'));
Widget _buildTest(BuildContext _) => const TestPage();
Widget _buildSettings(BuildContext _) => const Center(child: Text('设置'));

void _onSearchPressed() {
  // TODO: implement search
  throw UnimplementedError();
}

final _tabs = <TabConfig>[
  TabConfig(
    pageBuilder: _buildCalendar,
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    label: '日历',
  ),
  TabConfig(
    pageBuilder: _buildFavourites,
    icon: Icons.star_outline,
    selectedIcon: Icons.star,
    label: '收藏',
  ),
  TabConfig(
    pageBuilder: _buildCache,
    icon: Icons.download_outlined,
    selectedIcon: Icons.download_done,
    label: '缓存',
  ),
  TabConfig(
    pageBuilder: _buildTest,
    icon: Icons.developer_board,
    selectedIcon: Icons.developer_board_outlined,
    label: '测试',
  ),
  TabConfig(
    pageBuilder: _buildSettings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: '设置',
  ),
];
