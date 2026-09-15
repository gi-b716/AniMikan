import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'package:animikan/config.dart';
import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/router.dart';
import 'package:animikan/settings/app.dart';
import 'package:animikan/theme.dart';
import 'package:animikan/utils/platform.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppSettingsStore.instance.load();

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

class MainApp extends StatefulWidget {
  final bool isMaximized;

  const MainApp({super.key, required this.isMaximized});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router = createRouter(
    isMaximized: widget.isMaximized,
    onSearch: _onSearchPressed,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsStore.instance,
      builder: (context, settings, _) => MaterialApp.router(
        title: 'AniMikan',
        debugShowCheckedModeBanner: true,
        theme: AppTheme.of(Brightness.light),
        darkTheme: AppTheme.of(Brightness.dark),
        themeMode: settings.themeMode,
        locale: settings.language.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}
