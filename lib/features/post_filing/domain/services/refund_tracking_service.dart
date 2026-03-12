import '../models/refund_tracker.dart';

/// Value object carrying the fields to update on a [RefundTracker].
class RefundStatusUpdate {
  const RefundStatusUpdate({
    required this.newStatus,
    this.issuedDate,
    this.adjustedAgainstDemand,
    this.expectedDate,
  });

  final RefundTrackerStatus newStatus;
  final DateTime? issuedDate;
  final bool? adjustedAgainstDemand;
  final DateTime? expectedDate;
}

/// Stateless service for refund lifecycle management and interest computation
/// under Section 244A of the Income Tax Act.
///
/// All methods are pure functions — they return new [RefundTracker] instances
/// and never mutate the input.
///
/// Section 244A interest rules:
/// - Rate: 6% per annum (simple interest).
/// - Start: 1st April of the Assessment Year, OR the date of filing,
///   whichever is later.
/// - End: Date of grant of refund.
/// - Threshold: Only applicable when refund > 10% of the tax as determined.
///   (Caller is responsible for the 10% threshold check if needed.)
/// - Grace period: No interest is payable if the refund is processed within
///   90 days of the return due date.
class RefundTrackingService {
  RefundTrackingService._();

  static final instance = RefundTrackingService._();

  /// Number of days within which a refund must be issued before interest runs.
  static const int _gracePeriodDays = 90;

  /// Annual interest rate for delayed refunds (Sec 244A): 6% p.a.
  static const double _annualInterestRate = 0.06;

  /// Applies [update] to [tracker] and returns a new [RefundTracker] with the
  /// changed fields. The original [tracker] is not modified.
  static RefundTracker updateRefundStatus(
    RefundTracker tracker,
    RefundStatusUpdate update,
  ) {
    return tracker.copyWith(
      status: update.newStatus,
      issuedDate: update.issuedDate,
      adjustedAgainstDemand: update.adjustedAgainstDemand,
      expectedDate: update.expectedDate,
    );
  }

  /// Computes accrued Section 244A interest (in paise) on [tracker] as of
  /// [today].
  ///
  /// Returns 0 if:
  /// - The refund has already been issued.
  /// - [today] is within the 90-day grace period from [returnDueDate].
  ///
  /// Interest is computed from 1 April of the assessment year (derived from
  /// [returnDueDate] as the financial year start) to [today].
  static int computeRefundInterest(
    RefundTracker tracker,
    DateTime today, {
    required DateTime returnDueDate,
  }) {
    if (tracker.status == RefundTrackerStatus.issued) return 0;

    // Grace period: no interest if today is within 90 days of the return due date.
    final graceEnd = returnDueDate.add(const Duration(days: _gracePeriodDays));
    if (!today.isAfter(graceEnd)) return 0;

    // Interest starts from 1 April of the AY (the financial year that
    // corresponds to the return's due date).
    final interestStartDate = _interestStartDate(
      tracker.assessmentYear,
      returnDueDate,
    );

    final daysElapsed = today.difference(interestStartDate).inDays;
    if (daysElapsed <= 0) return 0;

    // Simple interest: principal × rate × (days / 365)
    final interest =
        tracker.refundAmount * _annualInterestRate * daysElapsed / 365;
    return interest.floor();
  }

  /// Returns `true` if the refund has not been issued within 90 days of
  /// [returnDueDate].
  static bool isDelayed(
    RefundTracker tracker, {
    required DateTime today,
    required DateTime returnDueDate,
  }) {
    final issuedDate = tracker.issuedDate;
    if (issuedDate != null) {
      // Refund was issued — check whether it was issued within the grace period.
      final graceEnd = returnDueDate.add(
        const Duration(days: _gracePeriodDays),
      );
      return issuedDate.isAfter(graceEnd);
    }
    // Refund not yet issued — delayed if today is past the grace period.
    final graceEnd = returnDueDate.add(const Duration(days: _gracePeriodDays));
    return today.isAfter(graceEnd);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Derives the interest start date: 1 April of the assessment year.
  ///
  /// For AY "2024-25", the financial year starts on 1 Apr 2024.
  static DateTime _interestStartDate(
    String assessmentYear,
    DateTime returnDueDate,
  ) {
    // Parse the starting year from "YYYY-YY" format (e.g. "2024-25" → 2024).
    final parts = assessmentYear.split('-');
    if (parts.length == 2) {
      final year = int.tryParse(parts[0]);
      if (year != null) {
        return DateTime(year, 4, 1);
      }
    }
    // Fallback: derive from the return due date's year.
    return DateTime(returnDueDate.year, 4, 1);
  }
}
