// LLP Form-8: Statement of Account and Solvency.
// Filed annually with MCA. Deadline: October 30 of the year following
// the financial year end. Must be certified by a Chartered Accountant.

/// Financial statements data used to prepare Form-8.
class FinancialStatements {
  const FinancialStatements({
    required this.totalAssetsPaise,
    required this.totalLiabilitiesPaise,
    required this.turnoverPaise,
    required this.profitAfterTaxPaise,
  });

  /// Total assets of the LLP in paise.
  final int totalAssetsPaise;

  /// Total liabilities of the LLP in paise.
  final int totalLiabilitiesPaise;

  /// Total turnover for the financial year in paise.
  final int turnoverPaise;

  /// Profit or loss after tax for the financial year in paise.
  /// Negative value indicates a loss.
  final int profitAfterTaxPaise;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialStatements &&
        other.totalAssetsPaise == totalAssetsPaise &&
        other.totalLiabilitiesPaise == totalLiabilitiesPaise &&
        other.turnoverPaise == turnoverPaise &&
        other.profitAfterTaxPaise == profitAfterTaxPaise;
  }

  @override
  int get hashCode => Object.hash(
    totalAssetsPaise,
    totalLiabilitiesPaise,
    turnoverPaise,
    profitAfterTaxPaise,
  );
}

/// Immutable model for LLP Form-8 (Statement of Account and Solvency).
class LlpForm8 {
  const LlpForm8({
    required this.llpin,
    required this.financialYear,
    required this.totalAssetsPaise,
    required this.totalLiabilitiesPaise,
    required this.turnoverPaise,
    required this.profitAfterTaxPaise,
    required this.solvencyDeclaration,
  });

  /// LLP Identification Number.
  final String llpin;

  /// Financial year for which this statement is being filed.
  final int financialYear;

  /// Total assets in paise.
  final int totalAssetsPaise;

  /// Total liabilities in paise.
  final int totalLiabilitiesPaise;

  /// Total turnover in paise.
  final int turnoverPaise;

  /// Profit or loss after tax in paise (negative = loss).
  final int profitAfterTaxPaise;

  /// Solvency declaration: true if assets >= liabilities.
  final bool solvencyDeclaration;

  LlpForm8 copyWith({
    String? llpin,
    int? financialYear,
    int? totalAssetsPaise,
    int? totalLiabilitiesPaise,
    int? turnoverPaise,
    int? profitAfterTaxPaise,
    bool? solvencyDeclaration,
  }) {
    return LlpForm8(
      llpin: llpin ?? this.llpin,
      financialYear: financialYear ?? this.financialYear,
      totalAssetsPaise: totalAssetsPaise ?? this.totalAssetsPaise,
      totalLiabilitiesPaise:
          totalLiabilitiesPaise ?? this.totalLiabilitiesPaise,
      turnoverPaise: turnoverPaise ?? this.turnoverPaise,
      profitAfterTaxPaise: profitAfterTaxPaise ?? this.profitAfterTaxPaise,
      solvencyDeclaration: solvencyDeclaration ?? this.solvencyDeclaration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LlpForm8 &&
        other.llpin == llpin &&
        other.financialYear == financialYear &&
        other.totalAssetsPaise == totalAssetsPaise &&
        other.totalLiabilitiesPaise == totalLiabilitiesPaise &&
        other.turnoverPaise == turnoverPaise &&
        other.profitAfterTaxPaise == profitAfterTaxPaise &&
        other.solvencyDeclaration == solvencyDeclaration;
  }

  @override
  int get hashCode => Object.hash(
    llpin,
    financialYear,
    totalAssetsPaise,
    totalLiabilitiesPaise,
    turnoverPaise,
    profitAfterTaxPaise,
    solvencyDeclaration,
  );
}
