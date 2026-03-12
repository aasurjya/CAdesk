// DSC token model for the e-verification feature.
//
// This is a domain-layer certificate distinct from the dsc_vault
// DscCertificate — it carries the raw PKI fields needed for signing.

/// Immutable model representing a DSC certificate used for document signing.
class DscCertificate {
  const DscCertificate({
    required this.tokenId,
    required this.subjectName,
    required this.issuer,
    required this.serialNumber,
    required this.validFrom,
    required this.validTo,
    required this.keyUsage,
  });

  /// Platform token / hardware identifier (e.g. USB-token slot id).
  final String tokenId;

  /// Distinguished name of the certificate holder (e.g. "CN=Test User").
  final String subjectName;

  /// Certifying authority distinguished name.
  final String issuer;

  /// Unique serial number issued by the CA.
  final String serialNumber;

  final DateTime validFrom;
  final DateTime validTo;

  /// List of key usage OIDs in human-readable form.
  /// e.g. ["digitalSignature", "nonRepudiation"]
  final List<String> keyUsage;

  // ── Computed properties ───────────────────────────────────────────────

  /// True if the certificate has passed its [validTo] date.
  bool get isExpired => DateTime.now().isAfter(validTo);

  /// Days remaining until expiry (negative if already expired).
  int get daysUntilExpiry => validTo.difference(DateTime.now()).inDays;

  // ── copyWith ──────────────────────────────────────────────────────────

  DscCertificate copyWith({
    String? tokenId,
    String? subjectName,
    String? issuer,
    String? serialNumber,
    DateTime? validFrom,
    DateTime? validTo,
    List<String>? keyUsage,
  }) {
    return DscCertificate(
      tokenId: tokenId ?? this.tokenId,
      subjectName: subjectName ?? this.subjectName,
      issuer: issuer ?? this.issuer,
      serialNumber: serialNumber ?? this.serialNumber,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      keyUsage: keyUsage ?? this.keyUsage,
    );
  }

  // ── Equality ─────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DscCertificate && other.serialNumber == serialNumber;
  }

  @override
  int get hashCode => serialNumber.hashCode;
}
