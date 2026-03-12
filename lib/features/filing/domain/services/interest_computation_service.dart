import 'package:ca_app/features/filing/domain/models/interest_result.dart';

/// Stateless service for computing interest under Sections 234A, 234B, 234C.
///
/// All interest rates are 1% per month (part of a month counted as full month).
class InterestComputationService {
  InterestComputationService._();

  /// Compute all interest components for a filing.
  ///
  /// [taxPayable] — net tax payable (after TDS/advance tax credits).
  /// [advanceTaxPaid] — total advance tax paid during the FY.
  /// [advanceTaxByQuarter] — advance tax paid by each quarterly due date:
  ///   [0] = paid by Jun 15, [1] = by Sep 15, [2] = by Dec 15, [3] = by Mar 15.
  /// [filingDate] — actual/expected date of filing the return.
  /// [dueDate] — statutory due date for filing (typically July 31).
  /// [assessmentYearStart] — April 1 of the assessment year.
  static InterestResult compute({
    required double taxPayable,
    required double advanceTaxPaid,
    required List<double> advanceTaxByQuarter,
    required DateTime filingDate,
    required DateTime dueDate,
    required DateTime assessmentYearStart,
  }) {
    if (taxPayable <= 0) {
      return const InterestResult(
        interest234A: 0,
        interest234B: 0,
        interest234C: 0,
        months234A: 0,
        months234B: 0,
        months234C: 0,
      );
    }

    final result234A = _compute234A(
      taxPayable: taxPayable,
      filingDate: filingDate,
      dueDate: dueDate,
    );

    final result234B = _compute234B(
      taxPayable: taxPayable,
      advanceTaxPaid: advanceTaxPaid,
      filingDate: filingDate,
      assessmentYearStart: assessmentYearStart,
    );

    final result234C = _compute234C(
      taxPayable: taxPayable,
      advanceTaxByQuarter: advanceTaxByQuarter,
    );

    return InterestResult(
      interest234A: result234A.$1,
      interest234B: result234B.$1,
      interest234C: result234C.$1,
      months234A: result234A.$2,
      months234B: result234B.$2,
      months234C: result234C.$2,
    );
  }

  // ---------------------------------------------------------------------------
  // 234A — Late filing of return
  // ---------------------------------------------------------------------------

  /// 1% per month on unpaid tax from due date to filing date.
  static (double interest, int months) _compute234A({
    required double taxPayable,
    required DateTime filingDate,
    required DateTime dueDate,
  }) {
    if (!filingDate.isAfter(dueDate)) return (0.0, 0);

    final months = _monthsBetween(dueDate, filingDate);
    if (months <= 0) return (0.0, 0);

    final interest = taxPayable * 0.01 * months;
    return (interest, months);
  }

  // ---------------------------------------------------------------------------
  // 234B — Non-payment / short-payment of advance tax
  // ---------------------------------------------------------------------------

  /// Applicable if advance tax paid < 90% of assessed tax.
  /// 1% per month from April 1 of AY to date of filing.
  static (double interest, int months) _compute234B({
    required double taxPayable,
    required double advanceTaxPaid,
    required DateTime filingDate,
    required DateTime assessmentYearStart,
  }) {
    // 234B is not applicable if advance tax paid >= 90% of tax payable.
    if (advanceTaxPaid >= taxPayable * 0.90) return (0.0, 0);

    final shortfall = taxPayable - advanceTaxPaid;
    if (shortfall <= 0) return (0.0, 0);

    final months = _monthsBetween(assessmentYearStart, filingDate);
    if (months <= 0) return (0.0, 0);

    final interest = shortfall * 0.01 * months;
    return (interest, months);
  }

  // ---------------------------------------------------------------------------
  // 234C — Deferment of advance tax installments
  // ---------------------------------------------------------------------------

  /// Quarterly installment schedule (% of estimated tax by each due date):
  /// Jun 15: 15%, Sep 15: 45%, Dec 15: 75%, Mar 15: 100%
  ///
  /// Interest: 1% per month for 3 months on shortfall per quarter.
  static (double interest, int months) _compute234C({
    required double taxPayable,
    required List<double> advanceTaxByQuarter,
  }) {
    // Advance tax is not required if tax payable < ₹10,000.
    if (taxPayable < 10000) return (0.0, 0);

    final q = List<double>.filled(4, 0);
    for (int i = 0; i < advanceTaxByQuarter.length && i < 4; i++) {
      q[i] = advanceTaxByQuarter[i];
    }

    // Cumulative amounts paid by each quarter.
    final cumulativePaid = <double>[
      q[0],
      q[0] + q[1],
      q[0] + q[1] + q[2],
      q[0] + q[1] + q[2] + q[3],
    ];

    // Required cumulative percentages.
    final requiredCumulative = <double>[
      taxPayable * 0.15, // by Jun 15
      taxPayable * 0.45, // by Sep 15
      taxPayable * 0.75, // by Dec 15
      taxPayable * 1.00, // by Mar 15
    ];

    double totalInterest = 0;
    int totalMonths = 0;

    for (int i = 0; i < 4; i++) {
      final shortfall = requiredCumulative[i] - cumulativePaid[i];
      if (shortfall > 0) {
        // Each quarter shortfall attracts 1% per month for 3 months.
        final interestMonths = i < 3 ? 3 : 1; // Last quarter = 1 month
        totalInterest += shortfall * 0.01 * interestMonths;
        totalMonths += interestMonths;
      }
    }

    return (totalInterest, totalMonths);
  }

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  /// Compute months between two dates. Part-month counted as full month.
  static int _monthsBetween(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return 0;

    int months = (to.year - from.year) * 12 + (to.month - from.month);

    // If there are remaining days beyond the month boundary, count as +1.
    if (to.day > from.day) months += 1;

    // Even if days are same but to is after from, at least 1 month.
    return months < 1 ? 1 : months;
  }
}
