/// Signature status for shared documents requiring e-signatures.
enum SignatureStatus {
  notRequired('Not Required'),
  pending('Pending'),
  signed('Signed'),
  rejected('Rejected'),
  expired('Expired');

  const SignatureStatus(this.label);

  final String label;
}

/// Represents a document shared with or uploaded by a client through the portal.
class SharedDocument {
  const SharedDocument({
    required this.id,
    required this.clientId,
    required this.documentName,
    required this.documentType,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.downloadUrl,
    this.expiresAt,
    this.isSignatureRequired = false,
    this.signatureStatus = SignatureStatus.notRequired,
  });

  final String id;
  final String clientId;
  final String documentName;
  final String documentType;
  final String uploadedBy;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final bool isSignatureRequired;
  final SignatureStatus signatureStatus;
  final String downloadUrl;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  SharedDocument copyWith({
    String? id,
    String? clientId,
    String? documentName,
    String? documentType,
    String? uploadedBy,
    DateTime? uploadedAt,
    DateTime? expiresAt,
    bool? isSignatureRequired,
    SignatureStatus? signatureStatus,
    String? downloadUrl,
  }) {
    return SharedDocument(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      documentName: documentName ?? this.documentName,
      documentType: documentType ?? this.documentType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isSignatureRequired: isSignatureRequired ?? this.isSignatureRequired,
      signatureStatus: signatureStatus ?? this.signatureStatus,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
