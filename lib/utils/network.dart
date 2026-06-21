import 'dart:io';

class ProxyOverrides extends HttpOverrides {
  final String proxyHost;

  ProxyOverrides(this.proxyHost);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (uri) => 'PROXY $proxyHost';
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}
