/// Status of an individual job within a filing batch.
enum JobStatus {
  /// Waiting in queue to be processed.
  queued(label: 'Queued'),

  /// Currently being processed.
  running(label: 'Running'),

  /// Completed successfully.
  success(label: 'Success'),

  /// Failed with an error.
  failed(label: 'Failed'),

  /// Failed previously, retrying.
  retrying(label: 'Retrying');

  const JobStatus({required this.label});

  final String label;
}

/// A single job within a bulk filing batch.
class BatchJob {
  const BatchJob({
    required this.jobId,
    required this.clientName,
    required this.clientId,
    required this.jobType,
    required this.status,
    required this.errorMessage,
  });

  /// Unique job identifier.
  final String jobId;

  /// Name of the client for this job.
  final String clientName;

  /// Client identifier.
  final String clientId;

  /// Type of filing (e.g., "ITR-1", "GSTR-3B").
  final String jobType;

  /// Current processing status.
  final JobStatus status;

  /// Error message if [status] is [JobStatus.failed]; null otherwise.
  final String? errorMessage;

  BatchJob copyWith({
    String? jobId,
    String? clientName,
    String? clientId,
    String? jobType,
    JobStatus? status,
    String? errorMessage,
  }) {
    return BatchJob(
      jobId: jobId ?? this.jobId,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BatchJob &&
        other.jobId == jobId &&
        other.clientName == clientName &&
        other.clientId == clientId &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(jobId, clientName, clientId, status);
}
