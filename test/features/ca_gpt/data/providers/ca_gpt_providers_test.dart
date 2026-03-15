import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ca_gpt/data/providers/ca_gpt_providers.dart';
import 'package:ca_app/features/ca_gpt/domain/services/tax_calendar_service.dart';

void main() {
  group('CA GPT Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('chatMessagesProvider', () {
      test('initial state contains a welcome message', () {
        final messages = container.read(chatMessagesProvider);
        expect(messages, isNotEmpty);
        expect(messages.first.isUser, isFalse);
      });

      test('addMessage appends a message immutably', () {
        final before = container.read(chatMessagesProvider).length;
        final newMsg = ChatMessage(
          id: 'test-001',
          text: 'What is Section 44AB?',
          isUser: true,
          at: DateTime.now(),
        );
        container.read(chatMessagesProvider.notifier).addMessage(newMsg);
        final after = container.read(chatMessagesProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'test-001');
        expect(after.last.isUser, isTrue);
      });

      test('addMessage does not mutate previous state snapshot', () {
        final snapshot = container.read(chatMessagesProvider);
        final snapshotLength = snapshot.length;
        final newMsg = ChatMessage(
          id: 'test-002',
          text: 'Test question',
          isUser: true,
          at: DateTime.now(),
        );
        container.read(chatMessagesProvider.notifier).addMessage(newMsg);
        expect(snapshot.length, snapshotLength);
      });

      test('clearHistory empties the message list', () {
        final newMsg = ChatMessage(
          id: 'test-003',
          text: 'Anything',
          isUser: true,
          at: DateTime.now(),
        );
        container.read(chatMessagesProvider.notifier).addMessage(newMsg);
        container.read(chatMessagesProvider.notifier).clearHistory();
        expect(container.read(chatMessagesProvider), isEmpty);
      });
    });

    group('ChatMessage model', () {
      test('copyWith returns a new instance with updated fields', () {
        final original = ChatMessage(
          id: 'msg-1',
          text: 'Hello',
          isUser: false,
          at: DateTime(2026, 1, 1),
        );
        final updated = original.copyWith(text: 'Updated text');
        expect(updated.text, 'Updated text');
        expect(updated.id, 'msg-1');
        expect(updated.isUser, isFalse);
        // Original is unchanged
        expect(original.text, 'Hello');
      });
    });

    group('sectionSearchResultsProvider', () {
      test('initial state is empty list', () {
        final results = container.read(sectionSearchResultsProvider);
        expect(results, isEmpty);
      });

      test('update replaces the results list', () {
        container
            .read(sectionSearchResultsProvider.notifier)
            .update(const []);
        expect(container.read(sectionSearchResultsProvider), isEmpty);
      });
    });

    group('noticeDraftProvider', () {
      test('initial state is null', () {
        expect(container.read(noticeDraftProvider), isNull);
      });

      test('update sets the draft to null clears it', () {
        container.read(noticeDraftProvider.notifier).update(null);
        expect(container.read(noticeDraftProvider), isNull);
      });
    });

    group('calendarEventsProvider', () {
      test('initial state is non-empty', () {
        final events = container.read(calendarEventsProvider);
        expect(events, isNotEmpty);
      });

      test('loadYear reloads events for a different year', () {
        container.read(calendarEventsProvider.notifier).loadYear(2024);
        final events = container.read(calendarEventsProvider);
        expect(events, isNotEmpty);
      });

      test('events are TaxDeadline instances', () {
        final events = container.read(calendarEventsProvider);
        for (final e in events) {
          expect(e, isA<TaxDeadline>());
        }
      });
    });

    group('selectedCalendarMonthProvider', () {
      test('initial state is current year and month', () {
        final selected = container.read(selectedCalendarMonthProvider);
        final now = DateTime.now();
        expect(selected.year, now.year);
        expect(selected.month, now.month);
      });

      test('update changes the selected month', () {
        container
            .read(selectedCalendarMonthProvider.notifier)
            .update(DateTime(2025, 4));
        final selected = container.read(selectedCalendarMonthProvider);
        expect(selected.year, 2025);
        expect(selected.month, 4);
      });
    });

    group('placeholder service providers', () {
      test('sectionLookupProvider throws when read (not yet implemented)', () {
        // Riverpod wraps provider errors in ProviderException; any throw is acceptable.
        expect(() => container.read(sectionLookupProvider), throwsA(anything));
      });

      test('noticeDraftingProvider throws when read (not yet implemented)', () {
        expect(
          () => container.read(noticeDraftingProvider),
          throwsA(anything),
        );
      });

      test('taxCalendarServiceProvider throws when read (not yet implemented)', () {
        expect(
          () => container.read(taxCalendarServiceProvider),
          throwsA(anything),
        );
      });
    });
  });
}
