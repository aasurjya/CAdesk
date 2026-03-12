/// Represents a single discrepancy found between a filed ITR and an
/// assessment/intimation order issued by the Income Tax Department.
///
/// All monetary amounts are in **paise** (integer).
class OrderDiscrepancy {
  const OrderDiscrepancy({
    required this.section,
    required this.filedAmount,
    required this.assessedAmount,
    required this.difference,
    required this.reason,
  });

  /// Human-readable section label, e.g. "TDS Credit", "14A Disallowance".
  final String section;

  /// Amount as claimed in the filed ITR (paise).
  final int filedAmount;

  /// Amount as accepted / assessed by the department (paise).
  final int assessedAmount;

  /// assessedAmount - filedAmount (paise).
  /// Positive → department increased the amount; negative → reduced.
  final int difference;

  /// Plain-English reason for the discrepancy.
  final String reason;

  OrderDiscrepancy copyWith({
    String? section,
    int? filedAmount,
    int? assessedAmount,
    int? difference,
    String? reason,
  }) {
    return OrderDiscrepancy(
      section: section ?? this.section,
      filedAmount: filedAmount ?? this.filedAmount,
      assessedAmount: assessedAmount ?? this.assessedAmount,
      difference: difference ?? this.difference,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDiscrepancy &&
        other.section == section &&
        other.filedAmount == filedAmount &&
        other.assessedAmount == assessedAmount &&
        other.difference == difference &&
        other.reason == reason;
  }

  @override
  int get hashCode =>
      Object.hash(section, filedAmount, assessedAmount, difference, reason);
}
