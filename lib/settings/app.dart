import 'dart:async';
import 'dart:convert';

import 'package:animikan/settings/proxy.dart';
import 'package:animikan/utils/network/network.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProxyMode {
  direct('禁用'),
  system('系统代理'),
  custom('自定义');

  const ProxyMode(this.label);

  final String label;
}

extension ThemeModeLabel on ThemeMode {
  String get label => switch (this) {
    ThemeMode.system => '跟随系统',
    ThemeMode.light => '浅色',
    ThemeMode.dark => '深色',
  };
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.proxyMode = ProxyMode.direct,
    this.customProxy,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: _oneOf(ThemeMode.values, json['themeMode'], ThemeMode.system),
    proxyMode: _oneOf(ProxyMode.values, json['proxyMode'], ProxyMode.direct),
    customProxy: _proxy(json['customProxy']),
  );

  final ThemeMode themeMode;
  final ProxyMode proxyMode;

  final ProxyConfig? customProxy;

  AppSettings copyWith({
    ThemeMode? themeMode,
    ProxyMode? proxyMode,
    ProxyConfig? customProxy,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    proxyMode: proxyMode ?? this.proxyMode,
    customProxy: customProxy ?? this.customProxy,
  );

  Map<String, dynamic> toJson() => {
    'v': 1,
    'themeMode': themeMode.name,
    'proxyMode': proxyMode.name,
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
      other.customProxy == customProxy;

  @override
  int get hashCode => Object.hash(themeMode, proxyMode, customProxy);
}

class AppSettingsStore extends ValueNotifier<AppSettings> {
  AppSettingsStore._() : super(const AppSettings());

  static final AppSettingsStore instance = AppSettingsStore._();

  static const _key = 'settings';

  SharedPreferencesAsync? _prefs;
  SharedPreferencesAsync get _storage => _prefs ??= SharedPreferencesAsync();

  SystemProxyResult? _systemProxy;

  SystemProxyResult? get systemProxy => _systemProxy;

  Future<void> load() async {
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
    await _apply(settings);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(value.copyWith(themeMode: mode));

  Future<void> setProxyMode(ProxyMode mode) =>
      _update(value.copyWith(proxyMode: mode));

  Future<void> setCustomProxy(ProxyConfig proxy) =>
      _update(value.copyWith(proxyMode: ProxyMode.custom, customProxy: proxy));

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
      // pass
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
