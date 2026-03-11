import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing.dart';

/// A card tile displaying a single FEMA filing with form type badge and status.
class FemaFilingTile extends StatelessWidget {
  const FemaFilingTile({super.key, required this.filing});

  final FemaFiling filing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final amountFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: filing.currency == 'USD'
          ? '\$'
          : filing.currency == 'EUR'
              ? '\u20AC'
              : '\u20B9',
      decimalDigits: 1,
    );

    final isOverdue = filing.status != FemaFilingStatus.approved &&
        filing.status != FemaFilingStatus.rejected &&
        filing.dueDate.isBefore(DateTime(2026, 3, 10));

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
              // Top row: client name and amount
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
                  Text(
                    amountFormat.format(filing.amount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Middle row: form type badge, status badge, AD bank
              Row(
                children: [
                  _FormTypeBadge(formType: filing.formType),
                  const SizedBox(width: 8),
                  _StatusBadge(status: filing.status),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Bottom row: dates and AD bank
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
                      color: isOverdue ? AppColors.error : AppColors.neutral400,
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (filing.adBankName != null) ...[
                    Icon(
                      Icons.account_balance_rounded,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      filing.adBankName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),

              // Reference number if present
              if (filing.referenceNumber != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ref: ${filing.referenceNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge showing the FEMA form type.
class _FormTypeBadge extends StatelessWidget {
  const _FormTypeBadge({required this.formType});

  final FemaFormType formType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        formType.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Badge showing the filing status with color.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final FemaFilingStatus status;

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
