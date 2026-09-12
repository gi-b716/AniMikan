import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:animikan/models/subject.dart';
import 'package:animikan/router.dart';
import 'package:animikan/widgets/subject_card.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subject = SlimSubject.fromJson(testSubject);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('GoRouter 导航示例', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('点击任意卡片会 push 同一个详情页；切换底部标签后再回来，测试页和各标签的状态会保留。'),
        const SizedBox(height: 24),
        SubjectCard(
          subject: subject,
          watchers: 12040,
          onTap: () =>
              context.push(AppRoute.subject(subject.id), extra: subject),
        ),
        const SizedBox(height: 12),
        SubjectCard(
          subject: subject,
          watchers: 5830,
          onTap: () =>
              context.push(AppRoute.subject(subject.id), extra: subject),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('打开详情页'),
          onPressed: () =>
              context.push(AppRoute.subject(subject.id), extra: subject),
        ),
      ],
    );
  }
}
