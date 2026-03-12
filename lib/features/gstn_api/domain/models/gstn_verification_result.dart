/// GST registration status on the GSTN portal.
enum GstnRegistrationStatus {
  active,
  cancelled,
  suspended,
}

/// Frequency at which the taxpayer files GST returns.
enum ReturnFilingFrequency {
  monthly,
  quarterly,
}

/// Immutable result of a GSTIN verification lookup.
class GstnVerificationResult {
  const GstnVerificationResult({
    required this.gstin,
    required this.legalName,
    required this.registrationDate,
    required this.status,
    required this.stateCode,
    required this.constitutionType,
    required this.returnFilingFrequency,
    this.tradeName,
  });

  /// 15-character GST Identification Number that was queried.
  final String gstin;

  /// Legal name of the taxpayer as registered with GST.
  final String legalName;

  /// Trade name (DBA), if different from the legal name.
  final String? tradeName;

  /// Date on which the GST registration became effective.
  final DateTime registrationDate;

  /// Current registration status on the GSTN portal.
  final GstnRegistrationStatus status;

  /// 2-digit state code extracted from the GSTIN.
  final String stateCode;

  /// Legal constitution, e.g. "Private Limited Company".
  final String constitutionType;

  /// Whether the taxpayer files monthly or quarterly.
  final ReturnFilingFrequency returnFilingFrequency;

  /// Derived validity flag — true only when status is active.
  bool get isValid => status == GstnRegistrationStatus.active;

  GstnVerificationResult copyWith({
    String? gstin,
    String? legalName,
    String? tradeName,
    DateTime? registrationDate,
    GstnRegistrationStatus? status,
    String? stateCode,
    String? constitutionType,
    ReturnFilingFrequency? returnFilingFrequency,
  }) {
    return GstnVerificationResult(
      gstin: gstin ?? this.gstin,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      stateCode: stateCode ?? this.stateCode,
      constitutionType: constitutionType ?? this.constitutionType,
      returnFilingFrequency:
          returnFilingFrequency ?? this.returnFilingFrequency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstnVerificationResult &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          legalName == other.legalName &&
          tradeName == other.tradeName &&
          registrationDate == other.registrationDate &&
          status == other.status &&
          stateCode == other.stateCode &&
          constitutionType == other.constitutionType &&
          returnFilingFrequency == other.returnFilingFrequency;

  @override
  int get hashCode => Object.hash(
        gstin,
        legalName,
        tradeName,
        registrationDate,
        status,
        stateCode,
        constitutionType,
        returnFilingFrequency,
      );
}
