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

  /// A date that falls on this weekday, so the name can come from `intl`
  /// (`DateFormat.EEEE` / `DateFormat.E`) instead of a translation table.
  DateTime get date => DateTime(2024, 1, value);

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
