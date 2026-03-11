import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/billing/domain/models/payment_receipt.dart';

/// Icon for each payment method.
IconData _methodIcon(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.upi:
      return Icons.qr_code_rounded;
    case PaymentMethod.bankTransfer:
      return Icons.account_balance_rounded;
    case PaymentMethod.cash:
      return Icons.payments_rounded;
    case PaymentMethod.cheque:
      return Icons.receipt_long_rounded;
    case PaymentMethod.card:
      return Icons.credit_card_rounded;
  }
}

/// Colour for each payment method icon.
Color _methodColor(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.upi:
      return const Color(0xFF4CAF50);
    case PaymentMethod.bankTransfer:
      return AppColors.primary;
    case PaymentMethod.cash:
      return AppColors.accent;
    case PaymentMethod.cheque:
      return AppColors.secondary;
    case PaymentMethod.card:
      return const Color(0xFF7B1FA2);
  }
}

/// List tile for a [PaymentReceipt].
class PaymentReceiptTile extends StatelessWidget {
  const PaymentReceiptTile({super.key, required this.receipt});

  final PaymentReceipt receipt;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _methodColor(receipt.paymentMethod);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Payment method icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _methodIcon(receipt.paymentMethod),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client + invoice number
                  Text(
                    receipt.clientName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    receipt.invoiceNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  if (receipt.referenceNumber != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.tag_rounded,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            receipt.referenceNumber!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Amount + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currency.format(receipt.amount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateFormat.format(receipt.paymentDate),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  receipt.paymentMethod.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
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
