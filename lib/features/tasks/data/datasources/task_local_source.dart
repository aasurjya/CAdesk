import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/tasks/data/mappers/task_mapper.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

class TaskLocalSource {
  const TaskLocalSource(this._db);

  final AppDatabase _db;

  Future<List<Task>> getAll({String firmId = ''}) async {
    final rows = await _db.tasksDao.getAllTasks(firmId);
    return rows.map(TaskMapper.fromRow).toList();
  }

  Future<Task?> getById(String id) async {
    final row = await _db.tasksDao.getTaskById(id);
    return row != null ? TaskMapper.fromRow(row) : null;
  }

  Future<List<Task>> getByClientId(String clientId) async {
    final rows = await _db.tasksDao.getByClientId(clientId);
    return rows.map(TaskMapper.fromRow).toList();
  }

  Future<List<Task>> getByStatus(
    TaskStatus status, {
    String firmId = '',
  }) async {
    final rows = await _db.tasksDao.getByStatus(firmId, status.name);
    return rows.map(TaskMapper.fromRow).toList();
  }

  Future<List<Task>> search(String query, {String firmId = ''}) async {
    final rows = await _db.tasksDao.searchTasks(firmId, query);
    return rows.map(TaskMapper.fromRow).toList();
  }

  Future<void> upsert(Task task, {String firmId = ''}) async {
    await _db.tasksDao.upsertTask(TaskMapper.toCompanion(task, firmId: firmId));
  }

  Future<void> delete(String id) => _db.tasksDao.deleteTask(id);

  Stream<List<Task>> watchAll({String firmId = ''}) {
    return _db.tasksDao
        .watchAllTasks(firmId)
        .map((rows) => rows.map(TaskMapper.fromRow).toList());
  }
}
