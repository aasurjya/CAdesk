import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';

/// Immutable log entry recording a single event during a submission job.
///
/// Services emit [SubmissionLog] entries via `Stream<SubmissionLog>` so the
/// UI can display live progress as the automation runs.
class SubmissionLog {
  const SubmissionLog({
    required this.id,
    required this.jobId,
    required this.timestamp,
    required this.step,
    required this.message,
    this.isError = false,
  });

  /// Unique log entry identifier.
  final String id;

  /// The [SubmissionJob.id] this entry belongs to.
  final String jobId;

  /// When this event occurred.
  final DateTime timestamp;

  /// The automation step active when this event was logged.
  final SubmissionStep step;

  /// Human-readable description of the event.
  final String message;

  /// Whether this entry represents an error condition.
  final bool isError;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  SubmissionLog copyWith({
    String? id,
    String? jobId,
    DateTime? timestamp,
    SubmissionStep? step,
    String? message,
    bool? isError,
  }) {
    return SubmissionLog(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      timestamp: timestamp ?? this.timestamp,
      step: step ?? this.step,
      message: message ?? this.message,
      isError: isError ?? this.isError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SubmissionLog(id: $id, jobId: $jobId, '
      'step: ${step.name}, isError: $isError, message: $message)';
}
