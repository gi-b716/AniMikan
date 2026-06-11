import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';

class BangumiClient {
  // ignore: unused_field
  late final Dio _nextDio;

  BangumiClient() {
    _nextDio = Dio(
      BaseOptions(
        baseUrl: BangumiConst.nextApi,
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          if (!kIsWeb) 'User-Agent': BangumiConst.userAgent,
        },
      ),
    );
  }
}
