import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/documents/data/mappers/document_mapper.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

class DocumentsLocalSource {
  const DocumentsLocalSource(this._db);

  final AppDatabase _db;

  /// Insert a new document and return its ID
  Future<String> insertDocument(Document document) async {
    return _db.documentsDao.insertDocument(
      DocumentMapper.toCompanion(document),
    );
  }

  /// Get all documents for a client
  Future<List<Document>> getDocumentsByClient(String clientId) async {
    final rows = await _db.documentsDao.getDocumentsByClient(clientId);
    return rows.map(DocumentMapper.fromRow).toList();
  }

  /// Watch documents for a client
  Stream<List<Document>> watchDocumentsByClient(String clientId) {
    return _db.documentsDao
        .watchDocumentsByClient(clientId)
        .map((rows) => rows.map(DocumentMapper.fromRow).toList());
  }

  /// Get all documents of a specific category
  Future<List<Document>> getDocumentsByCategory(String category) async {
    final rows = await _db.documentsDao.getDocumentsByCategory(category);
    return rows.map(DocumentMapper.fromRow).toList();
  }

  /// Get a document by ID
  Future<Document?> getDocumentById(String documentId) async {
    final row = await _db.documentsDao.getDocumentById(documentId);
    return row != null ? DocumentMapper.fromRow(row) : null;
  }

  /// Update a document
  Future<bool> updateDocument(Document document) async {
    return _db.documentsDao.updateDocument(
      DocumentMapper.toCompanion(document),
    );
  }

  /// Delete a document
  Future<bool> deleteDocument(String documentId) async {
    return _db.documentsDao.deleteDocument(documentId);
  }

  /// Search documents by title or tags
  Future<List<Document>> searchDocuments(String query) async {
    final rows = await _db.documentsDao.searchDocuments(query);
    return rows.map(DocumentMapper.fromRow).toList();
  }
}
