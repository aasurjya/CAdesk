import 'package:ca_app/features/documents/data/datasources/documents_local_source.dart';
import 'package:ca_app/features/documents/data/datasources/documents_remote_source.dart';
import 'package:ca_app/features/documents/data/mappers/document_mapper.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';
import 'package:ca_app/features/documents/domain/repositories/document_repository.dart';

/// Implementation of DocumentRepository with fallback to local cache on network error.
class DocumentRepositoryImpl implements DocumentRepository {
  const DocumentRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final DocumentsRemoteSource remote;
  final DocumentsLocalSource local;

  @override
  Future<String> insertDocument(Document document) async {
    try {
      final json = await remote.insertDocument(DocumentMapper.toJson(document));
      final inserted = DocumentMapper.fromJson(json);
      // Cache locally after successful remote insert
      await local.insertDocument(inserted);
      return inserted.id;
    } catch (_) {
      // Fallback to local insert on network failure
      return local.insertDocument(document);
    }
  }

  @override
  Future<List<Document>> getDocumentsByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchDocumentsByClient(clientId);
      final documents = jsonList.map(DocumentMapper.fromJson).toList();
      // Cache locally
      for (final doc in documents) {
        await local.insertDocument(doc);
      }
      return List.unmodifiable(documents);
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getDocumentsByClient(clientId);
    }
  }

  @override
  Future<List<Document>> getDocumentsByCategory(String category) async {
    try {
      final jsonList = await remote.fetchDocumentsByCategory(category);
      final documents = jsonList.map(DocumentMapper.fromJson).toList();
      // Cache locally
      for (final doc in documents) {
        await local.insertDocument(doc);
      }
      return List.unmodifiable(documents);
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getDocumentsByCategory(category);
    }
  }

  @override
  Future<Document?> getDocumentById(String documentId) async {
    try {
      final json = await remote.fetchDocumentById(documentId);
      if (json == null) return null;
      final document = DocumentMapper.fromJson(json);
      await local.insertDocument(document);
      return document;
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getDocumentById(documentId);
    }
  }

  @override
  Future<bool> updateDocument(Document document) async {
    try {
      final json = await remote.updateDocument(
        document.id,
        DocumentMapper.toJson(document),
      );
      final updated = DocumentMapper.fromJson(json);
      await local.updateDocument(updated);
      return true;
    } catch (_) {
      // Fallback to local update on network failure
      return local.updateDocument(document);
    }
  }

  @override
  Future<bool> deleteDocument(String documentId) async {
    try {
      await remote.deleteDocument(documentId);
      await local.deleteDocument(documentId);
      return true;
    } catch (_) {
      // Fallback to local delete on network failure
      return local.deleteDocument(documentId);
    }
  }

  @override
  Future<List<Document>> searchDocuments(String query) async {
    try {
      final jsonList = await remote.searchDocuments(query);
      return List.unmodifiable(jsonList.map(DocumentMapper.fromJson).toList());
    } catch (_) {
      // Fallback to local search on network failure
      return local.searchDocuments(query);
    }
  }

  @override
  Stream<List<Document>> watchDocumentsByClient(String clientId) {
    return local.watchDocumentsByClient(clientId);
  }
}
