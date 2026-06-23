import 'dart:async';

import 'package:flutter/material.dart';

import 'package:animikan/widgets/app_shell.dart';
import 'package:animikan/models/calendar.dart';
import 'package:animikan/services/bangumi.dart';
import 'package:animikan/widgets/subject_card.dart';

int _isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 3 - ((date.weekday + 5) % 7)));
  final jan4 = DateTime(thursday.year, 1, 4);
  final week1Monday = jan4.add(Duration(days: 1 - ((jan4.weekday + 5) % 7)));
  return thursday.difference(week1Monday).inDays ~/ 7 + 1;
}

const double _kCardHeight = 175; // SubjectCard fixed height
const double _kRowSpacing = 12; // _ItemGrid runSpacing
const double _kHeaderHeight = 44; // _SectionHeader approx height
const double _kSectionGap = 24; // 8 (before grid) + 16 (after grid)

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Calendar? _calendar;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  Timer? _refreshTimer;
  DateTime? _fetchedAt;

  final ScrollController _scrollCtrl = ScrollController();
  final ValueNotifier<WeekDay> _currentDayNotifier = ValueNotifier(
    WeekDay.today,
  );

  int _currentCols = 1;

  static const _weekdayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static String _weekdayLabel(DateTime date) =>
      _weekdayLabels[date.weekday - 1];

  static Duration _untilNextMidnight() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + 1);
    return target.difference(now);
  }

  void _scheduleDailyRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(_untilNextMidnight(), () {
      if (!mounted) return;
      _refreshData();
      _scheduleDailyRefresh();
    });
  }

  // TODO: Settings in future
  Future<void> _refreshData() async {
    setState(() => _refreshing = true);
    try {
      final cal = await BangumiClient().getCalendar();
      if (!mounted) return;
      setState(() {
        _calendar = cal;
        _fetchedAt = DateTime.now();
        _refreshing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _refreshing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _loadData();
    _scheduleDailyRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _currentDayNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cal = await BangumiClient().getCalendar();
      if (!mounted) return;
      setState(() {
        _calendar = cal;
        _fetchedAt = DateTime.now();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<WeekDay, double> _computeDayOffsets(int cols) {
    final map = <WeekDay, double>{};
    double cursor = 0;
    for (final d in WeekDay.values) {
      map[d] = cursor;
      final n = _calendar?.weekMap[d]?.length ?? 0;
      if (n == 0) {
        cursor += _kHeaderHeight + 52 + _kSectionGap;
      } else {
        final rows = (n / cols).ceil();
        final gridH = rows * _kCardHeight + (rows - 1) * _kRowSpacing;
        cursor += _kHeaderHeight + gridH + _kSectionGap;
      }
    }
    return map;
  }

  void _onScroll() {
    if (_calendar == null || !_scrollCtrl.hasClients) return;
    final maxExt = _scrollCtrl.position.maxScrollExtent;
    if (maxExt <= 0) return;

    final offsets = _computeDayOffsets(_currentCols);
    final pos = _scrollCtrl.offset;
    WeekDay closest = WeekDay.values.first;
    for (final d in WeekDay.values) {
      if ((offsets[d] ?? 0) <= pos + 12) {
        closest = d;
      }
    }
    if (closest != _currentDayNotifier.value) {
      _currentDayNotifier.value = closest;
    }
  }

  static int _columnCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1300) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    String title;
    if (_loading || _refreshing) {
      title = '${now.year}年第${_isoWeekNumber(now)}周放送时间表 [加载中]';
    } else if (_fetchedAt != null) {
      title =
          '${now.year}年第${_isoWeekNumber(now)}周放送时间表 · ${_weekdayLabel(_fetchedAt!)}获取';
    } else {
      title = '${now.year}年第${_isoWeekNumber(now)}周放送时间表';
    }
    AppShellScope.setTitle(context, title);

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 500),
              width: 500,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    final cal = _calendar!;

    return LayoutBuilder(
      builder: (context, constraints) {
        _currentCols = _columnCount(constraints.maxWidth);

        final avail =
            constraints.maxWidth - 72; // ListView horizontal padding (16+56)
        final gap = 12.0;
        final itemW = (avail - gap * (_currentCols - 1)) / _currentCols;

        return Stack(
          children: [
            ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 56, 24),
              children: [
                for (final d in WeekDay.values) ...[
                  _SectionHeader(day: d, count: cal.weekMap[d]?.length ?? 0),
                  const SizedBox(height: 8),
                  _ItemGrid(
                    items: cal.weekMap[d] ?? [],
                    itemWidth: itemW,
                    spacing: gap,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final WeekDay day;
  final int count;

  const _SectionHeader({required this.day, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isToday = day == WeekDay.today;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: isToday ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            day.label,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isToday ? colors.primary : null,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '今天',
                style: text.labelSmall?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            '$count 部',
            style: text.bodySmall?.copyWith(color: colors.outline),
          ),
        ],
      ),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  final List<CalendarSubject> items;
  final double itemWidth;
  final double spacing;

  const _ItemGrid({
    required this.items,
    required this.itemWidth,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '暂无',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: items
          .map(
            (e) => SizedBox(
              width: itemWidth,
              child: SubjectCard(
                subject: e.subject,
                watchers: e.watchers,
                onTap: () {},
              ),
            ),
          )
          .toList(),
    );
  }
}
