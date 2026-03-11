/// Document category for CA practice document classification.
enum DocumentCategory {
  taxReturns('Tax Returns'),
  gstReturns('GST Returns'),
  tdsCertificates('TDS Certificates'),
  financialStatements('Financial Statements'),
  auditReports('Audit Reports'),
  agreements('Agreements'),
  identity('Identity Docs'),
  bankStatements('Bank Statements'),
  notices('Notices'),
  miscellaneous('Miscellaneous');

  const DocumentCategory(this.label);
  final String label;
}

/// File type of a stored document.
enum DocumentFileType {
  pdf('PDF'),
  excel('Excel'),
  word('Word'),
  image('Image'),
  zip('ZIP');

  const DocumentFileType(this.label);
  final String label;
}

/// Immutable model representing a client document stored in the system.
class Document {
  const Document({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.category,
    required this.fileType,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
    this.tags = const [],
    this.isSharedWithClient = false,
    this.downloadCount = 0,
    this.version = 1,
    this.remarks,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String title;
  final DocumentCategory category;
  final DocumentFileType fileType;

  /// File size in bytes.
  final int fileSize;
  final String uploadedBy;
  final DateTime uploadedAt;
  final List<String> tags;
  final bool isSharedWithClient;
  final int downloadCount;
  final int version;
  final String? remarks;

  /// Human-readable file size string.
  String get fileSizeLabel {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Document copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? title,
    DocumentCategory? category,
    DocumentFileType? fileType,
    int? fileSize,
    String? uploadedBy,
    DateTime? uploadedAt,
    List<String>? tags,
    bool? isSharedWithClient,
    int? downloadCount,
    int? version,
    String? remarks,
  }) {
    return Document(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      title: title ?? this.title,
      category: category ?? this.category,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      tags: tags ?? this.tags,
      isSharedWithClient: isSharedWithClient ?? this.isSharedWithClient,
      downloadCount: downloadCount ?? this.downloadCount,
      version: version ?? this.version,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
