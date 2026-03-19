import 'package:ca_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:ca_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// In-memory mock [DashboardRepository] for offline development and testing.
///
/// Returns static seed data that resembles a realistic CA practice with
/// 15 clients, mixed filing statuses, and upcoming deadlines.
class MockDashboardRepository implements DashboardRepository {
  static const DashboardSummary _seedSummary = DashboardSummary(
    totalClients: 15,
    filedReturns: 48,
    pendingReturns: 12,
    overdueTasks: 4,
    upcomingDeadlines: 5,
    totalBilling: 285000.0,
  );

  static final List<RecentFiling> _seedRecentFilings = [
    RecentFiling(
      clientName: 'Bharat Electronics Ltd',
      filingType: 'GSTR-3B',
      status: 'filed',
      date: DateTime(2026, 3, 9),
    ),
    RecentFiling(
      clientName: 'GreenLeaf Organics LLP',
      filingType: 'ITR-5',
      status: 'verified',
      date: DateTime(2026, 3, 7),
    ),
    RecentFiling(
      clientName: 'TechVista Solutions LLP',
      filingType: '26Q',
      status: 'filed',
      date: DateTime(2026, 3, 5),
    ),
    RecentFiling(
      clientName: 'ABC Infra Pvt Ltd',
      filingType: 'GSTR-1',
      status: 'filed',
      date: DateTime(2026, 3, 4),
    ),
    RecentFiling(
      clientName: 'Rajesh Kumar Sharma',
      filingType: 'ITR-2',
      status: 'processed',
      date: DateTime(2026, 3, 1),
    ),
  ];

  static final List<TopClient> _seedTopClients = [
    const TopClient(
      clientName: 'Bharat Electronics Ltd',
      filingCount: 12,
      billingAmount: 75000.0,
    ),
    const TopClient(
      clientName: 'ABC Infra Pvt Ltd',
      filingCount: 10,
      billingAmount: 62000.0,
    ),
    const TopClient(
      clientName: 'TechVista Solutions LLP',
      filingCount: 8,
      billingAmount: 48000.0,
    ),
    const TopClient(
      clientName: 'Nirmala Textiles Pvt Ltd',
      filingCount: 7,
      billingAmount: 41000.0,
    ),
    const TopClient(
      clientName: 'GreenLeaf Organics LLP',
      filingCount: 6,
      billingAmount: 32000.0,
    ),
  ];

  @override
  Future<DashboardSummary> getDashboardSummary({String firmId = ''}) async {
    return _seedSummary;
  }

  @override
  Future<List<RecentFiling>> getRecentFilings({
    int limit = 10,
    String firmId = '',
  }) async {
    final capped = _seedRecentFilings.take(limit).toList(growable: false);
    return List.unmodifiable(capped);
  }

  @override
  Future<List<TopClient>> getTopClients({
    int limit = 5,
    String firmId = '',
  }) async {
    final capped = _seedTopClients.take(limit).toList(growable: false);
    return List.unmodifiable(capped);
  }
}
