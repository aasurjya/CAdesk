import 'dart:convert';

import 'package:ca_app/features/e_verification/domain/models/bulk_signing_job.dart';
import 'package:ca_app/features/e_verification/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';
import 'package:ca_app/features/e_verification/domain/services/dsc_signing_service.dart';
import 'package:crypto/crypto.dart';

/// Stateless service for bulk DSC signing operations.
///
/// CA firms sign 50–500 ITR-Vs per filing season.  This service
/// orchestrates batch signing, tracks progress, and supports retry of
/// failed items — all with immutable data patterns.
class BulkSigningService {
  BulkSigningService._();

  // ── Job creation ──────────────────────────────────────────────────────

  /// Creates a new [BulkSigningJob] in [BulkJobStatus.pending] state.
  static BulkSigningJob createBulkJob(List<SigningRequest> requests) {
    return BulkSigningJob(
      jobId: _generateJobId(),
      requests: List.unmodifiable(requests),
      status: BulkJobStatus.pending,
      completedCount: 0,
      failedCount: 0,
    );
  }

  // ── Processing ────────────────────────────────────────────────────────

  /// Processes every [SigningStatus.pending] request in [job] using [cert].
  ///
  /// Requests that are already [SigningStatus.signed] or
  /// [SigningStatus.cancelled] are carried over unchanged.
  ///
  /// Returns a new [BulkSigningJob] (original is never mutated).
  static BulkSigningJob processBulkJob(
    BulkSigningJob job,
    DscCertificate cert,
  ) {
    final startedAt = DateTime.now();
    final processed = job.requests.map((req) {
      if (req.status == SigningStatus.pending) {
        return DscSigningService.signDocument(req, cert);
      }
      return req;
    }).toList();

    final completedCount = processed
        .where((r) => r.status == SigningStatus.signed)
        .length;
    final failedCount = processed
        .where((r) => r.status == SigningStatus.failed)
        .length;

    final status = _resolveJobStatus(
      total: processed.length,
      completed: completedCount,
      failed: failedCount,
    );

    return job.copyWith(
      requests: List.unmodifiable(processed),
      status: status,
      completedCount: completedCount,
      failedCount: failedCount,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );
  }

  // ── Progress ──────────────────────────────────────────────────────────

  /// Returns job completion progress as a value between 0.0 and 1.0.
  ///
  /// Progress = (completedCount + failedCount) / totalCount.
  /// An empty job returns 0.0.
  static double getJobProgress(BulkSigningJob job) {
    if (job.totalCount == 0) return 0.0;
    return (job.completedCount + job.failedCount) / job.totalCount;
  }

  // ── Retry ─────────────────────────────────────────────────────────────

  /// Creates a new [BulkSigningJob] containing only the requests that
  /// previously failed, each reset to [SigningStatus.pending].
  ///
  /// Returns an empty job when there are no failed requests.
  static BulkSigningJob retryFailed(BulkSigningJob job) {
    final failedRequests = job.requests
        .where((r) => r.status == SigningStatus.failed)
        .map((r) => r.copyWith(status: SigningStatus.pending))
        .toList();

    return BulkSigningJob(
      jobId: _generateJobId(),
      requests: List.unmodifiable(failedRequests),
      status: BulkJobStatus.pending,
      completedCount: 0,
      failedCount: 0,
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────

  static BulkJobStatus _resolveJobStatus({
    required int total,
    required int completed,
    required int failed,
  }) {
    if (failed == 0 && completed == total) return BulkJobStatus.completed;
    if (completed == 0 && failed > 0) return BulkJobStatus.failed;
    if (completed > 0 && failed > 0) return BulkJobStatus.partiallyCompleted;
    // Edge: all cancelled (neither completed nor failed)
    return BulkJobStatus.completed;
  }

  static String _generateJobId() {
    final seed = 'bulk-${DateTime.now().microsecondsSinceEpoch}';
    final bytes = utf8.encode(seed);
    return 'job-${sha256.convert(bytes).toString().substring(0, 12)}';
  }
}
