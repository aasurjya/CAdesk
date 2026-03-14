import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';

/// Data Access Object for reconciliation results.
///
/// Operates directly on the [AppDatabase] using the [ReconciliationResultsTable].
/// Discrepancies are stored as JSON text inside the [discrepancies] column.
class ReconciliationDao {
  const ReconciliationDao(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Insert
  // ---------------------------------------------------------------------------

  /// Insert a new reconciliation result. Returns the inserted row ID.
  Future<String> insertReconciliationResult(
    ReconciliationResultsTableCompanion companion,
  ) async {
    await _db.into(_db.reconciliationResultsTable).insert(companion);
    return companion.id.value;
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Fetch all reconciliation results for a given client, newest first.
  Future<List<ReconciliationResultsTableData>> getReconciliationsByClient(
    String clientId,
  ) =>
      (_db.select(_db.reconciliationResultsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Fetch results for a specific [ReconciliationType] and client.
  Future<List<ReconciliationResultsTableData>> getReconciliationByType(
    String reconciliationType,
    String clientId,
  ) =>
      (_db.select(_db.reconciliationResultsTable)
            ..where(
              (t) =>
                  t.clientId.equals(clientId) &
                  t.reconciliationType.equals(reconciliationType),
            )
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Fetch a single result by ID.
  Future<ReconciliationResultsTableData?> getReconciliationById(String id) =>
      (_db.select(
        _db.reconciliationResultsTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Update the status field of a reconciliation result.
  /// Returns true if a row was modified.
  Future<bool> updateReconciliationStatus(
    String resultId,
    String status,
  ) async {
    final rows =
        await (_db.update(
          _db.reconciliationResultsTable,
        )..where((t) => t.id.equals(resultId))).write(
          ReconciliationResultsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rows > 0;
  }

  /// Upsert (insert or replace) a reconciliation result.
  Future<void> upsertReconciliationResult(
    ReconciliationResultsTableCompanion companion,
  ) => _db
      .into(_db.reconciliationResultsTable)
      .insertOnConflictUpdate(companion);

  // ---------------------------------------------------------------------------
  // Helpers for discrepancy resolution
  // ---------------------------------------------------------------------------

  /// Fetch every reconciliation result row (used for cross-client scans).
  Future<List<ReconciliationResultsTableData>> getAllResults() =>
      _db.select(_db.reconciliationResultsTable).get();

  /// Update the discrepancies JSON for a result (used by markDiscrepancyResolved).
  Future<bool> updateDiscrepanciesJson(
    String resultId,
    String discrepanciesJson,
  ) async {
    final rows =
        await (_db.update(
          _db.reconciliationResultsTable,
        )..where((t) => t.id.equals(resultId))).write(
          ReconciliationResultsTableCompanion(
            discrepancies: Value(discrepanciesJson),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rows > 0;
  }
}
