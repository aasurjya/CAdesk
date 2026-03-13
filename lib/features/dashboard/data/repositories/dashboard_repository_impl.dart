import 'package:ca_app/features/dashboard/data/datasources/dashboard_local_source.dart';
import 'package:ca_app/features/dashboard/data/datasources/dashboard_remote_source.dart';
import 'package:ca_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:ca_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Production [DashboardRepository] that queries Supabase RPC for remote
/// aggregates and falls back to local Drift aggregation on network errors.
///
/// The dashboard is read-only — no writes or syncs are performed.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final DashboardRemoteSource remote;
  final DashboardLocalSource local;
  final String firmId;

  @override
  Future<DashboardSummary> getDashboardSummary({String firmId = ''}) async {
    final effectiveFirmId = firmId.isNotEmpty ? firmId : this.firmId;
    try {
      return await remote.getDashboardSummary(firmId: effectiveFirmId);
    } catch (_) {
      return local.getDashboardSummary(firmId: effectiveFirmId);
    }
  }

  @override
  Future<List<RecentFiling>> getRecentFilings({
    int limit = 10,
    String firmId = '',
  }) async {
    final effectiveFirmId = firmId.isNotEmpty ? firmId : this.firmId;
    try {
      final filings = await remote.getRecentFilings(
        limit: limit,
        firmId: effectiveFirmId,
      );
      return List.unmodifiable(filings);
    } catch (_) {
      final filings = await local.getRecentFilings(
        limit: limit,
        firmId: effectiveFirmId,
      );
      return List.unmodifiable(filings);
    }
  }

  @override
  Future<List<TopClient>> getTopClients({
    int limit = 5,
    String firmId = '',
  }) async {
    final effectiveFirmId = firmId.isNotEmpty ? firmId : this.firmId;
    try {
      final clients = await remote.getTopClients(
        limit: limit,
        firmId: effectiveFirmId,
      );
      return List.unmodifiable(clients);
    } catch (_) {
      final clients = await local.getTopClients(
        limit: limit,
        firmId: effectiveFirmId,
      );
      return List.unmodifiable(clients);
    }
  }
}
