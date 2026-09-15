import 'dart:async';

import 'package:animikan/utils/network/proxy.dart';
import 'package:dio/dio.dart';

final NetworkBackend backend = _WebNetwork();

class _WebNetwork implements NetworkBackend {
  ProxyConfig? _proxy;
  bool _allowBadCertificates = false;
  final StreamController<ProxyConfig?> _changes =
      StreamController<ProxyConfig?>.broadcast();

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
    _changes.add(_proxy);
  }

  @override
  void configure(ProxyConfig? config) {
    if (_proxy == config) return;
    _proxy = config;
    _changes.add(config);
  }

  /// Nothing to do.
  @override
  void prepare() {}

  /// Nothing to read: the browser owns proxying.
  @override
  Future<SystemProxySource?> readSystemProxy() async => null;

  /// Nothing to do.
  @override
  void bindDio(Dio dio) {}
}
