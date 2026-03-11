import 'package:flutter/foundation.dart';

/// Aggregated TDS liability and deduction data for a single section.
///
/// Used to display section-wise compliance on the deductor detail sheet.
@immutable
class TdsSectionSummary {
  const TdsSectionSummary({
    required this.section,
    required this.sectionDescription,
    required this.ratePercent,
    required this.totalPayments,
    required this.totalTdsDeducted,
    required this.totalTdsPaid,
    required this.outstandingTds,
    required this.deducteeCount,
  });

  /// TDS section code, e.g. "192", "194J".
  final String section;

  /// Human-readable section description, e.g. "Professional / technical fees".
  final String sectionDescription;

  /// Standard TDS rate for this section (percentage), e.g. 10.0.
  final double ratePercent;

  /// Total payments made to deductees under this section.
  final double totalPayments;

  /// Total TDS already deducted from deductees.
  final double totalTdsDeducted;

  /// Total TDS deposited via challans.
  final double totalTdsPaid;

  /// TDS deducted but not yet deposited (totalTdsDeducted - totalTdsPaid).
  final double outstandingTds;

  /// Number of distinct deductees under this section.
  final int deducteeCount;

  // ---------------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------------

  /// Compliance percentage: how much of the deducted TDS has been deposited.
  ///
  /// Returns 100.0 when nothing has been deducted (no liability).
  double get compliancePercent {
    if (totalTdsDeducted <= 0) {
      return 100.0;
    }
    return (totalTdsPaid / totalTdsDeducted * 100).clamp(0.0, 100.0);
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  TdsSectionSummary copyWith({
    String? section,
    String? sectionDescription,
    double? ratePercent,
    double? totalPayments,
    double? totalTdsDeducted,
    double? totalTdsPaid,
    double? outstandingTds,
    int? deducteeCount,
  }) {
    return TdsSectionSummary(
      section: section ?? this.section,
      sectionDescription: sectionDescription ?? this.sectionDescription,
      ratePercent: ratePercent ?? this.ratePercent,
      totalPayments: totalPayments ?? this.totalPayments,
      totalTdsDeducted: totalTdsDeducted ?? this.totalTdsDeducted,
      totalTdsPaid: totalTdsPaid ?? this.totalTdsPaid,
      outstandingTds: outstandingTds ?? this.outstandingTds,
      deducteeCount: deducteeCount ?? this.deducteeCount,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsSectionSummary &&
          runtimeType == other.runtimeType &&
          section == other.section &&
          sectionDescription == other.sectionDescription &&
          ratePercent == other.ratePercent &&
          totalPayments == other.totalPayments &&
          totalTdsDeducted == other.totalTdsDeducted &&
          totalTdsPaid == other.totalTdsPaid &&
          outstandingTds == other.outstandingTds &&
          deducteeCount == other.deducteeCount;

  @override
  int get hashCode => Object.hash(
    section,
    sectionDescription,
    ratePercent,
    totalPayments,
    totalTdsDeducted,
    totalTdsPaid,
    outstandingTds,
    deducteeCount,
  );

  @override
  String toString() =>
      'TdsSectionSummary(section: $section, rate: $ratePercent%, '
      'deducted: $totalTdsDeducted, paid: $totalTdsPaid, '
      'outstanding: $outstandingTds)';
}
