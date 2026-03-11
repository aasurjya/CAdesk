/// Billing summary for a client over a given period.
class BillingSummary {
  const BillingSummary({
    required this.clientId,
    required this.clientName,
    required this.totalHours,
    required this.billableHours,
    required this.nonBillableHours,
    required this.totalBilled,
    required this.realizationRate,
    required this.period,
  });

  final String clientId;
  final String clientName;
  final double totalHours;
  final double billableHours;
  final double nonBillableHours;
  final double totalBilled;

  /// Percentage of billable hours actually billed (0–100).
  final double realizationRate;
  final String period;

  /// Formatted total billed in INR.
  String get formattedBilled {
    if (totalBilled >= 100000) {
      final lakhs = totalBilled / 100000;
      return '₹${lakhs.toStringAsFixed(1)}L';
    }
    return '₹${totalBilled.toStringAsFixed(0)}';
  }

  BillingSummary copyWith({
    String? clientId,
    String? clientName,
    double? totalHours,
    double? billableHours,
    double? nonBillableHours,
    double? totalBilled,
    double? realizationRate,
    String? period,
  }) {
    return BillingSummary(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      totalHours: totalHours ?? this.totalHours,
      billableHours: billableHours ?? this.billableHours,
      nonBillableHours: nonBillableHours ?? this.nonBillableHours,
      totalBilled: totalBilled ?? this.totalBilled,
      realizationRate: realizationRate ?? this.realizationRate,
      period: period ?? this.period,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingSummary &&
        other.clientId == clientId &&
        other.period == period;
  }

  @override
  int get hashCode => Object.hash(clientId, period);
}
