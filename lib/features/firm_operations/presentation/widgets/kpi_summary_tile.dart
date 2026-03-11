import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/firm_operations/domain/models/staff_kpi.dart';

/// Displays a KPI record with sparkline-style metric indicators.
class KpiSummaryTile extends StatelessWidget {
  const KpiSummaryTile({super.key, required this.kpi});

  final StaffKpi kpi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    kpi.staffName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kpi.period,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Metric bars
            Row(
              children: [
                Expanded(
                  child: _SparklineMetric(
                    label: 'Utilization',
                    value: kpi.utilizationRate,
                    color: _rateColor(kpi.utilizationRate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SparklineMetric(
                    label: 'Realization',
                    value: kpi.realizationRate,
                    color: _rateColor(kpi.realizationRate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SparklineMetric(
                    label: 'Tasks',
                    value: kpi.taskCompletionRate,
                    color: _rateColor(kpi.taskCompletionRate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom stats row
            Row(
              children: [
                _StatChip(
                  icon: Icons.timer_outlined,
                  label: '${kpi.billableHours.toInt()}/${kpi.totalHours.toInt()} hrs',
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.task_alt_rounded,
                  label: '${kpi.tasksCompleted}/${kpi.tasksAssigned} tasks',
                  color: AppColors.accent,
                ),
                const Spacer(),
                _QualityBadge(score: kpi.qualityScore),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _rateColor(double rate) {
    if (rate >= 0.80) return AppColors.success;
    if (rate >= 0.60) return AppColors.warning;
    return AppColors.error;
  }
}

/// A small progress bar with label and percentage.
class _SparklineMetric extends StatelessWidget {
  const _SparklineMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 10,
              ),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Small icon + label chip.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}

/// Quality score badge with color coding.
class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = score >= 90
        ? AppColors.success
        : score >= 75
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${score.toInt()}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
