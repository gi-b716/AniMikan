import 'dart:async';
import 'dart:io';

import 'package:animikan/utils/network/proxy.dart';
import 'package:animikan/utils/network/socks5.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// The [NetworkBackend] used wherever `dart:io` exists.
final NetworkBackend backend = _IoNetwork();

class _IoNetwork implements NetworkBackend {
  ProxyConfig? _proxy;
  bool _allowBadCertificates = false;

  final StreamController<ProxyConfig?> _changes =
      StreamController<ProxyConfig?>.broadcast();

  final Map<Dio, StreamSubscription<ProxyConfig?>> _bound = {};

  _ProxyOverrides? _installed;

  @override
  ProxyConfig? get proxy => _proxy;

  @override
  Stream<ProxyConfig?> get changes => _changes.stream;

  @override
  bool get allowBadCertificates => _allowBadCertificates;

  @override
  set allowBadCertificates(bool value) {
    if (_allowBadCertificates == value) return;
    _allowBadCertificates = value;
    _installOverrides();
    _changes.add(_proxy);
  }

  @override
  void configure(ProxyConfig? config) {
    if (_proxy == config) return;
    _proxy = config;
    _installOverrides();
    _changes.add(config);
  }

  @override
  void bindDio(Dio dio) {
    if (_bound.containsKey(dio)) return;
    if (dio.httpClientAdapter is! IOHttpClientAdapter) {
      // An adapter of somebody else's choosing — a test double, most likely.
      return;
    }
    _rebuildAdapter(dio);
    _bound[dio] = _changes.stream.listen((_) => _rebuildAdapter(dio));
  }

  HttpClient createHttpClient([SecurityContext? context]) =>
      _ProxyOverrides(this).createHttpClient(context);

  HttpClient _wire(HttpClient client, SecurityContext? context) {
    client.badCertificateCallback = _badCertificate;
    client.findProxy = _findProxy;
    client.connectionFactory = _createConnection(context);
    return client;
  }

  void _rebuildAdapter(Dio dio) {
    final previous = dio.httpClientAdapter;
    if (previous is! IOHttpClientAdapter) {
      // Somebody gave this Dio an adapter of their own since it was bound —
      // theirs to keep, and no longer ours to rebuild.
      _bound.remove(dio)?.cancel();
      return;
    }
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: createHttpClient,
    );
    previous.close();
  }

  void _installOverrides() {
    if (_proxy != null || _allowBadCertificates) {
      _installed = _ProxyOverrides(this);
      HttpOverrides.global = _installed;
      return;
    }
    // Nothing left to apply.
    if (identical(HttpOverrides.current, _installed)) {
      HttpOverrides.global = null;
    }
    _installed = null;
  }

  bool _badCertificate(X509Certificate _, String _, int _) =>
      _allowBadCertificates;

  String _findProxy(Uri uri) {
    final proxy = _proxy;
    if (proxy == null || proxy.type != ProxyType.http) return 'DIRECT';
    final credentials = proxy.isAuthenticated
        ? '${proxy.username}:${proxy.password}@'
        : '';
    return 'PROXY $credentials${proxy.authority}';
  }

  Future<ConnectionTask<Socket>> Function(Uri, String?, int?) _createConnection(
    SecurityContext? context,
  ) {
    return (uri, proxyHost, proxyPort) {
      final proxy = _proxy;
      if (proxy != null && proxy.type == ProxyType.socks5) {
        return socks5ConnectTask(
          proxy: proxy,
          target: uri,
          context: context,
          onBadCertificate: _allowBadCertificates
              ? _acceptAnyCertificate
              : null,
        );
      }
      if (proxyHost != null) {
        // An HTTP proxy
        return Socket.startConnect(proxyHost, proxyPort!);
      }
      // Direct
      return uri.isScheme('https')
          ? SecureSocket.startConnect(
              uri.host,
              uri.port,
              context: context,
              onBadCertificate: _allowBadCertificates
                  ? _acceptAnyCertificate
                  : null,
            )
          : Socket.startConnect(uri.host, uri.port);
    };
  }
}

bool _acceptAnyCertificate(X509Certificate _) => true;

class _ProxyOverrides extends HttpOverrides {
  _ProxyOverrides(this._network);

  final _IoNetwork _network;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _network._wire(super.createHttpClient(context), context);
}
