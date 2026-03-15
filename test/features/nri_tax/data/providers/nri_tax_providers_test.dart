import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/nri_tax/data/providers/nri_tax_providers.dart';
import 'package:ca_app/features/nri_tax/domain/models/nri_client.dart';

void main() {
  group('allNriClientsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 8 mock NRI clients', () {
      final clients = container.read(allNriClientsProvider);
      expect(clients.length, 8);
    });

    test('all clients have non-empty ids', () {
      final clients = container.read(allNriClientsProvider);
      expect(clients.every((c) => c.id.isNotEmpty), isTrue);
    });

    test('all clients have non-empty PANs', () {
      final clients = container.read(allNriClientsProvider);
      expect(clients.every((c) => c.pan.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final clients = container.read(allNriClientsProvider);
      expect(() => (clients as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('allForeignAssetsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 10 mock foreign assets', () {
      final assets = container.read(allForeignAssetsProvider);
      expect(assets.length, 10);
    });

    test('all assets have non-empty ids', () {
      final assets = container.read(allForeignAssetsProvider);
      expect(assets.every((a) => a.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final assets = container.read(allForeignAssetsProvider);
      expect(() => (assets as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('NriStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(nriStatusFilterProvider), isNull);
    });

    test('can be set to filingDue', () {
      container
          .read(nriStatusFilterProvider.notifier)
          .update(NriClientStatus.filingDue);
      expect(
        container.read(nriStatusFilterProvider),
        NriClientStatus.filingDue,
      );
    });

    test('can be set to pendingDocuments', () {
      container
          .read(nriStatusFilterProvider.notifier)
          .update(NriClientStatus.pendingDocuments);
      expect(
        container.read(nriStatusFilterProvider),
        NriClientStatus.pendingDocuments,
      );
    });

    test('can be reset to null', () {
      container
          .read(nriStatusFilterProvider.notifier)
          .update(NriClientStatus.active);
      container.read(nriStatusFilterProvider.notifier).update(null);
      expect(container.read(nriStatusFilterProvider), isNull);
    });
  });

  group('filteredNriClientsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all clients when no filter', () {
      final all = container.read(allNriClientsProvider);
      final filtered = container.read(filteredNriClientsProvider);
      expect(filtered.length, all.length);
    });

    test('filingDue filter returns only filingDue clients', () {
      container
          .read(nriStatusFilterProvider.notifier)
          .update(NriClientStatus.filingDue);
      final filtered = container.read(filteredNriClientsProvider);
      expect(
        filtered.every((c) => c.status == NriClientStatus.filingDue),
        isTrue,
      );
    });

    test('completed filter returns only completed clients', () {
      container
          .read(nriStatusFilterProvider.notifier)
          .update(NriClientStatus.completed);
      final filtered = container.read(filteredNriClientsProvider);
      expect(
        filtered.every((c) => c.status == NriClientStatus.completed),
        isTrue,
      );
    });

    test('filtered list is subset of all clients', () {
      container
          .read(nriStatusFilterProvider.notifier)
          .update(NriClientStatus.active);
      final all = container.read(allNriClientsProvider);
      final filtered = container.read(filteredNriClientsProvider);
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });
  });

  group('nriSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('contains required keys', () {
      final summary = container.read(nriSummaryProvider);
      expect(summary.containsKey('totalClients'), isTrue);
      expect(summary.containsKey('dtaaApplicable'), isTrue);
      expect(summary.containsKey('pendingDocuments'), isTrue);
      expect(summary.containsKey('filingDue'), isTrue);
    });

    test('totalClients matches client count', () {
      final clients = container.read(allNriClientsProvider);
      final summary = container.read(nriSummaryProvider);
      expect(summary['totalClients'], clients.length);
    });

    test('all counts are non-negative', () {
      final summary = container.read(nriSummaryProvider);
      expect(summary['totalClients'], greaterThanOrEqualTo(0));
      expect(summary['dtaaApplicable'], greaterThanOrEqualTo(0));
      expect(summary['pendingDocuments'], greaterThanOrEqualTo(0));
      expect(summary['filingDue'], greaterThanOrEqualTo(0));
    });

    test('dtaaApplicable count does not exceed totalClients', () {
      final summary = container.read(nriSummaryProvider);
      expect(
        summary['dtaaApplicable']!,
        lessThanOrEqualTo(summary['totalClients']!),
      );
    });
  });
}
