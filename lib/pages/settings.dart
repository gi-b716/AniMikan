import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:animikan/settings/app.dart';
import 'package:animikan/utils/network/proxy.dart';
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
    AppShellScope.setTitle(context, '设置');
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsStore.instance,
      builder: (context, settings, _) => SettingsBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSection(
              '外观',
              children: [
                SettingsExpansionRow(
                  icon: Icons.brightness_6_outlined,
                  title: '深浅色',
                  subtitle: settings.themeMode.label,
                  children: [_themeChoices(settings)],
                ),
              ],
            ),
            // The browser owns proxying: nothing set here could be applied, so
            // the web build does not offer the setting at all.
            if (!kIsWeb)
              SettingsSection(
                '网络',
                children: [
                  SettingsExpansionRow(
                    icon: Icons.vpn_lock_outlined,
                    title: '代理设置',
                    subtitle: _proxySummary(settings),
                    children: const [_ProxyOptions()],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _themeChoices(AppSettings settings) => RadioGroup<ThemeMode>(
    groupValue: settings.themeMode,
    onChanged: (mode) {
      if (mode != null) AppSettingsStore.instance.setThemeMode(mode);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final mode in ThemeMode.values)
          SettingsChoiceRow<ThemeMode>(value: mode, title: mode.label),
      ],
    ),
  );
}

String _proxySummary(AppSettings settings) => switch (settings.proxyMode) {
  ProxyMode.direct => '禁用',
  ProxyMode.system =>
    AppSettingsStore.instance.systemProxy?.detected ?? '跟随系统设置',
  ProxyMode.custom => settings.customProxy?.toString() ?? '未设置',
};

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
    if (_store.systemProxy == null) _redetect();
  }

  Future<void> _redetect() async {
    await _store.redetectSystemProxy();
    if (mounted) setState(() {});
  }

  Future<void> _select(ProxyMode mode) async {
    await _store.setProxyMode(mode);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              SettingsChoiceRow<ProxyMode>(value: mode, title: mode.label),
            if (settings.proxyMode == ProxyMode.system) _detection(),
            if (settings.proxyMode == ProxyMode.custom)
              SettingsInfoRow(
                child: _CustomProxyForm(initial: settings.customProxy),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detection() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final result = _store.systemProxy;

    final String message = result == null
        ? '检测中…'
        : (result.detected ?? result.note ?? '未检测到系统代理');

    return SettingsInfoRow(
      title: '自动检测结果',
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
          TextButton(onPressed: _redetect, child: const Text('重新检测')),
        ],
      ),
    );
  }
}

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

  void _save() {
    final port = int.tryParse(_port.text.trim());
    if (port == null) {
      setState(() {
        _error = '端口要填数字';
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
        _applied = '已应用 ${config.toString()}';
      });
    } on ArgumentError catch (e) {
      setState(() {
        _error = _messageFor(e);
        _applied = null;
      });
    }
  }

  String _messageFor(ArgumentError error) => switch (error.name) {
    'host' => '主机不能为空，也不能带端口',
    'port' => '端口要在 1 到 65535 之间',
    'username' => '用户名不能为空，也不能含 “:” 或 “@”',
    'password' => '密码不能含 “;”，也不能以空格开头或结尾',
    _ => error.message.toString(),
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

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
            Expanded(flex: 3, child: _field(_host, '主机')),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _field(_port, '端口', keyboardType: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _field(_username, '用户名（可选）'),
        const SizedBox(height: 12),
        _field(_password, '密码（可选）', obscureText: true),
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
          child: FilledButton.tonal(onPressed: _save, child: const Text('保存')),
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
