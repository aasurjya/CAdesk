import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/vda/domain/models/vda_transaction.dart';

/// Tile widget displaying a single VDA transaction.
///
/// Shows: asset name, buy/sell period, amount, gain/loss, TDS deducted.
class VdaTransactionTile extends StatelessWidget {
  const VdaTransactionTile({super.key, required this.transaction});

  final VdaTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gain = transaction.gainPaise;
    final isProfit = gain >= 0;
    final gainColor = isProfit ? AppColors.success : AppColors.error;
    final tds = transaction.saleConsiderationPaise ~/ 100; // 1% TDS

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.assetName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: gainColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isProfit ? '+${_formatPaise(gain)}' : _formatPaise(gain),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: gainColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MetaLabel(
                  label: 'Buy',
                  value: _formatDate(transaction.acquisitionDate),
                ),
                const SizedBox(width: 16),
                _MetaLabel(
                  label: 'Sell',
                  value: _formatDate(transaction.transferDate),
                ),
                const SizedBox(width: 16),
                _MetaLabel(
                  label: 'Period',
                  value: transaction.period == VdaPeriod.shortTerm
                      ? 'Short-term'
                      : 'Long-term',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetaLabel(
                    label: 'Cost',
                    value: _formatPaise(transaction.acquisitionCostPaise),
                  ),
                ),
                Expanded(
                  child: _MetaLabel(
                    label: 'Sale',
                    value: _formatPaise(transaction.saleConsiderationPaise),
                  ),
                ),
                Expanded(
                  child: _MetaLabel(
                    label: 'TDS (1%)',
                    value: _formatPaise(tds),
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({required this.label, required this.value});

  final String label;
  final String value;

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
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _formatPaise(int paise) {
  final rupees = paise ~/ 100;
  final isNegative = rupees < 0;
  final absRupees = rupees.abs();

  if (absRupees >= 10000000) {
    final cr = absRupees / 10000000;
    final prefix = isNegative ? '-' : '';
    return '$prefix$_inrSymbol${cr.toStringAsFixed(2)} Cr';
  }
  if (absRupees >= 100000) {
    final lakh = absRupees / 100000;
    final prefix = isNegative ? '-' : '';
    return '$prefix$_inrSymbol${lakh.toStringAsFixed(2)} L';
  }
  if (absRupees >= 1000) {
    final k = absRupees / 1000;
    final prefix = isNegative ? '-' : '';
    return '$prefix$_inrSymbol${k.toStringAsFixed(1)}K';
  }
  final prefix = isNegative ? '-' : '';
  return '$prefix$_inrSymbol$absRupees';
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

const _inrSymbol = '\u20B9';
