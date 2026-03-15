import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/data/providers/client_portal_providers.dart';
import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_notification.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document_ui.dart';

void main() {
  group('Client Portal Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // allMessagesProvider
    // -------------------------------------------------------------------------
    group('allMessagesProvider', () {
      test('initial state is non-empty list', () {
        final messages = container.read(allMessagesProvider);
        expect(messages, isNotEmpty);
        expect(messages.length, greaterThanOrEqualTo(10));
      });

      test('all items are PortalMessage objects', () {
        final messages = container.read(allMessagesProvider);
        expect(messages, everyElement(isA<PortalMessage>()));
      });

      test('update() replaces the message list', () {
        final messages = container.read(allMessagesProvider);
        final subset = messages.take(3).toList();
        container.read(allMessagesProvider.notifier).update(subset);
        expect(container.read(allMessagesProvider).length, 3);
      });

      test('messages span multiple threads', () {
        final messages = container.read(allMessagesProvider);
        final threads = messages.map((m) => m.threadId).toSet();
        expect(threads.length, greaterThanOrEqualTo(3));
      });

      test('messages include different sender types', () {
        final messages = container.read(allMessagesProvider);
        final senderTypes = messages.map((m) => m.senderType).toSet();
        expect(senderTypes.length, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // selectedThreadProvider
    // -------------------------------------------------------------------------
    group('selectedThreadProvider', () {
      test('initial state is null', () {
        expect(container.read(selectedThreadProvider), isNull);
      });

      test('can be set to a thread id', () {
        container.read(selectedThreadProvider.notifier).update('thread-1');
        expect(container.read(selectedThreadProvider), 'thread-1');
      });

      test('can be cleared', () {
        container.read(selectedThreadProvider.notifier).update('thread-2');
        container.read(selectedThreadProvider.notifier).update(null);
        expect(container.read(selectedThreadProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // threadIdsProvider
    // -------------------------------------------------------------------------
    group('threadIdsProvider', () {
      test('returns list of unique thread ids', () {
        final threadIds = container.read(threadIdsProvider);
        expect(threadIds, isNotEmpty);
        // Check no duplicates
        expect(threadIds.toSet().length, threadIds.length);
      });

      test('thread count matches distinct threads in messages', () {
        final messages = container.read(allMessagesProvider);
        final expected = messages.map((m) => m.threadId).toSet().length;
        final threadIds = container.read(threadIdsProvider);
        expect(threadIds.length, expected);
      });

      test('is unmodifiable', () {
        final threadIds = container.read(threadIdsProvider);
        expect(
          () => threadIds.add('new-thread'),
          throwsA(anything),
        );
      });
    });

    // -------------------------------------------------------------------------
    // messagesByThreadProvider
    // -------------------------------------------------------------------------
    group('messagesByThreadProvider', () {
      test('returns messages for a specific thread', () {
        final allMessages = container.read(allMessagesProvider);
        final threadId = allMessages.first.threadId;
        final threadMessages =
            container.read(messagesByThreadProvider(threadId));
        expect(threadMessages, isNotEmpty);
        expect(
          threadMessages.every((m) => m.threadId == threadId),
          isTrue,
        );
      });

      test('messages are sorted by createdAt ascending', () {
        final allMessages = container.read(allMessagesProvider);
        final threadId = allMessages.first.threadId;
        final threadMessages =
            container.read(messagesByThreadProvider(threadId));
        for (int i = 0; i < threadMessages.length - 1; i++) {
          expect(
            threadMessages[i]
                .createdAt
                .isBefore(threadMessages[i + 1].createdAt) ||
                threadMessages[i]
                    .createdAt
                    .isAtSameMomentAs(threadMessages[i + 1].createdAt),
            isTrue,
          );
        }
      });

      test('returns empty list for unknown thread', () {
        final messages = container.read(messagesByThreadProvider('nonexistent'));
        expect(messages, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // allDocumentsProvider
    // -------------------------------------------------------------------------
    group('allDocumentsProvider', () {
      test('initial state is non-empty list', () {
        final docs = container.read(allDocumentsProvider);
        expect(docs, isNotEmpty);
        expect(docs.length, greaterThanOrEqualTo(5));
      });

      test('all items are SharedDocument objects', () {
        final docs = container.read(allDocumentsProvider);
        expect(docs, everyElement(isA<SharedDocument>()));
      });

      test('update() replaces the document list', () {
        final docs = container.read(allDocumentsProvider);
        final subset = docs.take(2).toList();
        container.read(allDocumentsProvider.notifier).update(subset);
        expect(container.read(allDocumentsProvider).length, 2);
      });

      test('documents have varied statuses', () {
        final docs = container.read(allDocumentsProvider);
        final statuses = docs.map((d) => d.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // documentFilterProvider
    // -------------------------------------------------------------------------
    group('documentFilterProvider', () {
      test('initial state is null (no filter)', () {
        expect(container.read(documentFilterProvider), isNull);
      });

      test('can be set to a DocumentStatus', () {
        container
            .read(documentFilterProvider.notifier)
            .update(DocumentStatus.eSigned);
        expect(
          container.read(documentFilterProvider),
          DocumentStatus.eSigned,
        );
      });

      test('can be cleared to null', () {
        container
            .read(documentFilterProvider.notifier)
            .update(DocumentStatus.shared);
        container.read(documentFilterProvider.notifier).update(null);
        expect(container.read(documentFilterProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // filteredDocumentsProvider
    // -------------------------------------------------------------------------
    group('filteredDocumentsProvider', () {
      test('returns all documents when filter is null', () {
        final all = container.read(allDocumentsProvider);
        final filtered = container.read(filteredDocumentsProvider);
        expect(filtered.length, all.length);
      });

      test('filters documents by eSigned status', () {
        container
            .read(documentFilterProvider.notifier)
            .update(DocumentStatus.eSigned);
        final filtered = container.read(filteredDocumentsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((d) => d.status == DocumentStatus.eSigned),
          isTrue,
        );
      });

      test('filters documents by shared status', () {
        container
            .read(documentFilterProvider.notifier)
            .update(DocumentStatus.shared);
        final filtered = container.read(filteredDocumentsProvider);
        expect(
          filtered.every((d) => d.status == DocumentStatus.shared),
          isTrue,
        );
      });

      test('clearing filter returns all documents', () {
        container
            .read(documentFilterProvider.notifier)
            .update(DocumentStatus.expired);
        container.read(documentFilterProvider.notifier).update(null);
        final all = container.read(allDocumentsProvider);
        final filtered = container.read(filteredDocumentsProvider);
        expect(filtered.length, all.length);
      });
    });

    // -------------------------------------------------------------------------
    // allQueriesProvider
    // -------------------------------------------------------------------------
    group('allQueriesProvider', () {
      test('initial state is non-empty list', () {
        final queries = container.read(allQueriesProvider);
        expect(queries, isNotEmpty);
        expect(queries.length, greaterThanOrEqualTo(4));
      });

      test('all items are ClientQuery objects', () {
        final queries = container.read(allQueriesProvider);
        expect(queries, everyElement(isA<ClientQuery>()));
      });

      test('queries span different categories', () {
        final queries = container.read(allQueriesProvider);
        final categories = queries.map((q) => q.category).toSet();
        expect(categories.length, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // queryStatusFilterProvider
    // -------------------------------------------------------------------------
    group('queryStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(queryStatusFilterProvider), isNull);
      });

      test('can be set to open status', () {
        container
            .read(queryStatusFilterProvider.notifier)
            .update(QueryStatus.open);
        expect(
          container.read(queryStatusFilterProvider),
          QueryStatus.open,
        );
      });

      test('can be set to resolved status', () {
        container
            .read(queryStatusFilterProvider.notifier)
            .update(QueryStatus.resolved);
        expect(
          container.read(queryStatusFilterProvider),
          QueryStatus.resolved,
        );
      });

      test('can be cleared to null', () {
        container
            .read(queryStatusFilterProvider.notifier)
            .update(QueryStatus.inProgress);
        container.read(queryStatusFilterProvider.notifier).update(null);
        expect(container.read(queryStatusFilterProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // filteredQueriesProvider
    // -------------------------------------------------------------------------
    group('filteredQueriesProvider', () {
      test('returns all queries when filter is null', () {
        final all = container.read(allQueriesProvider);
        final filtered = container.read(filteredQueriesProvider);
        expect(filtered.length, all.length);
      });

      test('filters queries by open status', () {
        container
            .read(queryStatusFilterProvider.notifier)
            .update(QueryStatus.open);
        final filtered = container.read(filteredQueriesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((q) => q.status == QueryStatus.open),
          isTrue,
        );
      });

      test('filters queries by resolved status', () {
        container
            .read(queryStatusFilterProvider.notifier)
            .update(QueryStatus.resolved);
        final filtered = container.read(filteredQueriesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((q) => q.status == QueryStatus.resolved),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // allNotificationsProvider
    // -------------------------------------------------------------------------
    group('allNotificationsProvider', () {
      test('initial state is non-empty list', () {
        final notifications = container.read(allNotificationsProvider);
        expect(notifications, isNotEmpty);
        expect(notifications.length, greaterThanOrEqualTo(8));
      });

      test('all items are PortalNotification objects', () {
        final notifications = container.read(allNotificationsProvider);
        expect(notifications, everyElement(isA<PortalNotification>()));
      });

      test('notifications include different channels', () {
        final notifications = container.read(allNotificationsProvider);
        final channels = notifications.map((n) => n.channel).toSet();
        expect(channels.length, greaterThanOrEqualTo(3));
      });
    });

    // -------------------------------------------------------------------------
    // unreadNotificationCountProvider
    // -------------------------------------------------------------------------
    group('unreadNotificationCountProvider', () {
      test('returns count of unread notifications', () {
        final notifications = container.read(allNotificationsProvider);
        final expectedUnread = notifications.where((n) => !n.isRead).length;
        final count = container.read(unreadNotificationCountProvider);
        expect(count, expectedUnread);
      });

      test('count is greater than zero (has unread items)', () {
        final count = container.read(unreadNotificationCountProvider);
        expect(count, greaterThan(0));
      });
    });

    // -------------------------------------------------------------------------
    // portalAutomationSummaryProvider
    // -------------------------------------------------------------------------
    group('portalAutomationSummaryProvider', () {
      test('returns map with followUps, magicLinks, pendingSignatures', () {
        final summary = container.read(portalAutomationSummaryProvider);
        expect(summary.containsKey('followUps'), isTrue);
        expect(summary.containsKey('magicLinks'), isTrue);
        expect(summary.containsKey('pendingSignatures'), isTrue);
      });

      test('pendingSignatures matches documents requiring e-sign but unsigned',
          () {
        final docs = container.read(allDocumentsProvider);
        final expected = docs.where((d) => d.requiresESign && !d.eSigned).length;
        final summary = container.read(portalAutomationSummaryProvider);
        expect(summary['pendingSignatures'], expected);
      });

      test('all summary values are non-negative', () {
        final summary = container.read(portalAutomationSummaryProvider);
        for (final value in summary.values) {
          expect(value, greaterThanOrEqualTo(0));
        }
      });
    });
  });
}
