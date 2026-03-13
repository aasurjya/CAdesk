import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/export_jobs_table.dart';

part 'export_jobs_dao.g.dart';

@DriftAccessor(tables: [ExportJobsTable])
class ExportJobsDao extends DatabaseAccessor<AppDatabase>
    with _$ExportJobsDaoMixin {
  ExportJobsDao(super.db);

  /// Insert a new export job, returning its ID.
  Future<String> insertJob(ExportJobsTableCompanion companion) async {
    await into(exportJobsTable).insert(companion);
    final rows = await (select(exportJobsTable)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .get();
    return rows.isNotEmpty ? rows.first.id : '';
  }

  /// Get all export jobs for a client.
  Future<List<ExportJobRow>> getByClient(String clientId) =>
      (select(exportJobsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Watch export jobs for a client (reactive).
  Stream<List<ExportJobRow>> watchByClient(String clientId) =>
      (select(exportJobsTable)..where((t) => t.clientId.equals(clientId)))
          .watch();

  /// Get export jobs by status.
  Future<List<ExportJobRow>> getByStatus(String status) =>
      (select(exportJobsTable)..where((t) => t.status.equals(status))).get();

  /// Update status (and optional fields) for a job. Returns true if updated.
  Future<bool> updateStatus(
    String id,
    String status, {
    String? filePath,
    String? errorMessage,
    DateTime? completedAt,
  }) async {
    final rowsAffected = await (update(exportJobsTable)
          ..where((t) => t.id.equals(id)))
        .write(
          ExportJobsTableCompanion(
            status: Value(status),
            filePath: Value(filePath),
            errorMessage: Value(errorMessage),
            completedAt: Value(completedAt),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Delete jobs older than [beforeDate]. Returns number of deleted rows.
  Future<int> deleteOldJobs(DateTime beforeDate) =>
      (delete(exportJobsTable)
            ..where((t) => t.createdAt.isSmallerThanValue(beforeDate)))
          .go();

  /// Get a single export job by ID.
  Future<ExportJobRow?> getById(String id) =>
      (select(exportJobsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Upsert an export job.
  Future<void> upsert(ExportJobsTableCompanion companion) =>
      into(exportJobsTable).insertOnConflictUpdate(companion);
}
