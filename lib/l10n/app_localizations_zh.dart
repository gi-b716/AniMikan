// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tabCalendar => '日历';

  @override
  String get tabFavourites => '收藏';

  @override
  String get tabCache => '缓存';

  @override
  String get tabTest => '测试';

  @override
  String get tabSettings => '设置';

  @override
  String calendarTitleWeek(int year, int week) {
    return '$year年第$week周放送时间表';
  }

  @override
  String calendarTitleWeekLoading(int year, int week) {
    return '$year年第$week周放送时间表 [加载中]';
  }

  @override
  String calendarTitleWeekFetched(int year, int week, String weekday) {
    return '$year年第$week周放送时间表 · $weekday获取';
  }

  @override
  String get loadFailed => '加载失败';

  @override
  String get retry => '重试';

  @override
  String get today => '今天';

  @override
  String nSubjects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 部',
    );
    return '$_temp0';
  }

  @override
  String get noData => '暂无';

  @override
  String jumpToDay(String day) {
    return '跳转到$day';
  }

  @override
  String get collectionWish => '想看';

  @override
  String get collectionCollect => '看过';

  @override
  String get collectionDoing => '在看';

  @override
  String get collectionOnHold => '搁置';

  @override
  String get collectionDropped => '抛弃';

  @override
  String get collectionUnknown => '未知';

  @override
  String get subjectBook => '书籍';

  @override
  String get subjectAnime => '动画';

  @override
  String get subjectMusic => '音乐';

  @override
  String get subjectGame => '游戏';

  @override
  String get subjectReal => '三次元';

  @override
  String get subjectUnknown => '未知';

  @override
  String get subjectDetailTitle => '番剧详情';

  @override
  String subjectId(String id) {
    return 'Subject ID: $id';
  }

  @override
  String get invalidId => '无效';

  @override
  String score(String score) {
    return '$score 分';
  }

  @override
  String get detailDemoNote =>
      '这是一个由根 Navigator 承载的通用详情页：任何列表卡片都可以通过 context.push(AppRoute.subject(id), extra: subject) 打开它。';

  @override
  String nRatings(String count) {
    return '$count人';
  }

  @override
  String get bangumiRank => 'Bangumi 排名';

  @override
  String get testPageTitle => 'GoRouter 导航示例';

  @override
  String get testPageBody => '点击任意卡片会 push 同一个详情页；切换底部标签后再回来，测试页和各标签的状态会保留。';

  @override
  String get openDetailPage => '打开详情页';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionNetwork => '网络';

  @override
  String get themeModeTitle => '深浅色';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get languageTitle => '语言';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String get proxyTitle => '代理设置';

  @override
  String get proxyModeDirect => '禁用';

  @override
  String get proxyModeSystem => '系统代理';

  @override
  String get proxyModeCustom => '自定义';

  @override
  String get proxyFollowingSystem => '跟随系统设置';

  @override
  String get proxyNotSet => '未设置';

  @override
  String get proxyDetecting => '检测中…';

  @override
  String get proxyNotFound => '未检测到系统代理';

  @override
  String get proxyDetected => '自动检测结果';

  @override
  String get proxyRedetect => '重新检测';

  @override
  String proxyApplied(String proxy) {
    return '已应用 $proxy';
  }

  @override
  String get hostLabel => '主机';

  @override
  String get portLabel => '端口';

  @override
  String get usernameLabel => '用户名（可选）';

  @override
  String get passwordLabel => '密码（可选）';

  @override
  String get save => '保存';

  @override
  String get portMustBeNumber => '端口要填数字';

  @override
  String get hostInvalid => '主机不能为空，也不能带端口';

  @override
  String get portInvalid => '端口要在 1 到 65535 之间';

  @override
  String get usernameInvalid => '用户名不能为空，也不能含 “:” 或 “@”';

  @override
  String get passwordInvalid => '密码不能含 “;”，也不能以空格开头或结尾';

  @override
  String get sectionDebug => '调试';

  @override
  String get debugClearTitle => '清除所有数据';

  @override
  String get debugClearSubtitle => '清除设置并重启应用';

  @override
  String get debugClearAction => '清除';

  @override
  String get debugClearConfirmTitle => '清除所有数据？';

  @override
  String get debugClearConfirmBody => '所有设置会被删除，应用随后重启。此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get accountTitle => 'Bangumi 账号';

  @override
  String get accountSignInTitle => '登录 Bangumi';

  @override
  String get accountSignInDescription => '点击登录后会打开浏览器完成 Cloudflare 人机验证。';

  @override
  String get accountEmailLabel => '邮箱';

  @override
  String get accountPasswordLabel => '密码';

  @override
  String get accountSignIn => '登录';

  @override
  String get accountEmailRequired => '请填写邮箱';

  @override
  String get accountPasswordRequired => '请填写密码';

  @override
  String get accountWaitingForBrowser => '等待浏览器完成验证…';

  @override
  String get accountCancelWaiting => '取消等待';

  @override
  String get accountSignInCancelled => '已取消登录';

  @override
  String get accountSignInTimeout => '等待验证超时，请重试';

  @override
  String get accountBrowserFailed => '打不开浏览器';

  @override
  String get accountBadCredentials => '邮箱或密码不正确';

  @override
  String get accountRateLimited => '尝试次数过多，请稍后再试';

  @override
  String accountNetworkFailed(String detail) {
    return '网络错误：$detail';
  }

  @override
  String accountSignedInAs(String nickname) {
    return '已登录为 $nickname';
  }

  @override
  String get accountSignedOut => '已退出登录';

  @override
  String get accountSignOut => '退出登录';

  @override
  String accountUid(String id) {
    return 'UID $id';
  }

  @override
  String get proxyUnsupportedPlatform => '当前平台无法自动检测系统代理，将直连';

  @override
  String proxyPacScript(String detail) {
    return '检测到 PAC 自动配置脚本（$detail），暂不支持，将直连';
  }

  @override
  String get proxyDisabled => '系统未启用代理，将直连';

  @override
  String get proxyNoServer => '系统未设置代理地址，将直连';

  @override
  String proxyUnparsable(String detail) {
    return '无法识别系统代理地址：$detail';
  }
}
