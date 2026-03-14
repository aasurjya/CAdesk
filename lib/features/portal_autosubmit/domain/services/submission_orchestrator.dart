import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/repositories/submission_repository.dart';

/// Coordinates job lifecycle management for the portal auto-submit engine.
///
/// The orchestrator owns all state transitions and log persistence.  Portal
/// services (ITD, GSTN, TRACES, MCA, EPFO) call back into the orchestrator
/// via [updateStep], [markFailed], and [markDone] — they never write to the
/// repository directly.
class SubmissionOrchestrator {
  SubmissionOrchestrator({required SubmissionRepository repository})
    : _repo = repository;

  final SubmissionRepository _repo;

  // ---------------------------------------------------------------------------
  // Job management
  // ---------------------------------------------------------------------------

  /// Enqueues a new [job], persisting it to the repository.
  Future<SubmissionJob> enqueue(SubmissionJob job) async {
    await _repo.insert(job);
    return job;
  }

  /// Returns the current state of job [id], or `null` if unknown.
  Future<SubmissionJob?> getJob(String id) => _repo.getById(id);

  /// Returns all jobs whose step is [SubmissionStep.pending].
  Future<List<SubmissionJob>> getPending() => _repo.getPending();

  // ---------------------------------------------------------------------------
  // Step transitions
  // ---------------------------------------------------------------------------

  /// Advances job [id] to [step], optionally appending a [message] to its log.
  ///
  /// No-op if [id] does not exist.
  Future<void> updateStep(
    String id,
    SubmissionStep step, {
    String? message,
  }) async {
    final job = await _repo.getById(id);
    if (job == null) return;

    await _repo.update(job.copyWith(currentStep: step));

    if (message != null) {
      await _appendLog(jobId: id, step: step, message: message);
    }
  }

  /// Marks job [id] as failed with an [errorMessage], incrementing retry count.
  ///
  /// No-op if [id] does not exist.
  Future<void> markFailed(String id, String errorMessage) async {
    final job = await _repo.getById(id);
    if (job == null) return;

    await _repo.update(
      job.copyWith(
        currentStep: SubmissionStep.failed,
        errorMessage: errorMessage,
        retryCount: job.retryCount + 1,
      ),
    );
    await _appendLog(
      jobId: id,
      step: SubmissionStep.failed,
      message: errorMessage,
      isError: true,
    );
  }

  /// Marks job [id] as successfully completed.
  ///
  /// No-op if [id] does not exist.
  Future<void> markDone(
    String id, {
    required String ackNumber,
    required DateTime filedAt,
  }) async {
    final job = await _repo.getById(id);
    if (job == null) return;

    await _repo.update(
      job.copyWith(
        currentStep: SubmissionStep.done,
        ackNumber: ackNumber,
        filedAt: filedAt,
      ),
    );
    await _appendLog(
      jobId: id,
      step: SubmissionStep.done,
      message: 'Filed successfully. Ack: $ackNumber',
    );
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Returns all log entries for job [id] in chronological order.
  Future<List<SubmissionLog>> getLogs(String id) => _repo.getLogs(id);

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Emits the latest state of job [id] on every change.
  Stream<SubmissionJob> watchJob(String id) => _repo.watchJob(id);

  /// Emits new log batches for job [id] as they arrive.
  Stream<List<SubmissionLog>> watchLogs(String id) => _repo.watchLogs(id);

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _appendLog({
    required String jobId,
    required SubmissionStep step,
    required String message,
    bool isError = false,
  }) async {
    final log = SubmissionLog(
      id: '${jobId}_${step.name}_${DateTime.now().microsecondsSinceEpoch}',
      jobId: jobId,
      timestamp: DateTime.now(),
      step: step,
      message: message,
      isError: isError,
    );
    await _repo.insertLog(log);
  }
}
