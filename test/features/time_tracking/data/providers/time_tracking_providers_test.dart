import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/time_tracking/data/providers/time_tracking_providers.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

void main() {
  group('ActiveTimerNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is idle (not running)', () {
      final state = container.read(activeTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.elapsedSeconds, 0);
    });

    test('start sets isRunning to true', () {
      container.read(activeTimerProvider.notifier).start(
            clientName: 'Test Client',
            taskDescription: 'Test Task',
            billingRate: 2000,
          );
      final state = container.read(activeTimerProvider);
      expect(state.isRunning, isTrue);
      expect(state.clientName, 'Test Client');
    });

    test('pause sets isRunning to false', () {
      container.read(activeTimerProvider.notifier).start(
            clientName: 'Test Client',
            taskDescription: 'Test',
            billingRate: 1500,
          );
      container.read(activeTimerProvider.notifier).pause();
      expect(container.read(activeTimerProvider).isRunning, isFalse);
    });

    test('stop resets to idle', () {
      container.read(activeTimerProvider.notifier).start(
            clientName: 'Test Client',
            taskDescription: 'Test',
            billingRate: 1500,
          );
      container.read(activeTimerProvider.notifier).stop();
      final state = container.read(activeTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.elapsedSeconds, 0);
    });
  });

  group('RunningTimerNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has mock active timer', () {
      final state = container.read(runningTimerProvider);
      expect(state.isRunning, isTrue);
    });

    test('pause sets isRunning to false', () {
      container.read(runningTimerProvider.notifier).pause();
      expect(container.read(runningTimerProvider).isRunning, isFalse);
    });

    test('stop resets to no entry', () {
      container.read(runningTimerProvider.notifier).stop();
      expect(container.read(runningTimerProvider).entryId, isNull);
    });
  });

  group('TimeEntryFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial filter is today', () {
      expect(container.read(timeEntryFilterProvider), TimeEntryFilter.today);
    });

    test('can be set to all', () {
      container.read(timeEntryFilterProvider.notifier).update(TimeEntryFilter.all);
      expect(container.read(timeEntryFilterProvider), TimeEntryFilter.all);
    });

    test('can be set to billable', () {
      container
          .read(timeEntryFilterProvider.notifier)
          .update(TimeEntryFilter.billable);
      expect(container.read(timeEntryFilterProvider), TimeEntryFilter.billable);
    });
  });

  group('TimeEntriesNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 15 mock entries', () {
      final entries = container.read(timeEntriesProvider);
      expect(entries.length, 15);
    });

    test('all entries have non-empty ids', () {
      final entries = container.read(timeEntriesProvider);
      expect(entries.every((e) => e.id.isNotEmpty), isTrue);
    });

    test('addEntry prepends to list', () {
      final before = container.read(timeEntriesProvider).length;
      final newEntry = TimeEntry(
        id: 'te-test',
        staffId: 'staff-01',
        staffName: 'Test Staff',
        clientId: '1',
        clientName: 'Test Client',
        taskDescription: 'Test Task',
        startTime: DateTime.now(),
        durationMinutes: 60,
        isBillable: true,
        hourlyRate: 2000,
        billedAmount: 2000,
        status: TimeEntryStatus.completed,
      );
      container.read(timeEntriesProvider.notifier).addEntry(newEntry);
      expect(container.read(timeEntriesProvider).length, before + 1);
      expect(container.read(timeEntriesProvider).first.id, 'te-test');
    });
  });

  group('billingSummariesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 8 billing summaries', () {
      final summaries = container.read(billingSummariesProvider);
      expect(summaries.length, 8);
    });

    test('all summaries have non-empty clientIds', () {
      final summaries = container.read(billingSummariesProvider);
      expect(summaries.every((s) => s.clientId.isNotEmpty), isTrue);
    });
  });
}
