import 'package:ca_app/features/tasks/data/datasources/task_local_source.dart';
import 'package:ca_app/features/tasks/data/datasources/task_remote_source.dart';
import 'package:ca_app/features/tasks/data/mappers/task_mapper.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';
import 'package:ca_app/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final TaskRemoteSource remote;
  final TaskLocalSource local;
  final String firmId;

  @override
  Future<List<Task>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final tasks = jsonList.map(TaskMapper.fromJson).toList();
      // Write-through cache to Drift
      for (final task in tasks) {
        await local.upsert(task, firmId: effectiveFirmId);
      }
      return List.unmodifiable(tasks);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<Task?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final task = TaskMapper.fromJson(json);
      await local.upsert(task, firmId: firmId);
      return task;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<Task> create(Task task) async {
    final json = await remote.insert({
      ...TaskMapper.toJson(task),
      'firm_id': firmId,
    });
    final created = TaskMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<Task> update(Task task) async {
    final json = await remote.update(task.id, TaskMapper.toJson(task));
    final updated = TaskMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<Task>> getByClientId(String clientId) async {
    try {
      final jsonList = await remote.fetchByClientId(clientId);
      final tasks = jsonList.map(TaskMapper.fromJson).toList();
      for (final task in tasks) {
        await local.upsert(task, firmId: firmId);
      }
      return List.unmodifiable(tasks);
    } catch (_) {
      return local.getByClientId(clientId);
    }
  }

  @override
  Future<List<Task>> getByStatus(TaskStatus status, {String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchByStatus(
        status,
        firmId: effectiveFirmId,
      );
      final tasks = jsonList.map(TaskMapper.fromJson).toList();
      for (final task in tasks) {
        await local.upsert(task, firmId: effectiveFirmId);
      }
      return List.unmodifiable(tasks);
    } catch (_) {
      return local.getByStatus(status, firmId: effectiveFirmId);
    }
  }

  @override
  Future<List<Task>> search(String query, {String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.search(query, firmId: effectiveFirmId);
      return List.unmodifiable(jsonList.map(TaskMapper.fromJson).toList());
    } catch (_) {
      return local.search(query, firmId: effectiveFirmId);
    }
  }

  @override
  Stream<List<Task>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}
