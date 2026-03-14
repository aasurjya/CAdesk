import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';
import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/data/repositories/mock_client_portal_repository.dart';

void main() {
  group('MockClientPortalRepository', () {
    late MockClientPortalRepository repo;

    setUp(() {
      repo = MockClientPortalRepository();
    });

    // ── PortalMessage tests ──────────────────────────────────────────────────

    group('getMessagesByThread', () {
      test('returns seeded messages for thread-001', () async {
        final msgs = await repo.getMessagesByThread('thread-001');
        expect(msgs, isNotEmpty);
        expect(msgs.every((m) => m.threadId == 'thread-001'), isTrue);
      });

      test('returns empty list for unknown thread', () async {
        final msgs = await repo.getMessagesByThread('unknown-thread');
        expect(msgs, isEmpty);
      });
    });

    group('insertMessage', () {
      test('inserts and returns new message ID', () async {
        final msg = PortalMessage(
          id: 'new-msg-001',
          senderId: 'staff-001',
          senderName: 'CA Anil',
          senderType: SenderType.staff,
          content: 'Your ITR has been filed successfully.',
          threadId: 'thread-001',
          createdAt: DateTime(2026, 3, 10),
        );
        final id = await repo.insertMessage(msg);
        expect(id, 'new-msg-001');

        final fetched = await repo.getMessagesByThread('thread-001');
        expect(fetched.any((m) => m.id == 'new-msg-001'), isTrue);
      });
    });

    group('updateMessage', () {
      test('marks message as read', () async {
        final existing = (await repo.getMessagesByThread('thread-001')).first;
        final updated = existing.copyWith(isRead: true);
        final success = await repo.updateMessage(updated);
        expect(success, isTrue);
      });

      test('returns false for non-existent message', () async {
        final ghost = PortalMessage(
          id: 'ghost-msg',
          senderId: 's',
          senderName: 'Ghost',
          senderType: SenderType.system,
          content: 'Ghost',
          threadId: 'ghost-thread',
          createdAt: DateTime(2026, 1, 1),
        );
        final success = await repo.updateMessage(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteMessage', () {
      test('deletes message and returns true', () async {
        final id = await repo.insertMessage(
          PortalMessage(
            id: 'to-delete-msg',
            senderId: 'c',
            senderName: 'Client',
            senderType: SenderType.client,
            content: 'Delete me',
            threadId: 'thread-del',
            createdAt: DateTime(2026, 3, 1),
          ),
        );

        final success = await repo.deleteMessage(id);
        expect(success, isTrue);
      });

      test('returns false for non-existent message ID', () async {
        final success = await repo.deleteMessage('no-such-msg');
        expect(success, isFalse);
      });
    });

    // ── ClientQuery tests ────────────────────────────────────────────────────

    group('getQueriesByClient', () {
      test('returns seeded queries for mock-client-001', () async {
        final queries = await repo.getQueriesByClient('mock-client-001');
        expect(queries, isNotEmpty);
        expect(queries.every((q) => q.clientId == 'mock-client-001'), isTrue);
      });

      test('returns empty list for unknown client', () async {
        final queries = await repo.getQueriesByClient('unknown');
        expect(queries, isEmpty);
      });
    });

    group('insertClientQuery', () {
      test('inserts and returns new query ID', () async {
        final query = ClientQuery(
          id: 'new-cq-001',
          clientId: 'mock-client-001',
          clientName: 'Ravi Kumar',
          subject: 'TDS Refund Status',
          description: 'When will I receive my TDS refund?',
          category: QueryCategory.tax,
          priority: QueryPriority.medium,
          status: QueryStatus.open,
          createdAt: DateTime(2026, 3, 10),
        );
        final id = await repo.insertClientQuery(query);
        expect(id, 'new-cq-001');

        final fetched = await repo.getQueriesByClient('mock-client-001');
        expect(fetched.any((q) => q.id == 'new-cq-001'), isTrue);
      });
    });

    group('updateClientQuery', () {
      test('updates existing query status and returns true', () async {
        final all = await repo.getQueriesByClient('mock-client-001');
        expect(all, isNotEmpty);

        final existing = all.first;
        final updated = existing.copyWith(status: QueryStatus.resolved);
        final success = await repo.updateClientQuery(updated);
        expect(success, isTrue);
      });

      test('returns false for non-existent query', () async {
        final ghost = ClientQuery(
          id: 'ghost-cq',
          clientId: 'ghost',
          clientName: 'Ghost',
          subject: 'Ghost',
          description: 'Ghost',
          category: QueryCategory.general,
          priority: QueryPriority.low,
          status: QueryStatus.open,
          createdAt: DateTime(2026, 1, 1),
        );
        final success = await repo.updateClientQuery(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteClientQuery', () {
      test('deletes query and returns true', () async {
        final id = await repo.insertClientQuery(
          ClientQuery(
            id: 'to-delete-cq',
            clientId: 'client-del',
            clientName: 'Del Client',
            subject: 'Delete',
            description: 'Delete me',
            category: QueryCategory.billing,
            priority: QueryPriority.low,
            status: QueryStatus.open,
            createdAt: DateTime(2026, 3, 1),
          ),
        );

        final success = await repo.deleteClientQuery(id);
        expect(success, isTrue);
      });

      test('returns false for non-existent query ID', () async {
        final success = await repo.deleteClientQuery('no-such-cq');
        expect(success, isFalse);
      });
    });

    group('getAllMessages', () {
      test('returns all seeded messages', () async {
        final all = await repo.getAllMessages();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAllMessages();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });
  });
}
