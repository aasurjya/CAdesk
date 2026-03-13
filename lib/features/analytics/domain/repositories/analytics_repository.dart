import 'package:ca_app/features/analytics/domain/models/analytics_snapshot.dart';
import 'package:ca_app/features/analytics/domain/models/client_metric.dart';

abstract class AnalyticsRepository {
  Future<void> insertSnapshot(AnalyticsSnapshot snapshot);
  Future<List<AnalyticsSnapshot>> getByPeriod(String firmId, String period);
  Future<AnalyticsSnapshot?> getLatest(String firmId);
  Future<void> insertClientMetric(ClientMetric metric);
  Future<List<ClientMetric>> getClientMetrics(String clientId);
  Future<List<ClientMetric>> getRevenueByPeriod(String period);
}
