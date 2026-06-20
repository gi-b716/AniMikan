import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:animikan/config.dart';
import 'package:animikan/models/calendar.dart';

class BangumiException implements Exception {
  final String message;
  final int? statusCode;

  const BangumiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'BangumiException ($statusCode): $message'
      : 'BangumiException: $message';
}

class BangumiClient {
  final Dio _nextDio = Dio(
    BaseOptions(
      baseUrl: BangumiConst.nextApi,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        if (!kIsWeb) 'User-Agent': BangumiConst.userAgent,
      },
    ),
  );

  Future<Calendar> getCalendar() async {
    try {
      final resp = await _nextDio.get('/p1/calendar');
      return Calendar.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw BangumiException(
        e.message ?? 'Network request failed',
        statusCode: e.response?.statusCode,
      );
    } on TypeError catch (e) {
      throw BangumiException('Unexpected response format: $e');
    }
  }
}
