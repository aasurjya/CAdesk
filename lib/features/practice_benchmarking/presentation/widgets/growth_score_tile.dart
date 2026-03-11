import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/growth_score.dart';

/// A list-tile style widget displaying a growth score dimension with grade
/// badge, score-vs-peer comparison, progress bar, insight, and
/// recommendation count.
class GrowthScoreTile extends StatefulWidget {
  const GrowthScoreTile({super.key, required this.score});

  final GrowthScore score;

  @override
  State<GrowthScoreTile> createState() => _GrowthScoreTileState();
}

class _GrowthScoreTileState extends State<GrowthScoreTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = widget.score;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TileHeader(score: gs, theme: theme),
              const SizedBox(height: 10),
              _ScoreBar(score: gs),
              const SizedBox(height: 8),
              _InsightText(insight: gs.insight, theme: theme),
              if (_expanded) ...[
                const SizedBox(height: 10),
                _RecommendationsList(
                  recommendations: gs.recommendations,
                  theme: theme,
                ),
              ],
              const SizedBox(height: 4),
              _ExpandToggle(
                expanded: _expanded,
                count: gs.recommendations.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header row: dimension name + grade badge + score comparison
// ---------------------------------------------------------------------------

class _TileHeader extends StatelessWidget {
  const _TileHeader({required this.score, required this.theme});

  final GrowthScore score;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            score.dimension,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _GradeBadge(grade: score.grade),
        const SizedBox(width: 8),
        Text(
          '${score.score.toInt()} vs ${score.peerAverage.toInt()}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grade badge
// ---------------------------------------------------------------------------

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade});

  final String grade;

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(grade);
    return Container(
      width: 36,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  static Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
      case 'A-':
        return AppColors.success;
      case 'B+':
      case 'B':
        return AppColors.primary;
      case 'B-':
        return AppColors.secondary;
      case 'C':
        return AppColors.warning;
      case 'D':
        return AppColors.error;
      default:
        return AppColors.neutral600;
    }
  }
}

// ---------------------------------------------------------------------------
// Score progress bar with peer-average marker
// ---------------------------------------------------------------------------

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});

  final GrowthScore score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Score',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              'Peer Avg ${score.peerAverage.toInt()}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 12,
          child: CustomPaint(
            size: const Size(double.infinity, 12),
            painter: _ScoreBarPainter(
              scoreFraction: score.scoreFraction,
              peerFraction: score.peerAverageFraction,
              color: score.isAbovePeerAverage
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreBarPainter extends CustomPainter {
  const _ScoreBarPainter({
    required this.scoreFraction,
    required this.peerFraction,
    required this.color,
  });

  final double scoreFraction;
  final double peerFraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final radius = Radius.circular(size.height / 2);

    // Track background
    final trackPaint = Paint()..color = AppColors.neutral200;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ),
      trackPaint,
    );

    // Score fill
    if (scoreFraction > 0) {
      final fillPaint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width * scoreFraction, size.height),
          radius,
        ),
        fillPaint,
      );
    }

    // Peer-average marker line
    final markerX = size.width * peerFraction;
    final markerPaint = Paint()
      ..color = AppColors.neutral600
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(markerX, 0),
      Offset(markerX, size.height),
      markerPaint,
    );

    // Suppress unused variable warning for midY.
    assert(midY >= 0);
  }

  @override
  bool shouldRepaint(_ScoreBarPainter oldDelegate) {
    return oldDelegate.scoreFraction != scoreFraction ||
        oldDelegate.peerFraction != peerFraction ||
        oldDelegate.color != color;
  }
}

// ---------------------------------------------------------------------------
// Insight text
// ---------------------------------------------------------------------------

class _InsightText extends StatelessWidget {
  const _InsightText({required this.insight, required this.theme});

  final String insight;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      insight,
      style: theme.textTheme.bodySmall?.copyWith(
        color: AppColors.neutral600,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommendations list (shown when expanded)
// ---------------------------------------------------------------------------

class _RecommendationsList extends StatelessWidget {
  const _RecommendationsList({
    required this.recommendations,
    required this.theme,
  });

  final List<String> recommendations;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Actions',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          ...recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, right: 6),
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rec,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
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

// ---------------------------------------------------------------------------
// Expand / collapse toggle
// ---------------------------------------------------------------------------

class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({required this.expanded, required this.count});

  final bool expanded;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$count actions',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          size: 16,
          color: AppColors.neutral400,
        ),
      ],
    );
  }
}
