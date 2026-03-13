class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.id,
    required this.firmId,
    required this.period,
    required this.totalRevenue,
    required this.totalClients,
    required this.filingCompleted,
    required this.filingPending,
    required this.avgResponseTime,
    this.topModule,
    required this.createdAt,
  });

  final String id;
  final String firmId;
  final String period;
  final double totalRevenue;
  final int totalClients;
  final int filingCompleted;
  final int filingPending;
  final double avgResponseTime;
  final String? topModule;
  final DateTime createdAt;

  AnalyticsSnapshot copyWith({
    String? id,
    String? firmId,
    String? period,
    double? totalRevenue,
    int? totalClients,
    int? filingCompleted,
    int? filingPending,
    double? avgResponseTime,
    String? topModule,
    DateTime? createdAt,
  }) {
    return AnalyticsSnapshot(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      period: period ?? this.period,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalClients: totalClients ?? this.totalClients,
      filingCompleted: filingCompleted ?? this.filingCompleted,
      filingPending: filingPending ?? this.filingPending,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      topModule: topModule ?? this.topModule,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
