import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/analytics/data/mappers/analytics_mapper.dart';
import 'package:ca_app/features/analytics/domain/models/analytics_snapshot.dart';
import 'package:ca_app/features/analytics/domain/models/client_metric.dart';

class AnalyticsLocalSource {
  const AnalyticsLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insertSnapshot(AnalyticsSnapshot snapshot) => _db.analyticsDao
      .insertSnapshot(AnalyticsMapper.snapshotToCompanion(snapshot));

  Future<List<AnalyticsSnapshot>> getByPeriod(
    String firmId,
    String period,
  ) async {
    final rows = await _db.analyticsDao.getByPeriod(firmId, period);
    return rows.map(AnalyticsMapper.snapshotFromRow).toList();
  }

  Future<AnalyticsSnapshot?> getLatest(String firmId) async {
    final row = await _db.analyticsDao.getLatest(firmId);
    return row != null ? AnalyticsMapper.snapshotFromRow(row) : null;
  }

  Future<void> insertClientMetric(ClientMetric metric) => _db.analyticsDao
      .insertClientMetric(AnalyticsMapper.metricToCompanion(metric));

  Future<List<ClientMetric>> getClientMetrics(String clientId) async {
    final rows = await _db.analyticsDao.getClientMetrics(clientId);
    return rows.map(AnalyticsMapper.metricFromRow).toList();
  }

  Future<List<ClientMetric>> getRevenueByPeriod(String period) async {
    final rows = await _db.analyticsDao.getRevenueByPeriod(period);
    return rows.map(AnalyticsMapper.metricFromRow).toList();
  }
}
