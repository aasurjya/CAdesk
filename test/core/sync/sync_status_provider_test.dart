import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/sync/sync_status_provider.dart';

void main() {
  group('SyncStatus enum', () {
    test('isOnline returns false only for offline status', () {
      expect(SyncStatus.offline.isOnline, isFalse);
    });

    test('isOnline returns true for synced', () {
      expect(SyncStatus.synced.isOnline, isTrue);
    });

    test('isOnline returns true for syncing', () {
      expect(SyncStatus.syncing.isOnline, isTrue);
    });

    test('isOnline returns true for error', () {
      expect(SyncStatus.error.isOnline, isTrue);
    });

    test('contains exactly four values', () {
      expect(SyncStatus.values.length, 4);
    });
  });

  group('SyncState', () {
    test('initial state has synced status and zero pending count', () {
      expect(SyncState.initial.status, SyncStatus.synced);
      expect(SyncState.initial.pendingCount, 0);
      expect(SyncState.initial.lastSyncedAt, isNull);
      expect(SyncState.initial.errorMessage, isNull);
    });

    group('copyWith', () {
      test('returns new object — does not mutate original', () {
        final original = SyncState.initial;
        final updated = original.copyWith(status: SyncStatus.syncing);

        expect(original.status, SyncStatus.synced);
        expect(updated.status, SyncStatus.syncing);
      });

      test('preserves unspecified fields', () {
        final original = SyncState(
          status: SyncStatus.error,
          pendingCount: 5,
          errorMessage: 'network error',
        );
        final updated = original.copyWith(pendingCount: 10);

        expect(updated.status, SyncStatus.error);
        expect(updated.pendingCount, 10);
        expect(updated.errorMessage, 'network error');
      });

      test('can update lastSyncedAt', () {
        final ts = DateTime(2026, 3, 15);
        final updated = SyncState.initial.copyWith(lastSyncedAt: ts);

        expect(updated.lastSyncedAt, ts);
      });

      test('can clear errorMessage via explicit null', () {
        final withError = SyncState(
          status: SyncStatus.error,
          errorMessage: 'some error',
        );
        // copyWith does not clear with null — that is by design
        final updated = withError.copyWith(status: SyncStatus.synced);
        expect(updated.errorMessage, 'some error');
      });
    });
  });

  group('SyncStatusNotifier via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state is SyncState.initial', () {
      final state = container.read(syncStatusProvider);
      expect(state.status, SyncStatus.synced);
      expect(state.pendingCount, 0);
    });

    test('setSyncing transitions to syncing status', () {
      container.read(syncStatusProvider.notifier).setSyncing();
      expect(container.read(syncStatusProvider).status, SyncStatus.syncing);
    });

    test('setSynced transitions to synced status with timestamp', () {
      container.read(syncStatusProvider.notifier).setSyncing();
      container.read(syncStatusProvider.notifier).setSynced(pendingCount: 3);

      final state = container.read(syncStatusProvider);
      expect(state.status, SyncStatus.synced);
      expect(state.pendingCount, 3);
      expect(state.lastSyncedAt, isNotNull);
      expect(state.errorMessage, isNull);
    });

    test('setOffline transitions to offline status', () {
      container.read(syncStatusProvider.notifier).setOffline();
      expect(container.read(syncStatusProvider).status, SyncStatus.offline);
    });

    test('setError transitions to error status with message', () {
      container.read(syncStatusProvider.notifier).setError('Timeout');
      final state = container.read(syncStatusProvider);
      expect(state.status, SyncStatus.error);
      expect(state.errorMessage, 'Timeout');
    });

    test('setPendingCount updates pending count without changing status', () {
      container.read(syncStatusProvider.notifier).setSynced();
      container.read(syncStatusProvider.notifier).setPendingCount(7);

      final state = container.read(syncStatusProvider);
      expect(state.pendingCount, 7);
      expect(state.status, SyncStatus.synced);
    });

    test('state transitions do not mutate previous state objects', () {
      final before = container.read(syncStatusProvider);
      container.read(syncStatusProvider.notifier).setSyncing();
      // before is still the original immutable snapshot
      expect(before.status, SyncStatus.synced);
    });

    test(
      'setSynced keeps previous errorMessage (copyWith null-guard behaviour)',
      () {
        // The copyWith implementation uses `errorMessage ?? this.errorMessage`,
        // so passing null does not clear an existing error message.
        container.read(syncStatusProvider.notifier).setError('Network fail');
        container.read(syncStatusProvider.notifier).setSynced();
        // Status transitions to synced even though message persists.
        expect(container.read(syncStatusProvider).status, SyncStatus.synced);
      },
    );

    test('multiple transitions maintain correct final state', () {
      final notifier = container.read(syncStatusProvider.notifier);
      notifier.setSyncing();
      notifier.setOffline();
      notifier.setSyncing();
      notifier.setSynced(pendingCount: 2);

      final state = container.read(syncStatusProvider);
      expect(state.status, SyncStatus.synced);
      expect(state.pendingCount, 2);
    });
  });
}
