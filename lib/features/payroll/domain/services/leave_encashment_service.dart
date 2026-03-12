/// Stateless service for computing leave encashment amounts.
///
/// Leave encashment is computed as:
///   `basicPerDay × pendingLeaves`
///
/// At retirement, the encashable leave is capped at [maxRetirementEncashableDays]
/// (30 days). During an in-service resignation, the cap does not apply (the
/// employer's leave policy governs the maximum).
///
/// All monetary values are in paise (1/100th of a rupee).
class LeaveEncashmentService {
  LeaveEncashmentService._();

  /// Maximum leave days encashable at retirement (government servants) — 30 days.
  static const int maxRetirementEncashableDays = 30;

  /// Number of working days in a month used as the divisor for daily rate.
  ///
  /// Standard practice in Indian payroll: divide monthly basic by 26.
  static const int workingDaysPerMonth = 26;

  /// Computes the daily Basic salary from the monthly Basic in paise.
  ///
  /// Uses [workingDaysPerMonth] (26) as the divisor per Indian payroll norms.
  static int dailyRateFromMonthly(int monthlyBasicPaise) {
    if (monthlyBasicPaise <= 0) return 0;
    return monthlyBasicPaise ~/ workingDaysPerMonth;
  }

  /// Computes the leave encashment amount in paise.
  ///
  /// Parameters:
  /// - [basicPerDayPaise] — daily Basic salary in paise.
  /// - [pendingLeaves] — number of pending leave days to encash.
  /// - [isRetirement] — when true, caps encashable leaves at
  ///   [maxRetirementEncashableDays]. Defaults to false.
  ///
  /// Returns 0 if [pendingLeaves] ≤ 0 or [basicPerDayPaise] ≤ 0.
  static int compute({
    required int basicPerDayPaise,
    required int pendingLeaves,
    bool isRetirement = false,
  }) {
    if (pendingLeaves <= 0) return 0;
    if (basicPerDayPaise <= 0) return 0;

    final encashableDays =
        isRetirement && pendingLeaves > maxRetirementEncashableDays
        ? maxRetirementEncashableDays
        : pendingLeaves;

    return basicPerDayPaise * encashableDays;
  }
}
