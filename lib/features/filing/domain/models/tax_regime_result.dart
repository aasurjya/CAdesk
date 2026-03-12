import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';

/// Result of a tax computation comparing old vs new regime.
class TaxRegimeResult {
  const TaxRegimeResult({
    required this.oldRegimeTax,
    required this.newRegimeTax,
    required this.oldRegimeTaxBeforeCess,
    required this.newRegimeTaxBeforeCess,
    required this.oldRegimeSurcharge,
    required this.newRegimeSurcharge,
    required this.oldRegimeCess,
    required this.newRegimeCess,
    required this.oldRegimeTaxableIncome,
    required this.newRegimeTaxableIncome,
    required this.savings,
    required this.recommendedRegime,
  });

  /// Total tax liability under old regime (including surcharge + cess).
  final double oldRegimeTax;

  /// Total tax liability under new regime (including surcharge + cess).
  final double newRegimeTax;

  /// Tax before surcharge and cess under old regime.
  final double oldRegimeTaxBeforeCess;

  /// Tax before surcharge and cess under new regime.
  final double newRegimeTaxBeforeCess;

  /// Surcharge amount under old regime.
  final double oldRegimeSurcharge;

  /// Surcharge amount under new regime.
  final double newRegimeSurcharge;

  /// Health & Education Cess (4%) under old regime.
  final double oldRegimeCess;

  /// Health & Education Cess (4%) under new regime.
  final double newRegimeCess;

  /// Taxable income under old regime.
  final double oldRegimeTaxableIncome;

  /// Taxable income under new regime.
  final double newRegimeTaxableIncome;

  /// Absolute savings between the two regimes.
  final double savings;

  /// Whichever regime results in lower tax.
  final TaxRegime recommendedRegime;

  TaxRegimeResult copyWith({
    double? oldRegimeTax,
    double? newRegimeTax,
    double? oldRegimeTaxBeforeCess,
    double? newRegimeTaxBeforeCess,
    double? oldRegimeSurcharge,
    double? newRegimeSurcharge,
    double? oldRegimeCess,
    double? newRegimeCess,
    double? oldRegimeTaxableIncome,
    double? newRegimeTaxableIncome,
    double? savings,
    TaxRegime? recommendedRegime,
  }) {
    return TaxRegimeResult(
      oldRegimeTax: oldRegimeTax ?? this.oldRegimeTax,
      newRegimeTax: newRegimeTax ?? this.newRegimeTax,
      oldRegimeTaxBeforeCess:
          oldRegimeTaxBeforeCess ?? this.oldRegimeTaxBeforeCess,
      newRegimeTaxBeforeCess:
          newRegimeTaxBeforeCess ?? this.newRegimeTaxBeforeCess,
      oldRegimeSurcharge: oldRegimeSurcharge ?? this.oldRegimeSurcharge,
      newRegimeSurcharge: newRegimeSurcharge ?? this.newRegimeSurcharge,
      oldRegimeCess: oldRegimeCess ?? this.oldRegimeCess,
      newRegimeCess: newRegimeCess ?? this.newRegimeCess,
      oldRegimeTaxableIncome:
          oldRegimeTaxableIncome ?? this.oldRegimeTaxableIncome,
      newRegimeTaxableIncome:
          newRegimeTaxableIncome ?? this.newRegimeTaxableIncome,
      savings: savings ?? this.savings,
      recommendedRegime: recommendedRegime ?? this.recommendedRegime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxRegimeResult &&
        other.oldRegimeTax == oldRegimeTax &&
        other.newRegimeTax == newRegimeTax &&
        other.recommendedRegime == recommendedRegime;
  }

  @override
  int get hashCode =>
      Object.hash(oldRegimeTax, newRegimeTax, recommendedRegime);
}
