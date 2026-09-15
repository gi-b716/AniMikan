// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabFavourites => 'Favourites';

  @override
  String get tabCache => 'Downloads';

  @override
  String get tabTest => 'Test';

  @override
  String get tabSettings => 'Settings';

  @override
  String calendarTitleWeek(int year, int week) {
    return 'Airing schedule · week $week of $year';
  }

  @override
  String calendarTitleWeekLoading(int year, int week) {
    return 'Airing schedule · week $week of $year [loading]';
  }

  @override
  String calendarTitleWeekFetched(int year, int week, String weekday) {
    return 'Airing schedule · week $week of $year · fetched $weekday';
  }

  @override
  String get loadFailed => 'Couldn\'t load';

  @override
  String get retry => 'Retry';

  @override
  String get today => 'Today';

  @override
  String nSubjects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '$count title',
    );
    return '$_temp0';
  }

  @override
  String get noData => 'Nothing yet';

  @override
  String jumpToDay(String day) {
    return 'Jump to $day';
  }

  @override
  String get collectionWish => 'Wish';

  @override
  String get collectionCollect => 'Watched';

  @override
  String get collectionDoing => 'Watching';

  @override
  String get collectionOnHold => 'On hold';

  @override
  String get collectionDropped => 'Dropped';

  @override
  String get collectionUnknown => 'Unknown';

  @override
  String get subjectBook => 'Book';

  @override
  String get subjectAnime => 'Anime';

  @override
  String get subjectMusic => 'Music';

  @override
  String get subjectGame => 'Game';

  @override
  String get subjectReal => 'Live action';

  @override
  String get subjectUnknown => 'Unknown';

  @override
  String get subjectDetailTitle => 'Subject';

  @override
  String subjectId(String id) {
    return 'Subject ID: $id';
  }

  @override
  String get invalidId => 'invalid';

  @override
  String score(String score) {
    return '$score pts';
  }

  @override
  String get detailDemoNote =>
      'A generic detail page hosted by the root navigator: any list card can open it with context.push(AppRoute.subject(id), extra: subject).';

  @override
  String nRatings(String count) {
    return '$count rated';
  }

  @override
  String get testPageTitle => 'GoRouter navigation demo';

  @override
  String get testPageBody =>
      'Tapping any card pushes the same detail page. Switch tabs and come back: this page and every tab keep their state.';

  @override
  String get openDetailPage => 'Open the detail page';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionNetwork => 'Network';

  @override
  String get themeModeTitle => 'Theme';

  @override
  String get systemDefault => 'System default';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String get proxyTitle => 'Proxy';

  @override
  String get proxyModeDirect => 'Off';

  @override
  String get proxyModeSystem => 'System proxy';

  @override
  String get proxyModeCustom => 'Custom';

  @override
  String get proxyFollowingSystem => 'Follows the system';

  @override
  String get proxyNotSet => 'Not set';

  @override
  String get proxyDetecting => 'Checking…';

  @override
  String get proxyNotFound => 'No system proxy found';

  @override
  String get proxyDetected => 'Detected';

  @override
  String get proxyRedetect => 'Check again';

  @override
  String proxyApplied(String proxy) {
    return 'Applied $proxy';
  }

  @override
  String get hostLabel => 'Host';

  @override
  String get portLabel => 'Port';

  @override
  String get usernameLabel => 'Username (optional)';

  @override
  String get passwordLabel => 'Password (optional)';

  @override
  String get save => 'Save';

  @override
  String get portMustBeNumber => 'Port must be a number';

  @override
  String get hostInvalid => 'Host must not be empty or carry a port';

  @override
  String get portInvalid => 'Port must be between 1 and 65535';

  @override
  String get usernameInvalid =>
      'Username must not be empty or contain “:” or “@”';

  @override
  String get passwordInvalid =>
      'Password must not contain “;” or start or end with a space';

  @override
  String get proxyUnsupportedPlatform =>
      'This platform can\'t report a system proxy; going direct';

  @override
  String proxyPacScript(String detail) {
    return 'PAC script configured ($detail) — not supported, going direct';
  }

  @override
  String get proxyDisabled => 'No proxy enabled in the system; going direct';

  @override
  String get proxyNoServer =>
      'No proxy address set in the system; going direct';

  @override
  String proxyUnparsable(String detail) {
    return 'Can\'t read the system proxy address: $detail';
  }
}
