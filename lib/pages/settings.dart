import 'package:flutter/material.dart';

import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/l10n/labels.dart';
import 'package:animikan/settings/app.dart';
import 'package:animikan/utils/network/proxy.dart';
import 'package:animikan/utils/restart.dart';
import 'package:animikan/widgets/app_shell.dart';
import 'package:animikan/widgets/settings_list.dart';

/// Settings, each row expanding in place — there are no sub-pages.
///
/// To add one: put a [SettingsExpansionRow] in a [SettingsSection], and put
/// whatever it should reveal in that row's `children`.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    AppShellScope.setTitle(context, l.settingsTitle);
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsStore.instance,
      builder: (context, settings, _) => SettingsBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSection(
              l.sectionAppearance,
              children: [
                SettingsExpansionRow(
                  icon: Icons.brightness_6_outlined,
                  title: l.themeModeTitle,
                  subtitle: settings.themeMode.label(l),
                  children: [_themeChoices(l, settings)],
                ),
                SettingsExpansionRow(
                  icon: Icons.translate_rounded,
                  title: l.languageTitle,
                  subtitle: settings.language.label(l),
                  children: [_languageChoices(l, settings)],
                ),
              ],
            ),
            SettingsSection(
              l.sectionNetwork,
              children: [
                SettingsExpansionRow(
                  icon: Icons.vpn_lock_outlined,
                  title: l.proxyTitle,
                  subtitle: _proxySummary(l, settings),
                  children: const [_ProxyOptions()],
                ),
              ],
            ),
            SettingsSection(
              l.sectionDebug,
              children: [
                SettingsRow(
                  icon: Icons.delete_forever_outlined,
                  title: l.debugClearTitle,
                  subtitle: l.debugClearSubtitle,
                  trailing: TextButton(
                    onPressed: () => _clearAllData(context),
                    child: Text(l.debugClearAction),
                  ),
                  onTap: () => _clearAllData(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Wipes everything this app has stored and starts over — hence the confirm.
  Future<void> _clearAllData(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.debugClearConfirmTitle),
            content: Text(l.debugClearConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l.debugClearAction),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;

    await AppSettingsStore.instance.clearAll();
    await restartApp();
  }

  Widget _themeChoices(AppLocalizations l, AppSettings settings) =>
      RadioGroup<ThemeMode>(
        groupValue: settings.themeMode,
        onChanged: (mode) {
          if (mode != null) AppSettingsStore.instance.setThemeMode(mode);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final mode in ThemeMode.values)
              SettingsChoiceRow<ThemeMode>(value: mode, title: mode.label(l)),
          ],
        ),
      );

  Widget _languageChoices(AppLocalizations l, AppSettings settings) =>
      RadioGroup<Language>(
        groupValue: settings.language,
        onChanged: (language) {
          if (language != null) AppSettingsStore.instance.setLanguage(language);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final language in Language.values)
              SettingsChoiceRow<Language>(
                value: language,
                title: language.label(l),
              ),
          ],
        ),
      );
}

/// The row's subtitle: what this setting is set to right now.
String _proxySummary(AppLocalizations l, AppSettings settings) =>
    switch (settings.proxyMode) {
      ProxyMode.direct => l.proxyModeDirect,
      ProxyMode.system =>
        AppSettingsStore.instance.systemProxy?.detected ??
            l.proxyFollowingSystem,
      ProxyMode.custom => settings.customProxy?.toString() ?? l.proxyNotSet,
    };

/// The three modes, the system-proxy detection result and the custom form.
class _ProxyOptions extends StatefulWidget {
  const _ProxyOptions();

  @override
  State<_ProxyOptions> createState() => _ProxyOptionsState();
}

class _ProxyOptionsState extends State<_ProxyOptions> {
  final AppSettingsStore _store = AppSettingsStore.instance;

  @override
  void initState() {
    super.initState();
    // Detect on first expand, unless a result is already cached.
    if (_store.systemProxy == null) _redetect();
  }

  Future<void> _redetect() async {
    await _store.redetectSystemProxy();
    if (mounted) setState(() {});
  }

  /// Applies at once; the system-proxy result arrives later, so redraw then.
  Future<void> _select(ProxyMode mode) async {
    await _store.setProxyMode(mode);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ValueListenableBuilder<AppSettings>(
      valueListenable: _store,
      builder: (context, settings, _) => RadioGroup<ProxyMode>(
        groupValue: settings.proxyMode,
        onChanged: (mode) {
          if (mode != null) _select(mode);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final mode in ProxyMode.values)
              SettingsChoiceRow<ProxyMode>(value: mode, title: mode.label(l)),
            if (settings.proxyMode == ProxyMode.system) _detection(l),
            if (settings.proxyMode == ProxyMode.custom)
              SettingsInfoRow(
                child: _CustomProxyForm(initial: settings.customProxy),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detection(AppLocalizations l) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final result = _store.systemProxy;

    final String message;
    if (result == null) {
      message = l.proxyDetecting;
    } else if (result.detected != null) {
      message = result.detected!;
    } else if (result.reason != null) {
      message = systemProxyReasonText(l, result.reason!, result.detail);
    } else {
      message = l.proxyNotFound;
    }

    return SettingsInfoRow(
      title: l.proxyDetected,
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: text.bodySmall?.copyWith(
                color: colors.outline,
                fontFamily: result?.detected == null ? null : 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: _redetect, child: Text(l.proxyRedetect)),
        ],
      ),
    );
  }
}

/// Applies on save rather than per keystroke: every apply swaps the Dio adapter.
class _CustomProxyForm extends StatefulWidget {
  const _CustomProxyForm({required this.initial});

  final ProxyConfig? initial;

  @override
  State<_CustomProxyForm> createState() => _CustomProxyFormState();
}

class _CustomProxyFormState extends State<_CustomProxyForm> {
  late ProxyType _type = widget.initial?.type ?? ProxyType.http;
  late final TextEditingController _host = TextEditingController(
    text: widget.initial?.host ?? '127.0.0.1',
  );
  late final TextEditingController _port = TextEditingController(
    text: widget.initial?.port.toString() ?? '',
  );
  late final TextEditingController _username = TextEditingController(
    text: widget.initial?.username ?? '',
  );
  late final TextEditingController _password = TextEditingController(
    text: widget.initial?.password ?? '',
  );

  String? _error;
  String? _applied;

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l) {
    final port = int.tryParse(_port.text.trim());
    if (port == null) {
      setState(() {
        _error = l.portMustBeNumber;
        _applied = null;
      });
      return;
    }

    try {
      final config = ProxyConfig(
        type: _type,
        host: _host.text,
        port: port,
        username: _username.text.isEmpty ? null : _username.text,
        password: _password.text.isEmpty ? null : _password.text,
      );
      AppSettingsStore.instance.setCustomProxy(config);
      setState(() {
        _error = null;
        _applied = l.proxyApplied(config.toString());
      });
    } on ArgumentError catch (e) {
      setState(() {
        _error = _messageFor(l, e);
        _applied = null;
      });
    }
  }

  /// [ProxyConfig]'s errors are English (it is used elsewhere too) — say them in
  /// the UI's language.
  String _messageFor(AppLocalizations l, ArgumentError error) =>
      switch (error.name) {
        'host' => l.hostInvalid,
        'port' => l.portInvalid,
        'username' => l.usernameInvalid,
        'password' => l.passwordInvalid,
        _ => error.message.toString(),
      };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ProxyType>(
          segments: [
            for (final type in ProxyType.values)
              ButtonSegment(value: type, label: Text(type.label)),
          ],
          selected: {_type},
          onSelectionChanged: (selection) =>
              setState(() => _type = selection.first),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 3, child: _field(_host, l.hostLabel)),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _field(
                _port,
                l.portLabel,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _field(_username, l.usernameLabel),
        const SizedBox(height: 12),
        _field(_password, l.passwordLabel, obscureText: true),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: text.bodySmall?.copyWith(color: colors.error),
            ),
          ),
        if (_applied != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _applied!,
              style: text.bodySmall?.copyWith(color: colors.outline),
            ),
          ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            onPressed: () => _save(l),
            child: Text(l.save),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) => TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      border: const OutlineInputBorder(),
    ),
  );
}
