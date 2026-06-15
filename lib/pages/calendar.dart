import 'package:flutter/material.dart';

import '../main.dart';

int _isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 3 - ((date.weekday + 5) % 7)));
  final jan4 = DateTime(thursday.year, 1, 4);
  final week1Monday = jan4.add(Duration(days: 1 - ((jan4.weekday + 5) % 7)));
  return thursday.difference(week1Monday).inDays ~/ 7 + 1;
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final title = '${now.year}年第${_isoWeekNumber(now)}周放送时间表';

    AppShellScope.setTitle(context, title);

    return Center(child: Text(title));
  }
}
