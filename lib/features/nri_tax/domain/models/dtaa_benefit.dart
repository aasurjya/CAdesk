import 'package:flutter/foundation.dart';

/// Type of income for DTAA benefit computation.
enum IncomeType {
  salary('Salary'),
  dividend('Dividend'),
  interest('Interest'),
  royalty('Royalty'),
  capitalGains('Capital Gains'),
  businessProfits('Business Profits'),
  professionalFees('Professional Fees');

  const IncomeType(this.label);
  final String label;
}

/// Immutable model representing a DTAA (Double Tax Avoidance Agreement)
/// benefit claim for a specific income type and source country.
///
/// All monetary values are in **paise** (1/100 of Indian Rupee).
@immutable
class DtaaBenefit {
  const DtaaBenefit({
    required this.pan,
    required this.countryCode,
    required this.incomeType,
    required this.grossIncome,
    required this.withholdingTaxRate,
    required this.trcSubmitted,
    required this.form10fSubmitted,
    required this.dtaaTaxPaid,
    required this.reliefClaimed,
    required this.article,
  });

  /// PAN of the NRI taxpayer.
  final String pan;

  /// ISO alpha-2 country code of the source country (e.g. "US", "GB", "AE").
  final String countryCode;

  /// Type of income earned.
  final IncomeType incomeType;

  /// Gross income in paise before any tax deduction.
  final int grossIncome;

  /// DTAA withholding tax rate applicable (e.g. 0.10 for 10%).
  final double withholdingTaxRate;

  /// Whether a valid Tax Residency Certificate (TRC) has been submitted.
  final bool trcSubmitted;

  /// Whether Form 10F has been submitted (required when TRC is not in
  /// prescribed format under Section 90(4) of the IT Act).
  final bool form10fSubmitted;

  /// Foreign tax already paid in paise (basis for relief computation).
  final int dtaaTaxPaid;

  /// Relief claimed in paise (computed by [DtaaComputationService]).
  final int reliefClaimed;

  /// DTAA article reference (e.g. "Article 11 — Interest").
  final String article;

  DtaaBenefit copyWith({
    String? pan,
    String? countryCode,
    IncomeType? incomeType,
    int? grossIncome,
    double? withholdingTaxRate,
    bool? trcSubmitted,
    bool? form10fSubmitted,
    int? dtaaTaxPaid,
    int? reliefClaimed,
    String? article,
  }) {
    return DtaaBenefit(
      pan: pan ?? this.pan,
      countryCode: countryCode ?? this.countryCode,
      incomeType: incomeType ?? this.incomeType,
      grossIncome: grossIncome ?? this.grossIncome,
      withholdingTaxRate: withholdingTaxRate ?? this.withholdingTaxRate,
      trcSubmitted: trcSubmitted ?? this.trcSubmitted,
      form10fSubmitted: form10fSubmitted ?? this.form10fSubmitted,
      dtaaTaxPaid: dtaaTaxPaid ?? this.dtaaTaxPaid,
      reliefClaimed: reliefClaimed ?? this.reliefClaimed,
      article: article ?? this.article,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DtaaBenefit &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          countryCode == other.countryCode &&
          incomeType == other.incomeType &&
          grossIncome == other.grossIncome &&
          withholdingTaxRate == other.withholdingTaxRate &&
          trcSubmitted == other.trcSubmitted &&
          form10fSubmitted == other.form10fSubmitted &&
          dtaaTaxPaid == other.dtaaTaxPaid &&
          reliefClaimed == other.reliefClaimed &&
          article == other.article;

  @override
  int get hashCode => Object.hash(
        pan,
        countryCode,
        incomeType,
        grossIncome,
        withholdingTaxRate,
        trcSubmitted,
        form10fSubmitted,
        dtaaTaxPaid,
        reliefClaimed,
        article,
      );

  @override
  String toString() =>
      'DtaaBenefit(pan: $pan, country: $countryCode, '
      'type: ${incomeType.label}, gross: $grossIncome paise)';
}
