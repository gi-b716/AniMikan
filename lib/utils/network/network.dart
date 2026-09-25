import 'package:animikan/utils/network/proxy.dart';
import 'package:animikan/utils/network/io.dart';
import 'package:dio/dio.dart';

export 'package:animikan/utils/network/proxy.dart'
    show ProxyConfig, ProxyType, SystemProxySource;

/// Which proxy, if any, the app's HTTP traffic goes through.
///
/// ```dart
/// // No proxy:
/// Network.configure(null);
///
/// // Or from a settings field:
/// Network.use('http://user:pass@127.0.0.1:7890');
/// Network.use('socks5://user:pass@127.0.0.1:1080');
///
/// // Anything that has to rebuild itself when this changes:
/// Network.changes.listen(rebuild);
/// ```
abstract final class Network {
  static ProxyConfig? get proxy => backend.proxy;

  static Stream<ProxyConfig?> get changes => backend.changes;

  static bool get allowBadCertificates => backend.allowBadCertificates;
  static set allowBadCertificates(bool value) =>
      backend.allowBadCertificates = value;

  static void configure(ProxyConfig? config) => backend.configure(config);

  static void prepare() => backend.prepare();

  /// Throws [FormatException] when the string cannot be read as a proxy.
  static void use(String? input) {
    final text = input?.trim() ?? '';
    configure(text.isEmpty ? null : ProxyConfig.parse(text));
  }

  /// The OS proxy settings; null when this platform has none to read.
  static Future<SystemProxySource?> readSystemProxy() =>
      backend.readSystemProxy();

  static void bindDio(Dio dio) => backend.bindDio(dio);
}
