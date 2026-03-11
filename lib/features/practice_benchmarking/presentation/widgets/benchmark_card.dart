import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/benchmark_metric.dart';

/// A card displaying a single benchmark metric with a three-value comparison
/// row, trend indicator, and a visual scale showing your position relative
/// to the peer median and top quartile.
class BenchmarkCard extends StatelessWidget {
  const BenchmarkCard({super.key, required this.metric});

  final BenchmarkMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderRow(metric: metric, theme: theme),
            const SizedBox(height: 12),
            _ComparisonRow(metric: metric, theme: theme),
            const SizedBox(height: 12),
            _VisualScale(metric: metric),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: metric name + category chip + trend badge
// ---------------------------------------------------------------------------

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.metric, required this.theme});

  final BenchmarkMetric metric;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.metricName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              _CategoryChip(category: metric.category),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _TrendBadge(trend: metric.trend, trendPercent: metric.trendPercent),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Category chip
// ---------------------------------------------------------------------------

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Financial':
        return AppColors.primary;
      case 'Operational':
        return AppColors.secondary;
      case 'Client':
        return AppColors.accent;
      case 'Technology':
        return const Color(0xFF7C3AED);
      case 'Team':
        return AppColors.success;
      default:
        return AppColors.neutral600;
    }
  }
}

// ---------------------------------------------------------------------------
// Trend badge
// ---------------------------------------------------------------------------

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend, required this.trendPercent});

  final String trend;
  final double trendPercent;

  @override
  Widget build(BuildContext context) {
    final color = trend == 'Up'
        ? AppColors.success
        : trend == 'Down'
            ? AppColors.error
            : AppColors.neutral400;
    final icon = trend == 'Up'
        ? Icons.trending_up_rounded
        : trend == 'Down'
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    final label = trend == 'Stable' ? 'Stable' : '${trendPercent.toStringAsFixed(0)}% YoY';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Three-value comparison row: You | Median | Top 25%
// ---------------------------------------------------------------------------

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.metric, required this.theme});

  final BenchmarkMetric metric;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final yourColor = metric.isAboveMedian
        ? AppColors.success
        : metric.isSignificantlyBelowMedian
            ? AppColors.error
            : AppColors.warning;

    return Row(
      children: [
        _ValueItem(
          label: 'You',
          value: _formatValue(metric.yourValue, metric.unit),
          color: yourColor,
          isHighlighted: true,
          theme: theme,
        ),
        const _Divider(),
        _ValueItem(
          label: 'Median',
          value: _formatValue(metric.peerMedian, metric.unit),
          color: AppColors.neutral600,
          isHighlighted: false,
          theme: theme,
        ),
        const _Divider(),
        _ValueItem(
          label: 'Top 25%',
          value: _formatValue(metric.topQuartile, metric.unit),
          color: AppColors.primary,
          isHighlighted: false,
          theme: theme,
        ),
      ],
    );
  }

  static String _formatValue(double value, String unit) {
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    if (unit.isEmpty) {
      return formatted;
    }
    if (unit == '₹L' || unit == '₹K' || unit == '% adv') {
      return '$formatted $unit';
    }
    if (unit == '%') {
      return '$formatted%';
    }
    if (unit == 'days') {
      return '$formatted days';
    }
    if (unit == 'clients') {
      return formatted;
    }
    if (unit == 'ratio') {
      return '1:$formatted';
    }
    return '$formatted $unit';
  }
}

class _ValueItem extends StatelessWidget {
  const _ValueItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isHighlighted,
    required this.theme,
  });

  final String label;
  final String value;
  final Color color;
  final bool isHighlighted;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.neutral200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal visual scale
// ---------------------------------------------------------------------------

class _VisualScale extends StatelessWidget {
  const _VisualScale({required this.metric});

  final BenchmarkMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'vs Peer Range',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral400,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 20,
          child: CustomPaint(
            size: const Size(double.infinity, 20),
            painter: _ScalePainter(
              yourPosition: metric.yourPosition,
              medianPosition: metric.medianPosition,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScalePainter extends CustomPainter {
  const _ScalePainter({
    required this.yourPosition,
    required this.medianPosition,
  });

  final double yourPosition;
  final double medianPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = AppColors.neutral200
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final midY = size.height / 2;

    // Draw track
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      trackPaint,
    );

    // Draw top-quartile end marker
    final topPaint = Paint()..color = AppColors.primary.withAlpha(80);
    canvas.drawCircle(Offset(size.width, midY), 5, topPaint);

    // Draw median dot
    final medianX = medianPosition * size.width;
    final medianPaint = Paint()..color = AppColors.neutral400;
    canvas.drawCircle(Offset(medianX, midY), 4, medianPaint);

    // Draw your value dot (slightly larger)
    final yourX = yourPosition * size.width;
    final yourColor = yourPosition >= medianPosition
        ? AppColors.success
        : AppColors.warning;
    final yourPaint = Paint()..color = yourColor;
    canvas.drawCircle(Offset(yourX, midY), 6, yourPaint);
  }

  @override
  bool shouldRepaint(_ScalePainter oldDelegate) {
    return oldDelegate.yourPosition != yourPosition ||
        oldDelegate.medianPosition != medianPosition;
  }
}
