/// Immutable model for Angel Tax computation under Section 56(2)(viib).
///
/// When a closely-held company issues shares at a price exceeding Fair Market Value,
/// the excess is taxable as "Income from Other Sources" at 30% in the hands
/// of the issuing company.
///
/// DPIIT-registered startups are exempt from angel tax per CBDT notification
/// (Notification No. 13/2023 dated May 24, 2023).
class AngelTaxComputation {
  const AngelTaxComputation({
    required this.issuePricePaise,
    required this.fairMarketValuePaise,
    required this.amountRaisedPaise,
    required this.excessOverFmvPaise,
    required this.angelTaxPayablePaise,
    required this.exemptionApplied,
  });

  /// Issue price per share in paise.
  final int issuePricePaise;

  /// Fair Market Value (FMV) per share in paise.
  /// FMV determined by higher of DCF or NAV method.
  final int fairMarketValuePaise;

  /// Total amount raised in paise.
  final int amountRaisedPaise;

  /// Excess over FMV: total amount raised × (issue price − FMV) / issue price, in paise.
  final int excessOverFmvPaise;

  /// Angel tax payable at 30% of excess over FMV, in paise.
  final int angelTaxPayablePaise;

  /// Whether DPIIT registration exemption has been applied.
  final bool exemptionApplied;

  AngelTaxComputation copyWith({
    int? issuePricePaise,
    int? fairMarketValuePaise,
    int? amountRaisedPaise,
    int? excessOverFmvPaise,
    int? angelTaxPayablePaise,
    bool? exemptionApplied,
  }) {
    return AngelTaxComputation(
      issuePricePaise: issuePricePaise ?? this.issuePricePaise,
      fairMarketValuePaise: fairMarketValuePaise ?? this.fairMarketValuePaise,
      amountRaisedPaise: amountRaisedPaise ?? this.amountRaisedPaise,
      excessOverFmvPaise: excessOverFmvPaise ?? this.excessOverFmvPaise,
      angelTaxPayablePaise: angelTaxPayablePaise ?? this.angelTaxPayablePaise,
      exemptionApplied: exemptionApplied ?? this.exemptionApplied,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AngelTaxComputation &&
        other.issuePricePaise == issuePricePaise &&
        other.fairMarketValuePaise == fairMarketValuePaise &&
        other.amountRaisedPaise == amountRaisedPaise &&
        other.excessOverFmvPaise == excessOverFmvPaise &&
        other.angelTaxPayablePaise == angelTaxPayablePaise &&
        other.exemptionApplied == exemptionApplied;
  }

  @override
  int get hashCode => Object.hash(
    issuePricePaise,
    fairMarketValuePaise,
    amountRaisedPaise,
    excessOverFmvPaise,
    angelTaxPayablePaise,
    exemptionApplied,
  );
}
