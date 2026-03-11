import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/time_tracking/domain/models/billing_summary.dart';

/// A card showing a client's billing stats with realization rate gauge.
class BillingSummaryCard extends StatelessWidget {
  const BillingSummaryCard({super.key, required this.summary});

  final BillingSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rateColor = summary.realizationRate >= 90
        ? AppColors.success
        : summary.realizationRate >= 75
        ? AppColors.accent
        : AppColors.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client name + period
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary.clientName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    summary.period,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Hours row
            Row(
              children: [
                _StatColumn(
                  label: 'Total',
                  value: '${summary.totalHours.toStringAsFixed(1)}h',
                  color: AppColors.neutral900,
                ),
                const SizedBox(width: 16),
                _StatColumn(
                  label: 'Billable',
                  value: '${summary.billableHours.toStringAsFixed(1)}h',
                  color: AppColors.success,
                ),
                const SizedBox(width: 16),
                _StatColumn(
                  label: 'Non-Bill.',
                  value: '${summary.nonBillableHours.toStringAsFixed(1)}h',
                  color: AppColors.neutral400,
                ),
                const Spacer(),
                // Total billed
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Billed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.formattedBilled,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Realization rate bar
            Row(
              children: [
                Text(
                  'Realization',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (summary.realizationRate / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${summary.realizationRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: rateColor,
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

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
