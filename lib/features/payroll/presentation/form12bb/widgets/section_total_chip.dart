import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Compact chip displaying a section subtotal formatted as Indian currency.
class SectionTotalChip extends StatelessWidget {
  const SectionTotalChip({
    super.key,
    required this.label,
    required this.amountPaise,
  });

  /// Section label, e.g. "HRA", "Chapter VI-A".
  final String label;

  /// Amount in paise.
  final int amountPaise;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final rupees = amountPaise ~/ 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            formatter.format(rupees),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
