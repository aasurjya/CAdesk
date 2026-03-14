import 'package:ca_app/features/fee_leakage/domain/models/engagement.dart';
import 'package:ca_app/features/fee_leakage/domain/models/scope_item.dart';
import 'package:ca_app/features/fee_leakage/domain/repositories/fee_leakage_repository.dart';

/// In-memory mock implementation of [FeeLeakageRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockFeeLeakageRepository implements FeeLeakageRepository {
  static final List<Engagement> _seedEngagements = [
    const Engagement(
      id: 'mock-eng-001',
      clientId: 'mock-client-001',
      clientName: 'Rajesh Kumar Sharma',
      serviceType: 'Income Tax Return Filing',
      agreedFee: 15000,
      billedAmount: 12000,
      actualHours: 18,
      budgetHours: 12,
      status: EngagementStatus.overScope,
    ),
    const Engagement(
      id: 'mock-eng-002',
      clientId: 'mock-client-001',
      clientName: 'Rajesh Kumar Sharma',
      serviceType: 'GST Monthly Compliance',
      agreedFee: 8000,
      billedAmount: 8000,
      actualHours: 10,
      budgetHours: 12,
      status: EngagementStatus.onTrack,
    ),
    const Engagement(
      id: 'mock-eng-003',
      clientId: 'mock-client-002',
      clientName: 'Priya Nair',
      serviceType: 'Statutory Audit',
      agreedFee: 50000,
      billedAmount: 40000,
      actualHours: 80,
      budgetHours: 70,
      status: EngagementStatus.underBilled,
    ),
  ];

  static final List<ScopeItem> _seedScopeItems = [
    ScopeItem(
      id: 'mock-scope-001',
      engagementId: 'mock-eng-001',
      description: 'Capital gains computation from equity shares',
      isInScope: false,
      addedAt: DateTime(2026, 2, 10),
      billedExtra: false,
    ),
    ScopeItem(
      id: 'mock-scope-002',
      engagementId: 'mock-eng-001',
      description: 'Faceless assessment response drafting',
      isInScope: false,
      addedAt: DateTime(2026, 2, 15),
      billedExtra: true,
    ),
    ScopeItem(
      id: 'mock-scope-003',
      engagementId: 'mock-eng-003',
      description: 'Additional branch reconciliation',
      isInScope: false,
      addedAt: DateTime(2026, 1, 20),
      billedExtra: false,
    ),
  ];

  final List<Engagement> _engagements = List.of(_seedEngagements);
  final List<ScopeItem> _scopeItems = List.of(_seedScopeItems);

  // -------------------------------------------------------------------------
  // Engagement
  // -------------------------------------------------------------------------

  @override
  Future<List<Engagement>> getEngagements() async =>
      List.unmodifiable(_engagements);

  @override
  Future<List<Engagement>> getEngagementsByClient(String clientId) async =>
      List.unmodifiable(
        _engagements.where((e) => e.clientId == clientId).toList(),
      );

  @override
  Future<List<Engagement>> getEngagementsByStatus(
    EngagementStatus status,
  ) async =>
      List.unmodifiable(_engagements.where((e) => e.status == status).toList());

  @override
  Future<String> insertEngagement(Engagement engagement) async {
    _engagements.add(engagement);
    return engagement.id;
  }

  @override
  Future<bool> updateEngagement(Engagement engagement) async {
    final idx = _engagements.indexWhere((e) => e.id == engagement.id);
    if (idx == -1) return false;
    final updated = List<Engagement>.of(_engagements)..[idx] = engagement;
    _engagements
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteEngagement(String id) async {
    final before = _engagements.length;
    _engagements.removeWhere((e) => e.id == id);
    return _engagements.length < before;
  }

  // -------------------------------------------------------------------------
  // ScopeItem
  // -------------------------------------------------------------------------

  @override
  Future<List<ScopeItem>> getScopeItems() async =>
      List.unmodifiable(_scopeItems);

  @override
  Future<List<ScopeItem>> getScopeItemsByEngagement(
    String engagementId,
  ) async => List.unmodifiable(
    _scopeItems.where((s) => s.engagementId == engagementId).toList(),
  );

  @override
  Future<String> insertScopeItem(ScopeItem item) async {
    _scopeItems.add(item);
    return item.id;
  }

  @override
  Future<bool> updateScopeItem(ScopeItem item) async {
    final idx = _scopeItems.indexWhere((s) => s.id == item.id);
    if (idx == -1) return false;
    final updated = List<ScopeItem>.of(_scopeItems)..[idx] = item;
    _scopeItems
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteScopeItem(String id) async {
    final before = _scopeItems.length;
    _scopeItems.removeWhere((s) => s.id == id);
    return _scopeItems.length < before;
  }
}
