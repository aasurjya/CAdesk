import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_filing.dart';

/// A card tile displaying a Form 3CEB filing with transaction summary.
class TpFilingTile extends StatelessWidget {
  const TpFilingTile({super.key, required this.filing});

  final TpFiling filing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final amountFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 1,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: client name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      filing.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: filing.status),
                ],
              ),
              const SizedBox(height: 6),

              // AY and certifying CA
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'AY ${filing.assessmentYear}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filing.certifyingCA,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Transaction summary
              _TransactionSummary(
                transactionCount: filing.internationalTransactions.length,
                totalAlp: amountFormat.format(filing.totalAlpValue),
                totalActual: amountFormat.format(filing.totalActualValue),
                totalAdjustment: amountFormat.format(filing.totalAdjustment),
              ),
              const SizedBox(height: 10),

              // Date row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${dateFormat.format(filing.dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  if (filing.filingDate != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filed: ${dateFormat.format(filing.filingDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact transaction summary showing counts and totals.
class _TransactionSummary extends StatelessWidget {
  const _TransactionSummary({
    required this.transactionCount,
    required this.totalAlp,
    required this.totalActual,
    required this.totalAdjustment,
  });

  final int transactionCount;
  final String totalAlp;
  final String totalActual;
  final String totalAdjustment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 14,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 4),
              Text(
                '$transactionCount International Transaction${transactionCount == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SummaryMetric(label: 'ALP Value', value: totalAlp),
              const SizedBox(width: 12),
              _SummaryMetric(label: 'Actual', value: totalActual),
              const SizedBox(width: 12),
              _SummaryMetric(
                label: 'Adjustment',
                value: totalAdjustment,
                valueColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small labeled metric in the transaction summary.
class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge for TP filing.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TpFilingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
