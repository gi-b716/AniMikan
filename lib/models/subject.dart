import 'package:animikan/utils/validation.dart';

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

/// Test Subject: Bangumi 328609 ぼっち・ざ・ろっく！
const testSubject = {
  "airtime": {"date": "2022-10-08", "month": 10, "weekday": 6, "year": 2022},
  "collection": {"1": 4261, "2": 62889, "3": 5073, "4": 1096, "5": 602},
  "eps": 12,
  "id": 328609,
  "infobox": [
    {
      "key": "中文名",
      "values": [
        {"v": "孤独摇滚！"},
      ],
    },
    {
      "key": "别名",
      "values": [
        {"v": "BTR"},
        {"v": "Bocchi the Rock!"},
        {"v": "Bocchi the \"Guitar Hero\" Rock Story"},
      ],
    },
    {
      "key": "话数",
      "values": [
        {"v": "12"},
      ],
    },
    {
      "key": "放送开始",
      "values": [
        {"v": "2022年10月8日"},
      ],
    },
    {
      "key": "放送星期",
      "values": [
        {"v": "星期六"},
      ],
    },
    {
      "key": "官方网站",
      "values": [
        {"v": "https://bocchi.rocks/"},
      ],
    },
    {
      "key": "在线播放平台",
      "values": [
        {"v": ""},
      ],
    },
    {
      "key": "播放电视台",
      "values": [
        {"v": "TOKYO MX / BS11 / 群馬テレビ / とちぎテレビ"},
      ],
    },
    {
      "key": "其他电视台",
      "values": [
        {"v": "MRT宮崎放送 / MBS / RKB毎日放送 / AT-X"},
      ],
    },
    {
      "key": "播放结束",
      "values": [
        {"v": "2022年12月24日"},
      ],
    },
    {
      "key": "导演",
      "values": [
        {"v": "斎藤圭一郎"},
      ],
    },
    {
      "key": "音乐",
      "values": [
        {"v": "菊谷知樹"},
      ],
    },
    {"key": "链接", "values": []},
    {
      "key": "其他",
      "values": [
        {"v": ""},
      ],
    },
    {
      "key": "Copyright",
      "values": [
        {"v": "©はまじあき／芳文社・アニプレックス"},
      ],
    },
    {
      "key": "原作",
      "values": [
        {"v": "はまじあき（芳文社「まんがタイムきららMAX」連載中）"},
      ],
    },
    {
      "key": "系列构成",
      "values": [
        {"v": "吉田恵里香"},
      ],
    },
    {
      "key": "人物设定",
      "values": [
        {"v": "けろりら"},
      ],
    },
    {
      "key": "总作画监督",
      "values": [
        {"v": "けろりら"},
      ],
    },
    {
      "key": "副导演",
      "values": [
        {"v": "山本ゆうすけ"},
      ],
    },
    {
      "key": "道具设计",
      "values": [
        {"v": "永木歩実；人偶制作：佐藤利幸"},
      ],
    },
    {
      "key": "色彩设计",
      "values": [
        {"v": "横田明日香"},
      ],
    },
    {
      "key": "美术监督",
      "values": [
        {"v": "守安靖尚"},
      ],
    },
    {
      "key": "美术设计",
      "values": [
        {"v": "taracod"},
      ],
    },
    {
      "key": "摄影监督",
      "values": [
        {"v": "金森つばさ"},
      ],
    },
    {
      "key": "摄影监督助理",
      "values": [
        {"v": "佐藤瑠里"},
      ],
    },
    {
      "key": "CG 导演",
      "values": [
        {"v": "宮地克明；Live CG导演：内田博明"},
      ],
    },
    {
      "key": "剪辑",
      "values": [
        {"v": "平木大輔"},
      ],
    },
    {
      "key": "音响监督",
      "values": [
        {"v": "藤田亜紀子"},
      ],
    },
    {
      "key": "音响",
      "values": [
        {"v": "HALF H・P STUDIO"},
      ],
    },
    {
      "key": "音效",
      "values": [
        {"v": "八十正太"},
      ],
    },
    {
      "key": "主题歌编曲",
      "values": [
        {"v": "三井律郎"},
      ],
    },
    {
      "key": "主题歌作曲",
      "values": [
        {"v": "音羽-otoha-（OP）、谷口鮪 (KANA-BOON)、中嶋イッキュウ、北澤ゆうほ（ED）"},
      ],
    },
    {
      "key": "主题歌作词",
      "values": [
        {"v": "樋口愛（ヒグチアイ）（OP）、谷口鮪 (KANA-BOON)、中嶋イッキュウ、北澤ゆうほ（ED）"},
      ],
    },
    {
      "key": "主题歌演出",
      "values": [
        {"v": "結束バンド (青山吉能、長谷川育美、水野朔、鈴代紗弓)"},
      ],
    },
    {
      "key": "插入歌演出",
      "values": [
        {"v": "結束バンド、SICK HACK"},
      ],
    },
    {
      "key": "OP・ED 分镜",
      "values": [
        {"v": "斎藤圭一郎 / スズキハルカ"},
      ],
    },
    {
      "key": "OP・ED 演出",
      "values": [
        {"v": "斎藤圭一郎 / スズキハルカ"},
      ],
    },
    {
      "key": "动画制作",
      "values": [
        {"v": "CloverWorks"},
      ],
    },
    {
      "key": "制片人",
      "values": [
        {"v": "石川達也、小林宏之"},
      ],
    },
    {
      "key": "製作",
      "values": [
        {"v": "Aniplex、芳文社"},
      ],
    },
    {
      "key": "3DCG",
      "values": [
        {"v": "Boundary；LIVE 舞台CG：exsa"},
      ],
    },
    {
      "key": "企画",
      "values": [
        {"v": "岩上敦宏、孝壽尚志"},
      ],
    },
    {
      "key": "音乐制作",
      "values": [
        {"v": "Aniplex"},
      ],
    },
    {
      "key": "制作统括",
      "values": [
        {"v": "清水暁"},
      ],
    },
    {
      "key": "脚本",
      "values": [
        {"v": "吉田恵里香"},
      ],
    },
    {
      "key": "分镜",
      "values": [
        {
          "v":
              "斎藤圭一郎(1,2,8,12)、山本ゆうすけ(3,11)、刈谷暢秀(4)、川上雄介(5,10)、藤原佳幸(6)、アマタジャンチキ[石井俊匡](7)、平峯義大(9)",
        },
      ],
    },
    {
      "key": "演出",
      "values": [
        {
          "v":
              "斎藤圭一郎(1,12)、藤原佳幸(2,6,10)、山本ゆうすけ(3,11)、刈谷暢秀(4)、川上雄介(5,10)、篠原啓輔(7)、瀬尾健(8)、平峯義大(9)",
        },
      ],
    },
    {
      "key": "作画监督",
      "values": [
        {
          "v":
              "けろりら(OP,1,4,6-8,10,12)、助川裕彦(2,11)、中村颯(3)、Maring Song(4,10)、高橋沙妃(5,10)、冨田真理(6)、朴世英(7)、石田一将(7)、川妻智美(7)、Franziska van Wulfen(8)、TOMATO(8)、伊藤弘樹(9)、きーくん[杉本龍彦](10)、スズキハルカ(ED)",
        },
      ],
    },
    {
      "key": "主动画师",
      "values": [
        {"v": "LIVE动画师：伊藤優希"},
      ],
    },
    {
      "key": "作画监督助理",
      "values": [
        {"v": "森川侑紀、安野将人、山崎淳、中村颯、高橋沙妃、けろりら、冨田真理、刈谷暢秀、瀬尾健、平峯義大、伊藤弘樹"},
      ],
    },
    {
      "key": "演出助理",
      "values": [
        {"v": "山本ゆうすけ、篠原啓輔"},
      ],
    },
    {
      "key": "协力",
      "values": [
        {"v": "瀬古口拓也"},
      ],
    },
    {
      "key": "制作管理助理",
      "values": [
        {"v": "染野翔"},
      ],
    },
  ],
  "info": "12话 / 2022年10月8日 / 斎藤圭一郎 / はまじあき（芳文社「まんがタイムきららMAX」連載中） / けろりら",
  "metaTags": ["TV", "日本", "漫画改", "音乐", "日常"],
  "locked": false,
  "name": "ぼっち・ざ・ろっく！",
  "nameCN": "孤独摇滚！",
  "nsfw": false,
  "platform": {
    "id": 1,
    "type": "TV",
    "typeCN": "TV",
    "alias": "tv",
    "order": 0,
    "enableHeader": true,
    "wikiTpl": "TVAnime",
  },
  "rating": {
    "rank": 72,
    "count": [195, 49, 48, 107, 358, 1355, 4974, 13792, 12148, 6737],
    "score": 8.37,
    "total": 39763,
  },
  "redirect": 0,
  "series": false,
  "seriesEntry": 0,
  "summary":
      "作为网络吉他手“吉他英雄”而广受好评的后藤一里，在现实中却是个什么都不会的沟通障碍者。一里有着组建乐队的梦想，但因为不敢向人主动搭话而一直没有成功，直到一天在公园中被伊地知虹夏发现并邀请进入缺少吉他手的“结束乐队”。可是，完全没有和他人合作经历的一里，在人前完全发挥不出原本的实力。为了努力克服沟通障碍，一里与“结束乐队”的成员们一同开始努力……",
  "type": 2,
  "volumes": 0,
  "tags": [
    {"name": "芳文社", "count": 10693},
    {"name": "音乐", "count": 8922},
    {"name": "轻百合", "count": 7091},
    {"name": "CloverWorks", "count": 6955},
    {"name": "日常", "count": 6587},
    {"name": "漫画改", "count": 4602},
    {"name": "乐队题材", "count": 4494},
    {"name": "2022年10月", "count": 4450},
    {"name": "搞笑", "count": 3092},
    {"name": "TV", "count": 3044},
    {"name": "百合", "count": 2159},
    {"name": "2022", "count": 1793},
    {"name": "斎藤圭一郎", "count": 1500},
    {"name": "漫改", "count": 1482},
    {"name": "乐队", "count": 876},
    {"name": "日本", "count": 656},
    {"name": "梅原翔太", "count": 478},
    {"name": "校园", "count": 239},
    {"name": "斋藤圭一郎", "count": 211},
    {"name": "青春", "count": 185},
    {"name": "治愈", "count": 159},
    {"name": "神作", "count": 88},
    {"name": "萌", "count": 88},
    {"name": "孤独摇滚", "count": 79},
    {"name": "社恐", "count": 78},
    {"name": "少女乐队", "count": 76},
    {"name": "轻百", "count": 67},
    {"name": "摇滚", "count": 57},
    {"name": "2022年", "count": 55},
    {"name": "成长", "count": 36},
  ],
  "images": {
    "large": "https://lain.bgm.tv/pic/cover/l/e2/e7/328609_2EHLJ.jpg",
    "common": "https://lain.bgm.tv/r/400/pic/cover/l/e2/e7/328609_2EHLJ.jpg",
    "medium": "https://lain.bgm.tv/r/200/pic/cover/l/e2/e7/328609_2EHLJ.jpg",
    "small": "https://lain.bgm.tv/r/100/pic/cover/l/e2/e7/328609_2EHLJ.jpg",
    "grid": "https://lain.bgm.tv/r/100x100/pic/cover/l/e2/e7/328609_2EHLJ.jpg",
  },
  "interest": {
    "id": 51009576,
    "rate": 0,
    "type": 3,
    "comment": "",
    "tags": [],
    "epStatus": 12,
    "volStatus": 0,
    "private": false,
    "updatedAt": 1781020303,
  },
};
