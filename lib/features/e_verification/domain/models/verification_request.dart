import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';

/// Immutable model representing a single ITR e-verification request.
///
/// After ITR filing, returns must be verified within 30 days via EVC,
/// Aadhaar OTP, or DSC. This model tracks each pending/completed
/// verification.
class VerificationRequest {
  const VerificationRequest({
    required this.id,
    required this.clientName,
    required this.pan,
    required this.itrType,
    required this.assessmentYear,
    required this.filingDate,
    required this.deadlineDate,
    required this.status,
    this.acknowledgementNumber,
  });

  final String id;
  final String clientName;
  final String pan;

  /// ITR form type, e.g. 'ITR-1', 'ITR-4'.
  final String itrType;

  /// Assessment year, e.g. '2025-26'.
  final String assessmentYear;

  /// Date the ITR was filed.
  final DateTime filingDate;

  /// Verification deadline (filing date + 30 days).
  final DateTime deadlineDate;

  final VerificationStatus status;

  /// Acknowledgement number issued after successful verification.
  final String? acknowledgementNumber;

  /// Days remaining until the verification deadline.
  int get daysRemaining {
    final now = DateTime.now();
    return deadlineDate.difference(now).inDays;
  }

  /// Whether this request is expiring within 7 days.
  bool get isExpiringSoon => !status.isVerified && daysRemaining <= 7;

  VerificationRequest copyWith({
    String? id,
    String? clientName,
    String? pan,
    String? itrType,
    String? assessmentYear,
    DateTime? filingDate,
    DateTime? deadlineDate,
    VerificationStatus? status,
    String? acknowledgementNumber,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      itrType: itrType ?? this.itrType,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      filingDate: filingDate ?? this.filingDate,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      status: status ?? this.status,
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationRequest &&
        other.id == id &&
        other.clientName == clientName &&
        other.pan == pan &&
        other.itrType == itrType &&
        other.assessmentYear == assessmentYear &&
        other.filingDate == filingDate &&
        other.deadlineDate == deadlineDate &&
        other.status == status &&
        other.acknowledgementNumber == acknowledgementNumber;
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientName,
    pan,
    itrType,
    assessmentYear,
    filingDate,
    deadlineDate,
    status,
    acknowledgementNumber,
  );
}
