import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';

/// Immutable enriched details for a GSTIN lookup.
///
/// Extends [GstnVerificationResult] with address and return-filing frequency.
class GstinDetails {
  const GstinDetails({
    required this.gstin,
    required this.legalName,
    required this.tradeName,
    required this.address,
    required this.registrationDate,
    required this.status,
    required this.stateCode,
    required this.constitutionType,
    required this.returnFilingFrequency,
  });

  /// 15-character GST Identification Number.
  final String gstin;

  /// Legal name as registered with GST.
  final String legalName;

  /// Trade / DBA name (may be empty string when not set).
  final String tradeName;

  /// Full registered address.
  final String address;

  final DateTime registrationDate;

  final GstnRegistrationStatus status;

  /// 2-digit state code extracted from the GSTIN.
  final String stateCode;

  final String constitutionType;

  /// Monthly or quarterly return filer.
  final ReturnFilingFrequency returnFilingFrequency;

  GstinDetails copyWith({
    String? gstin,
    String? legalName,
    String? tradeName,
    String? address,
    DateTime? registrationDate,
    GstnRegistrationStatus? status,
    String? stateCode,
    String? constitutionType,
    ReturnFilingFrequency? returnFilingFrequency,
  }) {
    return GstinDetails(
      gstin: gstin ?? this.gstin,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      address: address ?? this.address,
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
      other is GstinDetails &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          legalName == other.legalName &&
          tradeName == other.tradeName &&
          address == other.address &&
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
        address,
        registrationDate,
        status,
        stateCode,
        constitutionType,
        returnFilingFrequency,
      );
}
