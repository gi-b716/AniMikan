library;

import 'package:dio/dio.dart';

enum ProxyType {
  http('http'),

  socks5('socks5');

  const ProxyType(this.scheme);

  final String scheme;

  String get label => switch (this) {
    ProxyType.http => 'HTTP',
    ProxyType.socks5 => 'SOCKS5',
  };
}

class ProxyConfig {
  const ProxyConfig._({
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  factory ProxyConfig({
    required ProxyType type,
    required String host,
    required int port,
    String? username,
    String? password,
  }) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(host, 'host', 'Must not be empty');
    }
    if (trimmed.contains(RegExp(r'[\s/@]'))) {
      throw ArgumentError.value(host, 'host', 'Must be a bare host name');
    }
    if (trimmed.contains(':') && !_looksLikeIpv6(trimmed)) {
      throw ArgumentError.value(
        host,
        'host',
        'Must not contain a port (IPv6 literals need two colons or more)',
      );
    }
    if (port < 1 || port > 65535) {
      throw ArgumentError.value(port, 'port', 'Must be between 1 and 65535');
    }
    if (username != null && username.isEmpty) {
      throw ArgumentError.value(username, 'username', 'Must not be empty');
    }
    if (type == ProxyType.http && username != null) {
      if (_httpUsername.hasMatch(username)) {
        throw ArgumentError.value(
          username,
          'username',
          "An HTTP proxy username cannot contain ':' or '@'",
        );
      }
      final secret = password ?? '';
      if (secret.contains(';') || secret.trim() != secret) {
        throw ArgumentError.value(
          password,
          'password',
          'An HTTP proxy password cannot contain ";" or start or end '
              'with whitespace',
        );
      }
    }
    return ProxyConfig._(
      type: type,
      host: trimmed,
      port: port,
      username: username,
      password: username == null ? null : (password ?? ''),
    );
  }

  factory ProxyConfig.parse(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      throw const FormatException('Enter a proxy address');
    }

    // Without a scheme, `host:port` would parse as scheme `host` and path
    // `port`, so give it one and read the type off the scheme below.
    final explicitScheme = text.contains('://');
    final Uri uri;
    try {
      uri = Uri.parse(explicitScheme ? text : 'http://$text');
    } on FormatException catch (e) {
      throw FormatException('Not a valid proxy address: ${e.message}');
    }

    final type = switch (uri.scheme.toLowerCase()) {
      'http' || 'https' => ProxyType.http,
      // `socks5h` means "let the proxy resolve host names", which is what this
      // implementation always does, so the two are the same thing here.
      'socks5' || 'socks5h' => ProxyType.socks5,
      final other => throw FormatException('Unsupported proxy type "$other"'),
    };

    if (uri.host.isEmpty) {
      throw const FormatException('Missing proxy host');
    }
    if (!uri.hasPort) {
      throw const FormatException('Missing proxy port');
    }

    final userInfo = uri.userInfo;
    String? username;
    String? password;
    if (userInfo.isNotEmpty) {
      final colon = userInfo.indexOf(':');
      if (colon == -1) {
        username = _decode(userInfo);
      } else {
        username = _decode(userInfo.substring(0, colon));
        password = _decode(userInfo.substring(colon + 1));
      }
    }

    try {
      return ProxyConfig(
        type: type,
        host: uri.host,
        port: uri.port,
        username: username,
        password: password,
      );
    } on ArgumentError catch (e) {
      throw FormatException(e.message.toString());
    }
  }

  factory ProxyConfig.fromJson(Map<String, dynamic> json) => ProxyConfig(
    type: ProxyType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => throw FormatException('Unknown proxy type ${json['type']}'),
    ),
    host: json['host'] as String,
    port: (json['port'] as num).toInt(),
    username: json['username'] as String?,
    password: json['password'] as String?,
  );

  final ProxyType type;

  final String host;

  final int port;

  final String? username;
  final String? password;

  bool get isAuthenticated => username != null;

  String get authority => host.contains(':') ? '[$host]:$port' : '$host:$port';

  String get _userInfo => isAuthenticated
      ? '${Uri.encodeComponent(username!)}:${Uri.encodeComponent(password!)}'
      : '';

  Uri toUri() => Uri(
    scheme: type.scheme,
    userInfo: _userInfo.isEmpty ? null : _userInfo,
    host: host,
    port: port,
  );

  String toUriString() => toUri().toString();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'host': host,
    'port': port,
    if (username != null) 'username': username,
    if (password != null) 'password': password,
  };

  @override
  bool operator ==(Object other) =>
      other is ProxyConfig &&
      other.type == type &&
      other.host == host &&
      other.port == port &&
      other.username == username &&
      other.password == password;

  @override
  int get hashCode => Object.hash(type, host, port, username, password);

  @override
  String toString() {
    if (!isAuthenticated) return '${type.scheme}://$authority';
    final secret = password!.isEmpty ? '' : '***';
    return '${type.scheme}://${Uri.encodeComponent(username!)}:$secret@$authority';
  }
}

bool _looksLikeIpv6(String host) =>
    ':'.allMatches(host).length >= 2 &&
    RegExp(r'^[0-9A-Fa-f:.]+$').hasMatch(host);

final RegExp _httpUsername = RegExp(r'[:@]');

String _decode(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    return value;
  }
}

abstract interface class NetworkBackend {
  ProxyConfig? get proxy;

  Stream<ProxyConfig?> get changes;

  bool get allowBadCertificates;
  set allowBadCertificates(bool value);

  void configure(ProxyConfig? config);

  void bindDio(Dio dio);
}
