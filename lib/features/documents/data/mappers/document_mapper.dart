import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

class DocumentMapper {
  const DocumentMapper._();

  /// JSON (from Supabase) → Document domain model
  static Document fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      title: json['title'] as String,
      category: _safeDocumentCategory(json['category'] as String? ?? 'miscellaneous'),
      fileType: _safeDocumentFileType(json['file_type'] as String? ?? 'pdf'),
      fileSize: json['file_size'] as int? ?? 0,
      uploadedBy: json['uploaded_by'] as String,
      uploadedAt: DateTime.parse(
        json['uploaded_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      tags: _parseTagsFromJson(json['tags']),
      isSharedWithClient: json['is_shared_with_client'] as bool? ?? false,
      downloadCount: json['download_count'] as int? ?? 0,
      version: json['version'] as int? ?? 1,
      remarks: json['remarks'] as String?,
    );
  }

  /// Document domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(Document document) {
    return {
      'id': document.id,
      'client_id': document.clientId,
      'client_name': document.clientName,
      'title': document.title,
      'category': document.category.name,
      'file_type': document.fileType.name,
      'file_size': document.fileSize,
      'uploaded_by': document.uploadedBy,
      'uploaded_at': document.uploadedAt.toIso8601String(),
      'tags': document.tags,
      'is_shared_with_client': document.isSharedWithClient,
      'download_count': document.downloadCount,
      'version': document.version,
      'remarks': document.remarks,
    };
  }

  /// Drift row → Document domain model
  static Document fromRow(DocumentRow row) {
    return Document(
      id: row.id,
      clientId: row.clientId,
      clientName: row.clientName,
      title: row.title,
      category: _safeDocumentCategory(row.category),
      fileType: _safeDocumentFileType(row.fileType),
      fileSize: row.fileSize,
      uploadedBy: row.uploadedBy,
      uploadedAt: row.uploadedAt,
      tags: _parseTagsFromJson(row.tags),
      isSharedWithClient: row.isSharedWithClient,
      downloadCount: row.downloadCount,
      version: row.version,
      remarks: row.remarks,
    );
  }

  /// Document → Drift companion (for insert/update)
  static DocumentsTableCompanion toCompanion(Document document) {
    return DocumentsTableCompanion(
      id: Value(document.id),
      clientId: Value(document.clientId),
      clientName: Value(document.clientName),
      title: Value(document.title),
      category: Value(document.category.name),
      fileType: Value(document.fileType.name),
      fileSize: Value(document.fileSize),
      uploadedBy: Value(document.uploadedBy),
      uploadedAt: Value(document.uploadedAt),
      tags: Value(jsonEncode(document.tags)),
      isSharedWithClient: Value(document.isSharedWithClient),
      downloadCount: Value(document.downloadCount),
      version: Value(document.version),
      remarks: Value(document.remarks),
      isDirty: const Value(true),
    );
  }

  static List<String> _parseTagsFromJson(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return (raw).cast<String>();
    }
    if (raw is String) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.cast<String>();
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }

  static DocumentCategory _safeDocumentCategory(String name) {
    try {
      return DocumentCategory.values.byName(name);
    } catch (_) {
      return DocumentCategory.miscellaneous;
    }
  }

  static DocumentFileType _safeDocumentFileType(String name) {
    try {
      return DocumentFileType.values.byName(name);
    } catch (_) {
      return DocumentFileType.pdf;
    }
  }
}
