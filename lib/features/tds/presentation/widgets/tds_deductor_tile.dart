import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';

/// A list tile showing deductor info, TAN, quarterly filing status dots,
/// and the total tax deducted amount for the selected form type and FY.
class TdsDeductorTile extends ConsumerWidget {
  const TdsDeductorTile({super.key, required this.deductor, this.onTap});

  final TdsDeductor deductor;

  /// Optional tap callback. Typically opens the deductor detail bottom sheet.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tabIndex = ref.watch(selectedFormTabProvider);
    final formType = formTypeForTab(tabIndex);
    final fy = ref.watch(selectedFinancialYearProvider);
    final allReturns = ref.watch(tdsReturnsProvider);

    // Returns for this deductor, form type, and FY.
    final deductorReturns = allReturns.where(
      (r) =>
          r.deductorId == deductor.id &&
          r.formType == formType &&
          r.financialYear == fy,
    );

    // Build a map from quarter to status for the dot indicators.
    final quarterStatusMap = <TdsQuarter, TdsReturnStatus>{};
    for (final r in deductorReturns) {
      quarterStatusMap[r.quarter] = r.status;
    }

    // Total tax deducted across all quarters for this form type.
    final totalTax = deductorReturns.fold<double>(
      0,
      (sum, r) => sum + r.totalTaxDeducted,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name and amount
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deductor.deductorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyUtils.formatINRCompact(totalTax),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Bottom row: TAN, form type badge, quarter dots
              Row(
                children: [
                  // TAN
                  Text(
                    deductor.tan,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Form type chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formType.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Quarter status dots
                  _QuarterDots(quarterStatusMap: quarterStatusMap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Four dots representing Q1-Q4 filing status.
///
/// Green = filed/revised, Amber = prepared/pending, Red = overdue (pending
/// with shortfall), Grey = no return exists for that quarter.
class _QuarterDots extends StatelessWidget {
  const _QuarterDots({required this.quarterStatusMap});

  final Map<TdsQuarter, TdsReturnStatus> quarterStatusMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: TdsQuarter.values.map((q) {
        final status = quarterStatusMap[q];
        final color = _colorForStatus(status);

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Tooltip(
            message: '${q.label}: ${status?.label ?? 'Not started'}',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  q.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _colorForStatus(TdsReturnStatus? status) {
    if (status == null) return AppColors.neutral200;
    switch (status) {
      case TdsReturnStatus.filed:
      case TdsReturnStatus.revised:
        return AppColors.success;
      case TdsReturnStatus.prepared:
        return AppColors.warning;
      case TdsReturnStatus.pending:
        return AppColors.error;
    }
  }
}
