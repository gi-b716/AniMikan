import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ratings_plus/ratings_plus.dart';

import 'package:animikan/l10n/app_localizations.dart';
import 'package:animikan/models/subject.dart';
import 'package:animikan/models/subject_extra.dart';
import 'package:animikan/router.dart';
import 'package:animikan/services/bangumi.dart';
import 'package:animikan/widgets/app_top_bar.dart';

const double _wideBreakpoint = 1080;
const double _leftColumnWidth = 300;
const double _rightColumnWidth = 320;
const double _maxContentWidth = 1240;

const _staffKeys = <String>[
  '动画制作', '原作', '音乐', '系列构成', '导演', '脚本', '制作', '製作',
  '音响监督', '人物设定', '总作画监督', '原画', '主动画师', '分镜', '演出',
  '美术监督', '色彩设计', '摄影监督', '制作协力',
];

String _compactCount(BuildContext context, int n) => NumberFormat.compact(
  locale: Localizations.localeOf(context).toString(),
).format(n);

void _comingSoon(BuildContext context) {
  final l = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l.comingSoon),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
}

class _DragScrollBehavior extends MaterialScrollBehavior {
  const _DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}


class SubjectDetailPage extends StatefulWidget {
  final int? subjectId;
  final SlimSubject? subject;
  final BangumiClient? client;

  const SubjectDetailPage({
    super.key,
    required this.subjectId,
    this.subject,
    this.client,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  Subject? _subject;
  bool _loading = true;
  bool _invalidId = false;
  String? _error;

  List<Episode>? _episodes;
  int _episodesTotal = 0;
  bool _episodesLoading = false;
  String? _episodesError;

  List<SubjectCharacter>? _characters;
  bool _charactersLoading = false;
  String? _charactersError;

  List<SubjectRelation>? _relations;
  bool _relationsLoading = false;
  String? _relationsError;

  BangumiClient get _client => widget.client ?? BangumiClient.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.subjectId;
    if (id == null) {
      setState(() {
        _loading = false;
        _invalidId = true;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await _client.getSubject(id);
      if (!mounted) return;
      setState(() {
        _subject = s;
        _loading = false;
      });
      _loadEpisodes(id);
      _loadCharacters(id);
      _loadRelations(id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadEpisodes(int id) async {
    setState(() {
      _episodesLoading = true;
      _episodesError = null;
    });
    try {
      final p = await _client.getSubjectEpisodes(id);
      if (!mounted) return;
      setState(() {
        _episodes = p.data;
        _episodesTotal = p.total;
        _episodesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _episodesError = e.toString();
        _episodesLoading = false;
      });
    }
  }

  Future<void> _loadCharacters(int id) async {
    setState(() {
      _charactersLoading = true;
      _charactersError = null;
    });
    try {
      final p = await _client.getSubjectCharacters(id);
      if (!mounted) return;
      setState(() {
        _characters = p.data;
        _charactersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _charactersError = e.toString();
        _charactersLoading = false;
      });
    }
  }

  Future<void> _loadRelations(int id) async {
    setState(() {
      _relationsLoading = true;
      _relationsError = null;
    });
    try {
      final p = await _client.getSubjectRelations(id);
      if (!mounted) return;
      setState(() {
        _relations = p.data;
        _relationsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _relationsError = e.toString();
        _relationsLoading = false;
      });
    }
  }

  SubjectImages? get _images => _subject?.images ?? widget.subject?.images;
  SubjectRating? get _rating => _subject?.rating ?? widget.subject?.rating;
  String get _name => _subject?.name ?? widget.subject?.name ?? '';
  String get _nameCn => _subject?.nameCn ?? widget.subject?.nameCn ?? '';
  String get _displayName => _nameCn.isNotEmpty ? _nameCn : _name;
  bool get _hasHeader => _subject != null || widget.subject != null;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = _displayName.isNotEmpty ? _displayName : l.subjectDetailTitle;
    final backdrop =
        _images?.large ?? _images?.common ?? _images?.medium ?? '';
    return Scaffold(
      body: Stack(
        children: [
          if (_hasHeader && backdrop.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 460,
              child: _Backdrop(url: backdrop),
            ),
          Column(
            children: [
              AppTopBar(title: title, onBack: () => context.pop()),
              Expanded(child: _body(context, l)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l) {
    if (_invalidId) {
      return _CenteredMessage(
        icon: Icons.link_off_rounded,
        title: l.loadFailed,
        detail: l.invalidId,
      );
    }
    if (!_hasHeader) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      if (_error != null) return _ErrorView(error: _error!, onRetry: _load);
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideBreakpoint;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 2,
                child: _loading
                    ? const LinearProgressIndicator(minHeight: 2)
                    : null,
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    child: wide
                        ? _wideLayout(context, l)
                        : _narrowLayout(l),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _wideLayout(BuildContext context, AppLocalizations l) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _leftColumnWidth,
          child: _column(_leftSections(l)),
        ),
        const SizedBox(width: 24),
        Expanded(child: _column(_centerSections(l, wide: true))),
        const SizedBox(width: 24),
        SizedBox(
          width: _rightColumnWidth,
          child: _column(_rightSections(l)),
        ),
      ],
    );
  }

  Widget _narrowLayout(AppLocalizations l) {
    return _column([
      _CoverArt(images: _images),
      _ActionButtons(),
      _TitleBlock(
        displayName: _displayName.isEmpty ? l.subjectDetailTitle : _displayName,
        originalName: _nameCn.isNotEmpty ? _name : '',
        metaLine: _metaLine(l),
      ),
      if (_subject != null) _StatsRow(subject: _subject!),
      if (_subject != null) _SummarySection(summary: _subject!.summary),
      _episodesSlot(l, wide: false),
      _charactersSlot(l),
      _relationsSlot(l),
      if (_rating != null) _RatingCard(rating: _rating!),
      if (_subject != null && _subject!.infobox.isNotEmpty)
        _StaffCard(infobox: _subject!.infobox),
      if (_subject != null) _WorkInfo(subject: _subject!),
      if (_subject != null && _subject!.tags.isNotEmpty)
        _TagWrap(tags: _subject!.tags),
      if (_subject == null && _error != null)
        _InlineRetry(error: _error!, onRetry: _load),
    ]);
  }

  List<Widget?> _leftSections(AppLocalizations l) {
    final full = _subject;
    return [
      _CoverArt(images: _images),
      _ActionButtons(),
      if (full != null) _StatsRow(subject: full),
      if (full != null) _WorkInfo(subject: full),
      if (full != null && full.tags.isNotEmpty) _TagWrap(tags: full.tags),
    ];
  }

  List<Widget?> _centerSections(AppLocalizations l, {required bool wide}) {
    final full = _subject;
    return [
      _TitleBlock(
        displayName: _displayName.isEmpty ? l.subjectDetailTitle : _displayName,
        originalName: _nameCn.isNotEmpty ? _name : '',
        metaLine: _metaLine(l),
      ),
      if (full != null) _SummarySection(summary: full.summary),
      _episodesSlot(l, wide: wide),
      _charactersSlot(l),
      _relationsSlot(l),
      if (full == null && _error != null)
        _InlineRetry(error: _error!, onRetry: _load),
    ];
  }

  List<Widget?> _rightSections(AppLocalizations l) {
    final full = _subject;
    return [
      if (_rating != null) _RatingCard(rating: _rating!),
      if (full != null && full.infobox.isNotEmpty)
        _StaffCard(infobox: full.infobox),
    ];
  }

  Widget? _episodesSlot(AppLocalizations l, {required bool wide}) {
    final eps = _episodes;
    if (eps != null && eps.isNotEmpty) {
      return _EpisodesSection(
        episodes: eps,
        total: _episodesTotal > eps.length ? _episodesTotal : eps.length,
        wide: wide,
      );
    }
    if (_episodesLoading) return _LoadingSlot(title: l.sectionEpisodes);
    if (_episodesError != null) {
      return _ErrorSlot(
        title: l.sectionEpisodes,
        error: _episodesError!,
        onRetry: () => _loadEpisodes(widget.subjectId!),
      );
    }
    return null;
  }

  Widget? _charactersSlot(AppLocalizations l) {
    final chars = _characters;
    if (chars != null && chars.isNotEmpty) {
      return _CharactersSection(characters: chars);
    }
    if (_charactersLoading) return _LoadingSlot(title: l.sectionCharacters);
    if (_charactersError != null) {
      return _ErrorSlot(
        title: l.sectionCharacters,
        error: _charactersError!,
        onRetry: () => _loadCharacters(widget.subjectId!),
      );
    }
    return null;
  }

  Widget? _relationsSlot(AppLocalizations l) {
    final rels = _relations;
    if (rels != null && rels.isNotEmpty) {
      return _RelationsSection(relations: rels);
    }
    if (_relationsLoading) return _LoadingSlot(title: l.sectionRelations);
    if (_relationsError != null) {
      return _ErrorSlot(
        title: l.sectionRelations,
        error: _relationsError!,
        onRetry: () => _loadRelations(widget.subjectId!),
      );
    }
    return null;
  }

  String _metaLine(AppLocalizations l) {
    final full = _subject;
    final parts = <String>[];
    if (full != null) {
      final at = full.airtime;
      if (at.year > 0 && at.month > 0) {
        parts.add(l.yearMonth(at.year, at.month));
      } else if (at.year > 0) {
        parts.add('${at.year}');
      } else if (at.date.isNotEmpty) {
        parts.add(at.date);
      }
      if (full.platform.typeCN.isNotEmpty) parts.add(full.platform.typeCN);
      if (full.eps > 0) parts.add(l.epsTotal(full.eps));
    }
    return parts.join(' · ');
  }

  Widget _column(List<Widget?> items) {
    final children = <Widget>[];
    for (final item in items) {
      if (item == null) continue;
      if (children.isNotEmpty) children.add(const SizedBox(height: 22));
      children.add(item);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }
}

class _SectionHead extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHead({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _TextAction extends StatelessWidget {  final String label;
  final VoidCallback onTap;

  const _TextAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colors.primary,
      ),
      child: Text(label),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _ImageBox extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;
  final Alignment alignment;

  const _ImageBox({
    required this.url,
    this.fallbackIcon = Icons.broken_image_outlined,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget fallback(IconData icon) => ColoredBox(
      color: colors.surfaceContainerHigh,
      child: Center(child: Icon(icon, color: colors.outline)),
    );
    if (url.isEmpty) return fallback(Icons.image_not_supported_outlined);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      alignment: alignment,
      errorWidget: (_, _, _) => fallback(fallbackIcon),
      placeholder: (_, _) => ColoredBox(
        color: colors.surfaceContainerHigh,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  final String url;

  const _Backdrop({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (url.isEmpty) return ColoredBox(color: colors.surface);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => ColoredBox(color: colors.surface),
              placeholder: (_, _) => ColoredBox(color: colors.surface),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.75, 1.0],
                colors: [
                  colors.surface.withValues(alpha: 0.45),
                  colors.surface.withValues(alpha: 0.78),
                  colors.surface,
                  colors.surface,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  final SubjectImages? images;

  const _CoverArt({required this.images});

  @override
  Widget build(BuildContext context) {
    final url =
        images?.large ?? images?.common ?? images?.medium ?? images?.small ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: _ImageBox(url: url),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _comingSoon(context),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l.actionWatch),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: () => _comingSoon(context),
            icon: const Icon(Icons.star_rounded),
            label: Text(l.actionSubscribe),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Subject subject;

  const _StatsRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = subject.collection;
    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            count: c[CollectionType.collect] ?? 0,
            label: l.statCollected,
          ),
          _Stat(count: c[CollectionType.doing] ?? 0, label: l.collectionDoing),
          _Stat(count: c[CollectionType.wish] ?? 0, label: l.collectionWish),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int count;
  final String label;

  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _compactCount(context, count),
          style: text.titleLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: text.labelSmall?.copyWith(color: colors.outline),
        ),
      ],
    );
  }
}

String? _infoboxValue(Subject subject, String key) {
  for (final item in subject.infobox) {
    if (item.key != key) continue;
    final v = item.values
        .map((e) => e.v)
        .where((s) => s.trim().isNotEmpty)
        .join(' / ');
    return v.isEmpty ? null : v;
  }
  return null;
}

class _WorkInfo extends StatelessWidget {
  final Subject subject;

  const _WorkInfo({required this.subject});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final airDate =
        _infoboxValue(subject, '放送开始') ??
        (subject.airtime.date.isNotEmpty ? subject.airtime.date : null);
    final eps = subject.eps > 0
        ? '${subject.eps}'
        : _infoboxValue(subject, '话数');
    final alias = _infoboxValue(subject, '别名');
    final rows = <(String, String)>[
      if (airDate != null) (l.infoAirDate, airDate),
      if (eps != null) (l.infoEps, eps),
      if (alias != null) (l.infoAlias, alias),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(title: l.sectionWorkInfo),
        _Panel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final r in rows) _InfoRow(name: r.$1, value: r.$2)],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String name;
  final String value;

  const _InfoRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              name,
              style: text.bodySmall?.copyWith(color: colors.outline),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: text.bodySmall)),
        ],
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  final List<SubjectTag> tags;

  const _TagWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final top = tags.take(30).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(title: l.sectionTags),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in top)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(t.name, style: text.bodySmall),
              ),
          ],
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String displayName;
  final String originalName;
  final String metaLine;

  const _TitleBlock({
    required this.displayName,
    required this.originalName,
    required this.metaLine,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (originalName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            originalName,
            style: text.titleSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
        if (metaLine.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            metaLine,
            style: text.bodySmall?.copyWith(color: colors.outline),
          ),
        ],
      ],
    );
  }
}

class _SummarySection extends StatefulWidget {
  final String summary;

  const _SummarySection({required this.summary});

  @override
  State<_SummarySection> createState() => _SummarySectionState();
}

class _SummarySectionState extends State<_SummarySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final body = widget.summary.trim();
    if (body.isEmpty) {
      return Text(
        l.noSummary,
        style: text.bodyMedium?.copyWith(color: colors.outline),
      );
    }
    final canToggle = body.length > 140;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canToggle
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: Text(
              body,
              maxLines: _expanded ? null : 4,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ),
        if (canToggle)
          Align(
            alignment: Alignment.centerRight,
            child: _TextAction(
              label: _expanded ? l.showLess : l.showMore,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ),
      ],
    );
  }
}

class _EpisodesSection extends StatefulWidget {
  final List<Episode> episodes;
  final int total;
  final bool wide;

  const _EpisodesSection({
    required this.episodes,
    required this.total,
    required this.wide,
  });

  @override
  State<_EpisodesSection> createState() => _EpisodesSectionState();
}

class _EpisodesSectionState extends State<_EpisodesSection> {
  static const int _pageSize = 10;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final eps = widget.episodes;
    final pages = (eps.length / _pageSize).ceil();
    final start = _page * _pageSize;
    final end = math.min(start + _pageSize, eps.length);
    final slice = eps.sublist(start, end);
    final cols = widget.wide ? 5 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          title: l.sectionEpisodes,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _page > 0 ? () => setState(() => _page--) : null,
                icon: const Icon(Icons.chevron_left_rounded),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              Text(
                l.pageRange(start + 1, end, eps.length),
                style: text.labelMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
              IconButton(
                onPressed: _page < pages - 1
                    ? () => setState(() => _page++)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 76,
          ),
          itemCount: slice.length,
          itemBuilder: (context, index) => _EpisodeCard(episode: slice[index]),
        ),
      ],
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final Episode episode;

  const _EpisodeCard({required this.episode});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                episode.sortLabel,
                style: text.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (episode.airdate.isNotEmpty)
                Text(
                  episode.airdate,
                  style: text.labelSmall?.copyWith(color: colors.outline),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              episode.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharactersSection extends StatelessWidget {
  final List<SubjectCharacter> characters;

  const _CharactersSection({required this.characters});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shown = characters.take(12).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(title: l.sectionCharacters),
        SizedBox(
          height: 176,
          child: ScrollConfiguration(
            behavior: const _DragScrollBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _CharacterAvatar(entry: shown[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterAvatar extends StatelessWidget {
  final SubjectCharacter entry;

  const _CharacterAvatar({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cast = entry.castName;
    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: _ImageBox(
                url: entry.character.images?.best ?? '',
                fallbackIcon: Icons.person_outline_rounded,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.character.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (cast != null)
            Text(
              cast,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: colors.outline),
            ),
        ],
      ),
    );
  }
}

class _RelationsSection extends StatelessWidget {
  final List<SubjectRelation> relations;

  const _RelationsSection({required this.relations});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(title: l.sectionRelations),
        SizedBox(
          height: 200,
          child: ScrollConfiguration(
            behavior: const _DragScrollBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: relations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _RelationCard(relation: relations[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _RelationCard extends StatelessWidget {
  final SubjectRelation relation;

  const _RelationCard({required this.relation});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final subject = relation.subject;
    final url = subject.images?.common ?? subject.images?.medium ?? '';
    return SizedBox(
      width: 104,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(
          AppRoute.subject(subject.id),
          extra: subject,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: _ImageBox(url: url),
              ),
            ),
            const SizedBox(height: 6),
            if (relation.relation.label.isNotEmpty)
              Text(
                relation.relation.label,
                style: text.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              subject.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final SubjectRating rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasScore = rating.score > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(title: l.sectionRating),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    hasScore ? rating.score.toStringAsFixed(1) : '—',
                    style: text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBarIndicator(
                          value: rating.score / 2,
                          itemCount: 5,
                          itemSize: 18,
                          unratedColor: colors.surfaceContainerHighest,
                          itemBuilder: (_, _) => Icon(
                            Icons.star_rounded,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (rating.rank > 0) '#${rating.rank}',
                            l.nRaters(_compactCount(context, rating.total)),
                          ].join(' · '),
                          style: text.bodySmall?.copyWith(
                            color: colors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (rating.count.length >= 10)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _RatingHistogram(count: rating.count),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingHistogram extends StatelessWidget {
  final List<int> count;

  const _RatingHistogram({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final peak = count.reduce(math.max);
    if (peak == 0) return const SizedBox.shrink();
    return SizedBox(
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 10; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: count[i] / peak,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(
                              alpha: 0.35 + 0.65 * (count[i] / peak),
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${i + 1}',
                      style: text.labelSmall?.copyWith(color: colors.outline),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StaffCard extends StatefulWidget {
  final List<InfoboxItem> infobox;

  const _StaffCard({required this.infobox});

  @override
  State<_StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<_StaffCard> {
  bool _expanded = false;

  String _join(InfoboxItem item) => item.values
      .map((e) => e.v)
      .where((s) => s.trim().isNotEmpty)
      .join(' / ');

  List<(String, String)> _rows() {
    if (_expanded) {
      final rows = <(String, String)>[];
      for (final item in widget.infobox) {
        final v = _join(item);
        if (v.isNotEmpty) rows.add((item.key, v));
      }
      return rows;
    }
    final byKey = {for (final item in widget.infobox) item.key: item};
    final rows = <(String, String)>[];
    for (final key in _staffKeys) {
      final item = byKey[key];
      if (item == null) continue;
      final v = _join(item);
      if (v.isNotEmpty) rows.add((key, v));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = _rows();
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          title: l.sectionStaff,
          trailing: _TextAction(
            label: _expanded ? l.showLess : l.viewAll,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
        ),
        _Panel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final r in rows) _InfoRow(name: r.$1, value: r.$2)],
          ),
        ),
      ],
    );
  }
}

class _LoadingSlot extends StatelessWidget {
  final String title;

  const _LoadingSlot({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(title: title),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorSlot extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback onRetry;

  const _ErrorSlot({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(title: title),
        _InlineRetry(error: error, onRetry: onRetry),
      ],
    );
  }
}

class _InlineRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _InlineRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return _Panel(
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 20, color: colors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onRetry, child: Text(l.retry)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: colors.outline),
          const SizedBox(height: 12),
          Text(l.loadFailed, style: text.titleMedium),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 500),
            width: 500,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                error,
                style: text.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: Text(l.retry)),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: colors.outline),
          const SizedBox(height: 12),
          Text(title, style: text.titleMedium),
          const SizedBox(height: 6),
          Text(
            detail,
            style: text.bodySmall?.copyWith(color: colors.outline),
          ),
        ],
      ),
    );
  }
}






