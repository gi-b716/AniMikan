import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/l10n/labels.dart';
import 'package:animikan/services/auth.dart';
import 'package:animikan/widgets/app_top_bar.dart';
import 'package:animikan/widgets/user_avatar.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          AppTopBar(title: l.accountTitle, onBack: () => context.pop()),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _content(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return ValueListenableBuilder<AuthState>(
      valueListenable: BangumiAuth.instance,
      builder: (context, state, _) => state.isLoggedIn
          ? _AccountView(user: state.user)
          : const _SignInForm(),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;

  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l) async {
    if (_busy) return;

    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = l.accountEmailRequired);
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _error = l.accountPasswordRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final user = await BangumiAuth.instance.login(
        email: email,
        password: _password.text,
      );
      _password.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.accountSignedInAs(user.nickname))),
      );
    } on LoginException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = loginFailureText(l, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.accountSignInTitle, style: text.titleLarge),
        const SizedBox(height: 6),
        Text(
          l.accountSignInDescription,
          style: text.bodySmall?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _email,
          enabled: !_busy,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l.accountEmailLabel,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          enabled: !_busy,
          obscureText: true,
          onSubmitted: (_) => _submit(l),
          decoration: InputDecoration(
            labelText: l.accountPasswordLabel,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        if (_busy)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.accountWaitingForBrowser,
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              _error!,
              style: text.bodySmall?.copyWith(color: colors.error),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            if (_busy) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: BangumiAuth.instance.cancelLogin,
                  child: Text(l.accountCancelWaiting),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: _busy ? null : () => _submit(l),
                child: Text(l.accountSignIn),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            UserAvatar(user: user, size: 64),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.nickname ?? '',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '@${user!.username}',
                        style: text.bodyMedium?.copyWith(color: colors.outline),
                      ),
                    ),
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        l.accountUid('${user!.id}'),
                        style: text.bodySmall?.copyWith(color: colors.outline),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            unawaited(BangumiAuth.instance.logout());
            messenger.showSnackBar(SnackBar(content: Text(l.accountSignedOut)));
          },
          child: Text(l.accountSignOut),
        ),
      ],
    );
  }
}
