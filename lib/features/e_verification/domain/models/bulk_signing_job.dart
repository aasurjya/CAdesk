import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';

/// Lifecycle status of a bulk signing job.
enum BulkJobStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  partiallyCompleted('Partially Completed'),
  failed('Failed');

  const BulkJobStatus(this.label);

  final String label;
}

/// Immutable model representing a batch signing operation.
///
/// CA firms sign 50–500 ITR-Vs per filing season.  A [BulkSigningJob]
/// tracks the entire batch lifecycle: progress, failures, and timestamps
/// for the audit trail.
class BulkSigningJob {
  const BulkSigningJob({
    required this.jobId,
    required this.requests,
    required this.status,
    required this.completedCount,
    required this.failedCount,
    this.startedAt,
    this.completedAt,
  });

  /// Unique identifier for this bulk job.
  final String jobId;

  /// Ordered list of signing requests in this batch.
  final List<SigningRequest> requests;

  final BulkJobStatus status;

  /// Number of requests that have been successfully signed.
  final int completedCount;

  /// Number of requests that failed signing.
  final int failedCount;

  /// When processing began. Null if not yet started.
  final DateTime? startedAt;

  /// When the entire batch finished (success or failure). Null if ongoing.
  final DateTime? completedAt;

  // ── Computed properties ───────────────────────────────────────────────

  /// Total number of requests in this batch.
  int get totalCount => requests.length;

  // ── copyWith ──────────────────────────────────────────────────────────

  BulkSigningJob copyWith({
    String? jobId,
    List<SigningRequest>? requests,
    BulkJobStatus? status,
    int? completedCount,
    int? failedCount,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return BulkSigningJob(
      jobId: jobId ?? this.jobId,
      requests: requests ?? this.requests,
      status: status ?? this.status,
      completedCount: completedCount ?? this.completedCount,
      failedCount: failedCount ?? this.failedCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // ── Equality ─────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BulkSigningJob && other.jobId == jobId;
  }

  @override
  int get hashCode => jobId.hashCode;
}
