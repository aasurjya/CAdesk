import 'dart:async';

import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Job and progress models
// ---------------------------------------------------------------------------

/// Type of document or data to be exported in a bulk operation.
enum BulkExportType {
  itrPdf(label: 'ITR PDF'),
  form16Pdf(label: 'Form 16 PDF'),
  gstrExcel(label: 'GSTR Excel'),
  balanceSheetPdf(label: 'Balance Sheet PDF'),
  trialBalanceCsv(label: 'Trial Balance CSV'),
  clientLedgerCsv(label: 'Client Ledger CSV');

  const BulkExportType({required this.label});

  final String label;
}

/// A single client export request within a bulk queue.
@immutable
class BulkExportJob {
  const BulkExportJob({
    required this.jobId,
    required this.clientId,
    required this.clientName,
    required this.exportType,
    this.parameters = const {},
  });

  /// Unique identifier for this individual job.
  final String jobId;

  /// ID of the client whose data is to be exported.
  final String clientId;

  /// Human-readable name of the client.
  final String clientName;

  final BulkExportType exportType;

  /// Additional parameters (e.g. financial year, date range).
  final Map<String, Object?> parameters;

  BulkExportJob copyWith({
    String? jobId,
    String? clientId,
    String? clientName,
    BulkExportType? exportType,
    Map<String, Object?>? parameters,
  }) {
    return BulkExportJob(
      jobId: jobId ?? this.jobId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      exportType: exportType ?? this.exportType,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulkExportJob &&
          runtimeType == other.runtimeType &&
          jobId == other.jobId;

  @override
  int get hashCode => jobId.hashCode;

  @override
  String toString() =>
      'BulkExportJob(jobId: $jobId, client: $clientName, '
      'type: ${exportType.label})';
}

/// Progress update emitted as each job in the queue is processed.
@immutable
class BulkExportProgress {
  const BulkExportProgress({
    required this.completedCount,
    required this.totalCount,
    required this.currentJobId,
    required this.currentClientName,
    required this.results,
  });

  /// Number of jobs completed so far (success + failure).
  final int completedCount;

  /// Total number of jobs in the queue.
  final int totalCount;

  /// ID of the job currently being processed.
  final String currentJobId;

  /// Name of the client being exported.
  final String currentClientName;

  /// Results accumulated so far (completed + failed jobs only).
  final List<BulkExportResult> results;

  /// Fraction of jobs completed, in the range [0.0, 1.0].
  double get fraction => totalCount == 0 ? 0.0 : completedCount / totalCount;

  bool get isComplete => completedCount >= totalCount;

  BulkExportProgress copyWith({
    int? completedCount,
    int? totalCount,
    String? currentJobId,
    String? currentClientName,
    List<BulkExportResult>? results,
  }) {
    return BulkExportProgress(
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      currentJobId: currentJobId ?? this.currentJobId,
      currentClientName: currentClientName ?? this.currentClientName,
      results: results ?? this.results,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulkExportProgress &&
          runtimeType == other.runtimeType &&
          completedCount == other.completedCount &&
          totalCount == other.totalCount &&
          currentJobId == other.currentJobId;

  @override
  int get hashCode => Object.hash(completedCount, totalCount, currentJobId);
}

/// Outcome of a single [BulkExportJob].
@immutable
class BulkExportResult {
  const BulkExportResult({
    required this.jobId,
    required this.clientId,
    required this.clientName,
    required this.exportType,
    required this.success,
    this.outputBytes,
    this.errorMessage,
    this.completedAt,
  });

  final String jobId;
  final String clientId;
  final String clientName;
  final BulkExportType exportType;
  final bool success;

  /// Raw bytes of the exported file; null on failure.
  final List<int>? outputBytes;

  final String? errorMessage;
  final DateTime? completedAt;

  BulkExportResult copyWith({
    String? jobId,
    String? clientId,
    String? clientName,
    BulkExportType? exportType,
    bool? success,
    List<int>? outputBytes,
    String? errorMessage,
    DateTime? completedAt,
  }) {
    return BulkExportResult(
      jobId: jobId ?? this.jobId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      exportType: exportType ?? this.exportType,
      success: success ?? this.success,
      outputBytes: outputBytes ?? this.outputBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulkExportResult &&
          runtimeType == other.runtimeType &&
          jobId == other.jobId &&
          success == other.success;

  @override
  int get hashCode => Object.hash(jobId, success);
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Service that processes a queue of export jobs sequentially, emitting
/// progress updates as a [Stream<BulkExportProgress>].
///
/// Each job is processed by [processJob], which subclasses or callers can
/// override by providing a custom [JobProcessor] function.
///
/// All intermediate progress objects are immutable — no state is mutated
/// in place.
///
/// ### Usage:
/// ```dart
/// final service = BulkExportService();
/// service.processQueue(jobs).listen((progress) {
///   print('${progress.completedCount}/${progress.totalCount}');
///   if (progress.isComplete) print('Done!');
/// });
/// ```
class BulkExportService {
  /// Creates a service with an optional custom job processor.
  ///
  /// If [jobProcessor] is null, [_defaultProcessor] is used, which simply
  /// marks every job as succeeded with empty bytes.
  BulkExportService({JobProcessor? jobProcessor})
    : _jobProcessor = jobProcessor ?? _defaultProcessor;

  final JobProcessor _jobProcessor;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Processes [jobs] sequentially and emits a [BulkExportProgress] update
  /// after each job completes.
  ///
  /// The stream completes when all jobs have been processed.
  /// It never errors — individual job failures are captured in
  /// [BulkExportResult.success] == false within the progress stream.
  Stream<BulkExportProgress> processQueue(List<BulkExportJob> jobs) {
    return _processJobsStream(List<BulkExportJob>.unmodifiable(jobs));
  }

  /// Builds a [BulkExportJob] from minimal parameters with an auto-generated
  /// unique [BulkExportJob.jobId].
  static BulkExportJob buildJob({
    required String clientId,
    required String clientName,
    required BulkExportType exportType,
    Map<String, Object?> parameters = const {},
  }) {
    final jobId =
        'export-$clientId-${exportType.name}-'
        '${DateTime.now().microsecondsSinceEpoch}';
    return BulkExportJob(
      jobId: jobId,
      clientId: clientId,
      clientName: clientName,
      exportType: exportType,
      parameters: parameters,
    );
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Stream<BulkExportProgress> _processJobsStream(
    List<BulkExportJob> jobs,
  ) async* {
    final results = <BulkExportResult>[];
    final total = jobs.length;

    for (var i = 0; i < total; i++) {
      final job = jobs[i];
      final result = await _runJob(job);
      results.add(result);

      yield BulkExportProgress(
        completedCount: i + 1,
        totalCount: total,
        currentJobId: job.jobId,
        currentClientName: job.clientName,
        results: List<BulkExportResult>.unmodifiable(results),
      );
    }
  }

  Future<BulkExportResult> _runJob(BulkExportJob job) async {
    try {
      return await _jobProcessor(job);
    } catch (e) {
      return BulkExportResult(
        jobId: job.jobId,
        clientId: job.clientId,
        clientName: job.clientName,
        exportType: job.exportType,
        success: false,
        errorMessage: 'Unexpected error: $e',
        completedAt: DateTime.now(),
      );
    }
  }

  static Future<BulkExportResult> _defaultProcessor(BulkExportJob job) async {
    // Default processor: mark as succeeded with empty bytes.
    return BulkExportResult(
      jobId: job.jobId,
      clientId: job.clientId,
      clientName: job.clientName,
      exportType: job.exportType,
      success: true,
      outputBytes: const [],
      completedAt: DateTime.now(),
    );
  }
}

/// Function type for processing a single [BulkExportJob].
typedef JobProcessor = Future<BulkExportResult> Function(BulkExportJob job);
