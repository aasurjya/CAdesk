import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/data/mappers/client_portal_mapper.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';
import 'package:ca_app/features/client_portal/domain/models/client_query.dart';

void main() {
  group('ClientPortalMapper', () {
    // -------------------------------------------------------------------------
    // PortalMessage
    // -------------------------------------------------------------------------
    group('messageFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'msg-001',
          'sender_id': 'user-001',
          'sender_name': 'Ramesh Kumar',
          'sender_type': 'client',
          'content': 'Please share my ITR acknowledgement',
          'attachments': ['file1.pdf', 'file2.jpg'],
          'thread_id': 'thread-001',
          'created_at': '2025-09-01T10:00:00.000Z',
          'is_read': true,
        };

        final msg = ClientPortalMapper.messageFromJson(json);

        expect(msg.id, 'msg-001');
        expect(msg.senderId, 'user-001');
        expect(msg.senderName, 'Ramesh Kumar');
        expect(msg.senderType, SenderType.client);
        expect(msg.content, 'Please share my ITR acknowledgement');
        expect(msg.attachments, ['file1.pdf', 'file2.jpg']);
        expect(msg.threadId, 'thread-001');
        expect(msg.isRead, true);
      });

      test('handles empty attachments list', () {
        final json = {
          'id': 'msg-002',
          'sender_id': 'staff-001',
          'sender_name': 'CA Mehta',
          'sender_type': 'staff',
          'content': 'Here is your ITR-V acknowledgement',
          'attachments': <String>[],
          'thread_id': 'thread-001',
          'created_at': '2025-09-01T11:00:00.000Z',
          'is_read': false,
        };

        final msg = ClientPortalMapper.messageFromJson(json);
        expect(msg.attachments, isEmpty);
        expect(msg.isRead, false);
        expect(msg.senderType, SenderType.staff);
      });

      test('handles missing attachments field with empty list', () {
        final json = {
          'id': 'msg-003',
          'sender_id': 'sys',
          'sender_type': 'system',
          'content': 'Your filing is complete',
          'thread_id': 'thread-002',
          'created_at': '2025-09-01T12:00:00.000Z',
        };

        final msg = ClientPortalMapper.messageFromJson(json);
        expect(msg.attachments, isEmpty);
        expect(msg.senderType, SenderType.system);
      });

      test('defaults sender_type to client for unknown value', () {
        final json = {
          'id': 'msg-004',
          'sender_id': 's1',
          'sender_name': '',
          'sender_type': 'unknownSender',
          'content': '',
          'thread_id': 't1',
          'created_at': '2025-09-01T00:00:00.000Z',
        };

        final msg = ClientPortalMapper.messageFromJson(json);
        expect(msg.senderType, SenderType.client);
      });

      test('handles all SenderType values', () {
        for (final type in SenderType.values) {
          final json = {
            'id': 'msg-type-${type.name}',
            'sender_id': 's1',
            'sender_name': '',
            'sender_type': type.name,
            'content': '',
            'thread_id': 't1',
            'created_at': '2025-09-01T00:00:00.000Z',
          };
          final msg = ClientPortalMapper.messageFromJson(json);
          expect(msg.senderType, type);
        }
      });
    });

    group('messageToJson', () {
      late PortalMessage sampleMessage;

      setUp(() {
        sampleMessage = PortalMessage(
          id: 'msg-json-001',
          senderId: 'staff-json-001',
          senderName: 'CA Sharma',
          senderType: SenderType.staff,
          content: 'Your GST return has been filed successfully',
          attachments: const ['gstr3b_ack.pdf'],
          threadId: 'thread-json-001',
          createdAt: DateTime(2025, 9, 10, 15, 0),
          isRead: true,
        );
      });

      test('includes all fields', () {
        final json = ClientPortalMapper.messageToJson(sampleMessage);

        expect(json['id'], 'msg-json-001');
        expect(json['sender_id'], 'staff-json-001');
        expect(json['sender_name'], 'CA Sharma');
        expect(json['sender_type'], 'staff');
        expect(json['content'], 'Your GST return has been filed successfully');
        expect(json['attachments'], ['gstr3b_ack.pdf']);
        expect(json['thread_id'], 'thread-json-001');
        expect(json['is_read'], true);
      });

      test('round-trip messageFromJson(messageToJson) preserves all fields', () {
        final json = ClientPortalMapper.messageToJson(sampleMessage);
        final restored = ClientPortalMapper.messageFromJson(json);

        expect(restored.id, sampleMessage.id);
        expect(restored.senderType, sampleMessage.senderType);
        expect(restored.content, sampleMessage.content);
        expect(restored.attachments, sampleMessage.attachments);
        expect(restored.isRead, sampleMessage.isRead);
      });
    });

    // -------------------------------------------------------------------------
    // ClientQuery
    // -------------------------------------------------------------------------
    group('queryFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'query-001',
          'client_id': 'client-001',
          'client_name': 'Priya Singh',
          'subject': 'GST Notice received',
          'description': 'I received a notice for FY 2023-24, please advise',
          'category': 'gst',
          'priority': 'high',
          'status': 'inProgress',
          'assigned_to': 'ca-001',
          'created_at': '2025-09-01T00:00:00.000Z',
          'resolved_at': null,
          'messages': ['msg-001', 'msg-002'],
        };

        final query = ClientPortalMapper.queryFromJson(json);

        expect(query.id, 'query-001');
        expect(query.clientId, 'client-001');
        expect(query.clientName, 'Priya Singh');
        expect(query.subject, 'GST Notice received');
        expect(query.category, QueryCategory.gst);
        expect(query.priority, QueryPriority.high);
        expect(query.status, QueryStatus.inProgress);
        expect(query.assignedTo, 'ca-001');
        expect(query.messages, ['msg-001', 'msg-002']);
        expect(query.resolvedAt, isNull);
      });

      test('handles all QueryStatus values', () {
        for (final status in QueryStatus.values) {
          final json = {
            'id': 'query-status-${status.name}',
            'client_id': 'c1',
            'client_name': '',
            'subject': '',
            'description': '',
            'category': 'tax',
            'priority': 'low',
            'status': status.name,
            'created_at': '2025-09-01T00:00:00.000Z',
          };
          final query = ClientPortalMapper.queryFromJson(json);
          expect(query.status, status);
        }
      });
    });

    group('queryToJson', () {
      test('includes all fields and round-trips correctly', () {
        final query = ClientQuery(
          id: 'query-json-001',
          clientId: 'client-json-001',
          clientName: 'Test Client',
          subject: 'Tax query',
          description: 'Need help with Section 80C',
          category: QueryCategory.tax,
          priority: QueryPriority.medium,
          status: QueryStatus.open,
          createdAt: DateTime(2025, 9, 1),
          messages: const ['msg-a'],
        );

        final json = ClientPortalMapper.queryToJson(query);

        expect(json['id'], 'query-json-001');
        expect(json['category'], 'tax');
        expect(json['priority'], 'medium');
        expect(json['status'], 'open');
        expect(json['messages'], ['msg-a']);
        expect(json['resolved_at'], isNull);
        expect(json['assigned_to'], isNull);

        final restored = ClientPortalMapper.queryFromJson(json);
        expect(restored.id, query.id);
        expect(restored.category, query.category);
        expect(restored.status, query.status);
      });
    });
  });
}
