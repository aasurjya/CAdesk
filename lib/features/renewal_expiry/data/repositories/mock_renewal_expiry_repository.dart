import 'package:ca_app/features/renewal_expiry/domain/models/renewal_item.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/retainer_contract.dart';
import 'package:ca_app/features/renewal_expiry/domain/repositories/renewal_expiry_repository.dart';

/// In-memory mock implementation of [RenewalExpiryRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockRenewalExpiryRepository implements RenewalExpiryRepository {
  static final List<RenewalItem> _renewalSeed = [
    RenewalItem(
      id: 'renewal-001',
      clientId: 'mock-client-001',
      clientName: 'Sharma Industries Pvt Ltd',
      itemType: RenewalItemType.dscCertificate,
      dueDate: DateTime(2026, 3, 25),
      status: RenewalStatus.dueSoon,
      fee: 2000.0,
      notes: 'DSC for director — renew before filing season',
    ),
    RenewalItem(
      id: 'renewal-002',
      clientId: 'mock-client-002',
      clientName: 'Patel Exports Ltd',
      itemType: RenewalItemType.gstRegistration,
      dueDate: DateTime(2026, 6, 30),
      status: RenewalStatus.upToDate,
      fee: 0.0,
      notes: 'Annual GST registration review',
    ),
    RenewalItem(
      id: 'renewal-003',
      clientId: 'mock-client-003',
      clientName: 'Reddy Tech Solutions',
      itemType: RenewalItemType.retainer,
      dueDate: DateTime(2026, 2, 28),
      status: RenewalStatus.overdue,
      fee: 15000.0,
      notes: 'Annual retainer renewal — client follow-up pending',
    ),
  ];

  static final List<RetainerContract> _contractSeed = [
    RetainerContract(
      id: 'contract-001',
      clientId: 'mock-client-001',
      clientName: 'Sharma Industries Pvt Ltd',
      serviceScope: 'Monthly GST filing, quarterly TDS, annual ITR',
      monthlyFee: 8000.0,
      startDate: DateTime(2025, 4, 1),
      endDate: DateTime(2026, 3, 31),
      autoRenew: true,
      status: RetainerStatus.expiringSoon,
    ),
    RetainerContract(
      id: 'contract-002',
      clientId: 'mock-client-002',
      clientName: 'Patel Exports Ltd',
      serviceScope: 'FEMA compliance, annual audit, ITR, GSTP filing',
      monthlyFee: 25000.0,
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2026, 12, 31),
      autoRenew: true,
      status: RetainerStatus.active,
    ),
    RetainerContract(
      id: 'contract-003',
      clientId: 'mock-client-003',
      clientName: 'Reddy Tech Solutions',
      serviceScope: 'Startup compliance, MCA filings, ITR',
      monthlyFee: 5000.0,
      startDate: DateTime(2024, 4, 1),
      endDate: DateTime(2025, 3, 31),
      autoRenew: false,
      status: RetainerStatus.expired,
    ),
  ];

  final List<RenewalItem> _renewalState = List.of(_renewalSeed);
  final List<RetainerContract> _contractState = List.of(_contractSeed);

  // ---------------------------------------------------------------------------
  // RenewalItem
  // ---------------------------------------------------------------------------

  @override
  Future<List<RenewalItem>> getRenewalItems() async =>
      List.unmodifiable(_renewalState);

  @override
  Future<RenewalItem?> getRenewalItemById(String id) async {
    final idx = _renewalState.indexWhere((i) => i.id == id);
    return idx == -1 ? null : _renewalState[idx];
  }

  @override
  Future<List<RenewalItem>> getRenewalItemsByClient(String clientId) async =>
      List.unmodifiable(
        _renewalState.where((i) => i.clientId == clientId).toList(),
      );

  @override
  Future<List<RenewalItem>> getRenewalItemsByStatus(
    RenewalStatus status,
  ) async => List.unmodifiable(
    _renewalState.where((i) => i.status == status).toList(),
  );

  @override
  Future<String> insertRenewalItem(RenewalItem item) async {
    _renewalState.add(item);
    return item.id;
  }

  @override
  Future<bool> updateRenewalItem(RenewalItem item) async {
    final idx = _renewalState.indexWhere((i) => i.id == item.id);
    if (idx == -1) return false;
    final updated = List<RenewalItem>.of(_renewalState)..[idx] = item;
    _renewalState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteRenewalItem(String id) async {
    final before = _renewalState.length;
    _renewalState.removeWhere((i) => i.id == id);
    return _renewalState.length < before;
  }

  // ---------------------------------------------------------------------------
  // RetainerContract
  // ---------------------------------------------------------------------------

  @override
  Future<List<RetainerContract>> getRetainerContracts() async =>
      List.unmodifiable(_contractState);

  @override
  Future<RetainerContract?> getRetainerContractById(String id) async {
    final idx = _contractState.indexWhere((c) => c.id == id);
    return idx == -1 ? null : _contractState[idx];
  }

  @override
  Future<List<RetainerContract>> getRetainerContractsByClient(
    String clientId,
  ) async => List.unmodifiable(
    _contractState.where((c) => c.clientId == clientId).toList(),
  );

  @override
  Future<String> insertRetainerContract(RetainerContract contract) async {
    _contractState.add(contract);
    return contract.id;
  }

  @override
  Future<bool> updateRetainerContract(RetainerContract contract) async {
    final idx = _contractState.indexWhere((c) => c.id == contract.id);
    if (idx == -1) return false;
    final updated = List<RetainerContract>.of(_contractState)..[idx] = contract;
    _contractState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteRetainerContract(String id) async {
    final before = _contractState.length;
    _contractState.removeWhere((c) => c.id == id);
    return _contractState.length < before;
  }
}
