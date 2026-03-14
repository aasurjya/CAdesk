import 'package:ca_app/features/portal_export/data/datasources/export_job_local_source.dart';
import 'package:ca_app/features/portal_export/data/datasources/export_job_remote_source.dart';
import 'package:ca_app/features/portal_export/data/mappers/export_job_mapper.dart';
import 'package:ca_app/features/portal_export/domain/models/export_job.dart';
import 'package:ca_app/features/portal_export/domain/repositories/export_job_repository.dart';

class ExportJobRepositoryImpl implements ExportJobRepository {
  const ExportJobRepositoryImpl({required this.remote, required this.local});

  final ExportJobRemoteSource remote;
  final ExportJobLocalSource local;

  @override
  Future<void> insert(ExportJob job) async {
    try {
      final json = await remote.insert(ExportJobMapper.toJson(job));
      final created = ExportJobMapper.fromJson(json);
      await local.upsert(created);
    } catch (_) {
      await local.insert(job);
    }
  }

  @override
  Future<List<ExportJob>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final jobs = jsonList.map(ExportJobMapper.fromJson).toList();
      for (final j in jobs) {
        await local.upsert(j);
      }
      return List.unmodifiable(jobs);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<ExportJob>> getByStatus(ExportJobStatus status) async {
    try {
      final jsonList = await remote.fetchByStatus(status.name);
      return List.unmodifiable(jsonList.map(ExportJobMapper.fromJson).toList());
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<bool> updateStatus(
    String id,
    ExportJobStatus status, {
    String? filePath,
    String? errorMessage,
    DateTime? completedAt,
  }) async {
    try {
      await remote.updateStatus(
        id,
        status.name,
        filePath: filePath,
        errorMessage: errorMessage,
        completedAt: completedAt?.toIso8601String(),
      );
      return local.updateStatus(
        id,
        status,
        filePath: filePath,
        errorMessage: errorMessage,
        completedAt: completedAt,
      );
    } catch (_) {
      return local.updateStatus(
        id,
        status,
        filePath: filePath,
        errorMessage: errorMessage,
        completedAt: completedAt,
      );
    }
  }

  @override
  Future<int> deleteOldJobs(DateTime beforeDate) async {
    try {
      await remote.deleteOldJobs(beforeDate);
    } catch (_) {
      // remote deletion is best-effort
    }
    return local.deleteOldJobs(beforeDate);
  }

  @override
  Future<ExportJob?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final job = ExportJobMapper.fromJson(json);
      await local.upsert(job);
      return job;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Stream<List<ExportJob>> watchByClient(String clientId) =>
      local.watchByClient(clientId);
}
