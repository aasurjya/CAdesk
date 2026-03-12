import 'dart:math' show min;

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr4/itr4_form_data.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';
import 'package:ca_app/features/filing/domain/services/tax_computation_engine.dart';

/// Stateless service that computes income tax under old and new regimes
/// for ITR-4 (Sugam) — FY 2025-26 / AY 2026-27.
///
/// Uses the same slab rates and surcharge/cess logic as [TaxComputationEngine]
/// but works with [Itr4FormData] (presumptive taxation).
class Itr4TaxComputationEngine {
  Itr4TaxComputationEngine._();

  // ---------------------------------------------------------------------------
  // New Regime — Section 115BAC (FY 2025-26)
  // Slabs: 0-4L Nil, 4-8L 5%, 8-12L 10%, 12-16L 15%,
  //        16-20L 20%, 20-24L 25%, >24L 30%
  // ---------------------------------------------------------------------------

  /// Compute tax under new regime from [Itr4FormData].
  ///
  /// New regime ignores Chapter VI-A deductions.
  static double computeNewRegimeTax(Itr4FormData data) {
    final formForNewRegime = data.copyWith(selectedRegime: TaxRegime.newRegime);
    final taxableIncome = formForNewRegime.taxableIncome;
    return _applyNewRegimeSlabs(taxableIncome);
  }

  /// Raw slab computation for new regime.
  static double _applyNewRegimeSlabs(double income) {
    if (income <= 0) return 0;

    // Rebate u/s 87A: If total income <= 12,00,000, tax is nil under
    // new regime for FY 2025-26.
    if (income <= 1200000) return 0;

    double tax = 0;
    if (income > 2400000) tax += (income - 2400000) * 0.30;
    if (income > 2000000) tax += (min(income, 2400000) - 2000000) * 0.25;
    if (income > 1600000) tax += (min(income, 2000000) - 1600000) * 0.20;
    if (income > 1200000) tax += (min(income, 1600000) - 1200000) * 0.15;
    if (income > 800000) tax += (min(income, 1200000) - 800000) * 0.10;
    if (income > 400000) tax += (min(income, 800000) - 400000) * 0.05;

    return tax;
  }

  // ---------------------------------------------------------------------------
  // Old Regime
  // Slabs: 0-2.5L Nil, 2.5-5L 5%, 5-10L 20%, >10L 30%
  // ---------------------------------------------------------------------------

  /// Compute tax under old regime from [Itr4FormData].
  ///
  /// Old regime allows full Chapter VI-A deductions.
  static double computeOldRegimeTax(Itr4FormData data) {
    final formForOld = data.copyWith(selectedRegime: TaxRegime.oldRegime);
    final taxableIncome = formForOld.taxableIncome;
    return _applyOldRegimeSlabs(taxableIncome);
  }

  /// Raw slab computation for old regime.
  static double _applyOldRegimeSlabs(double income) {
    if (income <= 0) return 0;

    // Rebate u/s 87A: If total income <= 5,00,000, tax is nil under old regime.
    if (income <= 500000) return 0;

    double tax = 0;
    if (income > 1000000) tax += (income - 1000000) * 0.30;
    if (income > 500000) tax += (min(income, 1000000) - 500000) * 0.20;
    if (income > 250000) tax += (min(income, 500000) - 250000) * 0.05;

    return tax;
  }

  // ---------------------------------------------------------------------------
  // Compare both regimes side-by-side
  // ---------------------------------------------------------------------------

  /// Compare old vs new regime and return a [TaxRegimeResult] with
  /// full breakdown including surcharge and cess.
  static TaxRegimeResult compare(Itr4FormData data) {
    // Old regime computation
    final formForOld = data.copyWith(selectedRegime: TaxRegime.oldRegime);
    final oldTaxableIncome = formForOld.taxableIncome;
    final oldBaseTax = _applyOldRegimeSlabs(oldTaxableIncome);
    final oldSurcharge = TaxComputationEngine.computeSurcharge(
      oldBaseTax,
      oldTaxableIncome,
      isNewRegime: false,
    );
    final oldCess = TaxComputationEngine.computeCess(oldBaseTax + oldSurcharge);
    final oldTotal = oldBaseTax + oldSurcharge + oldCess;

    // New regime computation
    final formForNew = data.copyWith(selectedRegime: TaxRegime.newRegime);
    final newTaxableIncome = formForNew.taxableIncome;
    final newBaseTax = _applyNewRegimeSlabs(newTaxableIncome);
    final newSurcharge = TaxComputationEngine.computeSurcharge(
      newBaseTax,
      newTaxableIncome,
      isNewRegime: true,
    );
    final newCess = TaxComputationEngine.computeCess(newBaseTax + newSurcharge);
    final newTotal = newBaseTax + newSurcharge + newCess;

    return TaxRegimeResult(
      oldRegimeTax: oldTotal,
      newRegimeTax: newTotal,
      oldRegimeTaxBeforeCess: oldBaseTax,
      newRegimeTaxBeforeCess: newBaseTax,
      oldRegimeSurcharge: oldSurcharge,
      newRegimeSurcharge: newSurcharge,
      oldRegimeCess: oldCess,
      newRegimeCess: newCess,
      oldRegimeTaxableIncome: oldTaxableIncome,
      newRegimeTaxableIncome: newTaxableIncome,
      savings: (oldTotal - newTotal).abs(),
      recommendedRegime: newTotal <= oldTotal
          ? TaxRegime.newRegime
          : TaxRegime.oldRegime,
    );
  }
}
