class ClientMetric {
  const ClientMetric({
    required this.id,
    required this.clientId,
    required this.period,
    required this.revenue,
    required this.filingsCompleted,
    required this.outstandingAmount,
    this.satisfactionScore,
    required this.createdAt,
  });

  final String id;
  final String clientId;
  final String period;
  final double revenue;
  final int filingsCompleted;
  final double outstandingAmount;
  final double? satisfactionScore;
  final DateTime createdAt;

  ClientMetric copyWith({
    String? id,
    String? clientId,
    String? period,
    double? revenue,
    int? filingsCompleted,
    double? outstandingAmount,
    double? satisfactionScore,
    DateTime? createdAt,
  }) {
    return ClientMetric(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      period: period ?? this.period,
      revenue: revenue ?? this.revenue,
      filingsCompleted: filingsCompleted ?? this.filingsCompleted,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      satisfactionScore: satisfactionScore ?? this.satisfactionScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
