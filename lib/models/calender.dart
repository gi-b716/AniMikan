import '../utils/validation.dart';
import 'subject.dart';

enum WeekDay {
  Monday(1), // ignore: constant_identifier_names
  Tuesday(2), // ignore: constant_identifier_names
  Wednesday(3), // ignore: constant_identifier_names
  Thursday(4), // ignore: constant_identifier_names
  Friday(5), // ignore: constant_identifier_names
  Saturday(6), // ignore: constant_identifier_names
  Sunday(7); // ignore: constant_identifier_names

  const WeekDay(this.value);
  final int value;

  static WeekDay fromValue(int value) {
    return WeekDay.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid WeekDay value: $value'),
    );
  }

  String get label => switch (this) {
    WeekDay.Monday => '星期一',
    WeekDay.Tuesday => '星期二',
    WeekDay.Wednesday => '星期三',
    WeekDay.Thursday => '星期四',
    WeekDay.Friday => '星期五',
    WeekDay.Saturday => '星期六',
    WeekDay.Sunday => '星期日',
  };
}

class CalendarSubject {
  final Subject subject;
  final int watchers;

  const CalendarSubject({required this.subject, required this.watchers});

  factory CalendarSubject.fromJson(Map<String, dynamic> json) =>
      CalendarSubject(
        subject: Subject.fromJson(rMap(json, 'subject')),
        watchers: rInt(json, 'watchers'),
      );
}

class Calendar {
  final Map<WeekDay, List<CalendarSubject>> weekMap;

  const Calendar({required this.weekMap});

  factory Calendar.fromJson(Map<String, dynamic> json) {
    final weekMap = <WeekDay, List<CalendarSubject>>{};
    for (final entry in json.entries) {
      final day = int.tryParse(entry.key);
      if (day == null) continue;
      weekMap[WeekDay.fromValue(day)] = (entry.value as List<dynamic>)
          .map((e) => CalendarSubject.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return Calendar(weekMap: weekMap);
  }
}
