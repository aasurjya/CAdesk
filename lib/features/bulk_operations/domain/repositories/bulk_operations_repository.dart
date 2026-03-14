import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';

/// Abstract contract for bulk operations data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class BulkOperationsRepository {
  /// Retrieve all batch jobs.
  Future<List<BatchJob>> getAllJobs();

  /// Retrieve a single [BatchJob] by [jobId]. Returns null if not found.
  Future<BatchJob?> getJobById(String jobId);

  /// Retrieve all batch jobs with a specific [status].
  Future<List<BatchJob>> getJobsByStatus(JobStatus status);

  /// Insert a new [BatchJob] and return its ID.
  Future<String> insertJob(BatchJob job);

  /// Update an existing [BatchJob]. Returns true on success.
  Future<bool> updateJob(BatchJob job);

  /// Delete the batch job identified by [jobId]. Returns true on success.
  Future<bool> deleteJob(String jobId);
}
