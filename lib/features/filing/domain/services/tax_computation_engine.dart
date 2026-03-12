import 'dart:math' show min;

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';

/// Stateless service that computes income tax under old and new regimes
/// for FY 2025-26 / AY 2026-27.
///
/// This replaces the simplified [TaxComputationService] from the income_tax
/// module with real form-data-aware computation including surcharge tiers.
class TaxComputationEngine {
  TaxComputationEngine._();

  // ---------------------------------------------------------------------------
  // New Regime — Section 115BAC (FY 2025-26)
  // Slabs: 0–4L Nil, 4–8L 5%, 8–12L 10%, 12–16L 15%,
  //        16–20L 20%, 20–24L 25%, >24L 30%
  // Standard deduction: ₹75,000
  // ---------------------------------------------------------------------------

  /// Compute tax under new regime from [Itr1FormData].
  ///
  /// New regime ignores Chapter VI-A deductions (except 80CCD(1B) NPS which
  /// is still allowed — but we keep it simple for ITR-1: no VI-A in new regime).
  /// Standard deduction = ₹75,000.
  static double computeNewRegimeTax(Itr1FormData data) {
    // In new regime, standard deduction is ₹75,000 — already in SalaryIncome model.
    // We use grossTotalIncome but under new regime, no Ch VI-A deductions.
    final formForNewRegime = data.copyWith(selectedRegime: TaxRegime.newRegime);
    final taxableIncome = formForNewRegime.taxableIncome;
    return _applyNewRegimeSlabs(taxableIncome);
  }

  /// Raw slab computation for new regime.
  static double _applyNewRegimeSlabs(double income) {
    if (income <= 0) return 0;

    // Rebate u/s 87A: If total income ≤ ₹12,00,000 (after standard deduction),
    // tax is nil under new regime for FY 2025-26.
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
  // Slabs: 0–2.5L Nil, 2.5–5L 5%, 5–10L 20%, >10L 30%
  // Standard deduction: ₹50,000
  // ---------------------------------------------------------------------------

  /// Compute tax under old regime from [Itr1FormData].
  ///
  /// Old regime uses ₹50,000 standard deduction and allows full Chapter VI-A.
  static double computeOldRegimeTax(Itr1FormData data) {
    // Override standard deduction to ₹50,000 for old regime.
    final salaryForOld = data.salaryIncome.copyWith(standardDeduction: 50000);
    final formForOld = data.copyWith(
      salaryIncome: salaryForOld,
      selectedRegime: TaxRegime.oldRegime,
    );
    final taxableIncome = formForOld.taxableIncome;
    return _applyOldRegimeSlabs(taxableIncome);
  }

  /// Raw slab computation for old regime.
  static double _applyOldRegimeSlabs(double income) {
    if (income <= 0) return 0;

    // Rebate u/s 87A: If total income ≤ ₹5,00,000, tax is nil under old regime.
    if (income <= 500000) return 0;

    double tax = 0;
    if (income > 1000000) tax += (income - 1000000) * 0.30;
    if (income > 500000) tax += (min(income, 1000000) - 500000) * 0.20;
    if (income > 250000) tax += (min(income, 500000) - 250000) * 0.05;

    return tax;
  }

  // ---------------------------------------------------------------------------
  // Surcharge tiers (both regimes)
  // ---------------------------------------------------------------------------

  /// Compute surcharge on base tax based on total income.
  ///
  /// FY 2025-26 surcharge tiers:
  /// - Income 50L–1Cr: 10%
  /// - Income 1Cr–2Cr: 15%
  /// - Income 2Cr–5Cr: 25%
  /// - Income >5Cr: 37% (old regime) / 25% (new regime capped)
  static double computeSurcharge(
    double baseTax,
    double totalIncome, {
    required bool isNewRegime,
  }) {
    if (totalIncome <= 5000000) return 0;
    if (totalIncome <= 10000000) return baseTax * 0.10;
    if (totalIncome <= 20000000) return baseTax * 0.15;
    if (totalIncome <= 50000000) return baseTax * 0.25;
    // Above 5 Cr: new regime caps at 25%, old regime goes to 37%.
    return baseTax * (isNewRegime ? 0.25 : 0.37);
  }

  /// Health & Education Cess — 4% on (tax + surcharge).
  static double computeCess(double taxPlusSurcharge) => taxPlusSurcharge * 0.04;

  // ---------------------------------------------------------------------------
  // Compare both regimes side-by-side
  // ---------------------------------------------------------------------------

  /// Compare old vs new regime and return a [TaxRegimeResult] with
  /// full breakdown including surcharge and cess.
  static TaxRegimeResult compare(Itr1FormData data) {
    // Old regime computation
    final salaryForOld = data.salaryIncome.copyWith(standardDeduction: 50000);
    final formForOld = data.copyWith(
      salaryIncome: salaryForOld,
      selectedRegime: TaxRegime.oldRegime,
    );
    final oldTaxableIncome = formForOld.taxableIncome;
    final oldBaseTax = _applyOldRegimeSlabs(oldTaxableIncome);
    final oldSurcharge = computeSurcharge(
      oldBaseTax,
      oldTaxableIncome,
      isNewRegime: false,
    );
    final oldCess = computeCess(oldBaseTax + oldSurcharge);
    final oldTotal = oldBaseTax + oldSurcharge + oldCess;

    // New regime computation
    final formForNew = data.copyWith(selectedRegime: TaxRegime.newRegime);
    final newTaxableIncome = formForNew.taxableIncome;
    final newBaseTax = _applyNewRegimeSlabs(newTaxableIncome);
    final newSurcharge = computeSurcharge(
      newBaseTax,
      newTaxableIncome,
      isNewRegime: true,
    );
    final newCess = computeCess(newBaseTax + newSurcharge);
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
