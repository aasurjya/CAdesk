import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';

/// Color for each invoice status badge.
Color _statusColor(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return AppColors.neutral600;
    case InvoiceStatus.sent:
      return AppColors.primaryVariant;
    case InvoiceStatus.partial:
      return AppColors.warning;
    case InvoiceStatus.paid:
      return AppColors.success;
    case InvoiceStatus.overdue:
      return AppColors.error;
    case InvoiceStatus.cancelled:
      return AppColors.neutral400;
  }
}

/// List tile for a single [Invoice].
class InvoiceTile extends StatelessWidget {
  const InvoiceTile({super.key, required this.invoice, this.onTap});

  final Invoice invoice;
  final VoidCallback? onTap;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(invoice.status);
    final isOverdue = invoice.status == InvoiceStatus.overdue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isOverdue
              ? AppColors.error.withValues(alpha: 0.4)
              : AppColors.neutral200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: invoice number + status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.invoiceNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (invoice.isRecurring) ...[
                    const Icon(
                      Icons.repeat_rounded,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  _StatusBadge(status: invoice.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 6),

              // Client name
              Text(
                invoice.clientName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),

              // Amount row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grand Total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currency.format(invoice.grandTotal),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (invoice.balanceDue > 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance Due',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currency.format(invoice.balanceDue),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isOverdue
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Due Date',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dateFormat.format(invoice.dueDate),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue
                              ? AppColors.error
                              : AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final InvoiceStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
