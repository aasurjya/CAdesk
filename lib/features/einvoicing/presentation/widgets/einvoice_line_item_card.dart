import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/einvoicing/data/providers/einvoice_form_providers.dart';

/// Card displaying a single line item in an e-invoice.
///
/// Shows HSN code badge, description, quantity x rate = amount,
/// tax breakdown row, and edit/delete action buttons.
class EinvoiceLineItemCard extends StatelessWidget {
  const EinvoiceLineItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.readOnly = false,
  });

  final EinvoiceLineItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            // Row 1: HSN badge + description
            Row(
              children: [
                if (item.hsnCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.secondary.withAlpha(51),
                      ),
                    ),
                    child: Text(
                      item.hsnCode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                if (item.hsnCode.isNotEmpty) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.description,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!readOnly) ...[
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: onDelete,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: qty x rate = amount
            Row(
              children: [
                Text(
                  '${item.quantity} ${item.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'x',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  CurrencyUtils.formatINR(item.rate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                if (item.discount > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(-${CurrencyUtils.formatINRCompact(item.discount)})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  CurrencyUtils.formatINR(item.taxableValue),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Row 3: Tax breakdown
            _TaxBreakdownRow(item: item),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _TaxBreakdownRow extends StatelessWidget {
  const _TaxBreakdownRow({required this.item});

  final EinvoiceLineItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInterState = item.igstAmount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_rounded,
            size: 12,
            color: AppColors.neutral400,
          ),
          const SizedBox(width: 4),
          if (isInterState)
            Text(
              'IGST ${item.igstRate.toStringAsFixed(1)}%: '
              '${CurrencyUtils.formatINRCompact(item.igstAmount)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            )
          else ...[
            Text(
              'CGST ${item.cgstRate.toStringAsFixed(1)}%: '
              '${CurrencyUtils.formatINRCompact(item.cgstAmount)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SGST ${item.sgstRate.toStringAsFixed(1)}%: '
              '${CurrencyUtils.formatINRCompact(item.sgstAmount)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          Text(
            'Tax: ${CurrencyUtils.formatINRCompact(item.cgstAmount + item.sgstAmount + item.igstAmount)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
