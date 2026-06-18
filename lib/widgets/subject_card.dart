import 'package:flutter/material.dart';
import 'package:ratings_plus/ratings_plus.dart';
import '../models/subject.dart';

class SubjectCard extends StatelessWidget {
  final SlimSubject subject;
  final int? watchers;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    this.watchers,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    // return RatingBarIndicator(
    //   value: 3.7,
    //   itemCount: 5,
    //   itemSize: 14.0,
    //   itemBuilder: (context, _) => Icon(Icons.star, color: colors.primary),
    // );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 12,
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 175,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CoverImage(url: subject.images?.common ?? '', width: 115),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          _TypeBadge(type: subject.type),
                          if ( /*true || */ subject.nsfw) ...[
                            const SizedBox(width: 6),
                            _NsfwBadge(),
                          ],
                          const Spacer(),
                          if (watchers != null) ...[
                            _StatChip(
                              icon: Icons.visibility_outlined,
                              value: _formatCount(watchers!),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),

                      if (subject.info.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _extractInfo(subject.info),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: colors.outline,
                            ),
                          ),
                        ),

                      if (subject.rating.rank > 0)
                        Text.rich(
                          TextSpan(
                            text: 'Bangumi Rank  ',
                            style: text.labelSmall?.copyWith(
                              color: colors.outline,
                            ),
                            children: [
                              TextSpan(
                                text: '#${subject.rating.rank}',
                                style: text.titleSmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (subject.rating.total > 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              subject.rating.score.toStringAsFixed(1),
                              style: text.headlineSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: RatingBarIndicator(
                                value: subject.rating.score / 2.0,
                                itemCount: 5,
                                itemSize: 14.0,
                                itemBuilder: (context, _) =>
                                    Icon(Icons.star, color: colors.primary),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text(
                                '${_formatCount(subject.rating.total)}人',
                                style: text.labelSmall?.copyWith(
                                  color: colors.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    return n.toString();
  }

  static String _extractInfo(String info) {
    // format: 'xxx / xxx / xxx'
    final parts = info.split(' / ');
    return parts.join(' · ');
  }
}

class _CoverImage extends StatelessWidget {
  final String url;
  final double width;

  const _CoverImage({required this.url, required this.width});

  @override
  Widget build(BuildContext context) {
    final errorImage = Container(
      width: width,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.outline,
      ),
    );

    if (url.isEmpty) {
      return errorImage;
    }

    return Image.network(
      url,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => errorImage,
      loadingBuilder: (_, child, progress) {
        if (progress == null) {
          return child;
        }
        return Container(
          width: width,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final SubjectType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight(500),
        ),
      ),
    );
  }
}

class _NsfwBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'NSFW',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.orange.shade900,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: outline),
        const SizedBox(width: 3),
        Transform.translate(
          offset: const Offset(0, -1),
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: outline),
          ),
        ),
      ],
    );
  }
}
