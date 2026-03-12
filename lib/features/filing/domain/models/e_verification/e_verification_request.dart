import 'package:ca_app/features/filing/domain/models/post_filing/filing_acknowledgement.dart';

/// Status of an e-verification request.
enum EVerificationStatus {
  notStarted('Not Started'),
  otpSent('OTP Sent'),
  otpVerified('OTP Verified'),
  completed('Completed'),
  failed('Failed'),
  expired('Expired');

  const EVerificationStatus(this.label);
  final String label;
}

/// Immutable model representing an e-verification request
/// submitted to the Income Tax Department portal.
class EVerificationRequest {
  const EVerificationRequest({
    required this.pan,
    required this.acknowledgementNumber,
    required this.method,
    required this.status,
    required this.requestedAt,
    this.otpReferenceNumber,
    this.completedAt,
  });

  final String pan;
  final String acknowledgementNumber;
  final VerificationMethod method;
  final String? otpReferenceNumber;
  final EVerificationStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;

  EVerificationRequest copyWith({
    String? pan,
    String? acknowledgementNumber,
    VerificationMethod? method,
    String? otpReferenceNumber,
    EVerificationStatus? status,
    DateTime? requestedAt,
    DateTime? completedAt,
  }) {
    return EVerificationRequest(
      pan: pan ?? this.pan,
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
      method: method ?? this.method,
      otpReferenceNumber: otpReferenceNumber ?? this.otpReferenceNumber,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EVerificationRequest &&
        other.pan == pan &&
        other.acknowledgementNumber == acknowledgementNumber &&
        other.method == method &&
        other.otpReferenceNumber == otpReferenceNumber &&
        other.status == status &&
        other.requestedAt == requestedAt &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode => Object.hash(
    pan,
    acknowledgementNumber,
    method,
    otpReferenceNumber,
    status,
    requestedAt,
    completedAt,
  );
}
