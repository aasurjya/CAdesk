import 'dart:async';

import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/repositories/submission_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// In-memory [SubmissionRepository] for testing and offline development.
class MockSubmissionRepository implements SubmissionRepository {
  final Map<String, SubmissionJob> _jobs = {};
  final Map<String, List<SubmissionLog>> _logs = {};

  final StreamController<List<SubmissionJob>> _jobsController =
      StreamController<List<SubmissionJob>>.broadcast();

  final Map<String, StreamController<SubmissionJob>> _jobControllers = {};
  final Map<String, StreamController<List<SubmissionLog>>> _logControllers = {};

  // ---------------------------------------------------------------------------
  // Jobs
  // ---------------------------------------------------------------------------

  @override
  Future<void> insert(SubmissionJob job) async {
    if (_jobs.containsKey(job.id)) {
      throw StateError('Job with id "${job.id}" already exists');
    }
    _jobs[job.id] = job;
    _logs[job.id] = [];
    _notifyJobsChanged();
  }

  @override
  Future<SubmissionJob?> getById(String id) async => _jobs[id];

  @override
  Future<List<SubmissionJob>> getAll() async =>
      List.unmodifiable(_jobs.values.toList());

  @override
  Future<List<SubmissionJob>> getByPortal(PortalType portalType) async =>
      List.unmodifiable(
        _jobs.values.where((j) => j.portalType == portalType).toList(),
      );

  @override
  Future<List<SubmissionJob>> getByClient(String clientId) async =>
      List.unmodifiable(
        _jobs.values.where((j) => j.clientId == clientId).toList(),
      );

  @override
  Future<List<SubmissionJob>> getPending() async => List.unmodifiable(
    _jobs.values.where((j) => j.currentStep.name == 'pending').toList(),
  );

  @override
  Future<void> update(SubmissionJob job) async {
    if (!_jobs.containsKey(job.id)) return;
    _jobs[job.id] = job;
    _notifyJobsChanged();
    _jobControllers[job.id]?.add(job);
  }

  // ---------------------------------------------------------------------------
  // Logs
  // ---------------------------------------------------------------------------

  @override
  Future<void> insertLog(SubmissionLog log) async {
    final bucket = _logs.putIfAbsent(log.jobId, () => []);
    bucket.add(log);
    // Emit to any active watchLogs stream for this job.
    _logControllers[log.jobId]?.add(List.unmodifiable([log]));
  }

  @override
  Future<List<SubmissionLog>> getLogs(String jobId) async =>
      List.unmodifiable(_logs[jobId] ?? []);

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  @override
  Stream<List<SubmissionJob>> watchAll() {
    // Emit current snapshot immediately, then forward all future updates.
    return Stream<List<SubmissionJob>>.multi((sink) {
      sink.add(List.unmodifiable(_jobs.values.toList()));
      final subscription = _jobsController.stream.listen(
        sink.add,
        onError: sink.addError,
        onDone: sink.close,
      );
      sink.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<SubmissionJob> watchJob(String id) {
    // Ensure the per-job controller exists before returning the stream.
    _jobControllers.putIfAbsent(
      id,
      () => StreamController<SubmissionJob>.broadcast(),
    );
    // Return a stream that immediately emits the current value (if any)
    // then forwards all future updates from the controller.
    return Stream<SubmissionJob>.multi((sink) {
      final current = _jobs[id];
      if (current != null) sink.add(current);
      final subscription = _jobControllers[id]!.stream.listen(
        sink.add,
        onError: sink.addError,
        onDone: sink.close,
      );
      sink.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<List<SubmissionLog>> watchLogs(String jobId) {
    final controller = _logControllers.putIfAbsent(
      jobId,
      () => StreamController<List<SubmissionLog>>.broadcast(),
    );
    return controller.stream;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Closes all stream controllers. Call in [tearDown] during tests.
  void dispose() {
    _jobsController.close();
    for (final c in _jobControllers.values) {
      c.close();
    }
    for (final c in _logControllers.values) {
      c.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _notifyJobsChanged() {
    _jobsController.add(List.unmodifiable(_jobs.values.toList()));
  }
}
