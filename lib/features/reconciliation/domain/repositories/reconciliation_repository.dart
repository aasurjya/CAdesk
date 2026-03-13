import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';

abstract class ReconciliationRepository {
  /// Insert a new reconciliation result and return its ID.
  Future<String> insertReconciliationResult(ReconciliationResult result);

  /// Get all reconciliation results for a specific client.
  Future<List<ReconciliationResult>> getReconciliationsByClient(
    String clientId,
  );

  /// Get reconciliation results for a specific type and client.
  Future<List<ReconciliationResult>> getReconciliationByType(
    ReconciliationType type,
    String clientId,
  );

  /// Get all unresolved discrepancies for a specific client.
  Future<List<Discrepancy>> getUnreconciledItems(String clientId);

  /// Update the status of a reconciliation result.
  /// Returns true if the update was successful.
  Future<bool> updateReconciliationStatus(
    String resultId,
    ReconciliationStatus status,
  );

  /// Mark a specific discrepancy as resolved.
  /// Returns true if the update was successful.
  Future<bool> markDiscrepancyResolved(String discrepancyId);
}
