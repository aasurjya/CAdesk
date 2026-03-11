import 'package:flutter/foundation.dart';

/// Status of a KYC verification process.
enum KycStatus {
  pending(label: 'Pending'),
  documentsSubmitted(label: 'Documents Submitted'),
  underVerification(label: 'Under Verification'),
  verified(label: 'Verified'),
  rejected(label: 'Rejected'),
  expired(label: 'Expired');

  const KycStatus({required this.label});

  final String label;
}

/// Immutable model representing a client KYC record.
@immutable
class KycRecord {
  const KycRecord({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.kycStatus,
    required this.aadhaarVerified,
    required this.panVerified,
    required this.ckycKin,
    required this.submittedAt,
    this.verifiedAt,
    this.expiryDate,
    required this.remarks,
  });

  final String id;
  final String clientId;
  final String clientName;
  final KycStatus kycStatus;
  final bool aadhaarVerified;
  final bool panVerified;
  final String ckycKin;
  final DateTime submittedAt;
  final DateTime? verifiedAt;
  final DateTime? expiryDate;
  final String remarks;

  /// Returns a new [KycRecord] with the given fields replaced.
  KycRecord copyWith({
    String? id,
    String? clientId,
    String? clientName,
    KycStatus? kycStatus,
    bool? aadhaarVerified,
    bool? panVerified,
    String? ckycKin,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    DateTime? expiryDate,
    String? remarks,
  }) {
    return KycRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      kycStatus: kycStatus ?? this.kycStatus,
      aadhaarVerified: aadhaarVerified ?? this.aadhaarVerified,
      panVerified: panVerified ?? this.panVerified,
      ckycKin: ckycKin ?? this.ckycKin,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KycRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          kycStatus == other.kycStatus &&
          aadhaarVerified == other.aadhaarVerified &&
          panVerified == other.panVerified &&
          ckycKin == other.ckycKin &&
          submittedAt == other.submittedAt &&
          verifiedAt == other.verifiedAt &&
          expiryDate == other.expiryDate;

  @override
  int get hashCode => Object.hash(
        id,
        clientId,
        kycStatus,
        aadhaarVerified,
        panVerified,
        ckycKin,
        submittedAt,
        verifiedAt,
        expiryDate,
      );

  @override
  String toString() =>
      'KycRecord(id: $id, client: $clientName, status: ${kycStatus.label})';
}
