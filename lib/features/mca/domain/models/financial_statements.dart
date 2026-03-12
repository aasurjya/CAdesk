/// Immutable model holding audited financial statement figures for a
/// company for a given financial year.
///
/// Used as input to [Aoc4PreparationService.prepareAoc4].
class FinancialStatements {
  const FinancialStatements({
    required this.balanceSheetTotal,
    required this.profitAfterTax,
    required this.dividendPaid,
    required this.auditReportDate,
  });

  /// Total assets (= total liabilities) from balance sheet in ₹.
  final double balanceSheetTotal;

  /// Net profit after tax for the year in ₹.
  final double profitAfterTax;

  /// Total dividends paid or declared during the year in ₹.
  final double dividendPaid;

  /// Date on which the auditor's report was signed.
  final DateTime auditReportDate;

  FinancialStatements copyWith({
    double? balanceSheetTotal,
    double? profitAfterTax,
    double? dividendPaid,
    DateTime? auditReportDate,
  }) {
    return FinancialStatements(
      balanceSheetTotal: balanceSheetTotal ?? this.balanceSheetTotal,
      profitAfterTax: profitAfterTax ?? this.profitAfterTax,
      dividendPaid: dividendPaid ?? this.dividendPaid,
      auditReportDate: auditReportDate ?? this.auditReportDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialStatements &&
        other.balanceSheetTotal == balanceSheetTotal &&
        other.profitAfterTax == profitAfterTax &&
        other.dividendPaid == dividendPaid &&
        other.auditReportDate == auditReportDate;
  }

  @override
  int get hashCode => Object.hash(
    balanceSheetTotal,
    profitAfterTax,
    dividendPaid,
    auditReportDate,
  );
}
