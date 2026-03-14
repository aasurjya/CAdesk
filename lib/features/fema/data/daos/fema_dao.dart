import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/fema_filings_table.dart';

part 'fema_dao.g.dart';

@DriftAccessor(tables: [FemaFilingsTable])
class FemaDao extends DatabaseAccessor<AppDatabase> with _$FemaDaoMixin {
  FemaDao(super.db);

  // ---------------------------------------------------------------------------
  // Inserts
  // ---------------------------------------------------------------------------

  /// Insert a filing companion and return the row ID.
  Future<String> insertFemaFiling(FemaFilingsTableCompanion companion) async {
    await into(femaFilingsTable).insert(companion);
    final rows =
        await (select(femaFilingsTable)
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isNotEmpty ? rows.first.id : '';
  }

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// Retrieve all filings for a given client.
  Future<List<FemaFilingsTableData>> getFemaFilingsByClient(String clientId) =>
      (select(femaFilingsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.transactionDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Retrieve filings by type.
  Future<List<FemaFilingsTableData>> getFemaFilingsByType(String filingType) =>
      (select(femaFilingsTable)
            ..where((t) => t.filingType.equals(filingType))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.transactionDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Retrieve filings by status.
  Future<List<FemaFilingsTableData>> getFemaFilingsByStatus(String status) =>
      (select(femaFilingsTable)
            ..where((t) => t.status.equals(status))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.transactionDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Retrieve filings for a client within a calendar year.
  Future<List<FemaFilingsTableData>> getFemaFilingsByYear(
    String clientId,
    int year,
  ) async {
    final start = DateTime(year);
    final end = DateTime(year + 1);
    return (select(femaFilingsTable)
          ..where(
            (t) =>
                t.clientId.equals(clientId) &
                t.transactionDate.isBetweenValues(start, end),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Retrieve a single filing by ID.
  Future<FemaFilingsTableData?> getFemaFilingById(String id) => (select(
    femaFilingsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Update the status field for a filing, returning true on success.
  Future<bool> updateFemaFilingStatus(String id, String status) async {
    final count =
        await (update(femaFilingsTable)..where((t) => t.id.equals(id))).write(
          FemaFilingsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Watch filings for a client (emits on every change).
  Stream<List<FemaFilingsTableData>> watchFemaFilingsByClient(
    String clientId,
  ) =>
      (select(femaFilingsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.transactionDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();
}
