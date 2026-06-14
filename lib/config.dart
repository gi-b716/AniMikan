import 'package:package_info_plus/package_info_plus.dart';

class BangumiConst {
  BangumiConst._();

  static const String nextApi = 'https://next.bgm.tv';

  static late final String userAgent;

  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    userAgent =
        'gi-b716/AniMikan/${info.version} (https://github.com/gi-b716/AniMikan)';
  }
}
