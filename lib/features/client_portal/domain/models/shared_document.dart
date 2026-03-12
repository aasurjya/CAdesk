/// Category of a document shared via the client portal.
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

/// Lifecycle status of a shared document.
enum DocumentStatus {
  shared('Shared'),
  viewed('Viewed'),
  downloaded('Downloaded'),
  eSigned('E-Signed'),
  expired('Expired');

  const DocumentStatus(this.label);

  final String label;
}

/// Immutable model representing a document shared with a client via the portal.
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

  /// File size in bytes.
  final int fileSize;

  final String mimeType;
  final DateTime sharedAt;

  /// Whether the document must be e-signed before it is considered complete.
  final bool requiresESign;

  final bool eSigned;
  final DateTime? eSignedAt;

  /// Optional expiry — document access is revoked after this timestamp.
  final DateTime? expiresAt;

  final DateTime? viewedAt;
  final DateTime? downloadedAt;
  final DocumentStatus status;

  SharedDocument copyWith({
    String? documentId,
    String? clientId,
    String? caFirmId,
    String? title,
    DocumentType? documentType,
    int? fileSize,
    String? mimeType,
    DateTime? sharedAt,
    bool? requiresESign,
    bool? eSigned,
    DateTime? eSignedAt,
    DateTime? expiresAt,
    DateTime? viewedAt,
    DateTime? downloadedAt,
    DocumentStatus? status,
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
      requiresESign: requiresESign ?? this.requiresESign,
      eSigned: eSigned ?? this.eSigned,
      eSignedAt: eSignedAt ?? this.eSignedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewedAt: viewedAt ?? this.viewedAt,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      status: status ?? this.status,
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
