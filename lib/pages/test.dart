import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/models/subject.dart';
import 'package:animikan/router.dart';
import 'package:animikan/widgets/subject_card.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subject = SlimSubject.fromJson(testSubject);
    final l = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.testPageTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l.testPageBody),
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
          label: Text(l.openDetailPage),
          onPressed: () =>
              context.push(AppRoute.subject(subject.id), extra: subject),
        ),
      ],
    );
  }
}
