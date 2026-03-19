import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../domain/models/employee.dart';

/// Data class for a single line item in a payslip section.
class PayslipLineItem {
  const PayslipLineItem(this.label, this.amount);
  final String label;
  final double amount;
}

/// Employee header card for the payslip detail screen.
class PayslipEmployeeHeader extends StatelessWidget {
  const PayslipEmployeeHeader({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                employee.name.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${employee.employeeCode} | ${employee.designation}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                  Text(
                    '${employee.department} | PAN: ${employee.pan}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Earnings/Deductions/Employer contributions section card.
class PayslipSection extends StatelessWidget {
  const PayslipSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.total,
    required this.totalLabel,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<PayslipLineItem> items;
  final double total;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatINR(item.amount),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  CurrencyUtils.formatINR(total),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

/// Net pay highlight card.
class PayslipNetPayCard extends StatelessWidget {
  const PayslipNetPayCard({super.key, required this.netPay});

  final double netPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryVariant],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Net Pay',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.formatINR(netPay),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// YTD summary section (estimated from current month).
class PayslipYtdSection extends StatelessWidget {
  const PayslipYtdSection({
    super.key,
    required this.grossPaid,
    required this.pfDeducted,
    required this.tdsDeducted,
    required this.netPaid,
    required this.month,
  });

  final double grossPaid;
  final double pfDeducted;
  final double tdsDeducted;
  final double netPaid;
  final int month;

  int get _monthsElapsed => month >= 4 ? month - 3 : month + 9;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Year-to-Date Summary (Estimated)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            _YtdRow(
              'YTD Gross',
              CurrencyUtils.formatINRCompact(grossPaid * _monthsElapsed),
            ),
            _YtdRow(
              'YTD PF',
              CurrencyUtils.formatINRCompact(pfDeducted * _monthsElapsed),
            ),
            _YtdRow(
              'YTD TDS',
              CurrencyUtils.formatINRCompact(tdsDeducted * _monthsElapsed),
            ),
            _YtdRow(
              'YTD Net',
              CurrencyUtils.formatINRCompact(netPaid * _monthsElapsed),
            ),
          ],
        ),
      ),
    );
  }
}

class _YtdRow extends StatelessWidget {
  const _YtdRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Action row for Form 16, Download, Share.
class PayslipActionRow extends StatelessWidget {
  const PayslipActionRow({
    super.key,
    required this.onForm16,
    required this.onDownload,
    required this.onShare,
  });

  final VoidCallback onForm16;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onForm16,
            icon: const Icon(Icons.description_rounded, size: 16),
            label: const Text('Form 16'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              textStyle: const TextStyle(fontSize: 11),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              textStyle: const TextStyle(fontSize: 11),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              textStyle: const TextStyle(fontSize: 11),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
