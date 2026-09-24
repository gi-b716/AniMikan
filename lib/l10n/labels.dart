import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/models/subject.dart';
import 'package:animikan/services/auth.dart';
import 'package:animikan/settings/app.dart';
import 'package:animikan/settings/proxy.dart';
import 'package:flutter/material.dart'
    show Locale, ThemeMode, WidgetsBinding, basicLocaleListResolution;

/// Where the enums of the data and settings layers meet the ARB strings.
///
/// The labels stay out of the models: a model has no build context, and the
/// text has to change when the language does.
extension CollectionTypeLabel on CollectionType {
  String label(AppLocalizations l) => switch (this) {
    CollectionType.wish => l.collectionWish,
    CollectionType.collect => l.collectionCollect,
    CollectionType.doing => l.collectionDoing,
    CollectionType.onHold => l.collectionOnHold,
    CollectionType.dropped => l.collectionDropped,
    CollectionType.unknown => l.collectionUnknown,
  };
}

extension SubjectTypeLabel on SubjectType {
  String label(AppLocalizations l) => switch (this) {
    SubjectType.book => l.subjectBook,
    SubjectType.anime => l.subjectAnime,
    SubjectType.music => l.subjectMusic,
    SubjectType.game => l.subjectGame,
    SubjectType.real => l.subjectReal,
    SubjectType.unknown => l.subjectUnknown,
  };
}

extension ProxyModeLabel on ProxyMode {
  String label(AppLocalizations l) => switch (this) {
    ProxyMode.direct => l.proxyModeDirect,
    ProxyMode.system => l.proxyModeSystem,
    ProxyMode.custom => l.proxyModeCustom,
  };
}

extension ThemeModeLabel on ThemeMode {
  String label(AppLocalizations l) => switch (this) {
    ThemeMode.system => l.systemDefault,
    ThemeMode.light => l.themeModeLight,
    ThemeMode.dark => l.themeModeDark,
  };
}

extension LanguageLabel on Language {
  String label(AppLocalizations l) => switch (this) {
    Language.system => lookupAppLocalizations(_detectedLocale()).systemDefault,
    Language.zh => l.languageZh,
    Language.en => l.languageEn,
  };
}

Locale _detectedLocale() => basicLocaleListResolution(
  WidgetsBinding.instance.platformDispatcher.locales,
  AppLocalizations.supportedLocales,
);

String loginFailureText(AppLocalizations l, LoginException error) =>
    switch (error.failure) {
      LoginFailure.cancelled => l.accountSignInCancelled,
      LoginFailure.timeout => l.accountSignInTimeout,
      LoginFailure.browser => l.accountBrowserFailed,
      LoginFailure.unsupported => l.accountUnsupportedPlatform,
      LoginFailure.credentials => l.accountBadCredentials,
      LoginFailure.rateLimited => l.accountRateLimited,
      LoginFailure.network => l.accountNetworkFailed(error.detail ?? ''),
    };

/// The sentence behind a [SystemProxyReason]; [detail] names the PAC URL or the
/// address that could not be read.
String systemProxyReasonText(
  AppLocalizations l,
  SystemProxyReason reason,
  String? detail,
) => switch (reason) {
  SystemProxyReason.unsupportedPlatform => l.proxyUnsupportedPlatform,
  SystemProxyReason.pacScript => l.proxyPacScript(detail ?? ''),
  SystemProxyReason.disabled => l.proxyDisabled,
  SystemProxyReason.noServer => l.proxyNoServer,
  SystemProxyReason.unparsable => l.proxyUnparsable(detail ?? ''),
};
