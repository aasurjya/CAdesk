import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/msme/domain/models/msme_payment.dart';

/// A list tile displaying an MSME payment record with 45-day compliance
/// indicator.
class MsmePaymentTile extends StatelessWidget {
  const MsmePaymentTile({super.key, required this.payment, this.onTap});

  final MsmePayment payment;
  final VoidCallback? onTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ComplianceIndicator(isWithin45Days: payment.isWithin45Days),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      payment.vendorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: payment.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.receipt_long,
                    label: payment.invoiceNumber,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: _dateFormat.format(payment.invoiceDate),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    _currencyFormat.format(payment.invoiceAmount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${payment.daysToPay} days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: payment.isWithin45Days
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (payment.penaltyInterest > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Penalty: ${_currencyFormat.format(payment.penaltyInterest)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
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

class _ComplianceIndicator extends StatelessWidget {
  const _ComplianceIndicator({required this.isWithin45Days});

  final bool isWithin45Days;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWithin45Days ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MsmePaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case MsmePaymentStatus.paidOnTime:
        return AppColors.success;
      case MsmePaymentStatus.paidLate:
        return AppColors.warning;
      case MsmePaymentStatus.overdue:
        return AppColors.error;
      case MsmePaymentStatus.disputed:
        return AppColors.accent;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.neutral400),
        ),
      ],
    );
  }
}
