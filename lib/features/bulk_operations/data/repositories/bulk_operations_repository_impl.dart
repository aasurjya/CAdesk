import 'package:ca_app/features/bulk_operations/data/datasources/bulk_operations_local_source.dart';
import 'package:ca_app/features/bulk_operations/data/datasources/bulk_operations_remote_source.dart';
import 'package:ca_app/features/bulk_operations/data/mappers/bulk_operations_mapper.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/repositories/bulk_operations_repository.dart';

/// Real implementation of [BulkOperationsRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// on any network error.
class BulkOperationsRepositoryImpl implements BulkOperationsRepository {
  const BulkOperationsRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final BulkOperationsRemoteSource remote;
  final BulkOperationsLocalSource local;

  @override
  Future<List<BatchJob>> getAllJobs() async {
    try {
      final jsonList = await remote.fetchAll();
      final jobs = jsonList.map(BulkOperationsMapper.fromJson).toList();
      for (final j in jobs) {
        await local.insertJob(j);
      }
      return List.unmodifiable(jobs);
    } catch (_) {
      return local.getAll();
    }
  }

  @override
  Future<BatchJob?> getJobById(String jobId) async {
    try {
      final json = await remote.fetchById(jobId);
      if (json == null) return null;
      final job = BulkOperationsMapper.fromJson(json);
      await local.insertJob(job);
      return job;
    } catch (_) {
      return local.getById(jobId);
    }
  }

  @override
  Future<List<BatchJob>> getJobsByStatus(JobStatus status) async {
    try {
      final jsonList = await remote.fetchByStatus(status.name);
      final jobs = jsonList.map(BulkOperationsMapper.fromJson).toList();
      for (final j in jobs) {
        await local.insertJob(j);
      }
      return List.unmodifiable(jobs);
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<String> insertJob(BatchJob job) async {
    try {
      final json = await remote.insert(BulkOperationsMapper.toJson(job));
      final inserted = BulkOperationsMapper.fromJson(json);
      await local.insertJob(inserted);
      return inserted.jobId;
    } catch (_) {
      return local.insertJob(job);
    }
  }

  @override
  Future<bool> updateJob(BatchJob job) async {
    try {
      final json = await remote.update(
        job.jobId,
        BulkOperationsMapper.toJson(job),
      );
      final updated = BulkOperationsMapper.fromJson(json);
      await local.updateJob(updated);
      return true;
    } catch (_) {
      return local.updateJob(job);
    }
  }

  @override
  Future<bool> deleteJob(String jobId) async {
    try {
      await remote.delete(jobId);
      await local.deleteJob(jobId);
      return true;
    } catch (_) {
      return local.deleteJob(jobId);
    }
  }
}
