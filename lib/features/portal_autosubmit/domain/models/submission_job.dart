import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Immutable model representing a single portal auto-submission task.
///
/// Each job tracks a client's return filing for one portal — from initial
/// queuing through login, form-fill, OTP, submission, and ack download.
class SubmissionJob {
  const SubmissionJob({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.portalType,
    required this.returnType,
    required this.currentStep,
    required this.retryCount,
    required this.createdAt,
    this.ackNumber,
    this.filedAt,
    this.errorMessage,
  });

  /// Unique job identifier (UUID).
  final String id;

  /// Owning client's identifier.
  final String clientId;

  /// Owning client's display name (denormalised for list views).
  final String clientName;

  /// Target government portal.
  final PortalType portalType;

  /// Return type being filed (e.g. 'ITR-1', 'GSTR-1', '26Q', 'MGT-7', 'ECR').
  final String returnType;

  /// Current automation stage.
  final SubmissionStep currentStep;

  /// Acknowledgement number received after successful submission.
  final String? ackNumber;

  /// Timestamp when the return was successfully filed.
  final DateTime? filedAt;

  /// Error description when [currentStep] is [SubmissionStep.failed].
  final String? errorMessage;

  /// Number of times this job has been retried after failure.
  final int retryCount;

  /// When this job was enqueued.
  final DateTime createdAt;

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  /// True when the job has successfully completed.
  bool get isCompleted => currentStep == SubmissionStep.done;

  /// True when the job has permanently or temporarily failed.
  bool get isFailed => currentStep == SubmissionStep.failed;

  /// True when the job is actively running (not queued, done, or failed).
  bool get isInProgress => const {
    SubmissionStep.loggingIn,
    SubmissionStep.filling,
    SubmissionStep.otp,
    SubmissionStep.submitting,
    SubmissionStep.downloading,
  }.contains(currentStep);

  /// True when the job has failed but can be retried (max 3 attempts).
  bool get canRetry => isFailed && retryCount < 3;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  SubmissionJob copyWith({
    String? id,
    String? clientId,
    String? clientName,
    PortalType? portalType,
    String? returnType,
    SubmissionStep? currentStep,
    String? ackNumber,
    DateTime? filedAt,
    String? errorMessage,
    int? retryCount,
    DateTime? createdAt,
  }) {
    return SubmissionJob(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      portalType: portalType ?? this.portalType,
      returnType: returnType ?? this.returnType,
      currentStep: currentStep ?? this.currentStep,
      ackNumber: ackNumber ?? this.ackNumber,
      filedAt: filedAt ?? this.filedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality — identity is based on [id] alone.
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionJob &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SubmissionJob(id: $id, client: $clientName, '
      'portal: ${portalType.name}, return: $returnType, '
      'step: ${currentStep.name})';
}
