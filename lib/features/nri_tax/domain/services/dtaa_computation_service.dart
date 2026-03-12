import 'package:ca_app/features/nri_tax/domain/models/dtaa_benefit.dart';

/// Service for computing DTAA (Double Tax Avoidance Agreement) relief.
///
/// Implements:
/// - Section 90: Bilateral relief (for countries with DTAA with India)
/// - Standard DTAA withholding rates for key treaty countries
/// - Double tax relief = min(foreign tax, Indian tax on same income)
///
/// All monetary values are in **paise** (1/100 of Indian Rupee).
///
/// Key treaty rates sourced from CBDT circulars and the respective DTAA texts.
class DtaaComputationService {
  DtaaComputationService._();

  static final DtaaComputationService instance = DtaaComputationService._();

  /// Standard Indian domestic tax rate used for relief computation (30%).
  static const double _domesticRate = 0.30;

  // ─── DTAA withholding rate tables ────────────────────────────────────────
  // Structure: countryCode → { IncomeType → rate }
  // Rates represent the maximum DTAA withholding tax rate.

  static const Map<String, Map<IncomeType, double>> _dtaaRates = {
    'US': {
      IncomeType.dividend: 0.25, // Article 10: 25% (15% if ≥10% beneficial ownership)
      IncomeType.interest: 0.10, // Article 11
      IncomeType.royalty: 0.15, // Article 12
      IncomeType.capitalGains: 0.20,
      IncomeType.businessProfits: 0.0, // taxed only in residence country
      IncomeType.salary: 0.0,
      IncomeType.professionalFees: 0.15,
    },
    'GB': {
      IncomeType.dividend: 0.15, // Article 10
      IncomeType.interest: 0.10, // Article 11
      IncomeType.royalty: 0.10, // Article 12 (15% for certain royalties)
      IncomeType.capitalGains: 0.20,
      IncomeType.businessProfits: 0.0,
      IncomeType.salary: 0.0,
      IncomeType.professionalFees: 0.10,
    },
    'AE': {
      // UAE: No DTAA with India. UAE levies no personal income tax.
      // Relief available only under Section 91 (unilateral) if any tax paid.
      IncomeType.dividend: 0.0,
      IncomeType.interest: 0.0,
      IncomeType.royalty: 0.0,
      IncomeType.capitalGains: 0.0,
      IncomeType.businessProfits: 0.0,
      IncomeType.salary: 0.0,
      IncomeType.professionalFees: 0.0,
    },
    'SG': {
      IncomeType.dividend: 0.10, // Article 10
      IncomeType.interest: 0.10, // Article 11
      IncomeType.royalty: 0.10, // Article 12
      IncomeType.capitalGains: 0.0,
      IncomeType.businessProfits: 0.0,
      IncomeType.salary: 0.0,
      IncomeType.professionalFees: 0.10,
    },
    'DE': {
      IncomeType.dividend: 0.10, // Article 10: 10% (25% if portfolio)
      IncomeType.interest: 0.10, // Article 11
      IncomeType.royalty: 0.10, // Article 12
      IncomeType.capitalGains: 0.10,
      IncomeType.businessProfits: 0.0,
      IncomeType.salary: 0.0,
      IncomeType.professionalFees: 0.10,
    },
  };

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Returns the DTAA withholding tax rate for [countryCode] and [type].
  ///
  /// Returns the domestic rate (30%) for countries without a DTAA or for
  /// income types not covered by the treaty.
  double getWithholdingRate(String countryCode, IncomeType type) {
    final countryRates = _dtaaRates[countryCode];
    if (countryRates == null) return _domesticRate;
    return countryRates[type] ?? _domesticRate;
  }

  /// Returns true — a TRC is always required to claim DTAA benefits under
  /// Section 90(4) of the Income Tax Act, 1961.
  bool isTrcRequired(String countryCode) => true;

  /// Computes the double tax relief available under Section 90 of the IT Act.
  ///
  /// Relief = min([indianTax], [foreignTax]).
  ///
  /// The foreign tax credit cannot exceed the Indian tax payable on the same
  /// income. [grossIncome] is retained as a parameter for future pro-rata
  /// allocation use cases.
  int computeDoubleTaxRelief(int indianTax, int foreignTax, int grossIncome) {
    if (grossIncome <= 0) return 0;
    return indianTax < foreignTax ? indianTax : foreignTax;
  }

  /// Computes the tax relief in paise for the given [benefit].
  ///
  /// Relief is 0 if TRC has not been submitted (mandatory condition under
  /// Section 90(4)).
  ///
  /// Otherwise, relief = [computeDoubleTaxRelief] where:
  /// - foreignTax = [DtaaBenefit.dtaaTaxPaid]
  /// - indianTax = [DtaaBenefit.grossIncome] × domestic rate (30%)
  int computeRelief(DtaaBenefit benefit) {
    if (!benefit.trcSubmitted) return 0;
    if (benefit.grossIncome <= 0) return 0;

    final indianTax = (benefit.grossIncome * _domesticRate).round();
    return computeDoubleTaxRelief(
      indianTax,
      benefit.dtaaTaxPaid,
      benefit.grossIncome,
    );
  }
}
