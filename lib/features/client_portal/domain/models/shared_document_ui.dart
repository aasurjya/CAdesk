/// Types of documents that can be shared.
enum DocumentType {
  itrV('ITR-V'),
  form16('Form 16'),
  gstCertificate('GST Certificate'),
  auditReport('Audit Report'),
  invoice('Invoice'),
  other('Other');

  const DocumentType(this.label);

  final String label;
}

/// Status of a shared document.
enum DocumentStatus {
  shared('Shared'),
  viewed('Viewed'),
  downloaded('Downloaded'),
  eSigned('E-Signed'),
  expired('Expired');

  const DocumentStatus(this.label);

  final String label;
}

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
    required this.documentId,
    required this.clientId,
    required this.caFirmId,
    required this.title,
    required this.documentType,
    required this.fileSize,
    required this.mimeType,
    required this.sharedAt,
    required this.requiresESign,
    required this.eSigned,
    required this.status,
    this.expiresAt,
    this.eSignedAt,
    this.viewedAt,
    this.downloadedAt,
  });

  final String documentId;
  final String clientId;
  final String caFirmId;
  final String title;
  final DocumentType documentType;
  final int fileSize;
  final String mimeType;
  final DateTime sharedAt;
  final DateTime? expiresAt;
  final bool requiresESign;
  final bool eSigned;
  final DocumentStatus status;
  final DateTime? eSignedAt;
  final DateTime? viewedAt;
  final DateTime? downloadedAt;

  SharedDocument copyWith({
    String? documentId,
    String? clientId,
    String? caFirmId,
    String? title,
    DocumentType? documentType,
    int? fileSize,
    String? mimeType,
    DateTime? sharedAt,
    DateTime? expiresAt,
    bool? requiresESign,
    bool? eSigned,
    DocumentStatus? status,
    DateTime? eSignedAt,
    DateTime? viewedAt,
    DateTime? downloadedAt,
  }) {
    return SharedDocument(
      documentId: documentId ?? this.documentId,
      clientId: clientId ?? this.clientId,
      caFirmId: caFirmId ?? this.caFirmId,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      sharedAt: sharedAt ?? this.sharedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      requiresESign: requiresESign ?? this.requiresESign,
      eSigned: eSigned ?? this.eSigned,
      status: status ?? this.status,
      eSignedAt: eSignedAt ?? this.eSignedAt,
      viewedAt: viewedAt ?? this.viewedAt,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedDocument && other.documentId == documentId;
  }

  @override
  int get hashCode => documentId.hashCode;
}
