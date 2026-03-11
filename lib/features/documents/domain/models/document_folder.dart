/// Immutable model representing a folder used to organise client documents.
class DocumentFolder {
  const DocumentFolder({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.folderName,
    required this.documentCount,
    required this.lastModified,
    required this.createdBy,
    this.parentFolderId,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String folderName;

  /// Optional parent folder — null means this is a root folder.
  final String? parentFolderId;
  final int documentCount;
  final DateTime lastModified;
  final String createdBy;

  DocumentFolder copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? folderName,
    String? parentFolderId,
    int? documentCount,
    DateTime? lastModified,
    String? createdBy,
  }) {
    return DocumentFolder(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      folderName: folderName ?? this.folderName,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      documentCount: documentCount ?? this.documentCount,
      lastModified: lastModified ?? this.lastModified,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentFolder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
