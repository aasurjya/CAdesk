/// Result of interest computation under Sections 234A, 234B, 234C.
class InterestResult {
  const InterestResult({
    required this.interest234A,
    required this.interest234B,
    required this.interest234C,
    required this.months234A,
    required this.months234B,
    required this.months234C,
  });

  /// Interest under Section 234A — late filing of return.
  /// 1% per month on tax payable.
  final double interest234A;

  /// Interest under Section 234B — non-payment / short-payment of advance tax.
  /// 1% per month from April 1 of AY to date of filing.
  final double interest234B;

  /// Interest under Section 234C — deferment of advance tax installments.
  /// 1% per month on shortfall per quarterly installment.
  final double interest234C;

  /// Number of months charged under 234A.
  final int months234A;

  /// Number of months charged under 234B.
  final int months234B;

  /// Number of months charged under 234C.
  final int months234C;

  /// Total interest payable across all three sections.
  double get totalInterest => interest234A + interest234B + interest234C;

  InterestResult copyWith({
    double? interest234A,
    double? interest234B,
    double? interest234C,
    int? months234A,
    int? months234B,
    int? months234C,
  }) {
    return InterestResult(
      interest234A: interest234A ?? this.interest234A,
      interest234B: interest234B ?? this.interest234B,
      interest234C: interest234C ?? this.interest234C,
      months234A: months234A ?? this.months234A,
      months234B: months234B ?? this.months234B,
      months234C: months234C ?? this.months234C,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterestResult &&
        other.interest234A == interest234A &&
        other.interest234B == interest234B &&
        other.interest234C == interest234C;
  }

  @override
  int get hashCode => Object.hash(interest234A, interest234B, interest234C);
}
