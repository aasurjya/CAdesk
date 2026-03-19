import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';
import 'package:ca_app/core/utils/currency_utils.dart';

/// A persistent bottom bar showing a running tax computation summary.
///
/// Displays three key figures — Gross Income, Deductions, and Tax Payable —
/// in a compact row. Designed to sit fixed at the bottom of the wizard
/// screen, above the navigation buttons.
class FloatingTaxBar extends StatelessWidget {
  const FloatingTaxBar({
    super.key,
    required this.grossIncome,
    required this.deductions,
    required this.taxPayable,
  });

  final double grossIncome;
  final double deductions;
  final double taxPayable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TaxFigure(
              label: 'Gross Income',
              value: grossIncome,
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _TaxFigure(
              label: 'Deductions',
              value: deductions,
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _TaxFigure(
              label: 'Tax Payable',
              value: taxPayable,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single figure column: caption label on top, bold INR value below.
class _TaxFigure extends StatelessWidget {
  const _TaxFigure({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            CurrencyUtils.formatINRCompact(value),
            key: ValueKey<double>(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Thin vertical line separating the three figures.
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: Colors.white24,
    );
  }
}
