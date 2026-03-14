import 'package:ca_app/features/sme_cfo/domain/models/cfo_deliverable.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_retainer.dart';
import 'package:ca_app/features/sme_cfo/domain/repositories/sme_cfo_repository.dart';

/// In-memory mock implementation of [SmeCfoRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockSmeCfoRepository implements SmeCfoRepository {
  static final List<CfoDeliverable> _deliverableSeed = [
    CfoDeliverable(
      id: 'deliverable-001',
      retainerId: 'cfo-retainer-001',
      clientName: 'Sharma Auto Parts Pvt Ltd',
      title: 'March 2026 MIS Report',
      deliverableType: DeliverableType.misReport,
      dueDate: DateTime(2026, 4, 5),
      status: DeliverableStatus.inProgress,
    ),
    CfoDeliverable(
      id: 'deliverable-002',
      retainerId: 'cfo-retainer-001',
      clientName: 'Sharma Auto Parts Pvt Ltd',
      title: 'Q4 FY2026 Cash Flow Forecast',
      deliverableType: DeliverableType.cashFlowForecast,
      dueDate: DateTime(2026, 3, 20),
      status: DeliverableStatus.delivered,
      completedAt: DateTime(2026, 3, 18),
    ),
    CfoDeliverable(
      id: 'deliverable-003',
      retainerId: 'cfo-retainer-002',
      clientName: 'Patel Foods Exports',
      title: 'Q4 Advance Tax Calculation',
      deliverableType: DeliverableType.advanceTaxCalc,
      dueDate: DateTime(2026, 3, 10),
      status: DeliverableStatus.approved,
      completedAt: DateTime(2026, 3, 8),
    ),
  ];

  static final List<CfoRetainer> _retainerSeed = [
    CfoRetainer(
      id: 'cfo-retainer-001',
      clientId: 'mock-client-001',
      clientName: 'Sharma Auto Parts Pvt Ltd',
      industry: 'Manufacturing',
      monthlyFee: 18000.0,
      startDate: DateTime(2025, 4, 1),
      nextReviewDate: DateTime(2026, 6, 30),
      deliverables: const ['MIS Report', 'Cash Flow Forecast', 'Tax Review'],
      status: CfoRetainerStatus.active,
      assignedPartner: 'CA Rajesh Sharma',
      healthScore: 88,
    ),
    CfoRetainer(
      id: 'cfo-retainer-002',
      clientId: 'mock-client-002',
      clientName: 'Patel Foods Exports',
      industry: 'Food Processing',
      monthlyFee: 35000.0,
      startDate: DateTime(2024, 10, 1),
      nextReviewDate: DateTime(2026, 4, 1),
      deliverables: const [
        'Board Pack',
        'Advance Tax Calc',
        'GST Outflow Analysis',
        'Budget Variance',
      ],
      status: CfoRetainerStatus.active,
      assignedPartner: 'CA Priya Patel',
      healthScore: 92,
    ),
    CfoRetainer(
      id: 'cfo-retainer-003',
      clientId: 'mock-client-003',
      clientName: 'Reddy Tech Innovations',
      industry: 'Technology',
      monthlyFee: 8000.0,
      startDate: DateTime(2025, 1, 1),
      nextReviewDate: DateTime(2026, 3, 31),
      deliverables: const ['MIS Report', 'Cash Flow Forecast'],
      status: CfoRetainerStatus.review,
      assignedPartner: 'CA Arun Reddy',
      healthScore: 55,
    ),
  ];

  final List<CfoDeliverable> _deliverableState = List.of(_deliverableSeed);
  final List<CfoRetainer> _retainerState = List.of(_retainerSeed);

  // ---------------------------------------------------------------------------
  // CfoDeliverable
  // ---------------------------------------------------------------------------

  @override
  Future<List<CfoDeliverable>> getDeliverables() async =>
      List.unmodifiable(_deliverableState);

  @override
  Future<CfoDeliverable?> getDeliverableById(String id) async {
    final idx = _deliverableState.indexWhere((d) => d.id == id);
    return idx == -1 ? null : _deliverableState[idx];
  }

  @override
  Future<List<CfoDeliverable>> getDeliverablesByRetainer(
    String retainerId,
  ) async => List.unmodifiable(
    _deliverableState.where((d) => d.retainerId == retainerId).toList(),
  );

  @override
  Future<List<CfoDeliverable>> getDeliverablesByStatus(
    DeliverableStatus status,
  ) async => List.unmodifiable(
    _deliverableState.where((d) => d.status == status).toList(),
  );

  @override
  Future<String> insertDeliverable(CfoDeliverable deliverable) async {
    _deliverableState.add(deliverable);
    return deliverable.id;
  }

  @override
  Future<bool> updateDeliverable(CfoDeliverable deliverable) async {
    final idx = _deliverableState.indexWhere((d) => d.id == deliverable.id);
    if (idx == -1) return false;
    final updated = List<CfoDeliverable>.of(_deliverableState)
      ..[idx] = deliverable;
    _deliverableState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteDeliverable(String id) async {
    final before = _deliverableState.length;
    _deliverableState.removeWhere((d) => d.id == id);
    return _deliverableState.length < before;
  }

  // ---------------------------------------------------------------------------
  // CfoRetainer
  // ---------------------------------------------------------------------------

  @override
  Future<List<CfoRetainer>> getRetainers() async =>
      List.unmodifiable(_retainerState);

  @override
  Future<CfoRetainer?> getRetainerById(String id) async {
    final idx = _retainerState.indexWhere((r) => r.id == id);
    return idx == -1 ? null : _retainerState[idx];
  }

  @override
  Future<List<CfoRetainer>> getRetainersByStatus(
    CfoRetainerStatus status,
  ) async => List.unmodifiable(
    _retainerState.where((r) => r.status == status).toList(),
  );

  @override
  Future<String> insertRetainer(CfoRetainer retainer) async {
    _retainerState.add(retainer);
    return retainer.id;
  }

  @override
  Future<bool> updateRetainer(CfoRetainer retainer) async {
    final idx = _retainerState.indexWhere((r) => r.id == retainer.id);
    if (idx == -1) return false;
    final updated = List<CfoRetainer>.of(_retainerState)..[idx] = retainer;
    _retainerState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteRetainer(String id) async {
    final before = _retainerState.length;
    _retainerState.removeWhere((r) => r.id == id);
    return _retainerState.length < before;
  }
}
