import 'package:animikan/models/calender.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';

class BangumiClient {
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

  Future<Calendar> getCalendar() async {
    final resp = await _nextDio.get('/p1/calendar');
    return Calendar.fromJson(resp.data as Map<String, dynamic>);
  }
}
