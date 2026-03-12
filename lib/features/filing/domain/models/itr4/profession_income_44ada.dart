/// Immutable model for presumptive professional income under Section 44ADA.
///
/// Section 44ADA applies to resident individuals and partnership firms
/// engaged in specified professions (legal, medical, engineering, architecture,
/// accountancy, technical consultancy, interior decoration, etc.) with gross
/// receipts up to ₹75 lakhs (FY 2025-26).
///
/// Presumptive rate: 50% of gross receipts.
class ProfessionIncome44ADA {
  const ProfessionIncome44ADA({
    required this.natureOfProfession,
    required this.grossReceipts,
  });

  factory ProfessionIncome44ADA.empty() =>
      const ProfessionIncome44ADA(natureOfProfession: '', grossReceipts: 0);

  /// Nature of profession (e.g. 'Legal', 'Medical', 'Engineering').
  final String natureOfProfession;

  /// Total gross receipts from the profession during the year.
  final double grossReceipts;

  /// Maximum gross receipts allowed for Section 44ADA eligibility.
  static const double maxGrossReceipts = 7500000; // ₹75 lakhs

  /// Presumptive income computed as per Section 44ADA rate.
  ///
  /// 50% of gross receipts is deemed as taxable profit.
  double get presumptiveIncome => grossReceipts * 0.50;

  ProfessionIncome44ADA copyWith({
    String? natureOfProfession,
    double? grossReceipts,
  }) {
    return ProfessionIncome44ADA(
      natureOfProfession: natureOfProfession ?? this.natureOfProfession,
      grossReceipts: grossReceipts ?? this.grossReceipts,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionIncome44ADA &&
        other.natureOfProfession == natureOfProfession &&
        other.grossReceipts == grossReceipts;
  }

  @override
  int get hashCode => Object.hash(natureOfProfession, grossReceipts);
}
