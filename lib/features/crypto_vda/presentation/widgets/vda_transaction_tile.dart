import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';

/// Tile displaying a single VDA transaction with asset icon placeholder,
/// gain/loss coloring, and TDS details.
class VdaTransactionTile extends StatelessWidget {
  const VdaTransactionTile({super.key, required this.transaction});

  final VdaTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    final isGain = transaction.gainLoss > 0;
    final isLoss = transaction.gainLoss < 0;
    final gainLossColor = isGain
        ? AppColors.success
        : isLoss
            ? AppColors.error
            : AppColors.neutral600;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: asset icon + name + transaction type badge
            Row(
              children: [
                _AssetIconPlaceholder(assetType: transaction.assetType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.assetName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${transaction.clientName} '
                        '\u2022 ${dateFormat.format(transaction.transactionDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                _TransactionTypeBadge(type: transaction.transactionType),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Detail row: quantity, buy, sell, gain/loss
            Row(
              children: [
                _DetailColumn(
                  label: 'Qty',
                  value: transaction.quantity.toStringAsFixed(
                    transaction.quantity == transaction.quantity.roundToDouble()
                        ? 0
                        : 4,
                  ),
                ),
                _DetailColumn(
                  label: 'Buy Price',
                  value: currencyFormat.format(transaction.buyPrice),
                ),
                _DetailColumn(
                  label: 'Sell Price',
                  value: transaction.sellPrice > 0
                      ? currencyFormat.format(transaction.sellPrice)
                      : '--',
                ),
                _DetailColumn(
                  label: 'Gain / Loss',
                  value: transaction.gainLoss != 0
                      ? '${isGain ? '+' : ''}'
                          '${currencyFormat.format(transaction.gainLoss)}'
                      : '--',
                  valueColor: gainLossColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tax row
            Row(
              children: [
                _DetailColumn(
                  label: 'Tax @30%',
                  value: transaction.taxAt30Percent > 0
                      ? currencyFormat.format(transaction.taxAt30Percent)
                      : '--',
                  valueColor: transaction.taxAt30Percent > 0
                      ? AppColors.error
                      : null,
                ),
                _DetailColumn(
                  label: 'TDS u/s 194S',
                  value: transaction.tdsUnder194S > 0
                      ? currencyFormat.format(transaction.tdsUnder194S)
                      : '--',
                ),
                _DetailColumn(
                  label: 'Exchange',
                  value: transaction.exchange,
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
            // Remarks
            if (transaction.remarks != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        transaction.remarks!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontStyle: FontStyle.italic,
                        ),
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
}

/// Circular placeholder for asset type icon.
class _AssetIconPlaceholder extends StatelessWidget {
  const _AssetIconPlaceholder({required this.assetType});

  final VdaAssetType assetType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryVariant.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        assetType.icon,
        size: 20,
        color: AppColors.primaryVariant,
      ),
    );
  }
}

/// Small colored badge for transaction type.
class _TransactionTypeBadge extends StatelessWidget {
  const _TransactionTypeBadge({required this.type});

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

/// Small label + value column used inside the detail rows.
class _DetailColumn extends StatelessWidget {
  const _DetailColumn({
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
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.neutral900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
