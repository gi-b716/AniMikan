import 'dart:async';
import 'dart:convert';

import 'package:animikan/settings/proxy.dart';
import 'package:animikan/utils/network/network.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProxyMode { direct, system, custom }

/// Which language the UI speaks; [system] follows the platform.
enum Language {
  system(null),
  zh(Locale('zh')),
  en(Locale('en'));

  const Language(this.locale);

  /// What to hand `MaterialApp.locale`, or null to follow the system.
  final Locale? locale;
}

/// Persisted as a single JSON blob; the `v` in [toJson] is its schema version.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.proxyMode = ProxyMode.system,
    this.customProxy,
    this.language = Language.system,
  });

  /// Anything unreadable falls back to the default rather than failing the load.
  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: _oneOf(ThemeMode.values, json['themeMode'], ThemeMode.system),
    proxyMode: _oneOf(ProxyMode.values, json['proxyMode'], ProxyMode.system),
    customProxy: _proxy(json['customProxy']),
    language: _oneOf(Language.values, json['language'], Language.system),
  );

  final ThemeMode themeMode;
  final ProxyMode proxyMode;

  /// Used by [ProxyMode.custom]; the other modes ignore it.
  final ProxyConfig? customProxy;

  final Language language;

  AppSettings copyWith({
    ThemeMode? themeMode,
    ProxyMode? proxyMode,
    ProxyConfig? customProxy,
    Language? language,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    proxyMode: proxyMode ?? this.proxyMode,
    customProxy: customProxy ?? this.customProxy,
    language: language ?? this.language,
  );

  Map<String, dynamic> toJson() => {
    'v': 1,
    'themeMode': themeMode.name,
    'proxyMode': proxyMode.name,
    'language': language.name,
    if (customProxy != null) 'customProxy': customProxy!.toJson(),
  };

  static T _oneOf<T extends Enum>(List<T> values, Object? name, T fallback) =>
      values.firstWhere((v) => v.name == name, orElse: () => fallback);

  static ProxyConfig? _proxy(Object? json) {
    if (json is! Map) return null;
    try {
      return ProxyConfig.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.proxyMode == proxyMode &&
      other.customProxy == customProxy &&
      other.language == language;

  @override
  int get hashCode => Object.hash(themeMode, proxyMode, customProxy, language);
}

/// Reads once at startup, then applies and persists on every change.
class AppSettingsStore extends ValueNotifier<AppSettings> {
  AppSettingsStore._() : super(const AppSettings());

  static final AppSettingsStore instance = AppSettingsStore._();

  static const _key = 'settings';

  /// Lazily created: a missing platform implementation should fail the
  /// read/write, not the app.
  SharedPreferencesAsync? _prefs;
  SharedPreferencesAsync get _storage => _prefs ??= SharedPreferencesAsync();

  SystemProxyResult? _systemProxy;

  SystemProxyResult? get systemProxy => _systemProxy;

  /// Call before the first request — see main().
  Future<void> load() async {
    // Flutter's image client exists only once; take it over before it is built.
    Network.prepare();

    var settings = const AppSettings();
    try {
      final raw = await _storage.getString(_key);
      if (raw != null) {
        settings = AppSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // pass
    }
    value = settings;
    await _apply(value);
  }

  Future<void> clearAll() async {
    try {
      await _storage.clear();
    } catch (_) {
      // pass
    }
    value = const AppSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(value.copyWith(themeMode: mode));

  Future<void> setLanguage(Language language) =>
      _update(value.copyWith(language: language));

  Future<void> setProxyMode(ProxyMode mode) =>
      _update(value.copyWith(proxyMode: mode));

  Future<void> setCustomProxy(ProxyConfig proxy) =>
      _update(value.copyWith(proxyMode: ProxyMode.custom, customProxy: proxy));

  /// Re-detect, for a proxy client that changed ports while the app was running.
  Future<SystemProxyResult> redetectSystemProxy() async {
    final result = await _detect(force: true);
    if (value.proxyMode == ProxyMode.system) {
      Network.configure(result.config);
    }
    return result;
  }

  Future<void> _update(AppSettings next) async {
    if (next == value) return;
    value = next;
    unawaited(_save(next));
    await _apply(next);
  }

  Future<void> _save(AppSettings settings) async {
    try {
      await _storage.setString(_key, jsonEncode(settings.toJson()));
    } catch (_) {
      // pass — a failed write must not undo what is already in effect
    }
  }

  Future<void> _apply(AppSettings settings) async {
    switch (settings.proxyMode) {
      case ProxyMode.direct:
        Network.configure(null);
      case ProxyMode.custom:
        Network.configure(settings.customProxy);
      case ProxyMode.system:
        final requested = settings;
        // Detection is async: drop the result if the user picked something else.
        final result = await _detect();
        if (!identical(value, requested)) return;
        Network.configure(result.config);
    }
  }

  /// Cached; [force] reads the OS again.
  Future<SystemProxyResult> _detect({bool force = false}) async {
    final cached = _systemProxy;
    if (!force && cached != null) return cached;
    return _systemProxy = await SystemProxy.detect();
  }
}
