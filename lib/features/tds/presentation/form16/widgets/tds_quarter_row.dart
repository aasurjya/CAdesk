import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/presentation/form16/form16_currency.dart';

/// A single row in the quarterly TDS breakdown table.
class TdsQuarterRow extends StatelessWidget {
  const TdsQuarterRow({super.key, required this.detail});

  final Form16QuarterDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final depositDate = detail.dateOfDeposit != null
        ? dateFormat.format(detail.dateOfDeposit!)
        : '--';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              detail.quarter.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              detail.receiptNumbers.join(', '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatPaise(detail.taxDeposited),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              depositDate,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
