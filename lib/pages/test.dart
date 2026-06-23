import 'dart:async';

import 'package:flutter/material.dart';

import 'package:animikan/widgets/app_shell.dart';
import 'package:animikan/models/subject.dart';
import 'package:animikan/widgets/subject_card.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    AppShellScope.setTitle(context, timeStr);

    return Stack(
      children: [
        Center(
          child: SubjectCard(
            subject: SlimSubject.fromJson(testSubject),
            watchers: 12040,
            onTap: () {},
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'test_sub',
            icon: const Icon(Icons.open_in_new),
            label: const Text('打开子页面'),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const _TestSubPage())),
          ),
        ),
      ],
    );
  }
}

class _TestSubPage extends StatelessWidget {
  const _TestSubPage();

  @override
  Widget build(BuildContext context) {
    AppShellScope.setTitle(context, '子页面示例');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('这是子页面', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '返回按钮在左上角 ←',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.subdirectory_arrow_right),
              label: const Text('再开一层'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _TestSubSubPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestSubSubPage extends StatelessWidget {
  const _TestSubSubPage();

  @override
  Widget build(BuildContext context) {
    AppShellScope.setTitle(context, '子子页面 🪆');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('这是子子页面', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '两层返回箭头仍然正常 ←',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
