import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/practice_workflows_table.dart';

part 'practice_dao.g.dart';

@DriftAccessor(tables: [PracticeWorkflowsTable])
class PracticeDao extends DatabaseAccessor<AppDatabase>
    with _$PracticeDaoMixin {
  PracticeDao(super.db);

  /// Insert a new workflow and return its ID.
  Future<String> insertWorkflow(
    PracticeWorkflowsTableCompanion companion,
  ) async {
    await into(practiceWorkflowsTable).insert(companion);
    return companion.id.value;
  }

  /// Get all workflows ordered by name.
  Future<List<WorkflowRow>> getAllWorkflows() =>
      (select(practiceWorkflowsTable)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  /// Get workflows filtered by category.
  Future<List<WorkflowRow>> getByCategory(String category) =>
      (select(practiceWorkflowsTable)
            ..where((t) => t.category.equals(category))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  /// Get a workflow by its ID.
  Future<WorkflowRow?> getWorkflowById(String id) =>
      (select(practiceWorkflowsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Update a workflow.
  /// Returns true if a row was affected, false otherwise.
  Future<bool> updateWorkflow(
    PracticeWorkflowsTableCompanion companion,
  ) async {
    final rowsAffected = await (update(practiceWorkflowsTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
    return rowsAffected > 0;
  }

  /// Delete a workflow by ID.
  /// Returns true if a row was affected.
  Future<bool> deleteWorkflow(String id) async {
    final rowsAffected =
        await (delete(practiceWorkflowsTable)..where((t) => t.id.equals(id)))
            .go();
    return rowsAffected > 0;
  }

  /// Get all active workflows.
  Future<List<WorkflowRow>> getActiveWorkflows() =>
      (select(practiceWorkflowsTable)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
}
