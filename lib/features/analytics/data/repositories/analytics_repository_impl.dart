import 'package:ca_app/features/analytics/data/datasources/analytics_local_source.dart';
import 'package:ca_app/features/analytics/data/datasources/analytics_remote_source.dart';
import 'package:ca_app/features/analytics/data/mappers/analytics_mapper.dart';
import 'package:ca_app/features/analytics/domain/models/analytics_snapshot.dart';
import 'package:ca_app/features/analytics/domain/models/client_metric.dart';
import 'package:ca_app/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl({required this.remote, required this.local});

  final AnalyticsRemoteSource remote;
  final AnalyticsLocalSource local;

  @override
  Future<void> insertSnapshot(AnalyticsSnapshot snapshot) async {
    try {
      await remote.insertSnapshot(AnalyticsMapper.snapshotToJson(snapshot));
    } catch (_) {
      // No-op — fall through to local write
    }
    await local.insertSnapshot(snapshot);
  }

  @override
  Future<List<AnalyticsSnapshot>> getByPeriod(
    String firmId,
    String period,
  ) async {
    try {
      final jsonList = await remote.fetchSnapshotsByPeriod(firmId, period);
      final snapshots = jsonList.map(AnalyticsMapper.snapshotFromJson).toList();
      for (final s in snapshots) {
        await local.insertSnapshot(s);
      }
      return List.unmodifiable(snapshots);
    } catch (_) {
      return local.getByPeriod(firmId, period);
    }
  }

  @override
  Future<AnalyticsSnapshot?> getLatest(String firmId) async {
    try {
      final json = await remote.fetchLatestSnapshot(firmId);
      if (json == null) return null;
      final snapshot = AnalyticsMapper.snapshotFromJson(json);
      await local.insertSnapshot(snapshot);
      return snapshot;
    } catch (_) {
      return local.getLatest(firmId);
    }
  }

  @override
  Future<void> insertClientMetric(ClientMetric metric) async {
    try {
      await remote.insertClientMetric(AnalyticsMapper.metricToJson(metric));
    } catch (_) {
      // No-op — fall through to local write
    }
    await local.insertClientMetric(metric);
  }

  @override
  Future<List<ClientMetric>> getClientMetrics(String clientId) async {
    try {
      final jsonList = await remote.fetchClientMetrics(clientId);
      final metrics = jsonList.map(AnalyticsMapper.metricFromJson).toList();
      for (final m in metrics) {
        await local.insertClientMetric(m);
      }
      return List.unmodifiable(metrics);
    } catch (_) {
      return local.getClientMetrics(clientId);
    }
  }

  @override
  Future<List<ClientMetric>> getRevenueByPeriod(String period) async {
    try {
      final jsonList = await remote.fetchRevenueByPeriod(period);
      final metrics = jsonList.map(AnalyticsMapper.metricFromJson).toList();
      return List.unmodifiable(metrics);
    } catch (_) {
      return local.getRevenueByPeriod(period);
    }
  }
}
