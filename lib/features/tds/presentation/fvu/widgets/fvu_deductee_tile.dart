import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';

/// List tile displaying a single FVU deductee record.
///
/// Shows PAN, name, section code, amount paid, TDS deducted, date,
/// and a status badge indicating validity based on pre-scrutiny.
class FvuDeducteeTile extends StatelessWidget {
  const FvuDeducteeTile({super.key, required this.record, this.isValid = true});

  final FvuDeducteeRecord record;

  /// Whether this record passed pre-scrutiny validation.
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
            // Row 1: Name + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.deducteeName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(isValid: isValid),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: PAN + Section + Date
            Row(
              children: [
                _InfoChip(
                  label: record.hasPan ? record.pan : 'NO PAN',
                  color: record.hasPan ? AppColors.neutral600 : AppColors.error,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  label: 'Sec ${record.sectionCode}',
                  color: AppColors.secondary,
                  icon: Icons.gavel_rounded,
                ),
                const Spacer(),
                Text(
                  _formatDate(record.dateOfPayment),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 3: Amount paid + TDS deducted
            Row(
              children: [
                _AmountColumn(
                  label: 'Amount Paid',
                  value: CurrencyUtils.formatINRCompact(record.amountPaid),
                  theme: theme,
                ),
                const SizedBox(width: 24),
                _AmountColumn(
                  label: 'TDS Deducted',
                  value: CurrencyUtils.formatINRCompact(record.tdsAmount),
                  theme: theme,
                  valueColor: AppColors.primary,
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
