import 'package:ca_app/features/documents/domain/models/document.dart';
import 'package:ca_app/features/documents/domain/repositories/document_repository.dart';

/// Mock implementation of DocumentRepository for testing and offline mode.
class MockDocumentRepository implements DocumentRepository {
  MockDocumentRepository({List<Document>? documents})
    : _documents = documents ?? [];

  final List<Document> _documents;

  @override
  Future<String> insertDocument(Document document) async {
    _documents.add(document);
    return document.id;
  }

  @override
  Future<List<Document>> getDocumentsByClient(String clientId) async {
    return _documents.where((doc) => doc.clientId == clientId).toList();
  }

  @override
  Future<List<Document>> getDocumentsByCategory(String category) async {
    return _documents.where((doc) => doc.category.name == category).toList();
  }

  @override
  Future<Document?> getDocumentById(String documentId) async {
    try {
      return _documents.firstWhere((doc) => doc.id == documentId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> updateDocument(Document document) async {
    final index = _documents.indexWhere((doc) => doc.id == document.id);
    if (index == -1) return false;
    _documents[index] = document;
    return true;
  }

  @override
  Future<bool> deleteDocument(String documentId) async {
    final index = _documents.indexWhere((doc) => doc.id == documentId);
    if (index == -1) return false;
    _documents.removeAt(index);
    return true;
  }

  @override
  Future<List<Document>> searchDocuments(String query) async {
    final lowerQuery = query.toLowerCase();
    return _documents
        .where(
          (doc) =>
              doc.title.toLowerCase().contains(lowerQuery) ||
              doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)),
        )
        .toList();
  }

  @override
  Stream<List<Document>> watchDocumentsByClient(String clientId) async* {
    yield* Stream.fromIterable([
      _documents.where((doc) => doc.clientId == clientId).toList(),
    ]);
  }
}
