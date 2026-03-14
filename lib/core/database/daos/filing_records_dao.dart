import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/filing_records_table.dart';

part 'filing_records_dao.g.dart';

@DriftAccessor(tables: [FilingRecordsTable])
class FilingRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$FilingRecordsDaoMixin {
  FilingRecordsDao(super.db);

  /// Insert a new filing record, returning its ID.
  Future<String> insertRecord(FilingRecordsTableCompanion companion) async {
    await into(filingRecordsTable).insert(companion);
    final rows =
        await (select(filingRecordsTable)
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

  /// Get all filing records for a client.
  Future<List<FilingRecordRow>> getByClient(String clientId) =>
      (select(filingRecordsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Watch filing records for a client (reactive).
  Stream<List<FilingRecordRow>> watchByClient(String clientId) => (select(
    filingRecordsTable,
  )..where((t) => t.clientId.equals(clientId))).watch();

  /// Get filing records by filing type.
  Future<List<FilingRecordRow>> getByType(String filingType) => (select(
    filingRecordsTable,
  )..where((t) => t.filingType.equals(filingType))).get();

  /// Get filing records by status.
  Future<List<FilingRecordRow>> getByStatus(String status) =>
      (select(filingRecordsTable)..where((t) => t.status.equals(status))).get();

  /// Update the status of a filing record. Returns true if a row was updated.
  Future<bool> updateStatus(String id, String status) async {
    final rowsAffected =
        await (update(filingRecordsTable)..where((t) => t.id.equals(id))).write(
          FilingRecordsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Get overdue records: status is pending/inProgress and filedDate is null,
  /// and the record was created more than 30 days ago.
  Future<List<FilingRecordRow>> getOverdue() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return (select(filingRecordsTable)..where(
          (t) =>
              t.filedDate.isNull() &
              (t.status.equals('pending') | t.status.equals('inProgress')) &
              t.createdAt.isSmallerThanValue(cutoff),
        ))
        .get();
  }

  /// Get a single filing record by ID.
  Future<FilingRecordRow?> getById(String id) => (select(
    filingRecordsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Upsert a filing record (insert or replace on conflict).
  Future<void> upsert(FilingRecordsTableCompanion companion) =>
      into(filingRecordsTable).insertOnConflictUpdate(companion);
}
