import 'package:ca_app/features/documents/domain/models/document.dart';

abstract class DocumentRepository {
  Future<String> insertDocument(Document document);
  Future<List<Document>> getDocumentsByClient(String clientId);
  Future<List<Document>> getDocumentsByCategory(String category);
  Future<Document?> getDocumentById(String documentId);
  Future<bool> updateDocument(Document document);
  Future<bool> deleteDocument(String documentId);
  Future<List<Document>> searchDocuments(String query);
  Stream<List<Document>> watchDocumentsByClient(String clientId);
}
