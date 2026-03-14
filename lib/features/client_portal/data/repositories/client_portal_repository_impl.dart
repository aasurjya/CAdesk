import 'package:ca_app/features/client_portal/data/datasources/client_portal_local_source.dart';
import 'package:ca_app/features/client_portal/data/datasources/client_portal_remote_source.dart';
import 'package:ca_app/features/client_portal/data/mappers/client_portal_mapper.dart';
import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';
import 'package:ca_app/features/client_portal/domain/repositories/client_portal_repository.dart';

/// Real implementation of [ClientPortalRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// on any network error.
class ClientPortalRepositoryImpl implements ClientPortalRepository {
  const ClientPortalRepositoryImpl({required this.remote, required this.local});

  final ClientPortalRemoteSource remote;
  final ClientPortalLocalSource local;

  // ── PortalMessage ────────────────────────────────────────────────────────

  @override
  Future<List<PortalMessage>> getMessagesByThread(String threadId) async {
    try {
      final jsonList = await remote.fetchMessagesByThread(threadId);
      final messages = jsonList
          .map(ClientPortalMapper.messageFromJson)
          .toList();
      for (final m in messages) {
        await local.insertMessage(m);
      }
      return List.unmodifiable(messages);
    } catch (_) {
      return local.getMessagesByThread(threadId);
    }
  }

  @override
  Future<List<PortalMessage>> getAllMessages() async {
    try {
      final jsonList = await remote.fetchAllMessages();
      final messages = jsonList
          .map(ClientPortalMapper.messageFromJson)
          .toList();
      for (final m in messages) {
        await local.insertMessage(m);
      }
      return List.unmodifiable(messages);
    } catch (_) {
      return local.getAllMessages();
    }
  }

  @override
  Future<String> insertMessage(PortalMessage message) async {
    try {
      final json = await remote.insertMessage(
        ClientPortalMapper.messageToJson(message),
      );
      final inserted = ClientPortalMapper.messageFromJson(json);
      await local.insertMessage(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertMessage(message);
    }
  }

  @override
  Future<bool> updateMessage(PortalMessage message) async {
    try {
      final json = await remote.updateMessage(
        message.id,
        ClientPortalMapper.messageToJson(message),
      );
      final updated = ClientPortalMapper.messageFromJson(json);
      await local.updateMessage(updated);
      return true;
    } catch (_) {
      return local.updateMessage(message);
    }
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    try {
      await remote.deleteMessage(messageId);
      await local.deleteMessage(messageId);
      return true;
    } catch (_) {
      return local.deleteMessage(messageId);
    }
  }

  // ── ClientQuery ──────────────────────────────────────────────────────────

  @override
  Future<List<ClientQuery>> getQueriesByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchQueriesByClient(clientId);
      final queries = jsonList.map(ClientPortalMapper.queryFromJson).toList();
      for (final q in queries) {
        await local.insertQuery(q);
      }
      return List.unmodifiable(queries);
    } catch (_) {
      return local.getQueriesByClient(clientId);
    }
  }

  @override
  Future<ClientQuery?> getClientQueryById(String queryId) async {
    try {
      final json = await remote.fetchQueryById(queryId);
      if (json == null) return null;
      final query = ClientPortalMapper.queryFromJson(json);
      await local.insertQuery(query);
      return query;
    } catch (_) {
      return local.getQueryById(queryId);
    }
  }

  @override
  Future<String> insertClientQuery(ClientQuery query) async {
    try {
      final json = await remote.insertQuery(
        ClientPortalMapper.queryToJson(query),
      );
      final inserted = ClientPortalMapper.queryFromJson(json);
      await local.insertQuery(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertQuery(query);
    }
  }

  @override
  Future<bool> updateClientQuery(ClientQuery query) async {
    try {
      final json = await remote.updateQuery(
        query.id,
        ClientPortalMapper.queryToJson(query),
      );
      final updated = ClientPortalMapper.queryFromJson(json);
      await local.updateQuery(updated);
      return true;
    } catch (_) {
      return local.updateQuery(query);
    }
  }

  @override
  Future<bool> deleteClientQuery(String queryId) async {
    try {
      await remote.deleteQuery(queryId);
      await local.deleteQuery(queryId);
      return true;
    } catch (_) {
      return local.deleteQuery(queryId);
    }
  }
}
