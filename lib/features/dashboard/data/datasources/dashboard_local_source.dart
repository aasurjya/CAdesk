import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/dashboard/domain/models/dashboard_summary.dart';

/// Reads aggregated dashboard data from the local Drift database.
///
/// All methods delegate to [DashboardDao], which executes the underlying
/// aggregation queries across clients, tasks, ITR filings, GST returns,
/// TDS returns, and invoices tables.
class DashboardLocalSource {
  const DashboardLocalSource(this._db);

  final AppDatabase _db;

  /// Returns a complete [DashboardSummary] aggregated from local tables.
  Future<DashboardSummary> getDashboardSummary({String firmId = ''}) {
    return _db.dashboardDao.getDashboardSummary(firmId: firmId);
  }

  /// Returns the [limit] most recent filings from local tables.
  Future<List<RecentFiling>> getRecentFilings({
    int limit = 10,
    String firmId = '',
  }) {
    return _db.dashboardDao.getRecentFilings(firmId, limit: limit);
  }

  /// Returns the [limit] top clients by billing amount from local tables.
  Future<List<TopClient>> getTopClients({
    int limit = 5,
    String firmId = '',
  }) {
    return _db.dashboardDao.getTopClients(firmId, limit: limit);
  }
}
