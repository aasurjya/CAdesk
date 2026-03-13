import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/startup_records_table.dart';

part 'startup_dao.g.dart';

@DriftAccessor(tables: [StartupRecordsTable])
class StartupDao extends DatabaseAccessor<AppDatabase>
    with _$StartupDaoMixin {
  StartupDao(super.db);

  // ---------------------------------------------------------------------------
  // Inserts
  // ---------------------------------------------------------------------------

  /// Insert a record companion and return the row ID.
  Future<String> insertStartupRecord(
    StartupRecordsTableCompanion companion,
  ) async {
    await into(startupRecordsTable).insert(companion);
    final rows = await (select(startupRecordsTable)
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
  Future<List<StartupRecordsTableData>> getStartupRecordsByClient(
    String clientId,
  ) =>
      (select(startupRecordsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.incorporationDate),
            ]))
          .get();

  /// Retrieve records by recognition status.
  Future<List<StartupRecordsTableData>> getStartupRecordsByStatus(
    String status,
  ) =>
      (select(startupRecordsTable)
            ..where((t) => t.recognitionStatus.equals(status))
            ..orderBy([
              (t) => OrderingTerm(expression: t.incorporationDate),
            ]))
          .get();

  /// Retrieve records eligible for Section 80-IAC or Section 56 exemptions.
  Future<List<StartupRecordsTableData>> getEligibleForExemptions() =>
      (select(startupRecordsTable)
            ..where(
              (t) =>
                  t.section80IacEligible.equals(true) |
                  t.section56ExemptEligible.equals(true),
            )
            ..orderBy([
              (t) => OrderingTerm(expression: t.incorporationDate),
            ]))
          .get();

  /// Retrieve a single record by ID.
  Future<StartupRecordsTableData?> getStartupRecordById(String id) =>
      (select(startupRecordsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Replace the full record row and return true on success.
  Future<bool> updateStartupRecord(
    StartupRecordsTableCompanion companion,
  ) =>
      update(startupRecordsTable).replace(companion);

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Watch records for a client (emits on every change).
  Stream<List<StartupRecordsTableData>> watchStartupRecordsByClient(
    String clientId,
  ) =>
      (select(startupRecordsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.incorporationDate),
            ]))
          .watch();
}
