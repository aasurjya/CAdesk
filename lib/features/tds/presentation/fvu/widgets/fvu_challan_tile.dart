import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';

/// List tile displaying a single FVU challan record.
///
/// Shows BSR code, challan serial, deposit date, amount, TDS deposited,
/// and a status badge indicating validity based on pre-scrutiny.
class FvuChallanTile extends StatelessWidget {
  const FvuChallanTile({super.key, required this.record, this.isValid = true});

  final FvuChallanRecord record;

  /// Whether this challan passed pre-scrutiny validation.
  final bool isValid;

  String _formatDate(String ddmmyyyy) {
    if (ddmmyyyy.length != 8) return ddmmyyyy;
    return '${ddmmyyyy.substring(0, 2)}/'
        '${ddmmyyyy.substring(2, 4)}/'
        '${ddmmyyyy.substring(4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isValid ? AppColors.neutral200 : AppColors.error.withAlpha(77),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: BSR code + serial + status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(13),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'BSR ${record.bsrCode}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${record.challanSerialNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _StatusBadge(isValid: isValid),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: Section + Date + Deductees
            Row(
              children: [
                Icon(Icons.gavel_rounded, size: 13, color: AppColors.secondary),
                const SizedBox(width: 3),
                Text(
                  'Sec ${record.sectionCode}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 3),
                Text(
                  _formatDate(record.challanTenderDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${record.deducteeCount} deductees',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 3: Amount
            Row(
              children: [
                Text(
                  'Tax Deposited: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                Text(
                  CurrencyUtils.formatINRCompact(record.totalTaxDeposited),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isValid});

  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final color = isValid ? AppColors.success : AppColors.error;
    final label = isValid ? 'Valid' : 'Invalid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
