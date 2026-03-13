import 'package:uuid/uuid.dart';
import 'package:ca_app/features/analytics/domain/models/analytics_snapshot.dart';
import 'package:ca_app/features/analytics/domain/models/client_metric.dart';
import 'package:ca_app/features/analytics/domain/repositories/analytics_repository.dart';

const _uuid = Uuid();

class MockAnalyticsRepository implements AnalyticsRepository {
  final List<AnalyticsSnapshot> _snapshots = [];
  final List<ClientMetric> _metrics = [];

  @override
  Future<void> insertSnapshot(AnalyticsSnapshot snapshot) async {
    final effective = snapshot.id.isEmpty
        ? snapshot.copyWith(id: _uuid.v4())
        : snapshot;
    _snapshots.add(effective);
  }

  @override
  Future<List<AnalyticsSnapshot>> getByPeriod(
    String firmId,
    String period,
  ) async {
    return List.unmodifiable(
      _snapshots
          .where((s) => s.firmId == firmId && s.period == period)
          .toList(),
    );
  }

  @override
  Future<AnalyticsSnapshot?> getLatest(String firmId) async {
    final filtered = _snapshots.where((s) => s.firmId == firmId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.isEmpty ? null : filtered.first;
  }

  @override
  Future<void> insertClientMetric(ClientMetric metric) async {
    final effective = metric.id.isEmpty
        ? metric.copyWith(id: _uuid.v4())
        : metric;
    _metrics.add(effective);
  }

  @override
  Future<List<ClientMetric>> getClientMetrics(String clientId) async {
    return List.unmodifiable(
      _metrics.where((m) => m.clientId == clientId).toList(),
    );
  }

  @override
  Future<List<ClientMetric>> getRevenueByPeriod(String period) async {
    final filtered = _metrics.where((m) => m.period == period).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    return List.unmodifiable(filtered);
  }
}
