import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/msme/domain/models/msme_vendor.dart';

/// Alert card warning about Section 43B(h) deduction forfeit risk.
///
/// Under Section 43B(h) of the Income Tax Act, payments to MSME vendors
/// must be made within 45 days (or the agreed period) to claim the expense
/// as a deduction in the current financial year.
class Section43BhAlert extends StatelessWidget {
  const Section43BhAlert({super.key, required this.vendor, this.onTap});

  final MsmeVendor vendor;
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
      color: AppColors.error.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
      ),
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
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Section 43B(h) Risk',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${vendor.daysPastDue} days overdue',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Text(
                vendor.vendorName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vendor.msmeRegistrationNumber,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _AlertDetail(
                    label: 'Outstanding',
                    value: _currencyFormat.format(vendor.outstandingAmount),
                    valueColor: AppColors.error,
                  ),
                  const SizedBox(width: 24),
                  _AlertDetail(
                    label: 'Classification',
                    value: vendor.classification.label,
                  ),
                  const SizedBox(width: 24),
                  if (vendor.oldestInvoiceDate != null)
                    _AlertDetail(
                      label: 'Oldest Invoice',
                      value: _dateFormat.format(vendor.oldestInvoiceDate!),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Deduction of ${_currencyFormat.format(vendor.outstandingAmount)} '
                  'may be disallowed under Section 43B(h) if not paid within '
                  '45 days of invoice date.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertDetail extends StatelessWidget {
  const _AlertDetail({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
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
    );
  }
}
