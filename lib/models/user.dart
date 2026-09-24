import 'package:animikan/utils/validation.dart';

class Avatar {
  final String small;
  final String medium;
  final String large;

  const Avatar({
    required this.small,
    required this.medium,
    required this.large,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
    small: rStr(json, 'small'),
    medium: rStr(json, 'medium'),
    large: rStr(json, 'large'),
  );

  String get url {
    if (medium.isNotEmpty) return medium;
    if (large.isNotEmpty) return large;
    return small;
  }

  @override
  bool operator ==(Object other) =>
      other is Avatar &&
      other.small == small &&
      other.medium == medium &&
      other.large == large;

  @override
  int get hashCode => Object.hash(small, medium, large);
}

class SlimUser {
  final int id;
  final String username;
  final String nickname;
  final Avatar avatar;
  final int group;
  final String sign;
  final DateTime joinedAt;
  final bool isFriend;

  const SlimUser({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.group,
    required this.sign,
    required this.joinedAt,
    required this.isFriend,
  });

  factory SlimUser.fromJson(Map<String, dynamic> json) => SlimUser(
    id: rInt(json, 'id'),
    username: rStr(json, 'username'),
    nickname: rStr(json, 'nickname'),
    avatar: Avatar.fromJson(rMap(json, 'avatar')),
    group: rInt(json, 'group'),
    sign: rStr(json, 'sign'),
    joinedAt: DateTime.fromMillisecondsSinceEpoch(
      rInt(json, 'joinedAt') * 1000,
    ),
    isFriend: rBool(json, 'isFriend'),
  );
}

class Permissions {
  final bool subjectWikiEdit;

  const Permissions({required this.subjectWikiEdit});

  factory Permissions.fromJson(Map<String, dynamic> json) =>
      Permissions(subjectWikiEdit: rBool(json, 'subjectWikiEdit'));
}

/// `GET /p1/me`
class Profile {
  final int id;
  final String username;
  final String nickname;
  final Avatar avatar;
  final String sign;
  final int group;
  final DateTime joinedAt;
  final String site;
  final String location;
  final Permissions permissions;

  const Profile({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.sign,
    required this.group,
    required this.joinedAt,
    required this.site,
    required this.location,
    required this.permissions,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: rInt(json, 'id'),
    username: rStr(json, 'username'),
    nickname: rStr(json, 'nickname'),
    avatar: Avatar.fromJson(rMap(json, 'avatar')),
    sign: rStr(json, 'sign'),
    group: rInt(json, 'group'),
    joinedAt: DateTime.fromMillisecondsSinceEpoch(
      rInt(json, 'joinedAt') * 1000,
    ),
    site: rStr(json, 'site'),
    location: rStr(json, 'location'),
    permissions: Permissions.fromJson(rMap(json, 'permissions')),
  );
}
