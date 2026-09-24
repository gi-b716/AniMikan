import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:animikan/config.dart';
import 'package:animikan/models/user.dart';
import 'package:animikan/services/bangumi.dart';
import 'package:animikan/settings/app.dart';
import 'package:animikan/utils/validation.dart';

enum LoginFailure {
  cancelled,
  timeout,
  browser,
  unsupported,
  credentials,
  rateLimited,
  network,
}

class LoginException implements Exception {
  const LoginException(this.failure, {this.detail});

  final LoginFailure failure;

  final String? detail;

  @override
  String toString() =>
      'LoginException(${failure.name}${detail == null ? '' : ': $detail'})';
}

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
  });

  factory AuthUser.fromSlimUser(SlimUser user) => AuthUser(
    id: user.id,
    username: user.username,
    nickname: user.nickname,
    avatar: user.avatar,
  );

  factory AuthUser.fromProfile(Profile profile) => AuthUser(
    id: profile.id,
    username: profile.username,
    nickname: profile.nickname,
    avatar: profile.avatar,
  );

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: rInt(json, 'id'),
    username: rStr(json, 'username'),
    nickname: rStr(json, 'nickname'),
    avatar: Avatar.fromJson(oMap(json, 'avatar') ?? const {}),
  );

  final int id;
  final String username;
  final String nickname;
  final Avatar avatar;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'nickname': nickname,
    'avatar': {
      'small': avatar.small,
      'medium': avatar.medium,
      'large': avatar.large,
    },
  };

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.username == username &&
      other.nickname == nickname &&
      other.avatar == avatar;

  @override
  int get hashCode => Object.hash(id, username, nickname, avatar);
}

@immutable
class AuthState {
  const AuthState({this.session, this.user});

  factory AuthState.fromJson(Map<String, dynamic> json) {
    final session = oStr(json, 'session');
    return AuthState(session: session, user: _user(json['user']));
  }

  final String? session;
  final AuthUser? user;

  bool get isLoggedIn => session != null && session!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'v': 1,
    if (session != null) 'session': session,
    if (user != null) 'user': user!.toJson(),
  };

  static AuthUser? _user(Object? json) {
    if (json is! Map) return null;
    try {
      return AuthUser.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AuthState && other.session == session && other.user == user;

  @override
  int get hashCode => Object.hash(session, user);
}

class BangumiAuth extends ValueNotifier<AuthState> {
  BangumiAuth._() : super(const AuthState());

  static final BangumiAuth instance = BangumiAuth._();

  static const _key = 'auth';

  static const _turnstileTimeout = Duration(minutes: 3);

  SharedPreferencesAsync? _prefs;

  SharedPreferencesAsync get _storage => _prefs ??= SharedPreferencesAsync();

  StreamSubscription<Uri>? _links;

  Completer<String>? _pendingTurnstile;

  Future<void> load() async {
    BangumiClient.instance.addInterceptor(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final session = value.session;
          if (session != null &&
              session.isNotEmpty &&
              options.path != BangumiClient.loginPath) {
            options.headers['Cookie'] =
                '${BangumiClient.sessionCookie}=$session';
          }
          handler.next(options);
        },
      ),
    );

    final appLinks = AppLinks();
    _links = appLinks.uriLinkStream.listen(_onLink);

    final launched = await appLinks.getInitialLink();
    if (launched != null) _onLink(launched);

    var state = const AuthState();
    try {
      final raw = await _storage.getString(_key);
      if (raw != null) {
        state = AuthState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // pass — an unreadable blob only means signing in again
    }
    value = state;

    unawaited(refresh());
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final token = await _solveTurnstile();
    try {
      final result = await BangumiClient.instance.login(
        email: email,
        password: password,
        turnstileToken: token,
      );
      await _set(result.session, AuthUser.fromSlimUser(result.user));
    } on BangumiException catch (e) {
      throw LoginException(_failureFor(e), detail: e.message);
    }
    return value.user!;
  }

  void cancelLogin() {
    final pending = _pendingTurnstile;
    _pendingTurnstile = null;
    if (pending != null && !pending.isCompleted) pending.complete('');
  }

  Future<void> logout() async {
    final session = value.session;
    if (session == null) return;
    value = const AuthState();
    await _save(value);
    await BangumiClient.instance.logout(session);
  }

  Future<void> refresh() async {
    final session = value.session;
    if (session == null) return;
    try {
      final profile = await BangumiClient.instance.getMe();
      if (value.session != session) return;
      await _set(session, AuthUser.fromProfile(profile));
    } on BangumiException catch (e) {
      if (e.statusCode == 401 && value.session == session) {
        value = const AuthState();
        await _save(value);
      }
    }
  }

  @override
  void dispose() {
    _links?.cancel();
    super.dispose();
  }

  Future<String> _solveTurnstile() async {
    if (kIsWeb) throw const LoginException(LoginFailure.unsupported);

    final pending = _pendingTurnstile = Completer<String>();
    try {
      final bool opened;
      try {
        opened = await launchUrl(
          BangumiConst.turnstilePage(
            theme: _themeParam(AppSettingsStore.instance.value.themeMode),
          ),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        throw LoginException(LoginFailure.browser, detail: '$e');
      }
      if (!opened) throw const LoginException(LoginFailure.browser);

      final token = await pending.future.timeout(_turnstileTimeout);
      if (token.isEmpty) throw const LoginException(LoginFailure.cancelled);
      return token;
    } on TimeoutException {
      throw const LoginException(LoginFailure.timeout);
    } finally {
      if (identical(_pendingTurnstile, pending)) _pendingTurnstile = null;
    }
  }

  void _onLink(Uri uri) {
    if (!BangumiConst.isTurnstileCallback(uri)) return;

    final token = uri.queryParameters['token'];
    final pending = _pendingTurnstile;
    _pendingTurnstile = null;
    if (pending == null || pending.isCompleted) return;
    if (token == null || token.isEmpty) return;
    pending.complete(token);
  }

  Future<void> _set(String session, AuthUser user) async {
    value = AuthState(session: session, user: user);
    await _save(value);
  }

  Future<void> _save(AuthState state) async {
    try {
      await _storage.setString(_key, jsonEncode(state.toJson()));
    } catch (_) {
      // pass — a failed write must not undo what is already in effect
    }
  }

  static LoginFailure _failureFor(BangumiException e) => switch (e.statusCode) {
    401 => LoginFailure.credentials,
    429 => LoginFailure.rateLimited,
    _ => LoginFailure.network,
  };

  static String _themeParam(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'auto',
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
  };
}
