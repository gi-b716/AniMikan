import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/models/subject.dart';

class SubjectDetailPage extends StatelessWidget {
  final int? subjectId;
  final SlimSubject? subject;

  const SubjectDetailPage({super.key, required this.subjectId, this.subject});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final displayName = subject?.displayName ?? l.subjectDetailTitle;
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
                      l.subjectId(subjectId?.toString() ?? l.invalidId),
                      style: text.bodyMedium?.copyWith(color: colors.outline),
                    ),
                    if (subject != null) ...[
                      const SizedBox(height: 20),
                      Text(subject!.info, style: text.bodyLarge),
                      const SizedBox(height: 12),
                      Text(
                        'Bangumi Rank #${subject!.rating.rank} · '
                        '${l.score(subject!.rating.score.toStringAsFixed(1))}',
                        style: text.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(l.detailDemoNote, style: text.bodyMedium),
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
