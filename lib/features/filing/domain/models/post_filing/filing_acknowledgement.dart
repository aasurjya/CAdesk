/// E-verification status of a filed return.
enum VerificationStatus {
  pending('Pending'),
  verified('Verified'),
  failed('Failed');

  const VerificationStatus(this.label);
  final String label;
}

/// Method used for e-verification of the return.
enum VerificationMethod {
  aadhaarOtp('Aadhaar OTP'),
  dsc('Digital Signature (DSC)'),
  evc('Electronic Verification Code (EVC)'),
  sendToCtoCpc('Send ITR-V to CPC by post'),
  none('Not yet selected');

  const VerificationMethod(this.label);
  final String label;
}

/// Immutable model representing an ITR filing acknowledgement
/// issued by the Income Tax Department after successful submission.
class FilingAcknowledgement {
  const FilingAcknowledgement({
    required this.acknowledgementNumber,
    required this.filingDate,
    required this.itrType,
    required this.assessmentYear,
    required this.verificationStatus,
    required this.verificationMethod,
    this.verificationDate,
    this.itrVFormUrl,
  });

  final String acknowledgementNumber;
  final DateTime filingDate;
  final String itrType;
  final String assessmentYear;
  final VerificationStatus verificationStatus;
  final VerificationMethod verificationMethod;
  final DateTime? verificationDate;
  final String? itrVFormUrl;

  FilingAcknowledgement copyWith({
    String? acknowledgementNumber,
    DateTime? filingDate,
    String? itrType,
    String? assessmentYear,
    VerificationStatus? verificationStatus,
    VerificationMethod? verificationMethod,
    DateTime? verificationDate,
    String? itrVFormUrl,
  }) {
    return FilingAcknowledgement(
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
      filingDate: filingDate ?? this.filingDate,
      itrType: itrType ?? this.itrType,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      verificationDate: verificationDate ?? this.verificationDate,
      itrVFormUrl: itrVFormUrl ?? this.itrVFormUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingAcknowledgement &&
        other.acknowledgementNumber == acknowledgementNumber &&
        other.filingDate == filingDate &&
        other.itrType == itrType &&
        other.assessmentYear == assessmentYear &&
        other.verificationStatus == verificationStatus &&
        other.verificationMethod == verificationMethod &&
        other.verificationDate == verificationDate &&
        other.itrVFormUrl == itrVFormUrl;
  }

  @override
  int get hashCode => Object.hash(
    acknowledgementNumber,
    filingDate,
    itrType,
    assessmentYear,
    verificationStatus,
    verificationMethod,
    verificationDate,
    itrVFormUrl,
  );
}
