import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/analytics/data/providers/analytics_providers.dart';

/// A 6-month stacked bar chart of revenue by service type using [CustomPainter].
class RevenueChartWidget extends ConsumerWidget {
  const RevenueChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(revenueBreakdownProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ChartLegend(),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: _BarChartPainterWidget(months: months),
            ),
            const SizedBox(height: 8),
            _MonthLabels(months: months),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chart legend
// ---------------------------------------------------------------------------

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: _serviceColors.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: entry.value,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Month labels row
// ---------------------------------------------------------------------------

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({required this.months});

  final List<RevenueBreakdown> months;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: months.map((m) {
        return Expanded(
          child: Text(
            _shortMonth(m.period),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  static String _shortMonth(String period) {
    // "Oct 2025" → "Oct"
    return period.split(' ').first;
  }
}

// ---------------------------------------------------------------------------
// Bar chart painter widget
// ---------------------------------------------------------------------------

class _BarChartPainterWidget extends StatelessWidget {
  const _BarChartPainterWidget({required this.months});

  final List<RevenueBreakdown> months;

  @override
  Widget build(BuildContext context) {
    final maxRevenue = months.fold<double>(0, (m, b) => max(m, b.totalRevenue));

    return CustomPaint(
      painter: _StackedBarPainter(months: months, maxRevenue: maxRevenue),
      child: const SizedBox.expand(),
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter — stacked bars + Y-axis labels
// ---------------------------------------------------------------------------

class _StackedBarPainter extends CustomPainter {
  _StackedBarPainter({required this.months, required this.maxRevenue});

  final List<RevenueBreakdown> months;
  final double maxRevenue;

  static const _yAxisWidth = 40.0;
  static const _barPadding = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty || maxRevenue == 0) {
      return;
    }

    final chartWidth = size.width - _yAxisWidth;
    final chartHeight = size.height;

    _drawYAxisLabels(canvas, size, chartHeight);
    _drawBars(canvas, chartWidth, chartHeight);
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double chartHeight) {
    const steps = 4;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= steps; i++) {
      final fraction = i / steps;
      final value = maxRevenue * fraction;
      final y = chartHeight - chartHeight * fraction;

      // Grid line
      final gridPaint = Paint()
        ..color = AppColors.neutral200
        ..strokeWidth = 0.5;
      canvas.drawLine(Offset(_yAxisWidth, y), Offset(size.width, y), gridPaint);

      // Y label
      textPainter.text = TextSpan(
        text: _shortInr(value),
        style: const TextStyle(
          fontSize: 9,
          color: AppColors.neutral400,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout(maxWidth: _yAxisWidth - 4);
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }
  }

  void _drawBars(Canvas canvas, double chartWidth, double chartHeight) {
    final barGroupWidth = chartWidth / months.length;

    for (var i = 0; i < months.length; i++) {
      final month = months[i];
      final groupLeft = _yAxisWidth + i * barGroupWidth + _barPadding;
      final barWidth = barGroupWidth - _barPadding * 2;
      final segments = _segmentsFor(month);

      var currentY = chartHeight;

      for (final seg in segments) {
        if (seg.value <= 0) continue;
        final barH = (seg.value / maxRevenue) * chartHeight;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(groupLeft, currentY - barH, barWidth, barH),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, Paint()..color = seg.color);
        currentY -= barH;
      }
    }
  }

  List<_Segment> _segmentsFor(RevenueBreakdown month) {
    return [
      _Segment(month.otherRevenue, _serviceColors['Other']!),
      _Segment(month.advisoryRevenue, _serviceColors['Advisory']!),
      _Segment(month.auditRevenue, _serviceColors['Audit']!),
      _Segment(month.gstRevenue, _serviceColors['GST']!),
      _Segment(month.itrRevenue, _serviceColors['ITR']!),
    ];
  }

  static String _shortInr(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    }
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(0)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  bool shouldRepaint(covariant _StackedBarPainter old) {
    return old.months != months || old.maxRevenue != maxRevenue;
  }
}

class _Segment {
  const _Segment(this.value, this.color);

  final double value;
  final Color color;
}

// ---------------------------------------------------------------------------
// Service color map (ITR, GST, Audit, Advisory, Other)
// ---------------------------------------------------------------------------

const _serviceColors = <String, Color>{
  'ITR': AppColors.primary,
  'GST': AppColors.secondary,
  'Audit': Color(0xFF7C3AED),
  'Advisory': AppColors.accent,
  'Other': AppColors.neutral300,
};
