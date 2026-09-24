import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:animikan/config.dart';
import 'package:animikan/models/calendar.dart';
import 'package:animikan/models/user.dart';
import 'package:animikan/utils/network/network.dart';

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
  static final BangumiClient instance = BangumiClient();

  static const String sessionCookie = 'chiiNextSessionID';

  static const String loginPath = '/p1/login';

  final Dio _dio;

  BangumiClient({Dio? dio}) : _dio = dio ?? _createDio() {
    Network.bindDio(_dio);
  }

  static Dio _createDio() => Dio(
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

  void addInterceptor(Interceptor interceptor) =>
      _dio.interceptors.add(interceptor);

  Future<Calendar> getCalendar() => _guard(() async {
    final resp = await _dio.get('/p1/calendar');
    return Calendar.fromJson(resp.data as Map<String, dynamic>);
  });

  Future<({SlimUser user, String session})> login({
    required String email,
    required String password,
    required String turnstileToken,
  }) => _guard(() async {
    final resp = await _dio.post(
      loginPath,
      data: {
        'email': email,
        'password': password,
        'turnstileToken': turnstileToken,
      },
    );
    final session = _sessionOf(resp.headers);
    if (session == null) {
      throw const BangumiException('Login answered without a session cookie');
    }
    return (
      user: SlimUser.fromJson(resp.data as Map<String, dynamic>),
      session: session,
    );
  });

  Future<Profile> getMe() => _guard(() async {
    final resp = await _dio.get('/p1/me');
    return Profile.fromJson(resp.data as Map<String, dynamic>);
  });

  Future<void> logout(String session) async {
    try {
      await _guard(
        () => _dio.post(
          '/p1/logout',
          data: const <String, dynamic>{},
          options: Options(headers: {'Cookie': '$sessionCookie=$session'}),
        ),
      );
    } on BangumiException {
      // pass
    }
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on BangumiException {
      rethrow;
    } on DioException catch (e) {
      throw BangumiException(
        e.message ?? 'Network request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BangumiException('Unexpected response format: $e');
    }
  }

  static String? _sessionOf(Headers headers) {
    final cookies = headers['set-cookie'] ?? const <String>[];
    for (final cookie in cookies) {
      final pair = cookie.split(';').first.trim();
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;
      if (pair.substring(0, separator) == sessionCookie) {
        final value = pair.substring(separator + 1);
        if (value.isEmpty) continue;
        return value;
      }
    }
    return null;
  }
}
