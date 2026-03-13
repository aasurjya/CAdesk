import 'dart:async';

import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';
import 'package:ca_app/features/reconciliation/domain/repositories/reconciliation_repository.dart';

/// In-memory mock implementation of [ReconciliationRepository].
///
/// Used when the `reconciliation_real_repo` feature flag is disabled
/// (offline / dev mode). Seeded with realistic Indian CA reconciliation data.
class MockReconciliationRepository implements ReconciliationRepository {
  static final List<ReconciliationResult> _seedResults = [
    ReconciliationResult(
      id: 'recon-1',
      clientId: 'client-1',
      reconciliationType: ReconciliationType.tds26as,
      period: 'FY 2024-25',
      totalMatched: 18,
      totalUnmatched: 3,
      discrepancies: [
        const Discrepancy(
          id: 'disc-1',
          resultId: 'recon-1',
          field: 'tds_amount',
          expectedValue: '125000',
          actualValue: '120000',
          source: '26AS',
          resolved: false,
        ),
        const Discrepancy(
          id: 'disc-2',
          resultId: 'recon-1',
          field: 'income',
          expectedValue: '850000',
          actualValue: '800000',
          source: 'AIS',
          resolved: true,
        ),
      ],
      status: ReconciliationStatus.inProgress,
      createdAt: DateTime(2025, 4, 10),
      updatedAt: DateTime(2025, 4, 10),
    ),
    ReconciliationResult(
      id: 'recon-2',
      clientId: 'client-1',
      reconciliationType: ReconciliationType.gstr2b,
      period: 'Mar 2025',
      totalMatched: 42,
      totalUnmatched: 1,
      discrepancies: [
        const Discrepancy(
          id: 'disc-3',
          resultId: 'recon-2',
          field: 'igst',
          expectedValue: '18000',
          actualValue: '0',
          source: 'GSTR-2B',
          resolved: false,
        ),
      ],
      status: ReconciliationStatus.pending,
      createdAt: DateTime(2025, 4, 15),
      updatedAt: DateTime(2025, 4, 15),
    ),
    ReconciliationResult(
      id: 'recon-3',
      clientId: 'client-2',
      reconciliationType: ReconciliationType.bankRecon,
      period: 'Mar 2025',
      totalMatched: 55,
      totalUnmatched: 0,
      discrepancies: const [],
      status: ReconciliationStatus.reviewed,
      reviewedBy: 'CA Meeta Joshi',
      reviewedDate: DateTime(2025, 4, 20),
      createdAt: DateTime(2025, 4, 18),
      updatedAt: DateTime(2025, 4, 20),
    ),
    ReconciliationResult(
      id: 'recon-4',
      clientId: 'client-2',
      reconciliationType: ReconciliationType.pan3way,
      period: 'FY 2024-25',
      totalMatched: 30,
      totalUnmatched: 5,
      discrepancies: [
        const Discrepancy(
          id: 'disc-4',
          resultId: 'recon-4',
          field: 'pan_income',
          expectedValue: '2500000',
          actualValue: '2350000',
          source: 'ITR',
          resolved: false,
        ),
        const Discrepancy(
          id: 'disc-5',
          resultId: 'recon-4',
          field: 'tds_credit',
          expectedValue: '75000',
          actualValue: '70000',
          source: '26AS',
          resolved: false,
        ),
      ],
      status: ReconciliationStatus.inProgress,
      createdAt: DateTime(2025, 5, 1),
      updatedAt: DateTime(2025, 5, 1),
    ),
  ];

  final List<ReconciliationResult> _state = List.of(_seedResults);

  @override
  Future<String> insertReconciliationResult(
    ReconciliationResult result,
  ) async {
    _state.add(result);
    return result.id;
  }

  @override
  Future<List<ReconciliationResult>> getReconciliationsByClient(
    String clientId,
  ) async =>
      List.unmodifiable(
        _state.where((r) => r.clientId == clientId),
      );

  @override
  Future<List<ReconciliationResult>> getReconciliationByType(
    ReconciliationType type,
    String clientId,
  ) async =>
      List.unmodifiable(
        _state.where(
          (r) => r.clientId == clientId && r.reconciliationType == type,
        ),
      );

  @override
  Future<List<Discrepancy>> getUnreconciledItems(String clientId) async =>
      List.unmodifiable(
        _state
            .where((r) => r.clientId == clientId)
            .expand((r) => r.discrepancies)
            .where((d) => !d.resolved),
      );

  @override
  Future<bool> updateReconciliationStatus(
    String resultId,
    ReconciliationStatus status,
  ) async {
    final idx = _state.indexWhere((r) => r.id == resultId);
    if (idx == -1) return false;
    // Immutable replacement.
    final updated = List<ReconciliationResult>.of(_state);
    updated[idx] = updated[idx].copyWith(status: status);
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> markDiscrepancyResolved(String discrepancyId) async {
    for (var i = 0; i < _state.length; i++) {
      final result = _state[i];
      final dIdx = result.discrepancies.indexWhere((d) => d.id == discrepancyId);
      if (dIdx == -1) continue;

      // Immutable replacement of the discrepancy list.
      final updatedDiscrepancies = List<Discrepancy>.of(result.discrepancies);
      updatedDiscrepancies[dIdx] =
          updatedDiscrepancies[dIdx].copyWith(resolved: true);

      final updatedResult = result.copyWith(
        discrepancies: List.unmodifiable(updatedDiscrepancies),
      );

      final updatedState = List<ReconciliationResult>.of(_state);
      updatedState[i] = updatedResult;
      _state
        ..clear()
        ..addAll(updatedState);
      return true;
    }
    return false;
  }
}
