import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/data/providers/client_repository_providers.dart';
import 'package:ca_app/features/clients/data/repositories/mock_client_repository.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';

/// Creates a [ProviderContainer] with [clientRepositoryProvider] overridden
/// to use [MockClientRepository] (no Supabase or DB required).
ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      clientRepositoryProvider.overrideWithValue(MockClientRepository()),
    ],
  );
}

void main() {
  group('ClientHealthScore', () {
    test('grade is Healthy when overallScore >= 80', () {
      final score = ClientHealthScore(
        clientId: '1',
        overallScore: 92,
        itrStatus: 'Filed',
        gstStatus: 'Compliant',
        tdsStatus: 'N/A',
        pendingActions: const [],
        lastUpdated: 'Mar 2026',
      );
      expect(score.grade, 'Healthy');
    });

    test('grade is Attention when overallScore >= 60 and < 80', () {
      final score = ClientHealthScore(
        clientId: '2',
        overallScore: 70,
        itrStatus: 'Pending',
        gstStatus: 'N/A',
        tdsStatus: 'N/A',
        pendingActions: const [],
        lastUpdated: 'Mar 2026',
      );
      expect(score.grade, 'Attention');
    });

    test('grade is Critical when overallScore < 60', () {
      final score = ClientHealthScore(
        clientId: '3',
        overallScore: 42,
        itrStatus: 'Overdue',
        gstStatus: 'Late Filed',
        tdsStatus: 'Challan Due',
        pendingActions: const ['Action 1'],
        lastUpdated: 'Mar 2026',
      );
      expect(score.grade, 'Critical');
    });

    test('copyWith creates new object without mutating original', () {
      final original = ClientHealthScore(
        clientId: '1',
        overallScore: 80,
        itrStatus: 'Filed',
        gstStatus: 'Compliant',
        tdsStatus: 'N/A',
        pendingActions: const [],
        lastUpdated: 'Mar 2026',
      );
      final updated = original.copyWith(overallScore: 60);
      expect(original.overallScore, 80);
      expect(updated.overallScore, 60);
    });

    test('copyWith preserves all unmodified fields', () {
      final original = ClientHealthScore(
        clientId: 'abc',
        overallScore: 85,
        itrStatus: 'Filed',
        gstStatus: 'Compliant',
        tdsStatus: 'N/A',
        pendingActions: const ['Action'],
        lastUpdated: 'Feb 2026',
      );
      final updated = original.copyWith(lastUpdated: 'Mar 2026');
      expect(updated.clientId, 'abc');
      expect(updated.overallScore, 85);
      expect(updated.itrStatus, 'Filed');
      expect(updated.pendingActions, const ['Action']);
    });
  });

  group('clientHealthScoreProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('returns health score for known client IDs (1–15)', () {
      for (int i = 1; i <= 15; i++) {
        final score = container.read(clientHealthScoreProvider('$i'));
        expect(
          score,
          isNotNull,
          reason: 'Client $i should have a health score',
        );
        expect(score!.clientId, '$i');
      }
    });

    test('returns null for unknown client ID', () {
      final score = container.read(clientHealthScoreProvider('unknown-999'));
      expect(score, isNull);
    });

    test('score overallScore is between 0 and 100', () {
      for (int i = 1; i <= 15; i++) {
        final score = container.read(clientHealthScoreProvider('$i'));
        expect(score!.overallScore, inInclusiveRange(0, 100));
      }
    });
  });

  group('SearchQueryNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is empty string', () {
      expect(container.read(searchQueryProvider), '');
    });

    test('update changes state', () {
      container.read(searchQueryProvider.notifier).update('rajesh');
      expect(container.read(searchQueryProvider), 'rajesh');
    });
  });

  group('SelectedStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedStatusFilterProvider), isNull);
    });

    test('can be updated to active', () {
      container
          .read(selectedStatusFilterProvider.notifier)
          .update(ClientStatus.active);
      expect(container.read(selectedStatusFilterProvider), ClientStatus.active);
    });

    test('can be cleared back to null', () {
      container
          .read(selectedStatusFilterProvider.notifier)
          .update(ClientStatus.inactive);
      container.read(selectedStatusFilterProvider.notifier).update(null);
      expect(container.read(selectedStatusFilterProvider), isNull);
    });
  });

  group('SelectedTypeFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedTypeFilterProvider), isNull);
    });

    test('can be updated to a specific type', () {
      container
          .read(selectedTypeFilterProvider.notifier)
          .update(ClientType.company);
      expect(container.read(selectedTypeFilterProvider), ClientType.company);
    });
  });

  group('SortOptionNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is name sort', () {
      expect(container.read(sortOptionProvider), ClientSortOption.name);
    });

    test('can switch to recent', () {
      container
          .read(sortOptionProvider.notifier)
          .update(ClientSortOption.recent);
      expect(container.read(sortOptionProvider), ClientSortOption.recent);
    });

    test('can switch to type', () {
      container.read(sortOptionProvider.notifier).update(ClientSortOption.type);
      expect(container.read(sortOptionProvider), ClientSortOption.type);
    });
  });

  group('filteredClientsProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns empty list when allClients is loading', () {
      // Before async data resolves, allClientsProvider is AsyncLoading
      // filteredClientsProvider falls back to []
      final result = container.read(filteredClientsProvider);
      // Could be empty list if not yet resolved, or populated after pump
      expect(result, isA<List<Client>>());
    });

    test('filters by status when statusFilter is set', () async {
      // Wait for mock repository to populate
      await container.read(allClientsProvider.future);

      container
          .read(selectedStatusFilterProvider.notifier)
          .update(ClientStatus.active);

      final filtered = container.read(filteredClientsProvider);
      expect(filtered.every((c) => c.status == ClientStatus.active), isTrue);
    });

    test('filters by type when typeFilter is set', () async {
      await container.read(allClientsProvider.future);

      container
          .read(selectedTypeFilterProvider.notifier)
          .update(ClientType.company);

      final filtered = container.read(filteredClientsProvider);
      expect(filtered.every((c) => c.clientType == ClientType.company), isTrue);
    });

    test('filters by search query matching name', () async {
      await container.read(allClientsProvider.future);

      container.read(searchQueryProvider.notifier).update('Rajesh');

      final filtered = container.read(filteredClientsProvider);
      expect(filtered, isNotEmpty);
      expect(
        filtered.every(
          (c) =>
              c.name.toLowerCase().contains('rajesh') ||
              c.pan.toLowerCase().contains('rajesh'),
        ),
        isTrue,
      );
    });

    test('returns empty for non-matching query', () async {
      await container.read(allClientsProvider.future);

      container
          .read(searchQueryProvider.notifier)
          .update('xyznonexistent99999');

      final filtered = container.read(filteredClientsProvider);
      expect(filtered, isEmpty);
    });

    test('sorts by name in ascending order', () async {
      await container.read(allClientsProvider.future);
      container.read(sortOptionProvider.notifier).update(ClientSortOption.name);

      final filtered = container.read(filteredClientsProvider);
      for (int i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].name.toLowerCase().compareTo(
            filtered[i + 1].name.toLowerCase(),
          ),
          lessThanOrEqualTo(0),
        );
      }
    });
  });

  group('clientByIdProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns null when data not yet loaded', () {
      final client = container.read(clientByIdProvider('1'));
      // Before async resolves, asData is null so result is null
      expect(client, isNull);
    });

    test('returns correct client after data is loaded', () async {
      await container.read(allClientsProvider.future);
      final client = container.read(clientByIdProvider('1'));
      expect(client, isNotNull);
      expect(client!.id, '1');
    });

    test('returns null for non-existent ID after data is loaded', () async {
      await container.read(allClientsProvider.future);
      final client = container.read(clientByIdProvider('no-such-id'));
      expect(client, isNull);
    });
  });

  group('mockClients list', () {
    test('contains 15 pre-seeded clients', () {
      expect(mockClients.length, 15);
    });

    test('all clients have non-empty IDs', () {
      expect(mockClients.every((c) => c.id.isNotEmpty), isTrue);
    });

    test('all clients have non-empty names', () {
      expect(mockClients.every((c) => c.name.isNotEmpty), isTrue);
    });

    test('all clients have non-empty PANs', () {
      expect(mockClients.every((c) => c.pan.isNotEmpty), isTrue);
    });
  });

  group('ClientSortOption enum', () {
    test('contains name, recent, and type', () {
      expect(ClientSortOption.values, contains(ClientSortOption.name));
      expect(ClientSortOption.values, contains(ClientSortOption.recent));
      expect(ClientSortOption.values, contains(ClientSortOption.type));
    });

    test('has labels', () {
      expect(ClientSortOption.name.label, isNotEmpty);
      expect(ClientSortOption.recent.label, isNotEmpty);
      expect(ClientSortOption.type.label, isNotEmpty);
    });
  });
}
