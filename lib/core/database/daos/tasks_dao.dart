import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/tasks_table.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [TasksTable])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Future<List<TaskRow>> getAllTasks(String firmId) =>
      (select(tasksTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<TaskRow?> getTaskById(String id) =>
      (select(tasksTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<TaskRow>> getByClientId(String clientId) =>
      (select(tasksTable)..where((t) => t.clientId.equals(clientId))).get();

  Future<List<TaskRow>> getByStatus(String firmId, String status) => (select(
    tasksTable,
  )..where((t) => t.firmId.equals(firmId) & t.status.equals(status))).get();

  Future<List<TaskRow>> searchTasks(String firmId, String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(tasksTable)..where(
          (t) =>
              t.firmId.equals(firmId) &
              (t.title.lower().like(q) |
                  t.clientName.lower().like(q) |
                  t.description.lower().like(q)),
        ))
        .get();
  }

  Future<void> upsertTask(TasksTableCompanion task) =>
      into(tasksTable).insertOnConflictUpdate(task);

  Future<void> deleteTask(String id) =>
      (delete(tasksTable)..where((t) => t.id.equals(id))).go();

  Stream<List<TaskRow>> watchAllTasks(String firmId) =>
      (select(tasksTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<TaskRow>> getDirtyTasks() =>
      (select(tasksTable)..where((t) => t.isDirty)).get();

  Future<void> markTaskSynced(String id, DateTime syncedAt) =>
      (update(tasksTable)..where((t) => t.id.equals(id))).write(
        TasksTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
