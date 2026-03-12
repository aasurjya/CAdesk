// ---------------------------------------------------------------------------
// Audit qualification
// ---------------------------------------------------------------------------

/// A qualification, reservation, or adverse remark in the audit report.
class AuditQualification {
  const AuditQualification({
    required this.qualificationNumber,
    required this.description,
    required this.managementReply,
  });

  final String qualificationNumber;
  final String description;
  final String managementReply;

  AuditQualification copyWith({
    String? qualificationNumber,
    String? description,
    String? managementReply,
  }) {
    return AuditQualification(
      qualificationNumber: qualificationNumber ?? this.qualificationNumber,
      description: description ?? this.description,
      managementReply: managementReply ?? this.managementReply,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditQualification &&
        other.qualificationNumber == qualificationNumber &&
        other.description == description &&
        other.managementReply == managementReply;
  }

  @override
  int get hashCode =>
      Object.hash(qualificationNumber, description, managementReply);
}

// ---------------------------------------------------------------------------
// AOC-4 Financial Statement
// ---------------------------------------------------------------------------

/// Immutable model representing an AOC-4 (Financial Statements) filing
/// under Section 137 of the Companies Act 2013.
///
/// Filing deadline: 30 days from the date of the AGM.
/// For March FY-end companies with September 30 AGM → deadline October 30.
class Aoc4FinancialStatement {
  const Aoc4FinancialStatement({
    required this.cin,
    required this.financialYear,
    required this.auditReportDate,
    required this.agmDate,
    required this.balanceSheetTotal,
    required this.profitAfterTax,
    required this.dividendPaid,
    required this.auditQualifications,
  });

  /// Corporate Identification Number.
  final String cin;

  /// Calendar year in which the financial year ends (e.g. 2024 for FY 2023-24).
  final int financialYear;

  final DateTime auditReportDate;
  final DateTime agmDate;

  /// Total assets / total liabilities figure from balance sheet (in ₹).
  final double balanceSheetTotal;

  /// Net profit after tax for the year (in ₹).
  final double profitAfterTax;

  /// Total dividend paid or declared during the year (in ₹).
  final double dividendPaid;

  final List<AuditQualification> auditQualifications;

  bool get hasQualifications => auditQualifications.isNotEmpty;

  Aoc4FinancialStatement copyWith({
    String? cin,
    int? financialYear,
    DateTime? auditReportDate,
    DateTime? agmDate,
    double? balanceSheetTotal,
    double? profitAfterTax,
    double? dividendPaid,
    List<AuditQualification>? auditQualifications,
  }) {
    return Aoc4FinancialStatement(
      cin: cin ?? this.cin,
      financialYear: financialYear ?? this.financialYear,
      auditReportDate: auditReportDate ?? this.auditReportDate,
      agmDate: agmDate ?? this.agmDate,
      balanceSheetTotal: balanceSheetTotal ?? this.balanceSheetTotal,
      profitAfterTax: profitAfterTax ?? this.profitAfterTax,
      dividendPaid: dividendPaid ?? this.dividendPaid,
      auditQualifications: auditQualifications ?? this.auditQualifications,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Aoc4FinancialStatement &&
        other.cin == cin &&
        other.financialYear == financialYear &&
        other.auditReportDate == auditReportDate &&
        other.agmDate == agmDate &&
        other.balanceSheetTotal == balanceSheetTotal &&
        other.profitAfterTax == profitAfterTax &&
        other.dividendPaid == dividendPaid;
  }

  @override
  int get hashCode => Object.hash(
    cin,
    financialYear,
    auditReportDate,
    agmDate,
    balanceSheetTotal,
    profitAfterTax,
    dividendPaid,
  );
}
