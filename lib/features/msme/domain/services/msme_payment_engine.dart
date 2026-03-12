import 'package:ca_app/features/msme/domain/models/msme_form1.dart';
import 'package:ca_app/features/msme/domain/models/msme_payment_tracker.dart';

/// Engine for tracking MSME payments and computing Section 43B(h) disallowances.
///
/// Section 43B(h) (effective FY 2023-24) disallows deductions for amounts
/// payable to micro and small MSME enterprises that remain unpaid as of
/// March 31 of the financial year beyond the statutory/contractual time limit.
///
/// Statutory limit: 45 days (15 days if written agreement specifies shorter).
/// Only micro and small enterprises are covered — medium enterprises are excluded.
class MsmePaymentEngine {
  MsmePaymentEngine._();

  static final MsmePaymentEngine instance = MsmePaymentEngine._();

  /// Computes the overdue status and disallowance risk for [tracker].
  ///
  /// Returns a new [MsmePaymentTracker] with [isOverdue], [daysOverdue],
  /// and [disallowanceRisk] fields populated.
  MsmePaymentTracker trackPayment(MsmePaymentTracker tracker) {
    final ref = _normalizeDate(tracker.referenceDate);
    final due = _normalizeDate(tracker.dueDate);
    final paid = tracker.paymentDate != null
        ? _normalizeDate(tracker.paymentDate!)
        : null;

    final bool isPaid = paid != null;
    final bool pastDue = isPaid ? paid.isAfter(due) : ref.isAfter(due);
    final int days = isPaid
        ? (paid.isAfter(due) ? paid.difference(due).inDays : 0)
        : (ref.isAfter(due) ? ref.difference(due).inDays : 0);

    // Disallowance risk: unpaid as of year-end (March 31) and beyond due date.
    final yearEnd = DateTime(ref.year, 3, 31);
    final bool atRisk =
        !isPaid &&
        (tracker.msmeCategory == MsmeCategory.micro ||
            tracker.msmeCategory == MsmeCategory.small) &&
        _normalizeDate(tracker.dueDate).isBefore(yearEnd) &&
        ref.isAfter(tracker.dueDate);

    return tracker.copyWith(
      isOverdue: pastDue && days > 0,
      daysOverdue: days,
      disallowanceRisk: atRisk,
    );
  }

  /// Computes the total Section 43B(h) disallowance amount in paise.
  ///
  /// Disallows amounts payable to micro and small MSME vendors that remain
  /// unpaid beyond the statutory 45-day period as of March 31 of [financialYear].
  ///
  /// [financialYear] is the ending year (e.g., 2024 for FY 2023-24).
  int computeSection43BhDisallowance(
    List<MsmePaymentTracker> trackers,
    int financialYear,
  ) {
    final yearEnd = DateTime(financialYear, 3, 31);
    var total = 0;

    for (final tracker in trackers) {
      // Only micro and small; medium is excluded from Sec 43B(h)
      if (tracker.msmeCategory == MsmeCategory.medium) continue;

      final due = _normalizeDate(tracker.dueDate);
      // Must be due before year end
      if (!due.isBefore(yearEnd) && due != yearEnd) continue;

      // Disallow if unpaid (no payment date or paid after year end)
      final paid = tracker.paymentDate != null
          ? _normalizeDate(tracker.paymentDate!)
          : null;
      final unpaidAtYearEnd = paid == null || paid.isAfter(yearEnd);

      if (unpaidAtYearEnd) {
        total += tracker.amountPaise;
      }
    }

    return total;
  }

  /// Generates an MSME Form-1 for the given [halfYear] period.
  ///
  /// Includes only trackers that have outstanding (unpaid) amounts.
  MsmeForm1 generateMsmeForm1(
    List<MsmePaymentTracker> trackers,
    String halfYear,
  ) {
    final unpaid = trackers
        .where((t) => t.paymentDate == null)
        .toList(growable: false);
    return MsmeForm1(period: halfYear, unpaidEntries: unpaid);
  }

  DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
