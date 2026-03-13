import 'dart:convert';

import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/reconciliation/data/daos/reconciliation_dao.dart';
import 'package:ca_app/features/reconciliation/data/mappers/reconciliation_mapper.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';

/// Local data source for reconciliation results backed by Drift (SQLite).
class ReconciliationLocalSource {
  ReconciliationLocalSource(AppDatabase db) : _dao = ReconciliationDao(db);

  final ReconciliationDao _dao;

  /// Insert a reconciliation result into local storage. Returns the inserted ID.
  Future<String> insertReconciliationResult(ReconciliationResult result) {
    final companion = ReconciliationMapper.toCompanion(result);
    return _dao.insertReconciliationResult(companion);
  }

  /// Fetch all reconciliation results for a client from local storage.
  Future<List<ReconciliationResult>> getReconciliationsByClient(
    String clientId,
  ) async {
    final rows = await _dao.getReconciliationsByClient(clientId);
    return rows.map(ReconciliationMapper.fromRow).toList();
  }

  /// Fetch results by type and client from local storage.
  Future<List<ReconciliationResult>> getReconciliationByType(
    ReconciliationType type,
    String clientId,
  ) async {
    final rows = await _dao.getReconciliationByType(type.name, clientId);
    return rows.map(ReconciliationMapper.fromRow).toList();
  }

  /// Fetch all unresolved discrepancies for a client from local storage.
  Future<List<Discrepancy>> getUnreconciledItems(String clientId) async {
    final rows = await _dao.getReconciliationsByClient(clientId);
    return rows
        .map(ReconciliationMapper.fromRow)
        .expand((r) => r.discrepancies)
        .where((d) => !d.resolved)
        .toList();
  }

  /// Update the status of a reconciliation result.
  Future<bool> updateReconciliationStatus(
    String resultId,
    ReconciliationStatus status,
  ) =>
      _dao.updateReconciliationStatus(resultId, status.name);

  /// Mark a discrepancy as resolved by updating the stored JSON.
  Future<bool> markDiscrepancyResolved(String discrepancyId) async {
    // We must find which result owns this discrepancy, then patch the JSON.
    // Since SQLite/Drift doesn't support JSON-path queries we scan all rows.
    final allRows = await _dao.getAllResults();
    final allResults = allRows.map(ReconciliationMapper.fromRow).toList();

    for (final result in allResults) {
      final idx = result.discrepancies.indexWhere((d) => d.id == discrepancyId);
      if (idx == -1) continue;

      // Build updated list — immutable replacement.
      final updated = List<Discrepancy>.of(result.discrepancies);
      updated[idx] = updated[idx].copyWith(resolved: true);

      final json = jsonEncode(
        updated.map((d) {
          return {
            'id': d.id,
            'result_id': d.resultId,
            'field': d.field,
            'expected_value': d.expectedValue,
            'actual_value': d.actualValue,
            'source': d.source,
            'resolved': d.resolved,
          };
        }).toList(),
      );
      return _dao.updateDiscrepanciesJson(result.id, json);
    }
    return false;
  }

  /// Upsert (write-through cache) a reconciliation result.
  Future<void> upsert(ReconciliationResult result) {
    final companion = ReconciliationMapper.toCompanion(result);
    return _dao.upsertReconciliationResult(companion);
  }
}
