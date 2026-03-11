import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_schedule_sheet.dart';

/// Scrollable list of VDA transactions inside the Schedule VDA sheet.
class VdaScheduleTransactionList extends StatelessWidget {
  const VdaScheduleTransactionList({super.key, required this.transactions});

  final List<VdaTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transactions (${transactions.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...transactions.map(
          (VdaTransaction t) => _ScheduleTransactionTile(transaction: t),
        ),
      ],
    );
  }
}

class _ScheduleTransactionTile extends StatelessWidget {
  const _ScheduleTransactionTile({required this.transaction});

  final VdaTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double gain = transaction.sellPrice - transaction.buyPrice;
    final bool isGain = gain > 0;
    final bool isLoss = gain < 0;
    final Color gainColor = isGain
        ? AppColors.success
        : isLoss
        ? AppColors.error
        : AppColors.neutral400;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.assetName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _TxnTypeBadge(type: transaction.transactionType),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${transaction.exchange}  •  ${_date(transaction.transactionDate)}'
              '  •  Qty: ${transaction.quantity}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniStat(
                  label: 'Sale Value',
                  value: transaction.sellPrice > 0
                      ? VdaScheduleSummaryCard.formatAmount(
                          transaction.sellPrice,
                        )
                      : '--',
                ),
                _MiniStat(
                  label: 'Gain / Loss',
                  value: gain != 0
                      ? '${isGain ? '+' : ''}'
                            '${VdaScheduleSummaryCard.formatAmount(gain.abs())}'
                      : '--',
                  color: gainColor,
                ),
                if (isLoss) _DisallowedChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year}';

  static String _month(int m) => const <String>[
    '',
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
  ][m];
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
              color: color ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxnTypeBadge extends StatelessWidget {
  const _TxnTypeBadge({required this.type});

  final VdaTransactionType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: type.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DisallowedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'disallowed',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.error, fontSize: 9),
      ),
    );
  }
}
