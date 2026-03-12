import 'dart:convert';

import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';

/// Minimal client data required to build an export job item.
class ClientData {
  const ClientData({
    required this.clientId,
    required this.clientName,
    required this.pan,
  });

  final String clientId;
  final String clientName;

  /// PAN or GSTIN identifier.
  final String pan;
}

/// Summary produced after a bulk export job completes.
class ExportManifest {
  const ExportManifest({
    required this.jobId,
    required this.completedAt,
    required this.successCount,
    required this.failedCount,
    required this.fileNames,
  });

  final String jobId;
  final DateTime completedAt;
  final int successCount;
  final int failedCount;
  final List<String> fileNames;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExportManifest && other.jobId == jobId;
  }

  @override
  int get hashCode => jobId.hashCode;

  @override
  String toString() =>
      'ExportManifest(jobId: $jobId, success: $successCount, failed: $failedCount)';
}

/// Stateless engine for creating and processing bulk export jobs.
///
/// All methods return new objects — no internal state is mutated.
class BulkExportEngine {
  BulkExportEngine._();

  static final BulkExportEngine instance = BulkExportEngine._();

  /// Public factory that allows tests to create independent instances.
  factory BulkExportEngine() => BulkExportEngine._();

  /// Processing time assumed per export item (for estimation).
  static const int _secondsPerItem = 2;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Creates a [BatchJob] for exporting [clients] in the specified [exportType]
  /// (e.g. "PDF", "CSV", "EXCEL").
  ///
  /// The job starts with [JobStatus.queued] and all items in
  /// [BatchJobItemStatus.pending].
  BatchJob createExportJob(List<ClientData> clients, String exportType) {
    final jobId = 'export-${DateTime.now().millisecondsSinceEpoch}';
    final items = clients
        .map((c) => _buildExportItem(c, exportType, jobId))
        .toList();

    return BatchJob(
      jobId: jobId,
      name: 'Bulk Export — $exportType',
      jobType: JobType.bulkExport,
      priority: JobPriority.normal,
      items: items,
      status: JobStatus.queued,
      completedItems: 0,
      failedItems: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Processes a single export [item] and returns an updated copy.
  ///
  /// In production this would perform the actual document generation.
  /// Here it marks the item [BatchJobItemStatus.completed] with the current
  /// timestamp — the caller is responsible for error handling.
  BatchJobItem processExportItem(BatchJobItem item, String exportType) {
    return item.copyWith(
      status: BatchJobItemStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// Estimates how long [job] will take to complete.
  ///
  /// Assumes [_secondsPerItem] seconds per item regardless of export format.
  Duration estimateCompletionTime(BatchJob job) {
    return Duration(seconds: job.totalItems * _secondsPerItem);
  }

  /// Generates an [ExportManifest] summarising a completed [BatchJob].
  ///
  /// [completedJob] should have status [JobStatus.completed].
  ExportManifest generateExportManifest(BatchJob completedJob) {
    final successCount = completedJob.items
        .where((i) => i.status == BatchJobItemStatus.completed)
        .length;
    final failedCount = completedJob.items
        .where((i) => i.status == BatchJobItemStatus.failed)
        .length;

    final fileNames = completedJob.items
        .where((i) => i.status == BatchJobItemStatus.completed)
        .map((i) => '${completedJob.jobId}_${i.itemId}.pdf')
        .toList();

    return ExportManifest(
      jobId: completedJob.jobId,
      completedAt: completedJob.completedAt ?? DateTime.now(),
      successCount: successCount,
      failedCount: failedCount,
      fileNames: fileNames,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  BatchJobItem _buildExportItem(
    ClientData client,
    String exportType,
    String jobId,
  ) {
    final payload = jsonEncode({
      'clientId': client.clientId,
      'clientName': client.clientName,
      'pan': client.pan,
      'exportType': exportType,
    });

    return BatchJobItem(
      itemId: '${jobId}_${client.clientId}',
      clientName: client.clientName,
      pan: client.pan,
      payload: payload,
      status: BatchJobItemStatus.pending,
      attempts: 0,
    );
  }
}
