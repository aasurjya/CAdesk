import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/analytics_table.dart';

part 'analytics_dao.g.dart';

@DriftAccessor(tables: [AnalyticsSnapshotsTable, ClientMetricsTable])
class AnalyticsDao extends DatabaseAccessor<AppDatabase>
    with _$AnalyticsDaoMixin {
  AnalyticsDao(super.db);

  // --- AnalyticsSnapshot ops ---

  Future<void> insertSnapshot(
    AnalyticsSnapshotsTableCompanion companion,
  ) => into(analyticsSnapshotsTable).insertOnConflictUpdate(companion);

  Future<List<AnalyticsSnapshotRow>> getByPeriod(
    String firmId,
    String period,
  ) =>
      (select(analyticsSnapshotsTable)
            ..where(
              (t) => t.firmId.equals(firmId) & t.period.equals(period),
            ))
          .get();

  Future<AnalyticsSnapshotRow?> getLatest(String firmId) async {
    final rows = await (select(analyticsSnapshotsTable)
          ..where((t) => t.firmId.equals(firmId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  // --- ClientMetric ops ---

  Future<void> insertClientMetric(
    ClientMetricsTableCompanion companion,
  ) => into(clientMetricsTable).insertOnConflictUpdate(companion);

  Future<List<ClientMetricRow>> getClientMetrics(String clientId) =>
      (select(clientMetricsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm.desc(t.period)]))
          .get();

  Future<List<ClientMetricRow>> getRevenueByPeriod(String period) =>
      (select(clientMetricsTable)
            ..where((t) => t.period.equals(period))
            ..orderBy([(t) => OrderingTerm.desc(t.revenue)]))
          .get();
}
