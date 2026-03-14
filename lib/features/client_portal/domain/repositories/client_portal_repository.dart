import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';
import 'package:ca_app/features/client_portal/domain/models/client_query.dart';

/// Abstract contract for client portal data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class ClientPortalRepository {
  // ── Portal Messages ────────────────────────────────────────────────────────

  /// Retrieve all messages in a given [threadId].
  Future<List<PortalMessage>> getMessagesByThread(String threadId);

  /// Retrieve all portal messages.
  Future<List<PortalMessage>> getAllMessages();

  /// Insert a new [PortalMessage] and return its ID.
  Future<String> insertMessage(PortalMessage message);

  /// Update an existing [PortalMessage]. Returns true on success.
  Future<bool> updateMessage(PortalMessage message);

  /// Delete the portal message identified by [messageId]. Returns true on success.
  Future<bool> deleteMessage(String messageId);

  // ── Client Queries ─────────────────────────────────────────────────────────

  /// Retrieve all client queries for a given [clientId].
  Future<List<ClientQuery>> getQueriesByClient(String clientId);

  /// Retrieve a single [ClientQuery] by [queryId]. Returns null if not found.
  Future<ClientQuery?> getClientQueryById(String queryId);

  /// Insert a new [ClientQuery] and return its ID.
  Future<String> insertClientQuery(ClientQuery query);

  /// Update an existing [ClientQuery]. Returns true on success.
  Future<bool> updateClientQuery(ClientQuery query);

  /// Delete the client query identified by [queryId]. Returns true on success.
  Future<bool> deleteClientQuery(String queryId);
}
