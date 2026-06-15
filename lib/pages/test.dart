import 'dart:async';

import 'package:animikan/main.dart';
import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../widgets/subject_card.dart';

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

    return Center(
      child: SubjectCard(
        subject: SlimSubject.fromJson(testSubject),
        watchers: 12040,
        onTap: () {},
      ),
    );
  }
}
