import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:animikan/config.dart';
import 'package:animikan/router.dart';
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

void _onSearchPressed() {
  // TODO: implement search
  throw UnimplementedError();
}

class MainApp extends StatelessWidget {
  final bool isMaximized;

  const MainApp({super.key, required this.isMaximized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AniMikan',
      debugShowCheckedModeBanner: true,
      theme: AppTheme.of(Brightness.light),
      darkTheme: AppTheme.of(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: createRouter(
        isMaximized: isMaximized,
        onSearch: _onSearchPressed,
      ),
    );
  }
}
