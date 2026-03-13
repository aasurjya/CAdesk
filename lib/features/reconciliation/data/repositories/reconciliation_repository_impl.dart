import 'package:ca_app/features/reconciliation/data/datasources/reconciliation_local_source.dart';
import 'package:ca_app/features/reconciliation/data/datasources/reconciliation_remote_source.dart';
import 'package:ca_app/features/reconciliation/data/mappers/reconciliation_mapper.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';
import 'package:ca_app/features/reconciliation/domain/repositories/reconciliation_repository.dart';

/// Concrete implementation of [ReconciliationRepository].
///
/// Follows the write-through cache pattern:
/// - Reads: try remote first, fall back to local on failure.
/// - Writes: write to remote, then cache locally.
class ReconciliationRepositoryImpl implements ReconciliationRepository {
  const ReconciliationRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final ReconciliationRemoteSource remote;
  final ReconciliationLocalSource local;
  final String firmId;

  @override
  Future<String> insertReconciliationResult(
    ReconciliationResult result,
  ) async {
    try {
      final json = await remote.insert({
        ...ReconciliationMapper.toJson(result),
        if (firmId.isNotEmpty) 'firm_id': firmId,
      });
      final created = ReconciliationMapper.fromJson(json);
      await local.upsert(created);
      return created.id;
    } catch (_) {
      // Offline fallback — write to local only.
      return local.insertReconciliationResult(result);
    }
  }

  @override
  Future<List<ReconciliationResult>> getReconciliationsByClient(
    String clientId,
  ) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final results = jsonList.map(ReconciliationMapper.fromJson).toList();
      // Write-through cache.
      for (final r in results) {
        await local.upsert(r);
      }
      return List.unmodifiable(results);
    } catch (_) {
      return local.getReconciliationsByClient(clientId);
    }
  }

  @override
  Future<List<ReconciliationResult>> getReconciliationByType(
    ReconciliationType type,
    String clientId,
  ) async {
    try {
      final jsonList = await remote.fetchByType(type, clientId);
      final results = jsonList.map(ReconciliationMapper.fromJson).toList();
      for (final r in results) {
        await local.upsert(r);
      }
      return List.unmodifiable(results);
    } catch (_) {
      return local.getReconciliationByType(type, clientId);
    }
  }

  @override
  Future<List<Discrepancy>> getUnreconciledItems(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final results = jsonList.map(ReconciliationMapper.fromJson).toList();
      for (final r in results) {
        await local.upsert(r);
      }
      return List.unmodifiable(
        results.expand((r) => r.discrepancies).where((d) => !d.resolved),
      );
    } catch (_) {
      return local.getUnreconciledItems(clientId);
    }
  }

  @override
  Future<bool> updateReconciliationStatus(
    String resultId,
    ReconciliationStatus status,
  ) async {
    try {
      await remote.updateStatus(resultId, status.name);
      await local.updateReconciliationStatus(resultId, status);
      return true;
    } catch (_) {
      return local.updateReconciliationStatus(resultId, status);
    }
  }

  @override
  Future<bool> markDiscrepancyResolved(String discrepancyId) async {
    // Resolve locally (updates JSON blob in SQLite).
    final localSuccess = await local.markDiscrepancyResolved(discrepancyId);
    // Best-effort remote sync — failure is non-fatal (local is source of truth).
    try {
      // Remote stores discrepancies as JSONB; a patch is complex without
      // knowing the result ID, so we accept eventual consistency here.
      // If future API supports discrepancy-level update, wire it here.
    } catch (_) {
      // Swallow remote failure — local write succeeded.
    }
    return localSuccess;
  }
}
