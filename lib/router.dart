import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:animikan/models/subject.dart';
import 'package:animikan/pages/calendar.dart';
import 'package:animikan/pages/subject_detail.dart';
import 'package:animikan/pages/test.dart';
import 'package:animikan/widgets/app_shell.dart';

abstract final class AppRoute {
  static const calendar = '/calendar';
  static const favourites = '/favourites';
  static const cache = '/cache';
  static const test = '/test';
  static const settings = '/settings';
  static const subjectPath = '/subject/:subjectId';

  static String subject(int subjectId) => '/subject/$subjectId';
}

final appTabs = <TabConfig>[
  TabConfig(
    location: AppRoute.calendar,
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    label: '日历',
  ),
  TabConfig(
    location: AppRoute.favourites,
    icon: Icons.star_outline,
    selectedIcon: Icons.star,
    label: '收藏',
  ),
  TabConfig(
    location: AppRoute.cache,
    icon: Icons.download_outlined,
    selectedIcon: Icons.download_done,
    label: '缓存',
  ),
  TabConfig(
    location: AppRoute.test,
    icon: Icons.developer_board_outlined,
    selectedIcon: Icons.developer_board,
    label: '测试',
  ),
  TabConfig(
    location: AppRoute.settings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: '设置',
  ),
];

GoRouter createRouter({required bool isMaximized, VoidCallback? onSearch}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.calendar,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => AppShell(
          navigationShell: navigationShell,
          tabs: appTabs,
          initialIsMaximized: isMaximized,
          onSearchPressed: onSearch,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.calendar,
                builder: (_, _) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.favourites,
                builder: (_, _) => const _PlaceholderPage(title: '收藏'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.cache,
                builder: (_, _) => const _PlaceholderPage(title: '缓存'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoute.test, builder: (_, _) => const TestPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.settings,
                builder: (_, _) => const _PlaceholderPage(title: '设置'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.subjectPath,
        builder: (context, state) {
          final subjectId = int.tryParse(
            state.pathParameters['subjectId'] ?? '',
          );
          final extra = state.extra;
          final subject = extra is SlimSubject ? extra : null;
          return SubjectDetailPage(subjectId: subjectId, subject: subject);
        },
      ),
    ],
  );
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
