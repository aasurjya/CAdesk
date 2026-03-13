import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_export/data/mappers/export_job_mapper.dart';
import 'package:ca_app/features/portal_export/domain/models/export_job.dart';

class ExportJobLocalSource {
  const ExportJobLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(ExportJob job) async {
    await _db.exportJobsDao.insertJob(ExportJobMapper.toCompanion(job));
  }

  Future<List<ExportJob>> getByClient(String clientId) async {
    final rows = await _db.exportJobsDao.getByClient(clientId);
    return rows.map(ExportJobMapper.fromRow).toList();
  }

  Stream<List<ExportJob>> watchByClient(String clientId) {
    return _db.exportJobsDao
        .watchByClient(clientId)
        .map((rows) => rows.map(ExportJobMapper.fromRow).toList());
  }

  Future<List<ExportJob>> getByStatus(ExportJobStatus status) async {
    final rows = await _db.exportJobsDao.getByStatus(status.name);
    return rows.map(ExportJobMapper.fromRow).toList();
  }

  Future<bool> updateStatus(
    String id,
    ExportJobStatus status, {
    String? filePath,
    String? errorMessage,
    DateTime? completedAt,
  }) =>
      _db.exportJobsDao.updateStatus(
        id,
        status.name,
        filePath: filePath,
        errorMessage: errorMessage,
        completedAt: completedAt,
      );

  Future<int> deleteOldJobs(DateTime beforeDate) =>
      _db.exportJobsDao.deleteOldJobs(beforeDate);

  Future<ExportJob?> getById(String id) async {
    final row = await _db.exportJobsDao.getById(id);
    return row != null ? ExportJobMapper.fromRow(row) : null;
  }

  Future<void> upsert(ExportJob job) async {
    await _db.exportJobsDao.upsert(ExportJobMapper.toCompanion(job));
  }
}
