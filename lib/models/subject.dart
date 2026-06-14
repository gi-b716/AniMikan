import '../utils/validation.dart';

enum CollectionType {
  wish(1),
  collect(2),
  doing(3),
  onHold(4),
  dropped(5),
  unknown(-1);

  const CollectionType(this.value);
  final int value;

  static CollectionType fromValue(int v) => CollectionType.values.firstWhere(
    (e) => e.value == v,
    orElse: () => CollectionType.unknown,
  );

  String get label => switch (this) {
    CollectionType.wish => '想看',
    CollectionType.collect => '看过',
    CollectionType.doing => '在看',
    CollectionType.onHold => '搁置',
    CollectionType.dropped => '抛弃',
    CollectionType.unknown => '未知',
  };
}

enum SubjectType {
  book(1),
  anime(2),
  music(3),
  game(4),
  real(6),
  unknown(-1);

  const SubjectType(this.value);
  final int value;

  static SubjectType fromValue(int v) => SubjectType.values.firstWhere(
    (e) => e.value == v,
    orElse: () => SubjectType.unknown,
  );

  String get label => switch (this) {
    SubjectType.book => '书籍',
    SubjectType.anime => '动画',
    SubjectType.music => '音乐',
    SubjectType.game => '游戏',
    SubjectType.real => '三次元',
    SubjectType.unknown => '未知',
  };
}

class SubjectImages {
  final String common;
  final String grid;
  final String large;
  final String medium;
  final String small;

  const SubjectImages({
    required this.common,
    required this.grid,
    required this.large,
    required this.medium,
    required this.small,
  });

  factory SubjectImages.fromJson(Map<String, dynamic> json) => SubjectImages(
    common: rStr(json, 'common'),
    grid: rStr(json, 'grid'),
    large: rStr(json, 'large'),
    medium: rStr(json, 'medium'),
    small: rStr(json, 'small'),
  );
}

class SlimSubjectInterest {
  final String comment;
  final int id;
  final int rate;
  final List<String> tags;
  final CollectionType type;
  final DateTime updatedAt;

  const SlimSubjectInterest({
    required this.comment,
    required this.id,
    required this.rate,
    required this.tags,
    required this.type,
    required this.updatedAt,
  });

  factory SlimSubjectInterest.fromJson(Map<String, dynamic> json) =>
      SlimSubjectInterest(
        comment: rStr(json, 'comment'),
        id: rInt(json, 'id'),
        rate: rInt(json, 'rate'),
        tags: oList(json, 'tags', (e) => e as String) ?? [],
        type: CollectionType.fromValue(rInt(json, 'type')),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          rInt(json, 'updatedAt') * 1000,
        ),
      );
}

class SubjectRating {
  final List<int> count;
  final int rank;
  final double score;
  final int total;

  const SubjectRating({
    required this.count,
    required this.rank,
    required this.score,
    required this.total,
  });

  factory SubjectRating.fromJson(Map<String, dynamic> json) => SubjectRating(
    count: oList(json, 'count', (e) => (e as num).toInt()) ?? [],
    rank: rInt(json, 'rank'),
    score: rDouble(json, 'score'),
    total: rInt(json, 'total'),
  );
}

class SlimSubject {
  final int id;
  final SubjectImages? images;
  final String info;
  final SlimSubjectInterest? interest;
  final bool locked;
  final String name;
  final String nameCn;
  final bool nsfw;
  final SubjectRating rating;
  final SubjectType type;

  const SlimSubject({
    required this.id,
    this.images,
    required this.info,
    this.interest,
    required this.locked,
    required this.name,
    required this.nameCn,
    required this.nsfw,
    required this.rating,
    required this.type,
  });

  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  factory SlimSubject.fromJson(Map<String, dynamic> json) {
    final imgs = oMap(json, 'images');
    final ints = oMap(json, 'interest');
    return SlimSubject(
      id: rInt(json, 'id'),
      images: imgs != null ? SubjectImages.fromJson(imgs) : null,
      info: rStr(json, 'info'),
      interest: ints != null ? SlimSubjectInterest.fromJson(ints) : null,
      locked: rBool(json, 'locked'),
      name: rStr(json, 'name'),
      nameCn: rStr(json, 'nameCN'),
      nsfw: rBool(json, 'nsfw'),
      rating: SubjectRating.fromJson(rMap(json, 'rating')),
      type: SubjectType.fromValue(rInt(json, 'type')),
    );
  }
}

class SubjectAirtime {
  final String date;
  final int month;
  final int weekday;
  final int year;

  const SubjectAirtime({
    required this.date,
    required this.month,
    required this.weekday,
    required this.year,
  });

  factory SubjectAirtime.fromJson(Map<String, dynamic> json) => SubjectAirtime(
    date: rStr(json, 'date'),
    month: rInt(json, 'month'),
    weekday: rInt(json, 'weekday'),
    year: rInt(json, 'year'),
  );
}

class SubjectInterest {
  final String comment;
  final int epStatus;
  final int id;
  final bool private;
  final int rate;
  final List<String> tags;
  final CollectionType type;
  final DateTime updatedAt;
  final int volStatus;

  const SubjectInterest({
    required this.comment,
    required this.epStatus,
    required this.id,
    required this.private,
    required this.rate,
    required this.tags,
    required this.type,
    required this.updatedAt,
    required this.volStatus,
  });

  factory SubjectInterest.fromJson(Map<String, dynamic> json) =>
      SubjectInterest(
        comment: rStr(json, 'comment'),
        epStatus: rInt(json, 'epStatus'),
        id: rInt(json, 'id'),
        private: rBool(json, 'private'),
        rate: rInt(json, 'rate'),
        tags: oList(json, 'tags', (e) => e as String) ?? [],
        type: CollectionType.fromValue(rInt(json, 'type')),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          rInt(json, 'updatedAt') * 1000,
        ),
        volStatus: rInt(json, 'volStatus'),
      );
}

class SubjectPlatform {
  final String alias;
  final bool? enableHeader;
  final int id;
  final int? order;
  final String? searchString;
  final List<String>? sortKeys;
  final String type;
  final String typeCN;
  final String? wikiTpl;

  const SubjectPlatform({
    required this.alias,
    this.enableHeader,
    required this.id,
    this.order,
    this.searchString,
    this.sortKeys,
    required this.type,
    required this.typeCN,
    this.wikiTpl,
  });

  factory SubjectPlatform.fromJson(Map<String, dynamic> json) =>
      SubjectPlatform(
        alias: rStr(json, 'alias'),
        enableHeader: json['enableHeader'] as bool?,
        id: rInt(json, 'id'),
        order: oInt(json, 'order'),
        searchString: oStr(json, 'searchString'),
        sortKeys: oList(json, 'sortKeys', (e) => e as String),
        type: rStr(json, 'type'),
        typeCN: rStr(json, 'typeCN'),
        wikiTpl: oStr(json, 'wikiTpl'),
      );
}

class SubjectTag {
  final String name;
  final int count;

  const SubjectTag({required this.name, required this.count});

  factory SubjectTag.fromJson(Map<String, dynamic> json) =>
      SubjectTag(name: rStr(json, 'name'), count: rInt(json, 'count'));
}

class Subject {
  final SubjectAirtime airtime;
  final Map<CollectionType, int> collection;
  final int eps;
  final int id;
  final SubjectImages? images;
  final String info;
  final List<InfoboxItem> infobox;
  final SubjectInterest? interest;
  final bool locked;
  final List<String> metaTags;
  final String name;
  final String nameCn;
  final bool nsfw;
  final SubjectPlatform platform;
  final SubjectRating rating;
  final int redirect;
  final bool series;
  final int seriesEntry;
  final String summary;
  final List<SubjectTag> tags;
  final SubjectType type;
  final int volumes;

  const Subject({
    required this.airtime,
    required this.collection,
    required this.eps,
    required this.id,
    this.images,
    required this.info,
    required this.infobox,
    this.interest,
    required this.locked,
    required this.metaTags,
    required this.name,
    required this.nameCn,
    required this.nsfw,
    required this.platform,
    required this.rating,
    required this.redirect,
    required this.series,
    required this.seriesEntry,
    required this.summary,
    required this.tags,
    required this.type,
    required this.volumes,
  });

  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  factory Subject.fromJson(Map<String, dynamic> json) {
    final imgs = oMap(json, 'images');
    final ints = oMap(json, 'interest');
    return Subject(
      airtime: SubjectAirtime.fromJson(rMap(json, 'airtime')),
      collection:
          (json['collection'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              CollectionType.fromValue(int.parse(k)),
              (v as num).toInt(),
            ),
          ) ??
          {},
      eps: rInt(json, 'eps'),
      id: rInt(json, 'id'),
      images: imgs != null ? SubjectImages.fromJson(imgs) : null,
      info: rStr(json, 'info'),
      infobox:
          oList(
            json,
            'infobox',
            (e) => InfoboxItem.fromJson(e as Map<String, dynamic>),
          ) ??
          [],
      interest: ints != null ? SubjectInterest.fromJson(ints) : null,
      locked: rBool(json, 'locked'),
      metaTags: oList(json, 'metaTags', (e) => e.toString()) ?? [],
      name: rStr(json, 'name'),
      nameCn: rStr(json, 'nameCN'),
      nsfw: rBool(json, 'nsfw'),
      platform: SubjectPlatform.fromJson(rMap(json, 'platform')),
      rating: SubjectRating.fromJson(rMap(json, 'rating')),
      redirect: rInt(json, 'redirect'),
      series: rBool(json, 'series'),
      seriesEntry: rInt(json, 'seriesEntry'),
      summary: rStr(json, 'summary'),
      tags:
          oList(
            json,
            'tags',
            (e) => SubjectTag.fromJson(e as Map<String, dynamic>),
          ) ??
          [],
      type: SubjectType.fromValue(rInt(json, 'type')),
      volumes: rInt(json, 'volumes'),
    );
  }
}

class InfoboxItem {
  final String key;
  final List<InfoboxValue> value;

  const InfoboxItem({required this.key, required this.value});

  factory InfoboxItem.fromJson(Map<String, dynamic> json) => InfoboxItem(
    key: rStr(json, 'key'),
    value:
        oList(
          json,
          'value',
          (e) => InfoboxValue.fromJson(e as Map<String, dynamic>),
        ) ??
        [],
  );
}

class InfoboxValue {
  final String v;
  final String? k;

  const InfoboxValue({required this.v, this.k});

  factory InfoboxValue.fromJson(Map<String, dynamic> json) =>
      InfoboxValue(v: rStr(json, 'v'), k: oStr(json, 'k'));
}
