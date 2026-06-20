import 'package:animikan/models/subject.dart';
import 'package:animikan/utils/validation.dart';

enum WeekDay {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const WeekDay(this.value);
  final int value;

  static WeekDay fromValue(int value) {
    return WeekDay.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WeekDay.monday,
    );
  }

  String get label => switch (this) {
    WeekDay.monday => '星期一',
    WeekDay.tuesday => '星期二',
    WeekDay.wednesday => '星期三',
    WeekDay.thursday => '星期四',
    WeekDay.friday => '星期五',
    WeekDay.saturday => '星期六',
    WeekDay.sunday => '星期日',
  };

  static WeekDay get today => fromValue(DateTime.now().weekday);
}

class CalendarSubject {
  final SlimSubject subject;
  final int watchers;

  const CalendarSubject({required this.subject, required this.watchers});

  factory CalendarSubject.fromJson(Map<String, dynamic> json) =>
      CalendarSubject(
        subject: SlimSubject.fromJson(rMap(json, 'subject')),
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
