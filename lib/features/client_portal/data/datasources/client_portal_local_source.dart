import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';

/// Local data source for client portal messages and queries.
///
/// Uses in-memory caches as a fallback when Supabase is unavailable.
class ClientPortalLocalSource {
  ClientPortalLocalSource();

  final List<PortalMessage> _messageCache = [];
  final List<ClientQuery> _queryCache = [];

  // ── PortalMessage ────────────────────────────────────────────────────────

  Future<String> insertMessage(PortalMessage message) async {
    final idx = _messageCache.indexWhere((m) => m.id == message.id);
    if (idx >= 0) {
      final updated = List<PortalMessage>.of(_messageCache)..[idx] = message;
      _messageCache
        ..clear()
        ..addAll(updated);
    } else {
      _messageCache.add(message);
    }
    return message.id;
  }

  Future<List<PortalMessage>> getMessagesByThread(String threadId) async {
    return List.unmodifiable(
      _messageCache.where((m) => m.threadId == threadId).toList(),
    );
  }

  Future<List<PortalMessage>> getAllMessages() async {
    return List.unmodifiable(_messageCache);
  }

  Future<bool> updateMessage(PortalMessage message) async {
    final idx = _messageCache.indexWhere((m) => m.id == message.id);
    if (idx == -1) return false;
    final updated = List<PortalMessage>.of(_messageCache)..[idx] = message;
    _messageCache
      ..clear()
      ..addAll(updated);
    return true;
  }

  Future<bool> deleteMessage(String messageId) async {
    final before = _messageCache.length;
    _messageCache.removeWhere((m) => m.id == messageId);
    return _messageCache.length < before;
  }

  // ── ClientQuery ──────────────────────────────────────────────────────────

  Future<String> insertQuery(ClientQuery query) async {
    final idx = _queryCache.indexWhere((q) => q.id == query.id);
    if (idx >= 0) {
      final updated = List<ClientQuery>.of(_queryCache)..[idx] = query;
      _queryCache
        ..clear()
        ..addAll(updated);
    } else {
      _queryCache.add(query);
    }
    return query.id;
  }

  Future<List<ClientQuery>> getQueriesByClient(String clientId) async {
    return List.unmodifiable(
      _queryCache.where((q) => q.clientId == clientId).toList(),
    );
  }

  Future<ClientQuery?> getQueryById(String queryId) async {
    try {
      return _queryCache.firstWhere((q) => q.id == queryId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateQuery(ClientQuery query) async {
    final idx = _queryCache.indexWhere((q) => q.id == query.id);
    if (idx == -1) return false;
    final updated = List<ClientQuery>.of(_queryCache)..[idx] = query;
    _queryCache
      ..clear()
      ..addAll(updated);
    return true;
  }

  Future<bool> deleteQuery(String queryId) async {
    final before = _queryCache.length;
    _queryCache.removeWhere((q) => q.id == queryId);
    return _queryCache.length < before;
  }
}
