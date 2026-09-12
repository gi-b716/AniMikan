import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:animikan/models/subject.dart';

class SubjectDetailPage extends StatelessWidget {
  final int? subjectId;
  final SlimSubject? subject;

  const SubjectDetailPage({super.key, required this.subjectId, this.subject});

  @override
  Widget build(BuildContext context) {
    final displayName = subject?.displayName ?? '番剧详情';
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: text.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Subject ID: ${subjectId ?? '无效'}',
                      style: text.bodyMedium?.copyWith(color: colors.outline),
                    ),
                    if (subject != null) ...[
                      const SizedBox(height: 20),
                      Text(subject!.info, style: text.bodyLarge),
                      const SizedBox(height: 12),
                      Text(
                        'Bangumi Rank #${subject!.rating.rank} · '
                        '${subject!.rating.score.toStringAsFixed(1)} 分',
                        style: text.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      '这是一个由根 Navigator 承载的通用详情页：任何列表卡片都可以通过 '
                      'context.push(AppRoute.subject(id), extra: subject) 打开它。',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
