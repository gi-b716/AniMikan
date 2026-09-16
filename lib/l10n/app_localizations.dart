import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @tabCalendar.
  ///
  /// In zh, this message translates to:
  /// **'日历'**
  String get tabCalendar;

  /// No description provided for @tabFavourites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get tabFavourites;

  /// No description provided for @tabCache.
  ///
  /// In zh, this message translates to:
  /// **'缓存'**
  String get tabCache;

  /// No description provided for @tabTest.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get tabTest;

  /// No description provided for @tabSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get tabSettings;

  /// No description provided for @calendarTitleWeek.
  ///
  /// In zh, this message translates to:
  /// **'{year}年第{week}周放送时间表'**
  String calendarTitleWeek(int year, int week);

  /// No description provided for @calendarTitleWeekLoading.
  ///
  /// In zh, this message translates to:
  /// **'{year}年第{week}周放送时间表 [加载中]'**
  String calendarTitleWeekLoading(int year, int week);

  /// No description provided for @calendarTitleWeekFetched.
  ///
  /// In zh, this message translates to:
  /// **'{year}年第{week}周放送时间表 · {weekday}获取'**
  String calendarTitleWeekFetched(int year, int week, String weekday);

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @nSubjects.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, other{{count} 部}}'**
  String nSubjects(num count);

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无'**
  String get noData;

  /// No description provided for @jumpToDay.
  ///
  /// In zh, this message translates to:
  /// **'跳转到{day}'**
  String jumpToDay(String day);

  /// No description provided for @collectionWish.
  ///
  /// In zh, this message translates to:
  /// **'想看'**
  String get collectionWish;

  /// No description provided for @collectionCollect.
  ///
  /// In zh, this message translates to:
  /// **'看过'**
  String get collectionCollect;

  /// No description provided for @collectionDoing.
  ///
  /// In zh, this message translates to:
  /// **'在看'**
  String get collectionDoing;

  /// No description provided for @collectionOnHold.
  ///
  /// In zh, this message translates to:
  /// **'搁置'**
  String get collectionOnHold;

  /// No description provided for @collectionDropped.
  ///
  /// In zh, this message translates to:
  /// **'抛弃'**
  String get collectionDropped;

  /// No description provided for @collectionUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get collectionUnknown;

  /// No description provided for @subjectBook.
  ///
  /// In zh, this message translates to:
  /// **'书籍'**
  String get subjectBook;

  /// No description provided for @subjectAnime.
  ///
  /// In zh, this message translates to:
  /// **'动画'**
  String get subjectAnime;

  /// No description provided for @subjectMusic.
  ///
  /// In zh, this message translates to:
  /// **'音乐'**
  String get subjectMusic;

  /// No description provided for @subjectGame.
  ///
  /// In zh, this message translates to:
  /// **'游戏'**
  String get subjectGame;

  /// No description provided for @subjectReal.
  ///
  /// In zh, this message translates to:
  /// **'三次元'**
  String get subjectReal;

  /// No description provided for @subjectUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get subjectUnknown;

  /// No description provided for @subjectDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'番剧详情'**
  String get subjectDetailTitle;

  /// No description provided for @subjectId.
  ///
  /// In zh, this message translates to:
  /// **'Subject ID: {id}'**
  String subjectId(String id);

  /// No description provided for @invalidId.
  ///
  /// In zh, this message translates to:
  /// **'无效'**
  String get invalidId;

  /// No description provided for @score.
  ///
  /// In zh, this message translates to:
  /// **'{score} 分'**
  String score(String score);

  /// No description provided for @detailDemoNote.
  ///
  /// In zh, this message translates to:
  /// **'这是一个由根 Navigator 承载的通用详情页：任何列表卡片都可以通过 context.push(AppRoute.subject(id), extra: subject) 打开它。'**
  String get detailDemoNote;

  /// No description provided for @nRatings.
  ///
  /// In zh, this message translates to:
  /// **'{count}人'**
  String nRatings(String count);

  /// No description provided for @testPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'GoRouter 导航示例'**
  String get testPageTitle;

  /// No description provided for @testPageBody.
  ///
  /// In zh, this message translates to:
  /// **'点击任意卡片会 push 同一个详情页；切换底部标签后再回来，测试页和各标签的状态会保留。'**
  String get testPageBody;

  /// No description provided for @openDetailPage.
  ///
  /// In zh, this message translates to:
  /// **'打开详情页'**
  String get openDetailPage;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get sectionAppearance;

  /// No description provided for @sectionNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get sectionNetwork;

  /// No description provided for @themeModeTitle.
  ///
  /// In zh, this message translates to:
  /// **'深浅色'**
  String get themeModeTitle;

  /// No description provided for @systemDefault.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get systemDefault;

  /// No description provided for @themeModeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeModeDark;

  /// No description provided for @languageTitle.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageTitle;

  /// No description provided for @languageZh.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get languageZh;

  /// No description provided for @languageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @proxyTitle.
  ///
  /// In zh, this message translates to:
  /// **'代理设置'**
  String get proxyTitle;

  /// No description provided for @proxyModeDirect.
  ///
  /// In zh, this message translates to:
  /// **'禁用'**
  String get proxyModeDirect;

  /// No description provided for @proxyModeSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统代理'**
  String get proxyModeSystem;

  /// No description provided for @proxyModeCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get proxyModeCustom;

  /// No description provided for @proxyFollowingSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统设置'**
  String get proxyFollowingSystem;

  /// No description provided for @proxyNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get proxyNotSet;

  /// No description provided for @proxyDetecting.
  ///
  /// In zh, this message translates to:
  /// **'检测中…'**
  String get proxyDetecting;

  /// No description provided for @proxyNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未检测到系统代理'**
  String get proxyNotFound;

  /// No description provided for @proxyDetected.
  ///
  /// In zh, this message translates to:
  /// **'自动检测结果'**
  String get proxyDetected;

  /// No description provided for @proxyRedetect.
  ///
  /// In zh, this message translates to:
  /// **'重新检测'**
  String get proxyRedetect;

  /// No description provided for @proxyApplied.
  ///
  /// In zh, this message translates to:
  /// **'已应用 {proxy}'**
  String proxyApplied(String proxy);

  /// No description provided for @hostLabel.
  ///
  /// In zh, this message translates to:
  /// **'主机'**
  String get hostLabel;

  /// No description provided for @portLabel.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get portLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In zh, this message translates to:
  /// **'用户名（可选）'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码（可选）'**
  String get passwordLabel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @portMustBeNumber.
  ///
  /// In zh, this message translates to:
  /// **'端口要填数字'**
  String get portMustBeNumber;

  /// No description provided for @hostInvalid.
  ///
  /// In zh, this message translates to:
  /// **'主机不能为空，也不能带端口'**
  String get hostInvalid;

  /// No description provided for @portInvalid.
  ///
  /// In zh, this message translates to:
  /// **'端口要在 1 到 65535 之间'**
  String get portInvalid;

  /// No description provided for @usernameInvalid.
  ///
  /// In zh, this message translates to:
  /// **'用户名不能为空，也不能含 “:” 或 “@”'**
  String get usernameInvalid;

  /// No description provided for @passwordInvalid.
  ///
  /// In zh, this message translates to:
  /// **'密码不能含 “;”，也不能以空格开头或结尾'**
  String get passwordInvalid;

  /// No description provided for @sectionDebug.
  ///
  /// In zh, this message translates to:
  /// **'调试'**
  String get sectionDebug;

  /// No description provided for @debugClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除所有数据'**
  String get debugClearTitle;

  /// No description provided for @debugClearSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'清除设置并重启应用'**
  String get debugClearSubtitle;

  /// No description provided for @debugClearAction.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get debugClearAction;

  /// No description provided for @debugClearConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除所有数据？'**
  String get debugClearConfirmTitle;

  /// No description provided for @debugClearConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'所有设置会被删除，应用随后重启。此操作无法撤销。'**
  String get debugClearConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @proxyUnsupportedPlatform.
  ///
  /// In zh, this message translates to:
  /// **'当前平台无法自动检测系统代理，将直连'**
  String get proxyUnsupportedPlatform;

  /// No description provided for @proxyPacScript.
  ///
  /// In zh, this message translates to:
  /// **'检测到 PAC 自动配置脚本（{detail}），暂不支持，将直连'**
  String proxyPacScript(String detail);

  /// No description provided for @proxyDisabled.
  ///
  /// In zh, this message translates to:
  /// **'系统未启用代理，将直连'**
  String get proxyDisabled;

  /// No description provided for @proxyNoServer.
  ///
  /// In zh, this message translates to:
  /// **'系统未设置代理地址，将直连'**
  String get proxyNoServer;

  /// No description provided for @proxyUnparsable.
  ///
  /// In zh, this message translates to:
  /// **'无法识别系统代理地址：{detail}'**
  String proxyUnparsable(String detail);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
