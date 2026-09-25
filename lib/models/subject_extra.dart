import 'package:animikan/models/subject.dart';
import 'package:animikan/utils/validation.dart';

class Paged<T> {
  final List<T> data;
  final int total;

  const Paged({required this.data, required this.total});

  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) item,
  ) => Paged(
    data:
        oList(json, 'data', (e) => item(e as Map<String, dynamic>)) ??
        const [],
    total: rInt(json, 'total'),
  );
}

class PersonImages {
  final String large;
  final String medium;
  final String small;
  final String grid;

  const PersonImages({
    required this.large,
    required this.medium,
    required this.small,
    required this.grid,
  });

  factory PersonImages.fromJson(Map<String, dynamic> json) => PersonImages(
    large: rStr(json, 'large'),
    medium: rStr(json, 'medium'),
    small: rStr(json, 'small'),
    grid: rStr(json, 'grid'),
  );

  String get best => medium.isNotEmpty
      ? medium
      : small.isNotEmpty
      ? small
      : grid.isNotEmpty
      ? grid
      : large;
}

class Episode {
  final int id;
  final int subjectId;
  final double sort;
  final int type;
  final int disc;
  final String name;
  final String nameCn;
  final String duration;
  final String airdate;
  final int comment;
  final String desc;

  const Episode({
    required this.id,
    required this.subjectId,
    required this.sort,
    required this.type,
    required this.disc,
    required this.name,
    required this.nameCn,
    required this.duration,
    required this.airdate,
    required this.comment,
    required this.desc,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    id: rInt(json, 'id'),
    subjectId: rInt(json, 'subjectID'),
    sort: rDouble(json, 'sort'),
    type: rInt(json, 'type'),
    disc: rInt(json, 'disc'),
    name: rStr(json, 'name'),
    nameCn: rStr(json, 'nameCN'),
    duration: rStr(json, 'duration'),
    airdate: rStr(json, 'airdate'),
    comment: rInt(json, 'comment'),
    desc: rStr(json, 'desc'),
  );

  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  String get sortLabel {
    if (sort == sort.roundToDouble()) {
      return sort.toInt().toString().padLeft(2, '0');
    }
    return sort.toString();
  }
}

class SlimPerson {
  final int id;
  final String name;
  final String nameCn;
  final int type;
  final String info;
  final List<String> career;
  final PersonImages? images;
  final int comment;
  final bool lock;
  final bool nsfw;

  const SlimPerson({
    required this.id,
    required this.name,
    required this.nameCn,
    required this.type,
    required this.info,
    required this.career,
    this.images,
    required this.comment,
    required this.lock,
    required this.nsfw,
  });

  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  factory SlimPerson.fromJson(Map<String, dynamic> json) {
    final imgs = oMap(json, 'images');
    return SlimPerson(
      id: rInt(json, 'id'),
      name: rStr(json, 'name'),
      nameCn: rStr(json, 'nameCN'),
      type: rInt(json, 'type'),
      info: rStr(json, 'info'),
      career: oList(json, 'career', (e) => e as String) ?? const [],
      images: imgs != null ? PersonImages.fromJson(imgs) : null,
      comment: rInt(json, 'comment'),
      lock: rBool(json, 'lock'),
      nsfw: rBool(json, 'nsfw'),
    );
  }
}

class SlimCharacter {
  final int id;
  final String name;
  final String nameCn;
  final int role;
  final String info;
  final PersonImages? images;
  final int comment;
  final bool lock;
  final bool nsfw;

  const SlimCharacter({
    required this.id,
    required this.name,
    required this.nameCn,
    required this.role,
    required this.info,
    this.images,
    required this.comment,
    required this.lock,
    required this.nsfw,
  });

  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  factory SlimCharacter.fromJson(Map<String, dynamic> json) {
    final imgs = oMap(json, 'images');
    return SlimCharacter(
      id: rInt(json, 'id'),
      name: rStr(json, 'name'),
      nameCn: rStr(json, 'nameCN'),
      role: rInt(json, 'role'),
      info: rStr(json, 'info'),
      images: imgs != null ? PersonImages.fromJson(imgs) : null,
      comment: rInt(json, 'comment'),
      lock: rBool(json, 'lock'),
      nsfw: rBool(json, 'nsfw'),
    );
  }
}

class CharacterCast {
  final SlimPerson person;
  final int relation;
  final String summary;

  const CharacterCast({
    required this.person,
    required this.relation,
    required this.summary,
  });

  factory CharacterCast.fromJson(Map<String, dynamic> json) {
    final rel = json['relation'];
    return CharacterCast(
      person: SlimPerson.fromJson(rMap(json, 'person')),
      relation: rel is Map<String, dynamic>
          ? ((rel['id'] as num?)?.toInt() ?? 0)
          : ((rel as num?)?.toInt() ?? 0),
      summary: oStr(json, 'summary') ?? '',
    );
  }
}

class SubjectCharacter {
  final SlimCharacter character;
  final List<CharacterCast> casts;
  final int type;
  final int order;

  const SubjectCharacter({
    required this.character,
    required this.casts,
    required this.type,
    required this.order,
  });

  factory SubjectCharacter.fromJson(Map<String, dynamic> json) =>
      SubjectCharacter(
        character: SlimCharacter.fromJson(rMap(json, 'character')),
        casts:
            oList(
              json,
              'casts',
              (e) => CharacterCast.fromJson(e as Map<String, dynamic>),
            ) ??
            const [],
        type: oInt(json, 'type') ?? 0,
        order: oInt(json, 'order') ?? 0,
      );

  String? get castName => casts.isEmpty ? null : casts.first.person.displayName;
}

class SubjectRelationType {
  final int id;
  final String en;
  final String cn;
  final String jp;
  final String desc;

  const SubjectRelationType({
    required this.id,
    required this.en,
    required this.cn,
    required this.jp,
    required this.desc,
  });

  factory SubjectRelationType.fromJson(Map<String, dynamic> json) =>
      SubjectRelationType(
        id: rInt(json, 'id'),
        en: oStr(json, 'en') ?? '',
        cn: oStr(json, 'cn') ?? '',
        jp: oStr(json, 'jp') ?? '',
        desc: oStr(json, 'desc') ?? '',
      );

  String get label => cn.isNotEmpty
      ? cn
      : jp.isNotEmpty
      ? jp
      : en;
}

class SubjectRelation {
  final SlimSubject subject;
  final SubjectRelationType relation;
  final int order;

  const SubjectRelation({
    required this.subject,
    required this.relation,
    required this.order,
  });

  factory SubjectRelation.fromJson(Map<String, dynamic> json) =>
      SubjectRelation(
        subject: SlimSubject.fromJson(rMap(json, 'subject')),
        relation: SubjectRelationType.fromJson(rMap(json, 'relation')),
        order: oInt(json, 'order') ?? 0,
      );
}


