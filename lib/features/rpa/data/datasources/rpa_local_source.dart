import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/rpa/data/mappers/rpa_mapper.dart';
import 'package:ca_app/features/rpa/domain/models/rpa_task.dart';

class RpaLocalSource {
  const RpaLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(RpaTask task) =>
      _db.rpaDao.insert(RpaMapper.toCompanion(task));

  Future<List<RpaTask>> getByClient(String clientId) async {
    final rows = await _db.rpaDao.getByClient(clientId);
    return rows.map(RpaMapper.fromRow).toList();
  }

  Future<List<RpaTask>> getByStatus(RpaStatus status) async {
    final rows = await _db.rpaDao.getByStatus(status.name);
    return rows.map(RpaMapper.fromRow).toList();
  }

  Future<List<RpaTask>> getByType(RpaTaskType taskType) async {
    final rows = await _db.rpaDao.getByType(taskType.name);
    return rows.map(RpaMapper.fromRow).toList();
  }

  Future<bool> updateStatus(
    String id,
    RpaStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    int? retryCount,
  }) =>
      _db.rpaDao.updateStatus(
        id,
        status.name,
        startedAt: startedAt,
        completedAt: completedAt,
        result: result,
        errorMessage: errorMessage,
        retryCount: retryCount,
      );

  Future<List<RpaTask>> getScheduled(DateTime beforeTime) async {
    final rows = await _db.rpaDao.getScheduled(beforeTime);
    return rows.map(RpaMapper.fromRow).toList();
  }

  Future<List<RpaTask>> getPending() async {
    final rows = await _db.rpaDao.getPending();
    return rows.map(RpaMapper.fromRow).toList();
  }

  Future<bool> cancel(String taskId) => _db.rpaDao.cancel(taskId);
}
