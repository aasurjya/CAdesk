/// Types of documents that can be shared via the client portal.
enum DocumentType {
  itrV,
  form16,
  gstCertificate,
  auditReport,
  invoice,
  other,
}

/// Lifecycle status of a shared document.
enum DocumentStatus {
  shared,
  viewed,
  downloaded,
  eSigned,
  expired,
}

/// Domain model representing a document shared with a client through the portal.
///
/// All money values are in paise (int). Immutable — use [copyWith] to derive
/// updated copies.
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
    this.viewedAt,
    this.downloadedAt,
    this.eSignedAt,
    this.expiresAt,
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
  final bool requiresESign;
  final bool eSigned;
  final DocumentStatus status;
  final DateTime? viewedAt;
  final DateTime? downloadedAt;
  final DateTime? eSignedAt;
  final DateTime? expiresAt;

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
    DocumentStatus? status,
    DateTime? viewedAt,
    DateTime? downloadedAt,
    DateTime? eSignedAt,
    DateTime? expiresAt,
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
      status: status ?? this.status,
      viewedAt: viewedAt ?? this.viewedAt,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      eSignedAt: eSignedAt ?? this.eSignedAt,
      expiresAt: expiresAt ?? this.expiresAt,
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
