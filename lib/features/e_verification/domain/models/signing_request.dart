/// Document type covered by DSC signing.
enum DocumentType {
  itrV('ITR-V'),
  gstReturn('GST Return'),
  tdsFvu('TDS FVU'),
  mcaForm('MCA Form'),
  auditReport('Audit Report');

  const DocumentType(this.label);

  final String label;
}

/// Status of a signing request through its lifecycle.
enum SigningStatus {
  pending('Pending'),
  inProgress('In Progress'),
  signed('Signed'),
  failed('Failed'),
  cancelled('Cancelled');

  const SigningStatus(this.label);

  final String label;
}

/// Immutable model representing a single document signing request.
class SigningRequest {
  const SigningRequest({
    required this.requestId,
    required this.documentHash,
    required this.documentType,
    required this.signerPan,
    required this.signerName,
    required this.status,
    this.signedAt,
    this.signature,
  });

  /// Unique identifier for this signing request.
  final String requestId;

  /// SHA-256 hash (hex-encoded) of the document to be signed.
  final String documentHash;

  final DocumentType documentType;

  /// PAN of the signer.
  final String signerPan;

  /// Full name of the signer (as on the DSC).
  final String signerName;

  final SigningStatus status;

  /// Timestamp when the signature was applied. Null until signed.
  final DateTime? signedAt;

  /// Base-64-encoded signature bytes. Null until signed.
  final String? signature;

  // ── copyWith ──────────────────────────────────────────────────────────

  SigningRequest copyWith({
    String? requestId,
    String? documentHash,
    DocumentType? documentType,
    String? signerPan,
    String? signerName,
    SigningStatus? status,
    DateTime? signedAt,
    String? signature,
  }) {
    return SigningRequest(
      requestId: requestId ?? this.requestId,
      documentHash: documentHash ?? this.documentHash,
      documentType: documentType ?? this.documentType,
      signerPan: signerPan ?? this.signerPan,
      signerName: signerName ?? this.signerName,
      status: status ?? this.status,
      signedAt: signedAt ?? this.signedAt,
      signature: signature ?? this.signature,
    );
  }

  // ── Equality ─────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SigningRequest && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;
}
