import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/analytics/domain/models/analytics_snapshot.dart';
import 'package:ca_app/features/analytics/domain/models/client_metric.dart';

const _uuid = Uuid();

class AnalyticsMapper {
  const AnalyticsMapper._();

  // --- AnalyticsSnapshot ---

  static AnalyticsSnapshot snapshotFromRow(AnalyticsSnapshotRow row) {
    return AnalyticsSnapshot(
      id: row.id,
      firmId: row.firmId,
      period: row.period,
      totalRevenue: row.totalRevenue,
      totalClients: row.totalClients,
      filingCompleted: row.filingCompleted,
      filingPending: row.filingPending,
      avgResponseTime: row.avgResponseTime,
      topModule: row.topModule,
      createdAt: row.createdAt,
    );
  }

  static AnalyticsSnapshotsTableCompanion snapshotToCompanion(
    AnalyticsSnapshot s,
  ) {
    return AnalyticsSnapshotsTableCompanion(
      id: Value(s.id.isEmpty ? _uuid.v4() : s.id),
      firmId: Value(s.firmId),
      period: Value(s.period),
      totalRevenue: Value(s.totalRevenue),
      totalClients: Value(s.totalClients),
      filingCompleted: Value(s.filingCompleted),
      filingPending: Value(s.filingPending),
      avgResponseTime: Value(s.avgResponseTime),
      topModule: Value(s.topModule),
      createdAt: Value(s.createdAt),
    );
  }

  static AnalyticsSnapshot snapshotFromJson(Map<String, dynamic> json) {
    return AnalyticsSnapshot(
      id: json['id'] as String,
      firmId: json['firm_id'] as String,
      period: json['period'] as String,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      totalClients: json['total_clients'] as int,
      filingCompleted: json['filing_completed'] as int,
      filingPending: json['filing_pending'] as int,
      avgResponseTime: (json['avg_response_time'] as num).toDouble(),
      topModule: json['top_module'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> snapshotToJson(AnalyticsSnapshot s) {
    return {
      'id': s.id,
      'firm_id': s.firmId,
      'period': s.period,
      'total_revenue': s.totalRevenue,
      'total_clients': s.totalClients,
      'filing_completed': s.filingCompleted,
      'filing_pending': s.filingPending,
      'avg_response_time': s.avgResponseTime,
      'top_module': s.topModule,
      'created_at': s.createdAt.toIso8601String(),
    };
  }

  // --- ClientMetric ---

  static ClientMetric metricFromRow(ClientMetricRow row) {
    return ClientMetric(
      id: row.id,
      clientId: row.clientId,
      period: row.period,
      revenue: row.revenue,
      filingsCompleted: row.filingsCompleted,
      outstandingAmount: row.outstandingAmount,
      satisfactionScore: row.satisfactionScore,
      createdAt: row.createdAt,
    );
  }

  static ClientMetricsTableCompanion metricToCompanion(ClientMetric m) {
    return ClientMetricsTableCompanion(
      id: Value(m.id.isEmpty ? _uuid.v4() : m.id),
      clientId: Value(m.clientId),
      period: Value(m.period),
      revenue: Value(m.revenue),
      filingsCompleted: Value(m.filingsCompleted),
      outstandingAmount: Value(m.outstandingAmount),
      satisfactionScore: Value(m.satisfactionScore),
      createdAt: Value(m.createdAt),
    );
  }

  static ClientMetric metricFromJson(Map<String, dynamic> json) {
    return ClientMetric(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      period: json['period'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      filingsCompleted: json['filings_completed'] as int,
      outstandingAmount: (json['outstanding_amount'] as num).toDouble(),
      satisfactionScore: (json['satisfaction_score'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> metricToJson(ClientMetric m) {
    return {
      'id': m.id,
      'client_id': m.clientId,
      'period': m.period,
      'revenue': m.revenue,
      'filings_completed': m.filingsCompleted,
      'outstanding_amount': m.outstandingAmount,
      'satisfaction_score': m.satisfactionScore,
      'created_at': m.createdAt.toIso8601String(),
    };
  }
}
