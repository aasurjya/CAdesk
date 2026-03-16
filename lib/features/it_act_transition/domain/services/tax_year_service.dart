import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';
import 'package:ca_app/features/it_act_transition/domain/models/tax_year.dart';

/// Utility service for Tax Year operations — conversion between AY/TY/FY,
/// due date calculation, and Act-aware formatting.
class TaxYearService {
  TaxYearService._();

  /// Convert an Assessment Year string to a Tax Year string.
  /// "AY 2026-27" → "TY 2025-26" (if under 2025 Act)
  /// "AY 2025-26" → "AY 2025-26" (still under 1961 Act)
  static String ayToDisplayLabel(String ay) {
    final ty = TaxYear.fromAssessmentYear(ay);
    return ty.displayLabel;
  }

  /// Convert a Financial Year string to the appropriate display label.
  /// "2025-26" → "AY 2026-27" (under 1961 Act)
  /// "2026-27" → "TY 2026-27" (under 2025 Act)
  static String fyToDisplayLabel(String fy) {
    final ty = TaxYear.fromFinancialYear(fy);
    return ty.displayLabel;
  }

  /// Returns the ITR filing due date for a given tax year.
  ///
  /// Non-audit: July 31 of the AY/TY year.
  /// Audit: October 31 of the AY/TY year.
  /// TP: November 30 of the AY/TY year.
  static DateTime filingDueDate({
    required TaxYear taxYear,
    bool isAuditCase = false,
    bool isTransferPricingCase = false,
  }) {
    final ayYear = taxYear.endYear;
    if (isTransferPricingCase) {
      return DateTime(ayYear, 11, 30);
    }
    if (isAuditCase) {
      return DateTime(ayYear, 10, 31);
    }
    return DateTime(ayYear, 7, 31);
  }

  /// Returns the belated/revised return deadline (December 31 of AY).
  static DateTime belatedReturnDeadline(TaxYear taxYear) {
    return DateTime(taxYear.endYear, 12, 31);
  }

  /// Returns the ITR-U (updated return) deadline — 4 years from end of AY.
  static DateTime updatedReturnDeadline(TaxYear taxYear) {
    return DateTime(taxYear.endYear + 4, 3, 31);
  }

  /// Returns advance tax installment dates for a given tax year.
  static List<AdvanceTaxInstallment> advanceTaxInstallments(TaxYear taxYear) {
    final year = taxYear.startYear;
    return [
      AdvanceTaxInstallment(
        dueDate: DateTime(year, 6, 15),
        cumulativePercent: 15,
        label: '1st installment',
      ),
      AdvanceTaxInstallment(
        dueDate: DateTime(year, 9, 15),
        cumulativePercent: 45,
        label: '2nd installment',
      ),
      AdvanceTaxInstallment(
        dueDate: DateTime(year, 12, 15),
        cumulativePercent: 75,
        label: '3rd installment',
      ),
      AdvanceTaxInstallment(
        dueDate: DateTime(year + 1, 3, 15),
        cumulativePercent: 100,
        label: '4th installment',
      ),
    ];
  }

  /// Returns the Act name for a given financial year.
  static String actNameForFy(String fy) => ActMode.forFinancialYear(fy).label;

  /// Returns a list of recent tax years (current + 5 prior).
  static List<TaxYear> recentTaxYears({int count = 6}) {
    final current = TaxYear.current;
    return List.generate(
      count,
      (i) => TaxYear(startYear: current.startYear - i),
    );
  }

  /// Returns whether an assessment year string is under the new Act.
  static bool isUnderNewAct(String ay) {
    return ActMode.forAssessmentYear(ay) == ActMode.act2025;
  }
}

/// An advance tax installment with due date and cumulative percentage.
class AdvanceTaxInstallment {
  const AdvanceTaxInstallment({
    required this.dueDate,
    required this.cumulativePercent,
    required this.label,
  });

  final DateTime dueDate;
  final int cumulativePercent;
  final String label;

  @override
  String toString() =>
      'AdvanceTaxInstallment($label: $cumulativePercent% by $dueDate)';
}
