import 'package:ca_app/features/startup/domain/models/angel_tax_computation.dart';

/// Input data for angel tax computation.
class AngelTaxInput {
  const AngelTaxInput({
    required this.issuePricePaise,
    required this.fairMarketValuePaise,
    required this.amountRaisedPaise,
    required this.exemptionApplied,
  });

  /// Issue price per share in paise.
  final int issuePricePaise;

  /// Fair Market Value (FMV) per share in paise.
  final int fairMarketValuePaise;

  /// Total amount raised in this round in paise.
  final int amountRaisedPaise;

  /// Whether DPIIT exemption applies.
  final bool exemptionApplied;
}

/// Service for computing Angel Tax under Section 56(2)(viib).
///
/// Angel tax applies when a closely-held company issues shares at a price
/// exceeding Fair Market Value (FMV). The excess is taxed at 30% in the
/// hands of the issuing company as "Income from Other Sources".
///
/// DPIIT-registered startups are fully exempt.
class AngelTaxService {
  AngelTaxService._();

  static final AngelTaxService instance = AngelTaxService._();

  /// Angel tax rate: 30%.
  static const int _taxRateNumerator = 30;
  static const int _taxRateDenominator = 100;

  /// Computes the angel tax for an investment round.
  ///
  /// If [AngelTaxInput.exemptionApplied] is `true` (DPIIT-registered startup),
  /// returns zero tax with [AngelTaxComputation.exemptionApplied] set to `true`.
  AngelTaxComputation computeAngelTax(AngelTaxInput input) {
    if (input.exemptionApplied) {
      return AngelTaxComputation(
        issuePricePaise: input.issuePricePaise,
        fairMarketValuePaise: input.fairMarketValuePaise,
        amountRaisedPaise: input.amountRaisedPaise,
        excessOverFmvPaise: 0,
        angelTaxPayablePaise: 0,
        exemptionApplied: true,
      );
    }

    // Excess = total raised × (issue price − FMV) / issue price
    // Simplified: total raised − (total raised × FMV / issue price)
    final excess = _computeExcess(
      issuePricePaise: input.issuePricePaise,
      fairMarketValuePaise: input.fairMarketValuePaise,
      amountRaisedPaise: input.amountRaisedPaise,
    );

    final tax = excess > 0
        ? (excess * _taxRateNumerator) ~/ _taxRateDenominator
        : 0;

    return AngelTaxComputation(
      issuePricePaise: input.issuePricePaise,
      fairMarketValuePaise: input.fairMarketValuePaise,
      amountRaisedPaise: input.amountRaisedPaise,
      excessOverFmvPaise: excess,
      angelTaxPayablePaise: tax,
      exemptionApplied: false,
    );
  }

  /// Checks whether a DPIIT-registered startup is exempt from angel tax.
  ///
  /// Returns `true` if [dpiitNumber] is non-empty (mock check).
  /// Production implementation would verify against DPIIT database.
  bool isDpiitExempt(String dpiitNumber) {
    return dpiitNumber.isNotEmpty;
  }

  /// Computes the excess consideration over FMV in paise.
  ///
  /// Excess = amount raised − FMV-equivalent amount raised
  /// Where FMV-equivalent = amount raised × FMV / issue price
  int _computeExcess({
    required int issuePricePaise,
    required int fairMarketValuePaise,
    required int amountRaisedPaise,
  }) {
    if (issuePricePaise <= fairMarketValuePaise) return 0;
    // fmvEquivalentRaised = amountRaised * fmv / issuePrice
    final fmvEquivalentRaised =
        (amountRaisedPaise * fairMarketValuePaise) ~/ issuePricePaise;
    return amountRaisedPaise - fmvEquivalentRaised;
  }
}
