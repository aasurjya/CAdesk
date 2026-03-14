import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/msme_records_table.dart';

part 'msme_dao.g.dart';

@DriftAccessor(tables: [MsmeRecordsTable])
class MsmeDao extends DatabaseAccessor<AppDatabase> with _$MsmeDaoMixin {
  MsmeDao(super.db);

  // ---------------------------------------------------------------------------
  // Inserts
  // ---------------------------------------------------------------------------

  /// Insert a record companion and return the row ID.
  Future<String> insertMsmeRecord(MsmeRecordsTableCompanion companion) async {
    await into(msmeRecordsTable).insert(companion);
    final rows =
        await (select(msmeRecordsTable)
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

  /// Retrieve all records for a given client.
  Future<List<MsmeRecordsTableData>> getMsmeRecordsByClient(String clientId) =>
      (select(msmeRecordsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.registrationDate)]))
          .get();

  /// Retrieve records by enterprise category.
  Future<List<MsmeRecordsTableData>> getMsmeRecordsByCategory(
    String category,
  ) =>
      (select(msmeRecordsTable)
            ..where((t) => t.category.equals(category))
            ..orderBy([(t) => OrderingTerm(expression: t.registrationDate)]))
          .get();

  /// Retrieve records by status.
  Future<List<MsmeRecordsTableData>> getMsmeRecordsByStatus(String status) =>
      (select(msmeRecordsTable)
            ..where((t) => t.status.equals(status))
            ..orderBy([(t) => OrderingTerm(expression: t.registrationDate)]))
          .get();

  /// Retrieve a single record by ID.
  Future<MsmeRecordsTableData?> getMsmeRecordById(String id) => (select(
    msmeRecordsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Replace the full record row and return true on success.
  Future<bool> updateMsmeRecord(MsmeRecordsTableCompanion companion) =>
      update(msmeRecordsTable).replace(companion);

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Watch records for a client (emits on every change).
  Stream<List<MsmeRecordsTableData>> watchMsmeRecordsByClient(
    String clientId,
  ) =>
      (select(msmeRecordsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.registrationDate)]))
          .watch();
}
