import 'dart:async';

import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/repositories/submission_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLite-backed [SubmissionRepository] using the `sqlite3` package directly.
///
/// This avoids Drift code generation while still persisting data to a real
/// SQLite database. Reactive streams are implemented via [StreamController]s
/// that fire whenever a mutation occurs.
class DriftSubmissionRepository implements SubmissionRepository {
  /// Creates a repository backed by the given [database].
  ///
  /// Pass [sqlite3.openInMemory()] for testing or [sqlite3.open(path)] for
  /// production use.
  DriftSubmissionRepository(this._db) {
    _createTables();
  }

  final Database _db;

  // ---------------------------------------------------------------------------
  // Stream infrastructure
  // ---------------------------------------------------------------------------

  final StreamController<List<SubmissionJob>> _allJobsController =
      StreamController<List<SubmissionJob>>.broadcast();

  final Map<String, StreamController<SubmissionJob>> _jobControllers = {};

  final Map<String, StreamController<List<SubmissionLog>>> _logControllers = {};

  // ---------------------------------------------------------------------------
  // Schema
  // ---------------------------------------------------------------------------

  void _createTables() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS submission_jobs (
        id TEXT PRIMARY KEY NOT NULL,
        client_id TEXT NOT NULL,
        client_name TEXT NOT NULL,
        portal_type TEXT NOT NULL,
        return_type TEXT NOT NULL,
        current_step TEXT NOT NULL,
        ack_number TEXT,
        filed_at TEXT,
        error_message TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        itr_json_path TEXT,
        assessment_year TEXT
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS submission_logs (
        id TEXT PRIMARY KEY NOT NULL,
        job_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        step TEXT NOT NULL,
        message TEXT NOT NULL,
        is_error INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (job_id) REFERENCES submission_jobs(id)
      )
    ''');

    _db.execute('''
      CREATE INDEX IF NOT EXISTS idx_submission_logs_job_id
        ON submission_logs(job_id)
    ''');
  }

  // ---------------------------------------------------------------------------
  // Jobs
  // ---------------------------------------------------------------------------

  @override
  Future<void> insert(SubmissionJob job) async {
    // Check for duplicates to match the contract.
    final existing = _db.select('SELECT id FROM submission_jobs WHERE id = ?', [
      job.id,
    ]);
    if (existing.isNotEmpty) {
      throw StateError('Job with id "${job.id}" already exists');
    }

    _db.execute(
      '''
      INSERT INTO submission_jobs
        (id, client_id, client_name, portal_type, return_type, current_step,
         ack_number, filed_at, error_message, retry_count, created_at,
         itr_json_path, assessment_year)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        job.id,
        job.clientId,
        job.clientName,
        job.portalType.name,
        job.returnType,
        job.currentStep.name,
        job.ackNumber,
        job.filedAt?.toIso8601String(),
        job.errorMessage,
        job.retryCount,
        job.createdAt.toIso8601String(),
        job.itrJsonPath,
        job.assessmentYear,
      ],
    );
    _notifyAllJobsChanged();
  }

  @override
  Future<SubmissionJob?> getById(String id) async {
    final rows = _db.select('SELECT * FROM submission_jobs WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    return _rowToJob(rows.first);
  }

  @override
  Future<List<SubmissionJob>> getAll() async {
    final rows = _db.select(
      'SELECT * FROM submission_jobs ORDER BY created_at',
    );
    return rows.map(_rowToJob).toList();
  }

  @override
  Future<List<SubmissionJob>> getByPortal(PortalType portalType) async {
    final rows = _db.select(
      'SELECT * FROM submission_jobs WHERE portal_type = ? ORDER BY created_at',
      [portalType.name],
    );
    return rows.map(_rowToJob).toList();
  }

  @override
  Future<List<SubmissionJob>> getByClient(String clientId) async {
    final rows = _db.select(
      'SELECT * FROM submission_jobs WHERE client_id = ? ORDER BY created_at',
      [clientId],
    );
    return rows.map(_rowToJob).toList();
  }

  @override
  Future<List<SubmissionJob>> getPending() async {
    final rows = _db.select(
      'SELECT * FROM submission_jobs WHERE current_step = ? ORDER BY created_at',
      [SubmissionStep.pending.name],
    );
    return rows.map(_rowToJob).toList();
  }

  @override
  Future<void> update(SubmissionJob job) async {
    final existing = _db.select('SELECT id FROM submission_jobs WHERE id = ?', [
      job.id,
    ]);
    if (existing.isEmpty) return; // No-op per contract.

    _db.execute(
      '''
      UPDATE submission_jobs SET
        client_id = ?,
        client_name = ?,
        portal_type = ?,
        return_type = ?,
        current_step = ?,
        ack_number = ?,
        filed_at = ?,
        error_message = ?,
        retry_count = ?,
        created_at = ?,
        itr_json_path = ?,
        assessment_year = ?
      WHERE id = ?
      ''',
      [
        job.clientId,
        job.clientName,
        job.portalType.name,
        job.returnType,
        job.currentStep.name,
        job.ackNumber,
        job.filedAt?.toIso8601String(),
        job.errorMessage,
        job.retryCount,
        job.createdAt.toIso8601String(),
        job.itrJsonPath,
        job.assessmentYear,
        job.id,
      ],
    );
    _notifyAllJobsChanged();
    _jobControllers[job.id]?.add(job);
  }

  // ---------------------------------------------------------------------------
  // Logs
  // ---------------------------------------------------------------------------

  @override
  Future<void> insertLog(SubmissionLog log) async {
    _db.execute(
      '''
      INSERT INTO submission_logs
        (id, job_id, timestamp, step, message, is_error)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [
        log.id,
        log.jobId,
        log.timestamp.toIso8601String(),
        log.step.name,
        log.message,
        log.isError ? 1 : 0,
      ],
    );
    _logControllers[log.jobId]?.add(List.unmodifiable([log]));
  }

  @override
  Future<List<SubmissionLog>> getLogs(String jobId) async {
    final rows = _db.select(
      'SELECT * FROM submission_logs WHERE job_id = ? ORDER BY timestamp',
      [jobId],
    );
    return rows.map(_rowToLog).toList();
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  @override
  Stream<List<SubmissionJob>> watchAll() {
    return Stream<List<SubmissionJob>>.multi((sink) async {
      // Emit current snapshot immediately.
      sink.add(await getAll());
      final subscription = _allJobsController.stream.listen(
        sink.add,
        onError: sink.addError,
        onDone: sink.close,
      );
      sink.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<SubmissionJob> watchJob(String id) {
    _jobControllers.putIfAbsent(
      id,
      () => StreamController<SubmissionJob>.broadcast(),
    );
    return Stream<SubmissionJob>.multi((sink) async {
      final current = await getById(id);
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

  /// Closes all stream controllers and the underlying database.
  void dispose() {
    _allJobsController.close();
    for (final c in _jobControllers.values) {
      c.close();
    }
    for (final c in _logControllers.values) {
      c.close();
    }
    _db.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _notifyAllJobsChanged() {
    // Re-query to get the authoritative list from SQLite.
    final rows = _db.select(
      'SELECT * FROM submission_jobs ORDER BY created_at',
    );
    _allJobsController.add(rows.map(_rowToJob).toList());
  }

  SubmissionJob _rowToJob(Row row) {
    return SubmissionJob(
      id: row['id'] as String,
      clientId: row['client_id'] as String,
      clientName: row['client_name'] as String,
      portalType: _parsePortalType(row['portal_type'] as String),
      returnType: row['return_type'] as String,
      currentStep: _parseSubmissionStep(row['current_step'] as String),
      ackNumber: row['ack_number'] as String?,
      filedAt: _parseDateTime(row['filed_at']),
      errorMessage: row['error_message'] as String?,
      retryCount: row['retry_count'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      itrJsonPath: row['itr_json_path'] as String?,
      assessmentYear: row['assessment_year'] as String?,
    );
  }

  SubmissionLog _rowToLog(Row row) {
    return SubmissionLog(
      id: row['id'] as String,
      jobId: row['job_id'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      step: _parseSubmissionStep(row['step'] as String),
      message: row['message'] as String,
      isError: (row['is_error'] as int) == 1,
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  static PortalType _parsePortalType(String name) {
    return PortalType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown PortalType: $name'),
    );
  }

  static SubmissionStep _parseSubmissionStep(String name) {
    return SubmissionStep.values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown SubmissionStep: $name'),
    );
  }
}
