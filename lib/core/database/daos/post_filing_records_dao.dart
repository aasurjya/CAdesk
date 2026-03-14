import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/post_filing_records_table.dart';

part 'post_filing_records_dao.g.dart';

@DriftAccessor(tables: [PostFilingRecordsTable])
class PostFilingRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$PostFilingRecordsDaoMixin {
  PostFilingRecordsDao(super.db);

  /// Insert a new post-filing record, returning its ID.
  Future<String> insertRecord(PostFilingRecordsTableCompanion companion) async {
    await into(postFilingRecordsTable).insert(companion);
    final rows =
        await (select(postFilingRecordsTable)
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

  /// Get all records for a specific filing.
  Future<List<PostFilingRecordRow>> getByFiling(String filingId) =>
      (select(postFilingRecordsTable)
            ..where((t) => t.filingId.equals(filingId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Get all records for a client.
  Future<List<PostFilingRecordRow>> getByClient(String clientId) =>
      (select(postFilingRecordsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Watch records for a client (reactive).
  Stream<List<PostFilingRecordRow>> watchByClient(String clientId) => (select(
    postFilingRecordsTable,
  )..where((t) => t.clientId.equals(clientId))).watch();

  /// Update the status of a record. Returns true if updated.
  Future<bool> updateStatus(
    String id,
    String status, {
    DateTime? completedAt,
    String? notes,
  }) async {
    final rowsAffected =
        await (update(
          postFilingRecordsTable,
        )..where((t) => t.id.equals(id))).write(
          PostFilingRecordsTableCompanion(
            status: Value(status),
            completedAt: Value(completedAt),
            notes: Value(notes),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Get all pending records.
  Future<List<PostFilingRecordRow>> getPending() =>
      (select(postFilingRecordsTable)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
            ]))
          .get();

  /// Get a single record by ID.
  Future<PostFilingRecordRow?> getById(String id) => (select(
    postFilingRecordsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Upsert a post-filing record.
  Future<void> upsert(PostFilingRecordsTableCompanion companion) =>
      into(postFilingRecordsTable).insertOnConflictUpdate(companion);
}
