import 'package:package_info_plus/package_info_plus.dart';

class BangumiConst {
  BangumiConst._();

  static const String nextApi = 'https://next.bgm.tv';

  static const String scheme = 'animikan';

  static const String turnstileRedirect =
      '$scheme://api/bangumi/turnstile/callback';

  static Uri turnstilePage({required String theme}) =>
      Uri.parse('$nextApi/p1/turnstile').replace(
        queryParameters: {'redirect_uri': turnstileRedirect, 'theme': theme},
      );

  static bool isTurnstileCallback(Uri uri) =>
      uri.scheme == scheme &&
      uri.host == 'api' &&
      uri.path == '/bangumi/turnstile/callback';

  static late final String userAgent;

  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    userAgent =
        'gi-b716/AniMikan/${info.version} (https://github.com/gi-b716/AniMikan)';
  }
}
