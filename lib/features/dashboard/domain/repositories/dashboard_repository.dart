import 'package:ca_app/features/dashboard/domain/models/dashboard_summary.dart';

/// Contract for reading aggregated dashboard KPI data.
abstract class DashboardRepository {
  /// Returns an aggregated snapshot of dashboard KPIs.
  Future<DashboardSummary> getDashboardSummary({String firmId});

  /// Returns the [limit] most recently filed returns across all modules.
  Future<List<RecentFiling>> getRecentFilings({int limit, String firmId});

  /// Returns the [limit] top clients ranked by filing count and billing.
  Future<List<TopClient>> getTopClients({int limit, String firmId});
}
