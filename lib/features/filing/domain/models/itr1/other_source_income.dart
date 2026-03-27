/// Immutable model for income from other sources in ITR-1 (Sahaj).
///
/// Covers interest, dividends, family pension, and miscellaneous income
/// reported under the head "Income from Other Sources" (Section 56).
class OtherSourceIncome {
  const OtherSourceIncome({
    required this.savingsAccountInterest,
    required this.fixedDepositInterest,
    required this.dividendIncome,
    required this.familyPension,
    required this.otherIncome,
  });

  factory OtherSourceIncome.empty() => const OtherSourceIncome(
    savingsAccountInterest: 0,
    fixedDepositInterest: 0,
    dividendIncome: 0,
    familyPension: 0,
    otherIncome: 0,
  );

  /// Interest credited to savings bank accounts during the year.
  final double savingsAccountInterest;

  /// Interest earned on fixed / recurring deposits.
  final double fixedDepositInterest;

  /// Dividends received from mutual funds and listed equities.
  final double dividendIncome;

  /// Family pension received by legal heirs of a deceased government employee.
  final double familyPension;

  /// Any other taxable income not covered above.
  final double otherIncome;

  /// Aggregate income from all other sources.
  double get total =>
      savingsAccountInterest +
      fixedDepositInterest +
      dividendIncome +
      familyPension +
      otherIncome;

  OtherSourceIncome copyWith({
    double? savingsAccountInterest,
    double? fixedDepositInterest,
    double? dividendIncome,
    double? familyPension,
    double? otherIncome,
  }) {
    return OtherSourceIncome(
      savingsAccountInterest:
          savingsAccountInterest ?? this.savingsAccountInterest,
      fixedDepositInterest: fixedDepositInterest ?? this.fixedDepositInterest,
      dividendIncome: dividendIncome ?? this.dividendIncome,
      familyPension: familyPension ?? this.familyPension,
      otherIncome: otherIncome ?? this.otherIncome,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtherSourceIncome &&
        other.savingsAccountInterest == savingsAccountInterest &&
        other.fixedDepositInterest == fixedDepositInterest &&
        other.dividendIncome == dividendIncome &&
        other.familyPension == familyPension &&
        other.otherIncome == otherIncome;
  }

  @override
  int get hashCode => Object.hash(
    savingsAccountInterest,
    fixedDepositInterest,
    dividendIncome,
    familyPension,
    otherIncome,
  );

  Map<String, dynamic> toJson() => {
    'savingsAccountInterest': savingsAccountInterest,
    'fixedDepositInterest': fixedDepositInterest,
    'dividendIncome': dividendIncome,
    'familyPension': familyPension,
    'otherIncome': otherIncome,
  };

  factory OtherSourceIncome.fromJson(Map<String, dynamic> json) =>
      OtherSourceIncome(
        savingsAccountInterest:
            (json['savingsAccountInterest'] as num?)?.toDouble() ?? 0,
        fixedDepositInterest:
            (json['fixedDepositInterest'] as num?)?.toDouble() ?? 0,
        dividendIncome: (json['dividendIncome'] as num?)?.toDouble() ?? 0,
        familyPension: (json['familyPension'] as num?)?.toDouble() ?? 0,
        otherIncome: (json['otherIncome'] as num?)?.toDouble() ?? 0,
      );
}
