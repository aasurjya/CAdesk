import 'package:ca_app/features/rpa/data/datasources/rpa_local_source.dart';
import 'package:ca_app/features/rpa/data/datasources/rpa_remote_source.dart';
import 'package:ca_app/features/rpa/data/mappers/rpa_mapper.dart';
import 'package:ca_app/features/rpa/domain/models/rpa_task.dart';
import 'package:ca_app/features/rpa/domain/repositories/rpa_repository.dart';

class RpaRepositoryImpl implements RpaRepository {
  const RpaRepositoryImpl({required this.remote, required this.local});

  final RpaRemoteSource remote;
  final RpaLocalSource local;

  @override
  Future<void> insert(RpaTask task) async {
    try {
      await remote.insert(RpaMapper.toJson(task));
    } catch (_) {
      // No-op — fall through to local write
    }
    await local.insert(task);
  }

  @override
  Future<List<RpaTask>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final tasks = jsonList.map(RpaMapper.fromJson).toList();
      for (final task in tasks) {
        await local.insert(task);
      }
      return List.unmodifiable(tasks);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<RpaTask>> getByStatus(RpaStatus status) async {
    try {
      final jsonList = await remote.fetchByStatus(status.name);
      final tasks = jsonList.map(RpaMapper.fromJson).toList();
      return List.unmodifiable(tasks);
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<List<RpaTask>> getByType(RpaTaskType taskType) async {
    try {
      final jsonList = await remote.fetchByType(taskType.name);
      final tasks = jsonList.map(RpaMapper.fromJson).toList();
      return List.unmodifiable(tasks);
    } catch (_) {
      return local.getByType(taskType);
    }
  }

  @override
  Future<bool> updateStatus(
    String id,
    RpaStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    int? retryCount,
  }) async {
    try {
      await remote.updateStatus(
        id,
        status.name,
        startedAt: startedAt,
        completedAt: completedAt,
        result: result,
        errorMessage: errorMessage,
        retryCount: retryCount,
      );
    } catch (_) {
      // No-op — always update local
    }
    return local.updateStatus(
      id,
      status,
      startedAt: startedAt,
      completedAt: completedAt,
      result: result,
      errorMessage: errorMessage,
      retryCount: retryCount,
    );
  }

  @override
  Future<List<RpaTask>> getScheduled(DateTime beforeTime) =>
      local.getScheduled(beforeTime);

  @override
  Future<List<RpaTask>> getPending() => local.getPending();

  @override
  Future<bool> cancel(String taskId) async {
    try {
      await remote.updateStatus(taskId, RpaStatus.cancelled.name);
    } catch (_) {
      // No-op — always cancel locally
    }
    return local.cancel(taskId);
  }
}
