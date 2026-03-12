/// TDS return quarter.
enum TdsQuarter { q1, q2, q3, q4 }

/// A single short-deduction entry in a TRACES justification report.
///
/// A short deduction arises when the amount deducted at source was less
/// than what was statutorily required under the relevant section.
///
/// All monetary values are in **paise**.
class ShortDeductionEntry {
  const ShortDeductionEntry({
    required this.pan,
    required this.section,
    required this.amountPaid,
    required this.tdsDeducted,
    required this.tdsRequired,
    required this.shortfall,
  });

  /// PAN of the deductee.
  final String pan;

  /// Income-tax section under which deduction was made (e.g. "192", "194C").
  final String section;

  /// Gross amount paid / credited to the deductee, in paise.
  final int amountPaid;

  /// Actual TDS deducted and deposited, in paise.
  final int tdsDeducted;

  /// TDS amount that should have been deducted, in paise.
  final int tdsRequired;

  /// Difference (tdsRequired − tdsDeducted), in paise.
  final int shortfall;

  /// Returns a new [ShortDeductionEntry] with selected fields replaced.
  ShortDeductionEntry copyWith({
    String? pan,
    String? section,
    int? amountPaid,
    int? tdsDeducted,
    int? tdsRequired,
    int? shortfall,
  }) {
    return ShortDeductionEntry(
      pan: pan ?? this.pan,
      section: section ?? this.section,
      amountPaid: amountPaid ?? this.amountPaid,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      tdsRequired: tdsRequired ?? this.tdsRequired,
      shortfall: shortfall ?? this.shortfall,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShortDeductionEntry &&
        other.pan == pan &&
        other.section == section &&
        other.amountPaid == amountPaid &&
        other.tdsDeducted == tdsDeducted &&
        other.tdsRequired == tdsRequired &&
        other.shortfall == shortfall;
  }

  @override
  int get hashCode => Object.hash(
        pan,
        section,
        amountPaid,
        tdsDeducted,
        tdsRequired,
        shortfall,
      );
}

/// A single late-deduction entry in a TRACES justification report.
///
/// A late deduction arises when TDS was deducted but deposited after the
/// due date prescribed under section 200 / Rule 30.
///
/// All monetary values are in **paise**.
class LateDeductionEntry {
  const LateDeductionEntry({
    required this.pan,
    required this.section,
    required this.dueDate,
    required this.depositedDate,
    required this.daysLate,
    required this.interest,
  });

  /// PAN of the deductee.
  final String pan;

  /// Income-tax section under which deduction was made.
  final String section;

  /// Statutory due date for depositing TDS.
  final String dueDate;

  /// Actual date on which TDS was deposited.
  final String depositedDate;

  /// Number of calendar days by which the deposit was late.
  final int daysLate;

  /// Interest levied for late deposit, in paise (@ 1.5% per month).
  final int interest;

  /// Returns a new [LateDeductionEntry] with selected fields replaced.
  LateDeductionEntry copyWith({
    String? pan,
    String? section,
    String? dueDate,
    String? depositedDate,
    int? daysLate,
    int? interest,
  }) {
    return LateDeductionEntry(
      pan: pan ?? this.pan,
      section: section ?? this.section,
      dueDate: dueDate ?? this.dueDate,
      depositedDate: depositedDate ?? this.depositedDate,
      daysLate: daysLate ?? this.daysLate,
      interest: interest ?? this.interest,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LateDeductionEntry &&
        other.pan == pan &&
        other.section == section &&
        other.dueDate == dueDate &&
        other.depositedDate == depositedDate &&
        other.daysLate == daysLate &&
        other.interest == interest;
  }

  @override
  int get hashCode => Object.hash(
        pan,
        section,
        dueDate,
        depositedDate,
        daysLate,
        interest,
      );
}

/// Immutable justification report for a TAN / quarter on TRACES.
///
/// Summarises all short-deduction and late-deduction entries raised by
/// CPC-TDS for the given TAN in the specified financial year and quarter.
///
/// All monetary totals are in **paise**.
class TracesJustificationReport {
  const TracesJustificationReport({
    required this.tan,
    required this.financialYear,
    required this.quarter,
    required this.shortDeductions,
    required this.lateDeductions,
    required this.totalShortfall,
    required this.totalInterestDemand,
  });

  /// TAN of the deductor.
  final String tan;

  /// Financial year (e.g. 2024 for FY 2024-25).
  final int financialYear;

  /// Quarter to which this report pertains.
  final TdsQuarter quarter;

  /// List of short-deduction entries (may be empty).
  final List<ShortDeductionEntry> shortDeductions;

  /// List of late-deduction entries (may be empty).
  final List<LateDeductionEntry> lateDeductions;

  /// Sum of all [ShortDeductionEntry.shortfall] values, in paise.
  final int totalShortfall;

  /// Total interest demand raised for late deposits, in paise.
  final int totalInterestDemand;

  /// Returns a new [TracesJustificationReport] with selected fields replaced.
  TracesJustificationReport copyWith({
    String? tan,
    int? financialYear,
    TdsQuarter? quarter,
    List<ShortDeductionEntry>? shortDeductions,
    List<LateDeductionEntry>? lateDeductions,
    int? totalShortfall,
    int? totalInterestDemand,
  }) {
    return TracesJustificationReport(
      tan: tan ?? this.tan,
      financialYear: financialYear ?? this.financialYear,
      quarter: quarter ?? this.quarter,
      shortDeductions: shortDeductions ?? this.shortDeductions,
      lateDeductions: lateDeductions ?? this.lateDeductions,
      totalShortfall: totalShortfall ?? this.totalShortfall,
      totalInterestDemand: totalInterestDemand ?? this.totalInterestDemand,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TracesJustificationReport) return false;
    if (other.tan != tan) return false;
    if (other.financialYear != financialYear) return false;
    if (other.quarter != quarter) return false;
    if (other.totalShortfall != totalShortfall) return false;
    if (other.totalInterestDemand != totalInterestDemand) return false;
    if (other.shortDeductions.length != shortDeductions.length) return false;
    if (other.lateDeductions.length != lateDeductions.length) return false;
    return true;
  }

  @override
  int get hashCode => Object.hash(
        tan,
        financialYear,
        quarter,
        totalShortfall,
        totalInterestDemand,
        shortDeductions.length,
        lateDeductions.length,
      );
}
