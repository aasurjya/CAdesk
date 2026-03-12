import 'package:ca_app/features/llp/domain/models/llp_form8.dart';
import 'package:ca_app/features/llp/domain/models/llp_form11.dart';

/// Service for preparing LLP Form-8 (Statement of Account and Solvency) and
/// computing the statutory filing deadline.
///
/// Form-8 must be filed within 30 days from the end of six months of the
/// financial year, effectively by October 30 of the year in which the
/// financial year ends.
class LlpForm8Service {
  LlpForm8Service._();

  static final LlpForm8Service instance = LlpForm8Service._();

  /// Prepares an LLP Form-8 from [llp] entity data and [fs] financial statements.
  ///
  /// [financialYear] is the ending year of the financial year
  /// (e.g., 2024 represents FY 2023-24).
  ///
  /// The solvency declaration is `true` if total assets >= total liabilities.
  LlpForm8 prepareForm8(
    LlpData llp,
    FinancialStatements fs,
    int financialYear,
  ) {
    final isSolvent = fs.totalAssetsPaise >= fs.totalLiabilitiesPaise;
    return LlpForm8(
      llpin: llp.llpin,
      financialYear: financialYear,
      totalAssetsPaise: fs.totalAssetsPaise,
      totalLiabilitiesPaise: fs.totalLiabilitiesPaise,
      turnoverPaise: fs.turnoverPaise,
      profitAfterTaxPaise: fs.profitAfterTaxPaise,
      solvencyDeclaration: isSolvent,
    );
  }

  /// Returns the statutory deadline for Form-8 filing.
  ///
  /// Deadline is October 30 of [financialYear] (the year in which the FY ends).
  /// For FY 2023-24 (ending March 31, 2024), deadline is October 30, 2024.
  DateTime computeDeadline(int financialYear) {
    return DateTime(financialYear, 10, 30);
  }
}
