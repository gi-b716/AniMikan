import 'package:package_info_plus/package_info_plus.dart';

class BangumiConst {
  BangumiConst._();

  static const String nextApi = 'https://next.bgm.tv';

  static String userAgent =
      'gi-b716/AniMikan (https://github.com/gi-b716/AniMikan)';

  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();

    /// add version to userAgent
    userAgent =
        'gi-b716/AniMikan/${info.version} (https://github.com/gi-b716/AniMikan)';
  }
}
