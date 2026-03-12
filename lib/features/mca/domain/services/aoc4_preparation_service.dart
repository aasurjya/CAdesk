import 'package:ca_app/features/mca/domain/models/aoc4_financial_statement.dart';
import 'package:ca_app/features/mca/domain/models/company.dart';
import 'package:ca_app/features/mca/domain/models/financial_statements.dart';

/// Stateless service for preparing AOC-4 (Financial Statements) filings
/// under Section 137 of the Companies Act 2013.
///
/// Usage:
/// ```dart
/// final svc = Aoc4PreparationService.instance;
/// final form = svc.prepareAoc4(company, financialStatements, 2024);
/// final deadline = svc.computeFilingDeadline(agmDate);
/// ```
class Aoc4PreparationService {
  Aoc4PreparationService._();

  static final Aoc4PreparationService instance = Aoc4PreparationService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Build an [Aoc4FinancialStatement] from company and audited
  /// [FinancialStatements] data.
  ///
  /// The [financialYear] is the calendar year in which the FY ends
  /// (e.g. 2024 for FY 2023-24).
  ///
  /// The AGM date is defaulted to September 30 of [financialYear] (standard
  /// for March FY-end companies). Update via [Aoc4FinancialStatement.copyWith]
  /// once the actual AGM date is known.
  Aoc4FinancialStatement prepareAoc4(
    Company company,
    FinancialStatements fs,
    int financialYear,
  ) {
    return Aoc4FinancialStatement(
      cin: company.cin,
      financialYear: financialYear,
      auditReportDate: fs.auditReportDate,
      // Default AGM date — September 30, the statutory deadline
      agmDate: DateTime(financialYear, 9, 30),
      balanceSheetTotal: fs.balanceSheetTotal,
      profitAfterTax: fs.profitAfterTax,
      dividendPaid: fs.dividendPaid,
      auditQualifications: const [],
    );
  }

  /// Compute the AOC-4 filing deadline as 30 days from [agmDate].
  ///
  /// Section 137 of the Companies Act 2013 requires AOC-4 to be filed
  /// within 30 days from the date of the AGM.
  DateTime computeFilingDeadline(DateTime agmDate) {
    return agmDate.add(const Duration(days: 30));
  }
}
