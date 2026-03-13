import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/rpa_table.dart';

part 'rpa_dao.g.dart';

@DriftAccessor(tables: [RpaTasksTable])
class RpaDao extends DatabaseAccessor<AppDatabase> with _$RpaDaoMixin {
  RpaDao(super.db);

  Future<void> insert(RpaTasksTableCompanion companion) =>
      into(rpaTasksTable).insertOnConflictUpdate(companion);

  Future<List<RpaTaskRow>> getByClient(String clientId) =>
      (select(rpaTasksTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
          .get();

  Future<List<RpaTaskRow>> getByStatus(String status) =>
      (select(rpaTasksTable)
            ..where((t) => t.status.equals(status))
            ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
          .get();

  Future<List<RpaTaskRow>> getByType(String taskType) =>
      (select(rpaTasksTable)
            ..where((t) => t.taskType.equals(taskType))
            ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
          .get();

  Future<bool> updateStatus(
    String id,
    String status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    int? retryCount,
  }) async {
    final count = await (update(rpaTasksTable)..where((t) => t.id.equals(id)))
        .write(
          RpaTasksTableCompanion(
            status: Value(status),
            startedAt: Value(startedAt),
            completedAt: Value(completedAt),
            result: Value(result),
            errorMessage: Value(errorMessage),
            retryCount: retryCount != null
                ? Value(retryCount)
                : const Value.absent(),
          ),
        );
    return count > 0;
  }

  Future<List<RpaTaskRow>> getScheduled(DateTime beforeTime) =>
      (select(rpaTasksTable)
            ..where(
              (t) =>
                  t.status.equals('scheduled') &
                  t.scheduledAt.isSmallerThanValue(beforeTime),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();

  Future<List<RpaTaskRow>> getPending() =>
      (select(rpaTasksTable)
            ..where(
              (t) =>
                  t.status.equals('scheduled') | t.status.equals('running'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();

  Future<bool> cancel(String taskId) async {
    final count =
        await (update(rpaTasksTable)..where((t) => t.id.equals(taskId))).write(
          const RpaTasksTableCompanion(status: Value('cancelled')),
        );
    return count > 0;
  }
}
