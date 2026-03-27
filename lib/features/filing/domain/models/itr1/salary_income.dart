/// Immutable model for salary income details in ITR-1 (Sahaj).
///
/// Standard deduction for AY 2024-25:
/// - New tax regime: ₹75,000
/// - Old tax regime: ₹50,000
class SalaryIncome {
  const SalaryIncome({
    required this.grossSalary,
    required this.allowancesExemptUnderSection10,
    required this.valueOfPerquisites,
    required this.profitsInLieuOfSalary,
    required this.standardDeduction,
  });

  factory SalaryIncome.empty() => const SalaryIncome(
    grossSalary: 0,
    allowancesExemptUnderSection10: 0,
    valueOfPerquisites: 0,
    profitsInLieuOfSalary: 0,
    standardDeduction: 75000,
  );

  /// Gross salary as per Form 16 / salary slips.
  final double grossSalary;

  /// Allowances exempt under Section 10 (HRA, LTA, etc.).
  final double allowancesExemptUnderSection10;

  /// Monetary value of perquisites provided by employer.
  final double valueOfPerquisites;

  /// Profits in lieu of salary (e.g. compensation on termination).
  final double profitsInLieuOfSalary;

  /// Standard deduction: ₹75,000 (new regime) or ₹50,000 (old regime).
  final double standardDeduction;

  /// Net taxable salary after exemptions and standard deduction.
  ///
  /// Formula: Gross - Section 10 exemptions + Perquisites
  ///          + Profits in lieu - Standard deduction
  double get netSalary =>
      grossSalary -
      allowancesExemptUnderSection10 +
      valueOfPerquisites +
      profitsInLieuOfSalary -
      standardDeduction;

  SalaryIncome copyWith({
    double? grossSalary,
    double? allowancesExemptUnderSection10,
    double? valueOfPerquisites,
    double? profitsInLieuOfSalary,
    double? standardDeduction,
  }) {
    return SalaryIncome(
      grossSalary: grossSalary ?? this.grossSalary,
      allowancesExemptUnderSection10:
          allowancesExemptUnderSection10 ?? this.allowancesExemptUnderSection10,
      valueOfPerquisites: valueOfPerquisites ?? this.valueOfPerquisites,
      profitsInLieuOfSalary:
          profitsInLieuOfSalary ?? this.profitsInLieuOfSalary,
      standardDeduction: standardDeduction ?? this.standardDeduction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalaryIncome &&
        other.grossSalary == grossSalary &&
        other.allowancesExemptUnderSection10 ==
            allowancesExemptUnderSection10 &&
        other.valueOfPerquisites == valueOfPerquisites &&
        other.profitsInLieuOfSalary == profitsInLieuOfSalary &&
        other.standardDeduction == standardDeduction;
  }

  @override
  int get hashCode => Object.hash(
    grossSalary,
    allowancesExemptUnderSection10,
    valueOfPerquisites,
    profitsInLieuOfSalary,
    standardDeduction,
  );

  Map<String, dynamic> toJson() => {
    'grossSalary': grossSalary,
    'allowancesExemptUnderSection10': allowancesExemptUnderSection10,
    'valueOfPerquisites': valueOfPerquisites,
    'profitsInLieuOfSalary': profitsInLieuOfSalary,
    'standardDeduction': standardDeduction,
  };

  factory SalaryIncome.fromJson(Map<String, dynamic> json) => SalaryIncome(
    grossSalary: (json['grossSalary'] as num?)?.toDouble() ?? 0,
    allowancesExemptUnderSection10:
        (json['allowancesExemptUnderSection10'] as num?)?.toDouble() ?? 0,
    valueOfPerquisites: (json['valueOfPerquisites'] as num?)?.toDouble() ?? 0,
    profitsInLieuOfSalary:
        (json['profitsInLieuOfSalary'] as num?)?.toDouble() ?? 0,
    standardDeduction: (json['standardDeduction'] as num?)?.toDouble() ?? 75000,
  );
}
