import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';

/// Local data source for batch jobs.
///
/// Uses an in-memory cache as a fallback when Supabase is unavailable.
class BulkOperationsLocalSource {
  BulkOperationsLocalSource();

  final List<BatchJob> _cache = [];

  /// Insert or replace a [BatchJob] in the local cache.
  Future<String> insertJob(BatchJob job) async {
    final idx = _cache.indexWhere((j) => j.jobId == job.jobId);
    if (idx >= 0) {
      final updated = List<BatchJob>.of(_cache)..[idx] = job;
      _cache
        ..clear()
        ..addAll(updated);
    } else {
      _cache.add(job);
    }
    return job.jobId;
  }

  /// Retrieve all cached batch jobs.
  Future<List<BatchJob>> getAll() async {
    return List.unmodifiable(_cache);
  }

  /// Retrieve a cached batch job by [jobId].
  Future<BatchJob?> getById(String jobId) async {
    try {
      return _cache.firstWhere((j) => j.jobId == jobId);
    } catch (_) {
      return null;
    }
  }

  /// Retrieve cached jobs with a given [status].
  Future<List<BatchJob>> getByStatus(JobStatus status) async {
    return List.unmodifiable(_cache.where((j) => j.status == status).toList());
  }

  /// Update a cached [BatchJob].
  Future<bool> updateJob(BatchJob job) async {
    final idx = _cache.indexWhere((j) => j.jobId == job.jobId);
    if (idx == -1) return false;
    final updated = List<BatchJob>.of(_cache)..[idx] = job;
    _cache
      ..clear()
      ..addAll(updated);
    return true;
  }

  /// Delete a cached batch job by [jobId].
  Future<bool> deleteJob(String jobId) async {
    final before = _cache.length;
    _cache.removeWhere((j) => j.jobId == jobId);
    return _cache.length < before;
  }
}
