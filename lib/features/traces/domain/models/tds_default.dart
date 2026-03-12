/// Immutable model for a TDS default entry from TRACES.
///
/// A TDS default arises when the deductor fails to deduct or deposit TDS
/// as required under the Income Tax Act. TRACES tracks these defaults
/// and generates demand notices.
class TdsDefault {
  const TdsDefault({
    required this.tan,
    required this.section,
    required this.financialYear,
    required this.quarter,
    required this.shortDeductionPaise,
    required this.lateFilingFeePaise,
    required this.interestPaise,
    required this.totalDemandPaise,
    required this.isResolved,
  });

  /// TAN of the deductor.
  final String tan;

  /// Section under which the default occurred (e.g., '194A', '192').
  final String section;

  /// Financial year ending year (e.g., 2026 for FY 2025-26).
  final int financialYear;

  /// Quarter (1-4).
  final int quarter;

  /// Short deduction amount in paise.
  final int shortDeductionPaise;

  /// Late filing fee under Section 234E in paise.
  final int lateFilingFeePaise;

  /// Interest under Section 201(1A) in paise.
  final int interestPaise;

  /// Total demand = short deduction + late filing fee + interest, in paise.
  final int totalDemandPaise;

  /// Whether the default has been resolved (corrected/paid).
  final bool isResolved;

  TdsDefault copyWith({
    String? tan,
    String? section,
    int? financialYear,
    int? quarter,
    int? shortDeductionPaise,
    int? lateFilingFeePaise,
    int? interestPaise,
    int? totalDemandPaise,
    bool? isResolved,
  }) {
    return TdsDefault(
      tan: tan ?? this.tan,
      section: section ?? this.section,
      financialYear: financialYear ?? this.financialYear,
      quarter: quarter ?? this.quarter,
      shortDeductionPaise: shortDeductionPaise ?? this.shortDeductionPaise,
      lateFilingFeePaise: lateFilingFeePaise ?? this.lateFilingFeePaise,
      interestPaise: interestPaise ?? this.interestPaise,
      totalDemandPaise: totalDemandPaise ?? this.totalDemandPaise,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TdsDefault &&
        other.tan == tan &&
        other.section == section &&
        other.financialYear == financialYear &&
        other.quarter == quarter &&
        other.shortDeductionPaise == shortDeductionPaise &&
        other.lateFilingFeePaise == lateFilingFeePaise &&
        other.interestPaise == interestPaise &&
        other.totalDemandPaise == totalDemandPaise &&
        other.isResolved == isResolved;
  }

  @override
  int get hashCode => Object.hash(
    tan,
    section,
    financialYear,
    quarter,
    shortDeductionPaise,
    lateFilingFeePaise,
    interestPaise,
    totalDemandPaise,
    isResolved,
  );
}
