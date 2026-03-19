import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';

/// Visual salary breakdown showing earnings vs deductions
/// as a horizontal stacked bar with legend.
class SalaryBreakdownChart extends StatelessWidget {
  const SalaryBreakdownChart({
    super.key,
    required this.basic,
    required this.hra,
    required this.allowances,
    required this.deductions,
  });

  final double basic;
  final double hra;
  final double allowances;
  final double deductions;

  double get _totalEarnings => basic + hra + allowances;
  double get _grandTotal => _totalEarnings + deductions;
  double get _netPay => _totalEarnings - deductions;

  @override
  Widget build(BuildContext context) {
    if (_grandTotal <= 0) return const SizedBox.shrink();

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
            // Title + net pay
            Row(
              children: [
                const Text(
                  'Salary Breakdown',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.neutral900,
                  ),
                ),
                const Spacer(),
                Text(
                  'Net: ${CurrencyUtils.formatINRCompact(_netPay)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Stacked bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    if (basic > 0)
                      _BarSegment(
                        fraction: basic / _grandTotal,
                        color: AppColors.primary,
                      ),
                    if (hra > 0)
                      _BarSegment(
                        fraction: hra / _grandTotal,
                        color: AppColors.secondary,
                      ),
                    if (allowances > 0)
                      _BarSegment(
                        fraction: allowances / _grandTotal,
                        color: AppColors.primaryVariant,
                      ),
                    if (deductions > 0)
                      _BarSegment(
                        fraction: deductions / _grandTotal,
                        color: AppColors.error,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (basic > 0)
                  _LegendItem(
                    label: 'Basic',
                    value: CurrencyUtils.formatINRCompact(basic),
                    color: AppColors.primary,
                  ),
                if (hra > 0)
                  _LegendItem(
                    label: 'HRA',
                    value: CurrencyUtils.formatINRCompact(hra),
                    color: AppColors.secondary,
                  ),
                if (allowances > 0)
                  _LegendItem(
                    label: 'Allowances',
                    value: CurrencyUtils.formatINRCompact(allowances),
                    color: AppColors.primaryVariant,
                  ),
                if (deductions > 0)
                  _LegendItem(
                    label: 'Deductions',
                    value: CurrencyUtils.formatINRCompact(deductions),
                    color: AppColors.error,
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
// Bar segment
// ---------------------------------------------------------------------------

class _BarSegment extends StatelessWidget {
  const _BarSegment({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (fraction * 1000).round().clamp(1, 1000),
      child: Container(color: color),
    );
  }
}

// ---------------------------------------------------------------------------
// Legend item
// ---------------------------------------------------------------------------

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}
