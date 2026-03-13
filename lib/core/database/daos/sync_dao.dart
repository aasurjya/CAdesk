import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/sync_table.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable, SyncConflictsTable])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<void> enqueue(SyncQueueTableCompanion entry) =>
      into(syncQueueTable).insert(entry);

  Future<List<SyncQueueRow>> getPending({int limit = 50}) =>
      (select(syncQueueTable)
            ..where((t) => t.attempts.isSmallerThanValue(3))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<void> incrementAttempt(String id, String error) async {
    final row = await (select(
      syncQueueTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(
        attempts: Value(row.attempts + 1),
        lastError: Value(error),
      ),
    );
  }

  Future<void> dequeue(String id) =>
      (delete(syncQueueTable)..where((t) => t.id.equals(id))).go();

  Future<void> recordConflict(SyncConflictsTableCompanion conflict) =>
      into(syncConflictsTable).insert(conflict);

  Future<List<SyncConflictRow>> getUnresolvedConflicts() =>
      (select(syncConflictsTable)..where((t) => t.resolvedAt.isNull())).get();

  Future<void> resolveConflict(String id, String resolution) =>
      (update(syncConflictsTable)..where((t) => t.id.equals(id))).write(
        SyncConflictsTableCompanion(
          resolvedAt: Value(DateTime.now()),
          resolution: Value(resolution),
        ),
      );
}
