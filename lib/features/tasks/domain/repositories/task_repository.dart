import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

abstract class TaskRepository {
  Future<List<Task>> getAll({String? firmId});
  Future<Task?> getById(String id);
  Future<Task> create(Task task);
  Future<Task> update(Task task);
  Future<void> delete(String id);
  Future<List<Task>> getByClientId(String clientId);
  Future<List<Task>> getByStatus(TaskStatus status, {String? firmId});
  Future<List<Task>> search(String query, {String? firmId});
  Stream<List<Task>> watchAll({String? firmId});
}
