import 'package:animikan/utils/network/network.dart';

/// Why there is no proxy to use. Kept as a value rather than a sentence:
/// detection runs before the first frame, where there is no build context to
/// translate with, so wording it is the UI's job.
enum SystemProxyReason {
  unsupportedPlatform,
  pacScript,
  disabled,
  noServer,
  unparsable,
}

/// What detection found, and what to show about it.
class SystemProxyResult {
  const SystemProxyResult({
    this.config,
    this.detected,
    this.reason,
    this.detail,
  });

  /// The proxy to route through, or null to go out directly.
  final ProxyConfig? config;

  /// Display form, e.g. `http://127.0.0.1:7891` — never the password.
  final String? detected;

  /// Why there is no config: the mode must never fail silently.
  final SystemProxyReason? reason;

  /// Whatever the reason has to name: a PAC URL, an address we could not read.
  final String? detail;
}

/// Turns what the OS says about its proxy into something the app can use.
abstract final class SystemProxy {
  /// Never throws: whatever goes wrong comes back as a [SystemProxyResult.reason].
  static Future<SystemProxyResult> detect() async {
    final source = await Network.readSystemProxy();
    if (source == null) {
      return const SystemProxyResult(
        reason: SystemProxyReason.unsupportedPlatform,
      );
    }
    return fromSource(source);
  }

  /// PAC scripts cannot be evaluated here, so they are reported, not guessed at.
  static SystemProxyResult fromSource(SystemProxySource source) {
    final pac = source.autoConfigUrl;
    if (pac != null && pac.isNotEmpty) {
      return SystemProxyResult(
        reason: SystemProxyReason.pacScript,
        detail: pac,
      );
    }
    if (!source.enabled) {
      return const SystemProxyResult(reason: SystemProxyReason.disabled);
    }
    final server = source.server;
    if (server == null || server.isEmpty) {
      return const SystemProxyResult(reason: SystemProxyReason.noServer);
    }
    final config = parseProxyServer(server);
    if (config == null) {
      return SystemProxyResult(
        reason: SystemProxyReason.unparsable,
        detail: server,
      );
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
