import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentsRemoteSource {
  const DocumentsRemoteSource(this._client);

  final SupabaseClient _client;

  /// Insert a new document
  Future<Map<String, dynamic>> insertDocument(Map<String, dynamic> data) async {
    final response = await _client
        .from('documents')
        .insert(data)
        .select('*')
        .single();
    return response;
  }

  /// Get all documents for a client
  Future<List<Map<String, dynamic>>> fetchDocumentsByClient(
    String clientId,
  ) async {
    final response = await _client
        .from('documents')
        .select('*')
        .eq('client_id', clientId)
        .order('uploaded_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get all documents of a specific category
  Future<List<Map<String, dynamic>>> fetchDocumentsByCategory(
    String category,
  ) async {
    final response = await _client
        .from('documents')
        .select('*')
        .eq('category', category)
        .order('uploaded_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get a document by ID
  Future<Map<String, dynamic>?> fetchDocumentById(String documentId) async {
    try {
      final response = await _client
          .from('documents')
          .select('*')
          .eq('id', documentId)
          .single();
      return response;
    } catch (_) {
      return null;
    }
  }

  /// Update a document
  Future<Map<String, dynamic>> updateDocument(
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('documents')
        .update(data)
        .eq('id', documentId)
        .select('*')
        .single();
    return response;
  }

  /// Delete a document
  Future<void> deleteDocument(String documentId) async {
    await _client.from('documents').delete().eq('id', documentId);
  }

  /// Search documents by title or tags
  Future<List<Map<String, dynamic>>> searchDocuments(String query) async {
    final response = await _client
        .from('documents')
        .select('*')
        .or('title.ilike.%$query%,tags.cs.{"$query"}')
        .order('uploaded_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
