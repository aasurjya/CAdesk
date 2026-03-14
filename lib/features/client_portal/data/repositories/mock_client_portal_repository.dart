import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';
import 'package:ca_app/features/client_portal/domain/repositories/client_portal_repository.dart';

/// In-memory mock implementation of [ClientPortalRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations use immutable patterns.
class MockClientPortalRepository implements ClientPortalRepository {
  static final List<PortalMessage> _messageSeed = [
    PortalMessage(
      id: 'mock-msg-001',
      senderId: 'mock-client-001',
      senderName: 'Ravi Kumar',
      senderType: SenderType.client,
      content: 'Please share my ITR computation for FY 2024-25.',
      threadId: 'thread-001',
      createdAt: DateTime(2026, 3, 1, 10, 0),
    ),
    PortalMessage(
      id: 'mock-msg-002',
      senderId: 'staff-anil',
      senderName: 'CA Anil Sharma',
      senderType: SenderType.staff,
      content: 'Hello Ravi, your ITR computation is attached. Please review.',
      threadId: 'thread-001',
      createdAt: DateTime(2026, 3, 2, 11, 30),
      isRead: true,
    ),
    PortalMessage(
      id: 'mock-msg-003',
      senderId: 'mock-client-002',
      senderName: 'Priya Sharma',
      senderType: SenderType.client,
      content: 'When will my GST returns be filed?',
      threadId: 'thread-002',
      createdAt: DateTime(2026, 3, 5, 9, 0),
    ),
  ];

  static final List<ClientQuery> _querySeed = [
    ClientQuery(
      id: 'mock-cq-001',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar',
      subject: 'ITR Filing Status',
      description: 'What is the status of my ITR for FY 2024-25?',
      category: QueryCategory.tax,
      priority: QueryPriority.high,
      status: QueryStatus.inProgress,
      assignedTo: 'CA Anil Sharma',
      createdAt: DateTime(2026, 2, 15),
    ),
    ClientQuery(
      id: 'mock-cq-002',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar',
      subject: 'GST Credit Mismatch',
      description: 'There is a mismatch in my GSTR-2B and purchase register.',
      category: QueryCategory.gst,
      priority: QueryPriority.urgent,
      status: QueryStatus.open,
      createdAt: DateTime(2026, 3, 1),
    ),
    ClientQuery(
      id: 'mock-cq-003',
      clientId: 'mock-client-002',
      clientName: 'Priya Sharma',
      subject: 'Invoice Copy Request',
      description: 'Please share the invoice for audit fees.',
      category: QueryCategory.billing,
      priority: QueryPriority.low,
      status: QueryStatus.resolved,
      assignedTo: 'CA Meena Iyer',
      createdAt: DateTime(2026, 1, 10),
      resolvedAt: DateTime(2026, 1, 12),
    ),
  ];

  final List<PortalMessage> _messages = List.of(_messageSeed);
  final List<ClientQuery> _queries = List.of(_querySeed);

  // ── PortalMessage ────────────────────────────────────────────────────────

  @override
  Future<List<PortalMessage>> getMessagesByThread(String threadId) async {
    return List.unmodifiable(
      _messages.where((m) => m.threadId == threadId).toList(),
    );
  }

  @override
  Future<List<PortalMessage>> getAllMessages() async {
    return List.unmodifiable(_messages);
  }

  @override
  Future<String> insertMessage(PortalMessage message) async {
    _messages.add(message);
    return message.id;
  }

  @override
  Future<bool> updateMessage(PortalMessage message) async {
    final idx = _messages.indexWhere((m) => m.id == message.id);
    if (idx == -1) return false;
    final updated = List<PortalMessage>.of(_messages)..[idx] = message;
    _messages
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    final before = _messages.length;
    _messages.removeWhere((m) => m.id == messageId);
    return _messages.length < before;
  }

  // ── ClientQuery ──────────────────────────────────────────────────────────

  @override
  Future<List<ClientQuery>> getQueriesByClient(String clientId) async {
    return List.unmodifiable(
      _queries.where((q) => q.clientId == clientId).toList(),
    );
  }

  @override
  Future<ClientQuery?> getClientQueryById(String queryId) async {
    try {
      return _queries.firstWhere((q) => q.id == queryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertClientQuery(ClientQuery query) async {
    _queries.add(query);
    return query.id;
  }

  @override
  Future<bool> updateClientQuery(ClientQuery query) async {
    final idx = _queries.indexWhere((q) => q.id == query.id);
    if (idx == -1) return false;
    final updated = List<ClientQuery>.of(_queries)..[idx] = query;
    _queries
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteClientQuery(String queryId) async {
    final before = _queries.length;
    _queries.removeWhere((q) => q.id == queryId);
    return _queries.length < before;
  }
}
