import 'package:ca_app/features/llp/domain/models/llp_form11.dart';

/// Service for preparing LLP Form-11 (Annual Return) and computing
/// related deadlines and penalties.
///
/// Form-11 must be filed within 60 days of close of financial year,
/// which translates to May 30 of the following calendar year.
class LlpForm11Service {
  LlpForm11Service._();

  static final LlpForm11Service instance = LlpForm11Service._();

  /// Prepares an LLP Form-11 from [llp] entity data.
  ///
  /// [financialYear] is the ending year of the financial year
  /// (e.g., 2024 represents FY 2023-24).
  LlpForm11 prepareForm11(LlpData llp, int financialYear) {
    return LlpForm11(
      llpin: llp.llpin,
      name: llp.name,
      registeredOffice: llp.registeredOffice,
      numberOfPartners: llp.numberOfPartners,
      totalContributionPaise: llp.totalContributionPaise,
      financialYear: financialYear,
      partners: const [],
      meetings: const [],
    );
  }

  /// Returns the statutory deadline for Form-11 filing.
  ///
  /// Deadline is May 30 of [financialYear] (the year in which the FY ends).
  /// For FY 2023-24 (ending March 31, 2024), deadline is May 30, 2024.
  DateTime computeDeadline(int financialYear) {
    return DateTime(financialYear, 5, 30);
  }

  /// Computes the penalty for late filing of Form-11.
  ///
  /// Penalty: ₹100 per day (= 10,000 paise/day) beyond the due date.
  /// Returns 0 if filed on or before the due date.
  int computePenalty(DateTime dueDate, DateTime filedDate) {
    final filedDay = DateTime(filedDate.year, filedDate.month, filedDate.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = filedDay.difference(dueDay).inDays;
    if (diff <= 0) return 0;
    // ₹100 per day = 10000 paise per day
    return diff * 10000;
  }
}
