import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Abstract data contract for persisting and querying submission jobs and logs.
///
/// Concrete implementations provide in-memory mocks or SQLite backends.
abstract class SubmissionRepository {
  // ---------------------------------------------------------------------------
  // Jobs
  // ---------------------------------------------------------------------------

  /// Inserts a new [job]. Throws if a job with the same [id] already exists.
  Future<void> insert(SubmissionJob job);

  /// Returns the job with [id], or `null` if not found.
  Future<SubmissionJob?> getById(String id);

  /// Returns all jobs.
  Future<List<SubmissionJob>> getAll();

  /// Returns all jobs targeting [portalType].
  Future<List<SubmissionJob>> getByPortal(PortalType portalType);

  /// Returns all jobs for [clientId].
  Future<List<SubmissionJob>> getByClient(String clientId);

  /// Returns jobs whose [SubmissionJob.currentStep] is `pending`.
  Future<List<SubmissionJob>> getPending();

  /// Replaces the stored job having the same [id] with [job].
  /// No-op if the job does not exist.
  Future<void> update(SubmissionJob job);

  // ---------------------------------------------------------------------------
  // Logs
  // ---------------------------------------------------------------------------

  /// Appends a [log] entry for its associated job.
  Future<void> insertLog(SubmissionLog log);

  /// Returns all log entries for [jobId], in chronological order.
  Future<List<SubmissionLog>> getLogs(String jobId);

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Emits the full job list whenever any job is added or updated.
  Stream<List<SubmissionJob>> watchAll();

  /// Emits the latest version of job [id] whenever it changes.
  /// Completes without emitting if the job does not exist.
  Stream<SubmissionJob> watchJob(String id);

  /// Emits new log batches for [jobId] as they are inserted.
  Stream<List<SubmissionLog>> watchLogs(String jobId);
}
