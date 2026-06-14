import 'dart:core';

Never _missing(String key) =>
    throw ArgumentError('Required field "$key" is missing or null in JSON');

T _req<T>(Map<String, dynamic> json, String key) =>
    json[key] as T? ?? _missing(key);

int rInt(Map<String, dynamic> json, String key) =>
    (_req<num>(json, key)).toInt();

double rDouble(Map<String, dynamic> json, String key) =>
    (_req<num>(json, key)).toDouble();

String rStr(Map<String, dynamic> json, String key) => _req<String>(json, key);

bool rBool(Map<String, dynamic> json, String key) => _req<bool>(json, key);

Map<String, dynamic> rMap(Map<String, dynamic> json, String key) =>
    _req<Map<String, dynamic>>(json, key);

List<T> rList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(dynamic) convert,
) => _req<List<dynamic>>(json, key).map(convert).toList();

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
