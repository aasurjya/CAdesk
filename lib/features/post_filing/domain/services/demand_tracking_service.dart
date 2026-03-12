import '../models/demand_tracker.dart';

/// Value object carrying the fields to update on a [DemandTracker].
class DemandStatusUpdate {
  const DemandStatusUpdate({
    required this.newStatus,
    this.newOutstandingAmount,
    this.interestAccruing,
  });

  final DemandTrackerStatus newStatus;
  final int? newOutstandingAmount;
  final bool? interestAccruing;
}

/// Stateless service for tax demand lifecycle management and interest
/// computation under Section 220(2) of the Income Tax Act.
///
/// All methods are pure functions — they return new [DemandTracker] instances
/// (or computed values) and never mutate the input.
///
/// Section 220(2) interest rules:
/// - Rate: 1% per month (or part thereof) on the outstanding demand.
/// - Charged from the date the demand was due until it is paid.
/// - Stops accruing when a stay is granted or demand is fully paid.
///
/// Note: Interest is computed on full completed months only (no proration for
/// partial months, consistent with the statute's "per month or part thereof"
/// reading applied conservatively here as completed months).
class DemandTrackingService {
  DemandTrackingService._();

  static final instance = DemandTrackingService._();

  /// Monthly interest rate under Sec 220(2): 1% per month.
  static const double _monthlyInterestRate = 0.01;

  /// Applies [update] to [tracker] and returns a new [DemandTracker] with the
  /// changed fields. The original [tracker] is not modified.
  static DemandTracker updateDemandStatus(
    DemandTracker tracker,
    DemandStatusUpdate update,
  ) {
    return tracker.copyWith(
      status: update.newStatus,
      outstandingAmount: update.newOutstandingAmount,
      interestAccruing: update.interestAccruing,
    );
  }

  /// Computes accrued Section 220(2) interest (in paise) on [tracker] as of
  /// [today].
  ///
  /// Returns 0 if:
  /// - [tracker.interestAccruing] is `false`.
  /// - [today] is on or before [tracker.dueDate].
  /// - [tracker.outstandingAmount] is 0.
  ///
  /// Interest is computed on **completed months only** from [tracker.dueDate]
  /// to [today].
  static int computeAccruedInterest(DemandTracker tracker, DateTime today) {
    if (!tracker.interestAccruing) return 0;
    if (tracker.outstandingAmount <= 0) return 0;
    if (!today.isAfter(tracker.dueDate)) return 0;

    final completedMonths = _completedMonths(tracker.dueDate, today);
    if (completedMonths <= 0) return 0;

    final interest =
        tracker.outstandingAmount * _monthlyInterestRate * completedMonths;
    return interest.floor();
  }

  /// Returns the sum of [DemandTracker.outstandingAmount] across all [demands].
  static int computeTotalOutstanding(List<DemandTracker> demands) {
    return demands.fold(0, (sum, d) => sum + d.outstandingAmount);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Counts fully completed calendar months between [from] and [to].
  static int _completedMonths(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return 0;
    int months = (to.year - from.year) * 12 + (to.month - from.month);
    // If the day of [to] has not yet reached the day of [from], subtract one.
    if (to.day < from.day) months--;
    return months < 0 ? 0 : months;
  }
}
