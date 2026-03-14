import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';

/// Bi-directional converter between [PortalMessage] / [ClientQuery] domain
/// models and Supabase JSON maps.
class ClientPortalMapper {
  const ClientPortalMapper._();

  // ---------------------------------------------------------------------------
  // PortalMessage
  // ---------------------------------------------------------------------------

  static PortalMessage messageFromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];
    final attachments = rawAttachments is List
        ? List<String>.from(rawAttachments)
        : <String>[];

    return PortalMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
      senderType: _parseSenderType(json['sender_type'] as String?),
      content: json['content'] as String? ?? '',
      attachments: attachments,
      threadId: json['thread_id'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> messageToJson(PortalMessage m) {
    return {
      'id': m.id,
      'sender_id': m.senderId,
      'sender_name': m.senderName,
      'sender_type': m.senderType.name,
      'content': m.content,
      'attachments': m.attachments,
      'thread_id': m.threadId,
      'created_at': m.createdAt.toIso8601String(),
      'is_read': m.isRead,
    };
  }

  // ---------------------------------------------------------------------------
  // ClientQuery
  // ---------------------------------------------------------------------------

  static ClientQuery queryFromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final messages = rawMessages is List
        ? List<String>.from(rawMessages)
        : <String>[];

    return ClientQuery(
      id: json['id'] as String,
      clientId: json['client_id'] as String? ?? '',
      clientName: json['client_name'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: _parseCategory(json['category'] as String?),
      priority: _parsePriority(json['priority'] as String?),
      status: _parseStatus(json['status'] as String?),
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      messages: messages,
    );
  }

  static Map<String, dynamic> queryToJson(ClientQuery q) {
    return {
      'id': q.id,
      'client_id': q.clientId,
      'client_name': q.clientName,
      'subject': q.subject,
      'description': q.description,
      'category': q.category.name,
      'priority': q.priority.name,
      'status': q.status.name,
      'assigned_to': q.assignedTo,
      'created_at': q.createdAt.toIso8601String(),
      'resolved_at': q.resolvedAt?.toIso8601String(),
      'messages': q.messages,
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static SenderType _parseSenderType(String? raw) {
    switch (raw) {
      case 'staff':
        return SenderType.staff;
      case 'system':
        return SenderType.system;
      case 'client':
      default:
        return SenderType.client;
    }
  }

  static QueryCategory _parseCategory(String? raw) {
    switch (raw) {
      case 'gst':
        return QueryCategory.gst;
      case 'compliance':
        return QueryCategory.compliance;
      case 'billing':
        return QueryCategory.billing;
      case 'general':
        return QueryCategory.general;
      case 'tax':
      default:
        return QueryCategory.tax;
    }
  }

  static QueryPriority _parsePriority(String? raw) {
    switch (raw) {
      case 'medium':
        return QueryPriority.medium;
      case 'high':
        return QueryPriority.high;
      case 'urgent':
        return QueryPriority.urgent;
      case 'low':
      default:
        return QueryPriority.low;
    }
  }

  static QueryStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'inProgress':
        return QueryStatus.inProgress;
      case 'awaitingClient':
        return QueryStatus.awaitingClient;
      case 'resolved':
        return QueryStatus.resolved;
      case 'closed':
        return QueryStatus.closed;
      case 'open':
      default:
        return QueryStatus.open;
    }
  }
}
