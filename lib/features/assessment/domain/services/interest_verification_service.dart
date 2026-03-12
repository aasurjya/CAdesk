/// A single advance tax installment paid by the taxpayer.
class AdvanceTaxInstallment {
  const AdvanceTaxInstallment({
    required this.dueDate,
    required this.amountPaid,
  });

  /// Statutory due date for the installment.
  final DateTime dueDate;

  /// Amount actually paid on or before [dueDate] (paise).
  final int amountPaid;
}

/// Stateless service for computing interest under Sections 234A, 234B, 234C,
/// and 220(2) of the Income Tax Act, 1961.
///
/// All inputs and outputs are in **paise** (integer arithmetic).
class InterestVerificationService {
  InterestVerificationService._();

  static final InterestVerificationService instance =
      InterestVerificationService._();

  // -------------------------------------------------------------------------
  // Section 234A — Delayed Filing
  // -------------------------------------------------------------------------

  /// Interest for delayed filing under Section 234A.
  ///
  /// Rate    : 1% per month or part thereof.
  /// Period  : [dueDate] (exclusive) to [filingDate] (inclusive).
  /// Base    : [taxDue] — the tax payable after deducting advance tax and TDS.
  ///
  /// Returns 0 if [taxDue] ≤ 0 or [filingDate] is on/before [dueDate].
  int computeInterest234A(int taxDue, DateTime dueDate, DateTime filingDate) {
    if (taxDue <= 0) return 0;
    final months = _monthsDelayed(dueDate, filingDate);
    if (months <= 0) return 0;
    return (taxDue * months) ~/ 100;
  }

  // -------------------------------------------------------------------------
  // Section 234B — Advance Tax Shortfall
  // -------------------------------------------------------------------------

  /// Interest for shortfall in advance tax under Section 234B.
  ///
  /// Applies when advance tax paid < 90% of assessed tax.
  /// Rate    : 1% per month for a fixed 12-month period (April 1 to March 31).
  /// Base    : shortfall = assessedTax - advanceTaxPaid.
  ///
  /// Returns 0 if advance tax paid ≥ 90% of [assessedTax].
  int computeInterest234B(int assessedTax, int advanceTaxPaid) {
    if (assessedTax <= 0) return 0;
    final threshold90Pct = (assessedTax * 90) ~/ 100;
    if (advanceTaxPaid >= threshold90Pct) return 0;
    final shortfall = assessedTax - advanceTaxPaid;
    // Fixed 12-month period from April 1 to end of assessment year.
    const months = 12;
    return (shortfall * months) ~/ 100;
  }

  // -------------------------------------------------------------------------
  // Section 234C — Deferment of Advance Tax Installments
  // -------------------------------------------------------------------------

  /// Interest for deferment of advance tax installments under Section 234C.
  ///
  /// Installment schedule (% of total tax due):
  /// - Jun 15  : 15% due; interest if cumulative paid < 12%
  /// - Sep 15  : 45% due; interest if cumulative paid < 36%
  /// - Dec 15  : 75% due; interest if cumulative paid < 75%
  /// - Mar 15  : 100% due; interest if cumulative paid < 100%
  ///
  /// Rate: 1% per month × 3 months per missed installment.
  /// Base: installment amount (not cumulative shortfall).
  ///
  /// [installments] must contain up to 4 entries ordered by due date.
  /// Returns total 234C interest in paise.
  int computeInterest234C(
    List<AdvanceTaxInstallment> installments,
    int totalTaxDue,
  ) {
    if (installments.isEmpty || totalTaxDue <= 0) return 0;

    // Installment thresholds: (duePercent, minimumPaidPercent)
    // The "minimum paid" is the fraction CPC requires to avoid interest.
    const schedule = [
      _InstallmentSchedule(duePct: 15, minPaidPct: 12),
      _InstallmentSchedule(duePct: 45, minPaidPct: 36),
      _InstallmentSchedule(duePct: 75, minPaidPct: 75),
      _InstallmentSchedule(duePct: 100, minPaidPct: 100),
    ];

    int totalInterest = 0;
    int cumulativePaid = 0;

    for (var i = 0; i < schedule.length && i < installments.length; i++) {
      final slot = schedule[i];
      final installment = installments[i];
      cumulativePaid += installment.amountPaid;

      final minRequired = (totalTaxDue * slot.minPaidPct) ~/ 100;
      if (cumulativePaid < minRequired) {
        // Shortfall = installment due amount (not cumulative)
        final installmentDue = (totalTaxDue * slot.duePct) ~/ 100;
        final shortfall = installmentDue - cumulativePaid;
        // Interest = 1% per month × 3 months
        totalInterest += (shortfall * 3) ~/ 100;
      }
    }

    return totalInterest;
  }

  // -------------------------------------------------------------------------
  // Section 220(2) — Overdue Demand
  // -------------------------------------------------------------------------

  /// Interest on overdue tax demand under Section 220(2).
  ///
  /// Rate   : 1% per month or part thereof.
  /// Base   : [demand] in paise.
  /// Period : [daysOverdue] days from the date the demand became payable.
  ///
  /// Returns 0 if [demand] ≤ 0 or [daysOverdue] ≤ 0.
  int computeInterest220_2(int demand, int daysOverdue) {
    if (demand <= 0 || daysOverdue <= 0) return 0;
    final months = _daysToMonthsCeilDiv(daysOverdue);
    return (demand * months) ~/ 100;
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Number of calendar months (rounded up) between [from] and [to].
  /// Returns 0 when [to] is on or before [from].
  int _monthsDelayed(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return 0;

    int months = (to.year - from.year) * 12 + (to.month - from.month);

    // If the day-of-month in [to] is strictly after [from]'s day, add one
    // more partial month.
    if (to.day > from.day) {
      months += 1;
    }

    // Guard: at least 1 month when there is any positive delay.
    if (months <= 0) return 1;
    return months;
  }

  /// Converts [days] to whole months (rounded up), where 30 days = 1 month.
  ///
  /// Any remainder above a complete 30-day month counts as one full month.
  int _daysToMonthsCeilDiv(int days) {
    return (days + 29) ~/ 30;
  }
}

/// Internal value object for the 234C installment schedule.
class _InstallmentSchedule {
  const _InstallmentSchedule({required this.duePct, required this.minPaidPct});

  final int duePct;
  final int minPaidPct;
}
