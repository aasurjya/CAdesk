import 'package:flutter/material.dart';

/// Status of a DSC certificate.
enum DscStatus {
  valid('Valid', Color(0xFF1A7A3A), Icons.verified_rounded),
  expiringSoon(
    'Expiring Soon',
    Color(0xFFD4890E),
    Icons.warning_amber_rounded,
  ),
  expired('Expired', Color(0xFFC62828), Icons.cancel_rounded),
  revoked('Revoked', Color(0xFF718096), Icons.block_rounded);

  const DscStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

/// Type of DSC token / certificate class.
enum DscTokenType {
  class3('Class 3', Icons.security_rounded),
  class2('Class 2', Icons.shield_rounded),
  usbToken('USB Token', Icons.usb_rounded),
  cloudDsc('Cloud DSC', Icons.cloud_rounded);

  const DscTokenType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Immutable model representing a Digital Signature Certificate.
class DscCertificate {
  const DscCertificate({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.panOrDin,
    required this.certHolder,
    required this.issuedBy,
    required this.expiryDate,
    required this.status,
    required this.tokenType,
    required this.usageCount,
    this.lastUsedAt,
  });

  final String id;
  final String clientId;
  final String clientName;

  /// PAN (10 chars) or DIN (8 digits) of the entity the DSC is issued for.
  final String panOrDin;

  /// Name as printed on the DSC.
  final String certHolder;

  /// Certifying Authority (e.g. "eMudhra", "Sify", "NSDL").
  final String issuedBy;

  final DateTime expiryDate;
  final DscStatus status;
  final DscTokenType tokenType;
  final int usageCount;
  final DateTime? lastUsedAt;

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// Days remaining until expiry (negative if already expired).
  int get daysToExpiry {
    final today = DateTime.now();
    return expiryDate.difference(today).inDays;
  }

  bool get isExpired => daysToExpiry < 0;

  /// True when the certificate expires within 30 days but is not yet expired.
  bool get isExpiringSoon => !isExpired && daysToExpiry <= 30;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  DscCertificate copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? panOrDin,
    String? certHolder,
    String? issuedBy,
    DateTime? expiryDate,
    DscStatus? status,
    DscTokenType? tokenType,
    int? usageCount,
    DateTime? lastUsedAt,
  }) {
    return DscCertificate(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      panOrDin: panOrDin ?? this.panOrDin,
      certHolder: certHolder ?? this.certHolder,
      issuedBy: issuedBy ?? this.issuedBy,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      tokenType: tokenType ?? this.tokenType,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
}
