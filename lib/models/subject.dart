enum CollectionType {
  wish(1),
  collect(2),
  doing(3),
  onHold(4),
  dropped(5);

  const CollectionType(this.value);
  final int value;

  static CollectionType fromValue(int v) => CollectionType.values.firstWhere(
    (e) => e.value == v,
    orElse: () => CollectionType.wish,
  );

  String get label => switch (this) {
    CollectionType.wish => '想看',
    CollectionType.collect => '看过',
    CollectionType.doing => '在看',
    CollectionType.onHold => '搁置',
    CollectionType.dropped => '抛弃',
  };
}

enum SubjectType {
  book(1),
  anime(2),
  music(3),
  game(4),
  real(6);

  const SubjectType(this.value);
  final int value;

  static SubjectType fromValue(int v) => SubjectType.values.firstWhere(
    (e) => e.value == v,
    orElse: () => SubjectType.anime,
  );

  String get label => switch (this) {
    SubjectType.book => '书籍',
    SubjectType.anime => '动画',
    SubjectType.music => '音乐',
    SubjectType.game => '游戏',
    SubjectType.real => '三次元',
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
    common: json['common'] as String? ?? '',
    grid: json['grid'] as String? ?? '',
    large: json['large'] as String? ?? '',
    medium: json['medium'] as String? ?? '',
    small: json['small'] as String? ?? '',
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
        comment: json['comment'] as String? ?? '',
        id: (json['id'] as num?)?.toInt() ?? 0,
        rate: (json['rate'] as num?)?.toInt() ?? 0,
        tags:
            (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        type: CollectionType.fromValue((json['type'] as num?)?.toInt() ?? 1),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          ((json['updatedAt'] as num?)?.toInt() ?? 0) * 1000,
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
    count:
        (json['count'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [],
    rank: (json['rank'] as num?)?.toInt() ?? 0,
    score: (json['score'] as num?)?.toDouble() ?? 0.0,
    total: (json['total'] as num?)?.toInt() ?? 0,
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

  factory SlimSubject.fromJson(Map<String, dynamic> json) => SlimSubject(
    id: (json['id'] as num?)?.toInt() ?? 0,
    images: json['images'] != null
        ? SubjectImages.fromJson(json['images'] as Map<String, dynamic>)
        : null,
    info: json['info'] as String? ?? '',
    interest: json['interest'] != null
        ? SlimSubjectInterest.fromJson(json['interest'] as Map<String, dynamic>)
        : null,
    locked: json['locked'] as bool? ?? false,
    name: json['name'] as String? ?? '',
    nameCn: json['nameCN'] as String? ?? '',
    nsfw: json['nsfw'] as bool? ?? false,
    rating: json['rating'] != null
        ? SubjectRating.fromJson(json['rating'] as Map<String, dynamic>)
        : const SubjectRating(count: [], rank: 0, score: 0, total: 0),
    type: SubjectType.fromValue(
      (json['type'] as num?)?.toInt() ?? SubjectType.anime.value,
    ),
  );
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
    date: json['date'] as String? ?? '',
    month: (json['month'] as num?)?.toInt() ?? 0,
    weekday: (json['weekday'] as num?)?.toInt() ?? 0,
    year: (json['year'] as num?)?.toInt() ?? 0,
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
        comment: json['comment'] as String? ?? '',
        epStatus: (json['epStatus'] as num?)?.toInt() ?? 0,
        id: (json['id'] as num?)?.toInt() ?? 0,
        private: json['private'] as bool? ?? false,
        rate: (json['rate'] as num?)?.toInt() ?? 0,
        tags:
            (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        type: CollectionType.fromValue((json['type'] as num?)?.toInt() ?? 1),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          ((json['updatedAt'] as num?)?.toInt() ?? 0) * 1000,
        ),
        volStatus: (json['volStatus'] as num?)?.toInt() ?? 0,
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
        alias: json['alias'] as String? ?? '',
        enableHeader: json['enableHeader'] as bool?,
        id: (json['id'] as num?)?.toInt() ?? 0,
        order: (json['order'] as num?)?.toInt(),
        searchString: json['searchString'] as String?,
        sortKeys: (json['sortKeys'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        type: json['type'] as String? ?? '',
        typeCN: json['typeCN'] as String? ?? '',
        wikiTpl: json['wikiTpl'] as String?,
      );
}

class SubjectTag {
  final String name;
  final int count;

  const SubjectTag({required this.name, required this.count});

  factory SubjectTag.fromJson(Map<String, dynamic> json) => SubjectTag(
    name: json['name'] as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
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

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    airtime: json['airtime'] != null
        ? SubjectAirtime.fromJson(json['airtime'] as Map<String, dynamic>)
        : const SubjectAirtime(date: '', month: 0, weekday: 0, year: 0),
    collection:
        (json['collection'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(
            CollectionType.fromValue(int.parse(k)),
            (v as num).toInt(),
          ),
        ) ??
        {},
    eps: (json['eps'] as num?)?.toInt() ?? 0,
    id: (json['id'] as num?)?.toInt() ?? 0,
    images: json['images'] != null
        ? SubjectImages.fromJson(json['images'] as Map<String, dynamic>)
        : null,
    info: json['info'] as String? ?? '',
    infobox:
        (json['infobox'] as List<dynamic>?)
            ?.map((e) => InfoboxItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    interest: json['interest'] != null
        ? SubjectInterest.fromJson(json['interest'] as Map<String, dynamic>)
        : null,
    locked: json['locked'] as bool? ?? false,
    metaTags:
        (json['metaTags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    name: json['name'] as String? ?? '',
    nameCn: json['nameCN'] as String? ?? '',
    nsfw: json['nsfw'] as bool? ?? false,
    platform: json['platform'] != null
        ? SubjectPlatform.fromJson(json['platform'] as Map<String, dynamic>)
        : const SubjectPlatform(alias: '', id: 0, type: '', typeCN: ''),
    rating: json['rating'] != null
        ? SubjectRating.fromJson(json['rating'] as Map<String, dynamic>)
        : const SubjectRating(count: [], rank: 0, score: 0, total: 0),
    redirect: (json['redirect'] as num?)?.toInt() ?? 0,
    series: json['series'] as bool? ?? false,
    seriesEntry: (json['seriesEntry'] as num?)?.toInt() ?? 0,
    summary: json['summary'] as String? ?? '',
    tags:
        (json['tags'] as List<dynamic>?)
            ?.map((e) => SubjectTag.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    type: SubjectType.fromValue((json['type'] as num?)?.toInt() ?? 2),
    volumes: (json['volumes'] as num?)?.toInt() ?? 0,
  );
}

class InfoboxItem {
  final String key;
  final List<InfoboxValue> value;

  const InfoboxItem({required this.key, required this.value});

  factory InfoboxItem.fromJson(Map<String, dynamic> json) => InfoboxItem(
    key: json['key'] as String? ?? '',
    value:
        (json['value'] as List<dynamic>?)
            ?.map((e) => InfoboxValue.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class InfoboxValue {
  final String v;
  final String? k;

  const InfoboxValue({required this.v, this.k});

  factory InfoboxValue.fromJson(Map<String, dynamic> json) =>
      InfoboxValue(v: json['v'] as String? ?? '', k: json['k'] as String?);
}
