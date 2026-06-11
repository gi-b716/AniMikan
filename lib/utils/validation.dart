int rInt(Map<String, dynamic> json, String key) => (json[key] as num).toInt();

double rDouble(Map<String, dynamic> json, String key) =>
    (json[key] as num).toDouble();

String rStr(Map<String, dynamic> json, String key) => json[key] as String;

bool rBool(Map<String, dynamic> json, String key) => json[key] as bool;

Map<String, dynamic> rMap(Map<String, dynamic> json, String key) =>
    json[key] as Map<String, dynamic>;

List<T> rList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(dynamic) convert,
) => (json[key] as List<dynamic>).map(convert).toList();

int? oInt(Map<String, dynamic> json, String key) =>
    (json[key] as num?)?.toInt();

double? oDouble(Map<String, dynamic> json, String key) =>
    (json[key] as num?)?.toDouble();

String? oStr(Map<String, dynamic> json, String key) => json[key] as String?;

bool? oBool(Map<String, dynamic> json, String key) => json[key] as bool?;

Map<String, dynamic>? oMap(Map<String, dynamic> json, String key) =>
    json[key] as Map<String, dynamic>?;

List<T>? oList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(dynamic) convert,
) => (json[key] as List<dynamic>?)?.map(convert).toList();
