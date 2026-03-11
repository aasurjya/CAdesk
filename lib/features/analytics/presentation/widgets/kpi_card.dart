import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/analytics/domain/models/kpi_metric.dart';

/// A card displaying a single KPI metric with trend arrow and progress bar.
class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.metric});

  final KpiMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _categoryColor(metric.category).withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                metric.category.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _categoryColor(metric.category),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Metric name
            Text(
              metric.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Current value + trend
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    _formatValue(metric.currentValue, metric.unit),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _TrendBadge(metric: metric),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            _ProgressIndicator(fraction: metric.progressFraction),
            const SizedBox(height: 4),
            // Target label
            Text(
              'Target: ${_formatValue(metric.target, metric.unit)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _categoryColor(KpiCategory category) {
    switch (category) {
      case KpiCategory.firm:
        return AppColors.primary;
      case KpiCategory.engagement:
        return AppColors.secondary;
      case KpiCategory.compliance:
        return AppColors.accent;
      case KpiCategory.staff:
        return const Color(0xFF7C3AED);
    }
  }

  static String _formatValue(double value, String unit) {
    if (unit == '₹') {
      if (value >= 100000) {
        final lakhs = value / 100000;
        return '₹${lakhs.toStringAsFixed(1)}L';
      }
      return '₹${value.toStringAsFixed(0)}';
    }
    if (unit == '%') {
      return '${value.toStringAsFixed(0)}%';
    }
    if (unit == 'days') {
      return '${value.toStringAsFixed(1)} days';
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.metric});

  final KpiMetric metric;

  @override
  Widget build(BuildContext context) {
    final isPositive = _isTrendPositive(metric);
    final color = metric.trend == KpiTrend.flat
        ? AppColors.neutral400
        : isPositive
            ? AppColors.success
            : AppColors.error;
    final icon = metric.trend == KpiTrend.up
        ? Icons.trending_up_rounded
        : metric.trend == KpiTrend.down
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    final percent = metric.changePercent.abs().toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '$percent%',
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

  /// Whether the trend direction is positive for this metric.
  /// For "Overdue Tasks" and "Outstanding Receivables", up is negative.
  static bool _isTrendPositive(KpiMetric metric) {
    final inverseMetrics = {'kpi-06', 'kpi-09', 'kpi-12'};
    final isInverse = inverseMetrics.contains(metric.id);
    if (metric.trend == KpiTrend.up) return !isInverse;
    if (metric.trend == KpiTrend.down) return isInverse;
    return true;
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final color = fraction >= 0.8
        ? AppColors.success
        : fraction >= 0.5
            ? AppColors.accent
            : AppColors.error;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 6,
        backgroundColor: AppColors.neutral200,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
