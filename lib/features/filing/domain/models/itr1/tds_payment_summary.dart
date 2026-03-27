/// Immutable model for TDS deducted and taxes paid details in ITR-1 (Sahaj).
///
/// Captures:
/// - TDS deducted at source (salary + other income)
/// - Advance tax paid quarterly
/// - Self-assessment tax paid before filing
class TdsPaymentSummary {
  const TdsPaymentSummary({
    required this.tdsOnSalary,
    required this.tdsOnOtherIncome,
    required this.advanceTaxQ1,
    required this.advanceTaxQ2,
    required this.advanceTaxQ3,
    required this.advanceTaxQ4,
    required this.selfAssessmentTax,
  });

  factory TdsPaymentSummary.empty() => const TdsPaymentSummary(
    tdsOnSalary: 0,
    tdsOnOtherIncome: 0,
    advanceTaxQ1: 0,
    advanceTaxQ2: 0,
    advanceTaxQ3: 0,
    advanceTaxQ4: 0,
    selfAssessmentTax: 0,
  );

  /// TDS deducted on salary as per Form 16 Part A.
  final double tdsOnSalary;

  /// TDS deducted on other income (interest, rent, etc.) as per 26AS/AIS.
  final double tdsOnOtherIncome;

  /// Advance tax paid by 15 Jun (Q1).
  final double advanceTaxQ1;

  /// Advance tax paid by 15 Sep (Q2).
  final double advanceTaxQ2;

  /// Advance tax paid by 15 Dec (Q3).
  final double advanceTaxQ3;

  /// Advance tax paid by 15 Mar (Q4).
  final double advanceTaxQ4;

  /// Self-assessment tax (challan 280) paid before filing.
  final double selfAssessmentTax;

  /// Total TDS deducted (salary + other income).
  double get totalTds => tdsOnSalary + tdsOnOtherIncome;

  /// Total advance tax paid across all four quarters.
  double get totalAdvanceTax =>
      advanceTaxQ1 + advanceTaxQ2 + advanceTaxQ3 + advanceTaxQ4;

  /// Advance tax paid by quarter as a list (for interest computation).
  List<double> get advanceTaxByQuarter => [
    advanceTaxQ1,
    advanceTaxQ2,
    advanceTaxQ3,
    advanceTaxQ4,
  ];

  /// Total taxes paid (TDS + Advance Tax + Self-Assessment).
  double get totalTaxesPaid => totalTds + totalAdvanceTax + selfAssessmentTax;

  TdsPaymentSummary copyWith({
    double? tdsOnSalary,
    double? tdsOnOtherIncome,
    double? advanceTaxQ1,
    double? advanceTaxQ2,
    double? advanceTaxQ3,
    double? advanceTaxQ4,
    double? selfAssessmentTax,
  }) {
    return TdsPaymentSummary(
      tdsOnSalary: tdsOnSalary ?? this.tdsOnSalary,
      tdsOnOtherIncome: tdsOnOtherIncome ?? this.tdsOnOtherIncome,
      advanceTaxQ1: advanceTaxQ1 ?? this.advanceTaxQ1,
      advanceTaxQ2: advanceTaxQ2 ?? this.advanceTaxQ2,
      advanceTaxQ3: advanceTaxQ3 ?? this.advanceTaxQ3,
      advanceTaxQ4: advanceTaxQ4 ?? this.advanceTaxQ4,
      selfAssessmentTax: selfAssessmentTax ?? this.selfAssessmentTax,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TdsPaymentSummary &&
        other.tdsOnSalary == tdsOnSalary &&
        other.tdsOnOtherIncome == tdsOnOtherIncome &&
        other.advanceTaxQ1 == advanceTaxQ1 &&
        other.advanceTaxQ2 == advanceTaxQ2 &&
        other.advanceTaxQ3 == advanceTaxQ3 &&
        other.advanceTaxQ4 == advanceTaxQ4 &&
        other.selfAssessmentTax == selfAssessmentTax;
  }

  @override
  int get hashCode => Object.hash(
    tdsOnSalary,
    tdsOnOtherIncome,
    advanceTaxQ1,
    advanceTaxQ2,
    advanceTaxQ3,
    advanceTaxQ4,
    selfAssessmentTax,
  );

  Map<String, dynamic> toJson() => {
    'tdsOnSalary': tdsOnSalary,
    'tdsOnOtherIncome': tdsOnOtherIncome,
    'advanceTaxQ1': advanceTaxQ1,
    'advanceTaxQ2': advanceTaxQ2,
    'advanceTaxQ3': advanceTaxQ3,
    'advanceTaxQ4': advanceTaxQ4,
    'selfAssessmentTax': selfAssessmentTax,
  };

  factory TdsPaymentSummary.fromJson(Map<String, dynamic> json) =>
      TdsPaymentSummary(
        tdsOnSalary: (json['tdsOnSalary'] as num?)?.toDouble() ?? 0,
        tdsOnOtherIncome: (json['tdsOnOtherIncome'] as num?)?.toDouble() ?? 0,
        advanceTaxQ1: (json['advanceTaxQ1'] as num?)?.toDouble() ?? 0,
        advanceTaxQ2: (json['advanceTaxQ2'] as num?)?.toDouble() ?? 0,
        advanceTaxQ3: (json['advanceTaxQ3'] as num?)?.toDouble() ?? 0,
        advanceTaxQ4: (json['advanceTaxQ4'] as num?)?.toDouble() ?? 0,
        selfAssessmentTax: (json['selfAssessmentTax'] as num?)?.toDouble() ?? 0,
      );
}
