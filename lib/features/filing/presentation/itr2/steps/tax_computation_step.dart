import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';

/// STCG (Section 111A) tax rate — 20% post Budget 2024.
const double _kStcg111ARate = 0.20;

/// LTCG (Section 112A) tax rate — 12.5% post Budget 2024.
const double _kLtcg112ARate = 0.125;

/// LTCG (Section 112A) exemption limit — 1.25 lakhs.
const double _kLtcg112AExemption = 125000.0;

/// LTCG (Section 112) tax rate for property — 20% with indexation.
const double _kLtcg112Rate = 0.20;

/// Health & Education Cess rate — 4%.
const double _kCessRate = 0.04;

/// ITR-2 tax computation step — enhanced for capital gains.
///
/// Splits into:
/// - Ordinary income tax (salary, HP, other sources minus deductions)
/// - STCG tax at 20% (Section 111A) or slab rate (other)
/// - LTCG tax at 12.5% (Section 112A over 1.25L) or 20% (Section 112)
/// - Total = ordinary + CG taxes + surcharge + cess
/// - Tax regime selection (old vs new)
class Itr2TaxComputationStep extends ConsumerWidget {
  const Itr2TaxComputationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(itr2FormDataProvider);
    final selected = formData.selectedRegime;
    final cg = formData.scheduleCg;

    // --- Ordinary income tax (simplified slab computation) ---
    final taxableOrdinary = formData.taxableOrdinaryIncome;

    final ordinaryTaxOld = _computeOldRegimeTax(taxableOrdinary);
    final ordinaryTaxNew = _computeNewRegimeTax(taxableOrdinary);

    // --- Capital gains tax ---
    final stcg111ATax = cg.netStcgAfterSetOff > 0
        ? cg.totalStcg111A.clamp(0, cg.netStcgAfterSetOff) * _kStcg111ARate
        : 0.0;

    final ltcg112AExemptedGain = cg.totalLtcg112A > _kLtcg112AExemption
        ? cg.totalLtcg112A - _kLtcg112AExemption
        : 0.0;
    final ltcg112ATax = ltcg112AExemptedGain > 0
        ? ltcg112AExemptedGain * _kLtcg112ARate
        : 0.0;

    final ltcg112Tax = cg.totalLtcgOnProperty > 0
        ? cg.totalLtcgOnProperty * _kLtcg112Rate
        : 0.0;

    final totalCgTax = stcg111ATax + ltcg112ATax + ltcg112Tax;

    // --- Total tax per regime ---
    final totalOld = ordinaryTaxOld + totalCgTax;
    final totalNew = ordinaryTaxNew + totalCgTax;

    final cessOld = totalOld * _kCessRate;
    final cessNew = totalNew * _kCessRate;

    final grandTotalOld = totalOld + cessOld;
    final grandTotalNew = totalNew + cessNew;

    final recommendedRegime = grandTotalOld <= grandTotalNew
        ? TaxRegime.oldRegime
        : TaxRegime.newRegime;
    final savings = (grandTotalOld - grandTotalNew).abs();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommendation badge
          if (savings > 0)
            _RecommendedBadge(regime: recommendedRegime, savings: savings),
          const SizedBox(height: 16),

          // Regime cards side-by-side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RegimeCard(
                  title: 'Old Regime',
                  regime: TaxRegime.oldRegime,
                  ordinaryTax: ordinaryTaxOld,
                  cgTax: totalCgTax,
                  cess: cessOld,
                  totalTax: grandTotalOld,
                  isRecommended: recommendedRegime == TaxRegime.oldRegime,
                  isSelected: selected == TaxRegime.oldRegime,
                  onSelect: () => ref
                      .read(itr2FormDataProvider.notifier)
                      .updateRegime(TaxRegime.oldRegime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RegimeCard(
                  title: 'New Regime',
                  regime: TaxRegime.newRegime,
                  ordinaryTax: ordinaryTaxNew,
                  cgTax: totalCgTax,
                  cess: cessNew,
                  totalTax: grandTotalNew,
                  isRecommended: recommendedRegime == TaxRegime.newRegime,
                  isSelected: selected == TaxRegime.newRegime,
                  onSelect: () => ref
                      .read(itr2FormDataProvider.notifier)
                      .updateRegime(TaxRegime.newRegime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // CG breakdown
          _CgBreakdownCard(
            stcg111ATax: stcg111ATax,
            ltcg112ATax: ltcg112ATax,
            ltcg112Tax: ltcg112Tax,
            totalCgTax: totalCgTax,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Old regime slab computation (AY 2026-27)
  // -------------------------------------------------------------------------

  double _computeOldRegimeTax(double taxableIncome) {
    if (taxableIncome <= 250000) return 0;
    double tax = 0;
    if (taxableIncome > 250000) {
      tax += (taxableIncome.clamp(250000, 500000) - 250000) * 0.05;
    }
    if (taxableIncome > 500000) {
      tax += (taxableIncome.clamp(500000, 1000000) - 500000) * 0.20;
    }
    if (taxableIncome > 1000000) {
      tax += (taxableIncome - 1000000) * 0.30;
    }
    // Rebate 87A for old regime (income <= 5L)
    if (taxableIncome <= 500000) tax = 0;
    return tax;
  }

  // -------------------------------------------------------------------------
  // New regime slab computation (AY 2026-27, Section 115BAC)
  // -------------------------------------------------------------------------

  double _computeNewRegimeTax(double taxableIncome) {
    if (taxableIncome <= 400000) return 0;
    double tax = 0;
    if (taxableIncome > 400000) {
      tax += (taxableIncome.clamp(400000, 800000) - 400000) * 0.05;
    }
    if (taxableIncome > 800000) {
      tax += (taxableIncome.clamp(800000, 1200000) - 800000) * 0.10;
    }
    if (taxableIncome > 1200000) {
      tax += (taxableIncome.clamp(1200000, 1600000) - 1200000) * 0.15;
    }
    if (taxableIncome > 1600000) {
      tax += (taxableIncome.clamp(1600000, 2000000) - 1600000) * 0.20;
    }
    if (taxableIncome > 2000000) {
      tax += (taxableIncome.clamp(2000000, 2400000) - 2000000) * 0.25;
    }
    if (taxableIncome > 2400000) {
      tax += (taxableIncome - 2400000) * 0.30;
    }
    // Rebate 87A for new regime (income <= 12L, max rebate 60K)
    if (taxableIncome <= 1200000) {
      final rebate = tax > 60000 ? 60000.0 : tax;
      tax -= rebate;
    }
    return tax;
  }
}

// ---------------------------------------------------------------------------
// Recommended badge
// ---------------------------------------------------------------------------

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge({required this.regime, required this.savings});

  final TaxRegime regime;
  final double savings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${regime.label} saves you '
              '${CurrencyUtils.formatINR(savings)} in tax.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Regime selection card
// ---------------------------------------------------------------------------

class _RegimeCard extends StatelessWidget {
  const _RegimeCard({
    required this.title,
    required this.regime,
    required this.ordinaryTax,
    required this.cgTax,
    required this.cess,
    required this.totalTax,
    required this.isRecommended,
    required this.isSelected,
    required this.onSelect,
  });

  final String title;
  final TaxRegime regime;
  final double ordinaryTax;
  final double cgTax;
  final double cess;
  final double totalTax;
  final bool isRecommended;
  final bool isSelected;
  final VoidCallback onSelect;

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.neutral600,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            CurrencyUtils.formatINR(value),
            style: TextStyle(
              fontSize: 11,
              color: bold ? AppColors.primary : AppColors.neutral900,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.neutral400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Best',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 12),
            _row('Ordinary Tax', ordinaryTax),
            _row('CG Tax', cgTax),
            _row('Cess (4%)', cess),
            const Divider(height: 10),
            _row('Total Tax', totalTax, bold: true),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Capital gains tax breakdown card
// ---------------------------------------------------------------------------

class _CgBreakdownCard extends StatelessWidget {
  const _CgBreakdownCard({
    required this.stcg111ATax,
    required this.ltcg112ATax,
    required this.ltcg112Tax,
    required this.totalCgTax,
  });

  final double stcg111ATax;
  final double ltcg112ATax;
  final double ltcg112Tax;
  final double totalCgTax;

  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Text(
            CurrencyUtils.formatINR(value),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capital Gains Tax Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
            const Divider(height: 12),
            _row('STCG (Sec 111A) @ 20%', stcg111ATax),
            _row('LTCG (Sec 112A) @ 12.5% (over \u20b91.25L)', ltcg112ATax),
            _row('LTCG (Sec 112) Property @ 20%', ltcg112Tax),
            const Divider(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Total CG Tax',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(totalCgTax),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
