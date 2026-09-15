import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/models/calendar.dart';
import 'package:animikan/widgets/app_shell.dart';
import 'package:animikan/services/bangumi.dart';
import 'package:animikan/widgets/subject_card.dart';

String _localeOf(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Weekday names come from `intl`, not from a translation table — the same
/// strings ('周五' / 'Fri') for every locale that has date symbols.
extension _WeekDayNames on WeekDay {
  String fullName(BuildContext context) =>
      DateFormat.EEEE(_localeOf(context)).format(date);

  String shortName(BuildContext context) =>
      DateFormat.E(_localeOf(context)).format(date);
}

int _isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 3 - ((date.weekday + 5) % 7)));
  final jan4 = DateTime(thursday.year, 1, 4);
  final week1Monday = jan4.add(Duration(days: 1 - ((jan4.weekday + 5) % 7)));
  return thursday.difference(week1Monday).inDays ~/ 7 + 1;
}

/// A scroll offset expressed as a day plus the distance from that day's header.
///
/// Used to keep the reader on the same spot when the grid is re-flowed into a
/// different column count.
class CalendarAnchor {
  final WeekDay day;
  final double intraDayOffset;

  const CalendarAnchor(this.day, this.intraDayOffset);
}

/// Geometry of the calendar's scrollable content.
class CalendarLayout {
  const CalendarLayout({required this.columns, required this.itemCounts})
    : assert(columns > 0);

  final int columns;

  final Map<WeekDay, int> itemCounts;

  static const double cardExtent = SubjectCard.mainAxisExtent;
  static const double gridSpacing = 12;
  static const double headerExtent = 44;
  static const double headerBodyGap = 8;
  static const double emptyBodyExtent = 52;
  static const double sectionGap = 16;
  static const double contentTopPadding = 8;
  static const double contentBottomPadding = 24;
  static const double contentLeftPadding = 16;
  static const double contentRightPadding = 56;

  int _count(WeekDay day) => itemCounts[day] ?? 0;

  int _rows(WeekDay day) => (_count(day) / columns).ceil();

  double sectionExtent(WeekDay day) {
    final rows = _rows(day);
    final body = rows == 0
        ? emptyBodyExtent
        : rows * cardExtent + (rows - 1) * gridSpacing;
    return headerExtent + headerBodyGap + body + sectionGap;
  }

  double dayOffset(WeekDay day) {
    var offset = contentTopPadding;
    for (final candidate in WeekDay.values) {
      if (candidate == day) break;
      offset += sectionExtent(candidate);
    }
    return offset;
  }

  WeekDay? stuckDay(double offset) {
    WeekDay? stuck;
    for (final day in WeekDay.values) {
      if (dayOffset(day) <= offset) {
        stuck = day;
      } else {
        break;
      }
    }
    return stuck;
  }

  CalendarAnchor anchorForOffset(double offset) {
    var start = contentTopPadding;
    for (final day in WeekDay.values) {
      final extent = sectionExtent(day);
      if (offset < start + extent || day == WeekDay.sunday) {
        return CalendarAnchor(day, offset - start);
      }
      start += extent;
    }
    return const CalendarAnchor(WeekDay.sunday, 0);
  }
}

class CalendarPage extends StatefulWidget {
  final BangumiClient? client;

  const CalendarPage({super.key, this.client});

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

  CalendarLayout _layout = const CalendarLayout(columns: 1, itemCounts: {});
  bool _didSyncInitialDay = false;

  BangumiClient get _client => widget.client ?? BangumiClient.instance;

  Map<WeekDay, int> get _itemCounts => {
    for (final day in WeekDay.values) day: _calendar?.weekMap[day]?.length ?? 0,
  };

  static String _weekdayLabel(BuildContext context, DateTime date) =>
      WeekDay.fromValue(date.weekday).shortName(context);

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
      final cal = await _client.getCalendar();
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
      final cal = await _client.getCalendar();
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

  void _scheduleColumnRestore(CalendarLayout next) {
    if (!_scrollCtrl.hasClients) return;
    final anchor = _layout.anchorForOffset(_scrollCtrl.offset);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollCtrl.hasClients) return;
      final target = next.dayOffset(anchor.day) + anchor.intraDayOffset;
      _scrollCtrl.jumpTo(
        target.clamp(
          _scrollCtrl.position.minScrollExtent,
          _scrollCtrl.position.maxScrollExtent,
        ),
      );
      _onScroll();
    });
  }

  void _scrollToDay(WeekDay day) {
    if (!_scrollCtrl.hasClients) return;
    final target = _layout
        .dayOffset(day)
        .clamp(
          _scrollCtrl.position.minScrollExtent,
          _scrollCtrl.position.maxScrollExtent,
        );
    _scrollCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _syncInitialDay() {
    if (!mounted || !_scrollCtrl.hasClients) return;
    _onScroll();
    setState(() {});
  }

  void _onScroll() {
    if (_calendar == null || !_scrollCtrl.hasClients) return;
    final day = _layout.stuckDay(_scrollCtrl.offset) ?? WeekDay.monday;
    if (day != _currentDayNotifier.value) {
      _currentDayNotifier.value = day;
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
    final l = AppLocalizations.of(context);
    final year = now.year;
    final week = _isoWeekNumber(now);

    final String title;
    if (_loading || _refreshing) {
      title = l.calendarTitleWeekLoading(year, week);
    } else if (_fetchedAt != null) {
      title = l.calendarTitleWeekFetched(
        year,
        week,
        _weekdayLabel(context, _fetchedAt!),
      );
    } else {
      title = l.calendarTitleWeek(year, week);
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
            Text(l.loadFailed, style: Theme.of(context).textTheme.titleMedium),
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
            FilledButton.tonal(onPressed: _loadData, child: Text(l.retry)),
          ],
        ),
      );
    }

    final cal = _calendar!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnCount(constraints.maxWidth);
        final next = CalendarLayout(columns: columns, itemCounts: _itemCounts);
        if (columns != _layout.columns) _scheduleColumnRestore(next);
        _layout = next;

        if (!_didSyncInitialDay) {
          _didSyncInitialDay = true;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _syncInitialDay(),
          );
        }

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Scrollbar(
            controller: _scrollCtrl,
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scrollCtrl,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: CalendarLayout.contentTopPadding),
                    ),
                    for (final day in WeekDay.values)
                      ..._buildDaySlivers(day, cal, columns),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: CalendarLayout.contentBottomPadding,
                      ),
                    ),
                  ],
                ),
                _stickyHeader(cal),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: _WeekDayIsland(
                    currentDay: _currentDayNotifier,
                    onSelected: _scrollToDay,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stickyHeader(Calendar calendar) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: IgnorePointer(
        child: ListenableBuilder(
          listenable: _scrollCtrl,
          builder: (context, _) {
            if (!_scrollCtrl.hasClients) return const SizedBox.shrink();

            final offset = _scrollCtrl.offset;
            final stuck = _layout.stuckDay(offset);
            if (stuck == null) return const SizedBox.shrink();

            final next = stuck == WeekDay.sunday
                ? null
                : WeekDay.values[stuck.index + 1];
            final push = next == null
                ? 0.0
                : _layout.dayOffset(next) -
                      CalendarLayout.headerExtent -
                      offset;

            return Transform.translate(
              offset: Offset(0, push < 0 ? push : 0),
              child: _sectionHeaderBand(
                stuck,
                calendar.weekMap[stuck]?.length ?? 0,
                background: Theme.of(context).colorScheme.surfaceContainer,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionHeaderBand(WeekDay day, int count, {Color? background}) {
    final band = Padding(
      padding: const EdgeInsets.only(
        left: CalendarLayout.contentLeftPadding,
        right: CalendarLayout.contentRightPadding,
      ),
      child: SizedBox(
        height: CalendarLayout.headerExtent,
        child: _SectionHeader(day: day, count: count),
      ),
    );
    if (background == null) return band;
    return Container(color: background, child: band);
  }

  List<Widget> _buildDaySlivers(WeekDay day, Calendar calendar, int columns) {
    final items = calendar.weekMap[day] ?? const <CalendarSubject>[];
    return [
      SliverToBoxAdapter(child: _sectionHeaderBand(day, items.length)),
      const SliverToBoxAdapter(
        child: SizedBox(height: CalendarLayout.headerBodyGap),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: CalendarLayout.contentLeftPadding,
        ).copyWith(right: CalendarLayout.contentRightPadding),
        sliver: items.isEmpty
            ? const SliverToBoxAdapter(child: _EmptyDayBody())
            : SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return SubjectCard(
                    subject: item.subject,
                    watchers: item.watchers,
                    onTap: () {},
                  );
                }, childCount: items.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: CalendarLayout.gridSpacing,
                  mainAxisSpacing: CalendarLayout.gridSpacing,
                  mainAxisExtent: CalendarLayout.cardExtent,
                ),
              ),
      ),
      const SliverToBoxAdapter(
        child: SizedBox(height: CalendarLayout.sectionGap),
      ),
    ];
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
      padding: const EdgeInsets.only(top: 8, bottom: 12),
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
            day.fullName(context),
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
                AppLocalizations.of(context).today,
                style: text.labelSmall?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            AppLocalizations.of(context).nSubjects(count),
            style: text.bodySmall?.copyWith(color: colors.outline),
          ),
        ],
      ),
    );
  }
}

class _EmptyDayBody extends StatelessWidget {
  const _EmptyDayBody();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CalendarLayout.emptyBodyExtent,
      child: Center(
        child: Text(
          AppLocalizations.of(context).noData,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _WeekDayIsland extends StatelessWidget {
  final ValueListenable<WeekDay> currentDay;
  final ValueChanged<WeekDay> onSelected;

  const _WeekDayIsland({required this.currentDay, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Material(
        color: colors.surfaceContainerHigh,
        elevation: 2,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: ValueListenableBuilder<WeekDay>(
            valueListenable: currentDay,
            builder: (context, selectedDay, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final day in WeekDay.values)
                    _WeekDayIslandButton(
                      day: day,
                      label: day.shortName(context),
                      selected: day == selectedDay,
                      onPressed: () => onSelected(day),
                      colors: colors,
                      text: text,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WeekDayIslandButton extends StatelessWidget {
  final WeekDay day;
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final ColorScheme colors;
  final TextTheme text;

  const _WeekDayIslandButton({
    required this.day,
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.colors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: AppLocalizations.of(context).jumpToDay(day.fullName(context)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 40,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: text.labelSmall?.copyWith(
              color: selected
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
