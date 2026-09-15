import 'package:animikan/utils/network/network.dart';

/// What detection found, and what to show about it.
class SystemProxyResult {
  const SystemProxyResult({this.config, this.detected, this.note});

  /// The proxy to route through, or null to go out directly.
  final ProxyConfig? config;

  /// Display form, e.g. `http://127.0.0.1:7891` — never the password.
  final String? detected;

  /// Why there is no config, in words for the user: the mode must never fail
  /// silently.
  final String? note;
}

/// Turns what the OS says about its proxy into something the app can use.
abstract final class SystemProxy {
  /// Never throws: whatever goes wrong comes back as a [SystemProxyResult.note].
  static Future<SystemProxyResult> detect() async {
    final source = await Network.readSystemProxy();
    if (source == null) {
      return const SystemProxyResult(note: '当前平台无法自动检测系统代理，将直连');
    }
    return fromSource(source);
  }

  /// PAC scripts cannot be evaluated here, so they are reported, not guessed at.
  static SystemProxyResult fromSource(SystemProxySource source) {
    final pac = source.autoConfigUrl;
    if (pac != null && pac.isNotEmpty) {
      return SystemProxyResult(note: '检测到 PAC 自动配置脚本（$pac），暂不支持，将直连');
    }
    if (!source.enabled) {
      return const SystemProxyResult(note: '系统未启用代理，将直连');
    }
    final server = source.server;
    if (server == null || server.isEmpty) {
      return const SystemProxyResult(note: '系统未设置代理地址，将直连');
    }
    final config = parseProxyServer(server);
    if (config == null) {
      return SystemProxyResult(note: '无法识别系统代理地址：$server');
    }
    return SystemProxyResult(config: config, detected: config.toString());
  }

  /// Either a bare `host:port`, or Windows' per-scheme form
  /// (`http=…;https=…;socks=…`).
  static ProxyConfig? parseProxyServer(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    if (!text.contains('=')) return _config(ProxyType.http, text);

    final byScheme = <String, String>{};
    for (final part in text.split(';')) {
      final eq = part.indexOf('=');
      if (eq <= 0) continue;
      byScheme[part.substring(0, eq).trim().toLowerCase()] = part
          .substring(eq + 1)
          .trim();
    }
    for (final scheme in const ['https', 'http']) {
      final entry = byScheme[scheme];
      if (entry != null && entry.isNotEmpty) {
        return _config(ProxyType.http, entry);
      }
    }
    final socks = byScheme['socks'];
    if (socks != null && socks.isNotEmpty) {
      return _config(ProxyType.socks5, socks);
    }
    return null;
  }

  static ProxyConfig? _config(ProxyType type, String hostPort) {
    try {
      final url = hostPort.contains('://')
          ? hostPort
          : '${type.scheme}://$hostPort';
      return ProxyConfig.parse(url);
    } on FormatException {
      return null;
    }
  }
}
