import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/reconciliation/data/providers/reconciliation_providers.dart';

/// Donut-style summary card showing matched vs mismatched vs missing
/// percentages for the reconciliation dashboard.
class MatchSummaryCard extends StatelessWidget {
  const MatchSummaryCard({super.key, required this.summary});

  final ReconSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match Overview',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      matched: summary.matched,
                      mismatched: summary.mismatched,
                      missing: summary.missing,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                        color: AppColors.success,
                        label: 'Matched',
                        count: summary.matched,
                        percent: summary.matchedPercent,
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: AppColors.warning,
                        label: 'Mismatched',
                        count: summary.mismatched,
                        percent: summary.mismatchedPercent,
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: AppColors.error,
                        label: 'Missing',
                        count: summary.missing,
                        percent: summary.missingPercent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.percent,
  });

  final Color color;
  final String label;
  final int count;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        Text(
          '$count (${percent.toStringAsFixed(0)}%)',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Donut chart painter
// ---------------------------------------------------------------------------

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.matched,
    required this.mismatched,
    required this.missing,
  });

  final int matched;
  final int mismatched;
  final int missing;

  @override
  void paint(Canvas canvas, Size size) {
    final total = matched + mismatched + missing;
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const strokeWidth = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final segments = [
      (matched, AppColors.success),
      (mismatched, AppColors.warning),
      (missing, AppColors.error),
    ];

    var currentAngle = startAngle;
    for (final (count, color) in segments) {
      if (count == 0) continue;
      final sweep = (count / total) * 2 * math.pi;
      paint.color = color;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        currentAngle,
        sweep - 0.04, // small gap between segments
        false,
        paint,
      );
      currentAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      matched != oldDelegate.matched ||
      mismatched != oldDelegate.mismatched ||
      missing != oldDelegate.missing;
}
