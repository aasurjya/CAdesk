import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/analytics/domain/models/aging_receivable.dart';

/// A simple horizontal bar chart showing receivable amounts by aging bucket.
class AgingBar extends StatelessWidget {
  const AgingBar({
    super.key,
    required this.bucketTotals,
    required this.grandTotal,
  });

  /// Amounts keyed by aging bucket.
  final Map<AgingBucket, double> bucketTotals;

  /// Sum of all receivables (used to compute bar widths).
  final double grandTotal;

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
              'Receivables Aging',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total outstanding: ${_formatAmount(grandTotal)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            ...AgingBucket.values.map(
              (bucket) => _BucketRow(
                bucket: bucket,
                amount: bucketTotals[bucket] ?? 0,
                maxAmount: grandTotal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class _BucketRow extends StatelessWidget {
  const _BucketRow({
    required this.bucket,
    required this.amount,
    required this.maxAmount,
  });

  final AgingBucket bucket;
  final double amount;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxAmount > 0 ? (amount / maxAmount).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bucket.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                _formatInr(amount),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * fraction;
              return Container(
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: barWidth,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _bucketColor(bucket),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Color _bucketColor(AgingBucket bucket) {
    switch (bucket) {
      case AgingBucket.current:
        return AppColors.success;
      case AgingBucket.days30:
        return AppColors.secondary;
      case AgingBucket.days60:
        return AppColors.accent;
      case AgingBucket.days90:
        return const Color(0xFFE65100);
      case AgingBucket.over90:
        return AppColors.error;
    }
  }

  static String _formatInr(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}
