import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../domain/models/interest_calculation.dart';

/// Tile showing an interest calculation with section label,
/// principal, computed vs actual interest, and variance highlight.
///
/// Green background = calculation matches (isCorrect = true).
/// Red border = discrepancy found (isCorrect = false).
class InterestCalculationTile extends StatelessWidget {
  const InterestCalculationTile({super.key, required this.calc, this.onTap});

  final InterestCalculation calc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = calc.isCorrect;
    final borderColor = isCorrect
        ? AppColors.success.withValues(alpha: 0.30)
        : AppColors.error.withValues(alpha: 0.40);
    final bgColor = isCorrect
        ? AppColors.success.withValues(alpha: 0.04)
        : AppColors.error.withValues(alpha: 0.04);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: isCorrect ? 1.0 : 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: client name + correctness icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      calc.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 20,
                    color: isCorrect ? AppColors.success : AppColors.error,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Section full label
              Text(
                calc.section.fullLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _sectionColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              // Detail grid
              _DetailGrid(calc: calc),

              const SizedBox(height: 8),

              // Variance row
              _VarianceRow(calc: calc),
            ],
          ),
        ),
      ),
    );
  }

  Color get _sectionColor {
    switch (calc.section) {
      case InterestSection.section234B:
        return AppColors.error;
      case InterestSection.section234C:
        return AppColors.warning;
      case InterestSection.section234D:
        return AppColors.accent;
      case InterestSection.section220_2:
        return AppColors.primaryVariant;
      case InterestSection.section244A:
        return AppColors.secondary;
    }
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.calc});

  final InterestCalculation calc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Cell(
          label: 'Principal',
          value: CurrencyUtils.formatINRCompact(calc.principal),
          color: AppColors.primary,
        ),
        const _Separator(),
        _Cell(
          label: 'Rate',
          value: '${calc.rate}% p.m.',
          color: AppColors.neutral600,
        ),
        const _Separator(),
        _Cell(
          label: 'Period',
          value: '${calc.period} mo',
          color: AppColors.neutral600,
        ),
        const _Separator(),
        _Cell(
          label: 'Computed',
          value: CurrencyUtils.formatINRCompact(calc.calculatedInterest),
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _VarianceRow extends StatelessWidget {
  const _VarianceRow({required this.calc});

  final InterestCalculation calc;

  @override
  Widget build(BuildContext context) {
    final isCorrect = calc.isCorrect;
    final varianceColor = isCorrect ? AppColors.success : AppColors.error;
    final varianceLabel = calc.variance < 0
        ? 'Over-charged by dept'
        : calc.variance > 0
        ? 'Under-charged'
        : 'Matches exactly';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: varianceColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            size: 14,
            color: varianceColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              varianceLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: varianceColor,
              ),
            ),
          ),
          if (!isCorrect) ...[
            Text(
              'As per order: ${CurrencyUtils.formatINRCompact(calc.actualInterest)}',
              style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
            ),
            const SizedBox(width: 8),
            Text(
              'Variance: ${CurrencyUtils.formatINRCompact(calc.variance.abs())}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: varianceColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.neutral200,
    );
  }
}
