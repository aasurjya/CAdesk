import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A two- or three-column card showing amounts from different tax data sources
/// with the variance highlighted.
///
/// Used on the detail screen to show side-by-side comparisons between
/// 26AS, AIS, and ITR values.
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({
    super.key,
    required this.title,
    required this.columns,
  });

  /// Section title (e.g. "Salary — Infosys Ltd").
  final String title;

  /// Each column: (label, amountPaise). Provide 2 or 3 columns.
  final List<ComparisonColumn> columns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount = columns
        .map((c) => c.amountPaise)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _ColumnWidget(
                      column: columns[i],
                      isHighest: columns[i].amountPaise == maxAmount,
                      hasDifference: _hasDifference,
                    ),
                  ),
                ],
              ],
            ),
            if (_hasDifference) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Variance: ${_formatPaise(_variance.abs())}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasDifference {
    if (columns.length < 2) return false;
    final amounts = columns.map((c) => c.amountPaise).toSet();
    return amounts.length > 1;
  }

  int get _variance {
    if (columns.length < 2) return 0;
    return columns.first.amountPaise - columns.last.amountPaise;
  }

  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    if (rupees >= 10000000) {
      return '${(rupees / 10000000).toStringAsFixed(2)} Cr';
    }
    if (rupees >= 100000) {
      return '${(rupees / 100000).toStringAsFixed(2)} L';
    }
    if (rupees >= 1000) {
      return '${(rupees / 1000).toStringAsFixed(1)} K';
    }
    return rupees.toString();
  }
}

/// A single column in a [ComparisonCard].
class ComparisonColumn {
  const ComparisonColumn({
    required this.label,
    required this.amountPaise,
  });

  final String label;
  final int amountPaise;
}

class _ColumnWidget extends StatelessWidget {
  const _ColumnWidget({
    required this.column,
    required this.isHighest,
    required this.hasDifference,
  });

  final ComparisonColumn column;
  final bool isHighest;
  final bool hasDifference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isZero = column.amountPaise == 0;
    final amountColor = isZero
        ? AppColors.error
        : (hasDifference && !isHighest)
            ? AppColors.warning
            : AppColors.neutral900;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isZero
            ? AppColors.error.withAlpha(8)
            : AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isZero ? AppColors.error.withAlpha(40) : AppColors.neutral100,
        ),
      ),
      child: Column(
        children: [
          Text(
            column.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isZero ? 'N/A' : _formatInr(column.amountPaise),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatInr(int paise) {
    final rupees = paise ~/ 100;
    // Indian number formatting
    if (rupees >= 10000000) {
      return '${(rupees / 10000000).toStringAsFixed(2)} Cr';
    }
    if (rupees >= 100000) {
      return '${(rupees / 100000).toStringAsFixed(2)} L';
    }
    if (rupees >= 1000) {
      return '${(rupees / 1000).toStringAsFixed(1)}K';
    }
    return '$rupees';
  }
}
