import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:animikan/utils/network/proxy.dart';
import 'package:async/async.dart';

/// SOCKS5 (RFC 1928), with username/password authentication (RFC 1929).
///
/// `HttpClient.findProxy` understands only `DIRECT` and `PROXY host:port`, so
/// the connection is dialled here and handed to `HttpClient.connectionFactory`
/// instead — the documented way to plug a socket of your own into dart:io, see
/// `ConnectionTask.fromSocket`. That factory is also where TLS has to happen:
/// with one installed, dart:io treats the socket it gets back as final and
/// performs no security upgrade of its own.
///
/// The plumbing at the bottom of this file — [_Handshake] and [_TunneledSocket]
/// — exists because a dart:io `Socket` can only ever be listened to once, and
/// the handshake spends that one subscription.

const int _version = 0x05;

const int _authNone = 0x00;
const int _authUserPass = 0x02;
const int _authRejected = 0xFF;

const int _commandConnect = 0x01;

const int _addressIpv4 = 0x01;
const int _addressDomain = 0x03;
const int _addressIpv6 = 0x04;

/// No timeout is applied here: `dart:io` races this against
/// `HttpClient.connectionTimeout` itself and cancels the task if it loses.
Future<ConnectionTask<Socket>> socks5ConnectTask({
  required ProxyConfig proxy,
  required Uri target,
  required bool Function(X509Certificate)? onBadCertificate,
  SecurityContext? context,
}) async {
  var live = await _open(proxy);
  final handshake = _Handshake(live);

  Future<Socket> connect() async {
    try {
      await _negotiate(live, handshake, proxy, target);
      if (target.isScheme('https')) {
        return live = await SecureSocket.secure(
          live,
          host: target.host,
          context: context,
          onBadCertificate: onBadCertificate,
        );
      }
      return live = _TunneledSocket(live, handshake.rest());
    } catch (_) {
      live.destroy();
      rethrow;
    }
  }

  final pending = connect();
  unawaited(pending.then((_) {}, onError: (Object _) {}));

  return ConnectionTask.fromSocket(pending, () => live.destroy());
}

Future<Socket> _open(ProxyConfig proxy) async {
  try {
    return await Socket.connect(proxy.host, proxy.port);
  } on SocketException catch (e) {
    throw SocketException(
      'Cannot reach the SOCKS5 proxy at ${proxy.authority}: ${e.message}',
    );
  }
}

/// Performs the greeting, the authentication and the CONNECT request, leaving
/// the connection positioned at the start of the tunnelled data.
Future<void> _negotiate(
  Socket socket,
  _Handshake handshake,
  ProxyConfig proxy,
  Uri target,
) async {
  // Greeting: what this client is able to do.
  final methods = <int>[_authNone, if (proxy.isAuthenticated) _authUserPass];
  socket.add(<int>[_version, methods.length, ...methods]);
  await socket.flush();

  // What the proxy picked.
  final choice = await handshake.read(2);
  if (choice[0] != _version) {
    throw SocketException(
      'SOCKS5 proxy replied with protocol version ${choice[0]}',
    );
  }
  switch (choice[1]) {
    case _authNone:
      break;
    case _authUserPass:
      await _authenticate(socket, handshake, proxy);
    case _authRejected:
      throw SocketException(
        'SOCKS5 proxy accepted none of the offered authentication methods',
      );
    default:
      throw SocketException(
        'SOCKS5 proxy chose unsupported authentication method ${choice[1]}',
      );
  }

  // The request: connect to the target and leave the socket open.
  final port = target.port;
  socket.add(<int>[
    _version,
    _commandConnect,
    0x00, // reserved
    ..._encodeAddress(target.host),
    (port >> 8) & 0xFF,
    port & 0xFF,
  ]);
  await socket.flush();

  final reply = await handshake.read(4);
  if (reply[0] != _version) {
    throw SocketException(
      'SOCKS5 proxy replied with protocol version ${reply[0]}',
    );
  }
  if (reply[1] != 0x00) {
    throw SocketException(
      'SOCKS5 proxy could not reach ${target.host}:${target.port} '
      '(${_replyMessage(reply[1])})',
    );
  }

  final int boundLength;
  switch (reply[3]) {
    case _addressIpv4:
      boundLength = 4;
    case _addressIpv6:
      boundLength = 16;
    case _addressDomain:
      boundLength = (await handshake.read(1))[0];
    default:
      throw SocketException(
        'SOCKS5 proxy replied with unsupported address type ${reply[3]}',
      );
  }
  await handshake.read(boundLength + 2); // bound address, then bound port
}

/// Sends the credentials of [proxy] (RFC 1929) and checks they were accepted.
Future<void> _authenticate(
  Socket socket,
  _Handshake handshake,
  ProxyConfig proxy,
) async {
  final username = utf8.encode(proxy.username!);
  final password = utf8.encode(proxy.password!);
  if (username.isEmpty || username.length > 255 || password.length > 255) {
    throw SocketException(
      'SOCKS5 username and password must be 1 to 255 bytes when UTF-8 encoded',
    );
  }

  socket.add(<int>[
    0x01, // authentication version
    username.length,
    ...username,
    password.length,
    ...password,
  ]);
  await socket.flush();

  final reply = await handshake.read(2);
  if (reply[0] != 0x01) {
    throw SocketException(
      'SOCKS5 proxy replied with authentication version ${reply[0]}',
    );
  }
  if (reply[1] != 0x00) {
    throw SocketException('SOCKS5 proxy rejected the username and password');
  }
}

/// Encodes [host] as a SOCKS5 address field.
///
/// Literal IP addresses go out as such; everything else is sent as a name for
/// the proxy to resolve.
List<int> _encodeAddress(String host) {
  final address = InternetAddress.tryParse(host);
  if (address != null) {
    return <int>[
      address.type == InternetAddressType.IPv6 ? _addressIpv6 : _addressIpv4,
      ...address.rawAddress,
    ];
  }

  final name = utf8.encode(host);
  if (name.length > 255) {
    throw SocketException('Host name is too long for SOCKS5: $host');
  }
  return <int>[_addressDomain, name.length, ...name];
}

String _replyMessage(int code) => switch (code) {
  0x01 => 'general SOCKS server failure',
  0x02 => 'connection not allowed by ruleset',
  0x03 => 'network unreachable',
  0x04 => 'host unreachable',
  0x05 => 'connection refused',
  0x06 => 'TTL expired',
  0x07 => 'command not supported',
  0x08 => 'address type not supported',
  _ => 'unknown error $code',
};

class _Handshake {
  _Handshake(Socket socket) : _chunks = StreamQueue<Uint8List>(socket);

  final StreamQueue<Uint8List> _chunks;

  final List<int> _arrived = [];

  /// Waits for [count] bytes and takes them, so they will not be seen again.
  Future<Uint8List> read(int count) async {
    while (_arrived.length < count) {
      if (!await _chunks.hasNext) {
        throw const SocketException('SOCKS5 proxy closed the connection');
      }
      _arrived.addAll(await _chunks.next);
    }
    final bytes = Uint8List.fromList(_arrived.sublist(0, count));
    _arrived.removeRange(0, count);
    return bytes;
  }

  Stream<Uint8List> rest() async* {
    if (_arrived.isNotEmpty) yield Uint8List.fromList(_arrived);
    yield* _chunks.rest;
  }
}

class _TunneledSocket extends Stream<Uint8List> implements Socket {
  _TunneledSocket(this._socket, this._incoming);

  final Socket _socket;
  final Stream<Uint8List> _incoming;

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _incoming.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  InternetAddress get address => _socket.address;

  @override
  int get port => _socket.port;

  @override
  InternetAddress get remoteAddress => _socket.remoteAddress;

  @override
  int get remotePort => _socket.remotePort;

  @override
  bool setOption(SocketOption option, bool enabled) =>
      _socket.setOption(option, enabled);

  @override
  Uint8List getRawOption(RawSocketOption option) =>
      _socket.getRawOption(option);

  @override
  void setRawOption(RawSocketOption option) => _socket.setRawOption(option);

  @override
  void destroy() => _socket.destroy();

  @override
  void add(List<int> data) => _socket.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _socket.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<List<int>> stream) => _socket.addStream(stream);

  @override
  Future<void> close() => _socket.close();

  @override
  Future<void> get done => _socket.done;

  @override
  Encoding get encoding => _socket.encoding;

  @override
  set encoding(Encoding encoding) => _socket.encoding = encoding;

  @override
  Future<void> flush() => _socket.flush();

  @override
  void write(Object? object) => _socket.write(object);

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      _socket.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _socket.writeCharCode(charCode);

  @override
  void writeln([Object? object = '']) => _socket.writeln(object);
}
