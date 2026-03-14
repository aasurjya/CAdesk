import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/practice/data/mappers/practice_mapper.dart';
import 'package:ca_app/features/practice/domain/models/workflow.dart';

class PracticeLocalSource {
  const PracticeLocalSource(this._db);

  final AppDatabase _db;

  Future<String> insertWorkflow(Workflow workflow) => _db.practiceDao
      .insertWorkflow(PracticeMapper.workflowToCompanion(workflow));

  Future<List<Workflow>> getAllWorkflows() async {
    final rows = await _db.practiceDao.getAllWorkflows();
    return rows.map(PracticeMapper.workflowFromRow).toList();
  }

  Future<List<Workflow>> getByCategory(WorkflowCategory category) async {
    final rows = await _db.practiceDao.getByCategory(category.name);
    return rows.map(PracticeMapper.workflowFromRow).toList();
  }

  Future<Workflow?> getWorkflowById(String id) async {
    final row = await _db.practiceDao.getWorkflowById(id);
    return row != null ? PracticeMapper.workflowFromRow(row) : null;
  }

  Future<bool> updateWorkflow(Workflow workflow) => _db.practiceDao
      .updateWorkflow(PracticeMapper.workflowToCompanion(workflow));

  Future<bool> deleteWorkflow(String id) => _db.practiceDao.deleteWorkflow(id);

  Future<List<Workflow>> getActiveWorkflows() async {
    final rows = await _db.practiceDao.getActiveWorkflows();
    return rows.map(PracticeMapper.workflowFromRow).toList();
  }
}
