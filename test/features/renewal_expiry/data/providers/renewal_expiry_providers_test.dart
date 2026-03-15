import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/renewal_expiry/data/providers/renewal_expiry_providers.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/renewal_item.dart';

void main() {
  group('allRenewalItemsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 10 mock renewal items', () {
      final items = container.read(allRenewalItemsProvider);
      expect(items.length, 10);
    });

    test('all items have non-empty ids', () {
      final items = container.read(allRenewalItemsProvider);
      expect(items.every((i) => i.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final items = container.read(allRenewalItemsProvider);
      expect(() => (items as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('allRetainerContractsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 6 mock retainer contracts', () {
      final contracts = container.read(allRetainerContractsProvider);
      expect(contracts.length, 6);
    });

    test('all contracts have non-empty ids', () {
      final contracts = container.read(allRetainerContractsProvider);
      expect(contracts.every((c) => c.id.isNotEmpty), isTrue);
    });
  });

  group('RenewalStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(renewalStatusFilterProvider), isNull);
    });

    test('can be set to overdue', () {
      container
          .read(renewalStatusFilterProvider.notifier)
          .update(RenewalStatus.overdue);
      expect(
        container.read(renewalStatusFilterProvider),
        RenewalStatus.overdue,
      );
    });

    test('can be set to dueSoon', () {
      container
          .read(renewalStatusFilterProvider.notifier)
          .update(RenewalStatus.dueSoon);
      expect(
        container.read(renewalStatusFilterProvider),
        RenewalStatus.dueSoon,
      );
    });

    test('can be reset to null', () {
      container
          .read(renewalStatusFilterProvider.notifier)
          .update(RenewalStatus.overdue);
      container.read(renewalStatusFilterProvider.notifier).update(null);
      expect(container.read(renewalStatusFilterProvider), isNull);
    });
  });

  group('filteredRenewalItemsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all items when no filter', () {
      final all = container.read(allRenewalItemsProvider);
      final filtered = container.read(filteredRenewalItemsProvider);
      expect(filtered.length, all.length);
    });

    test('overdue filter returns only overdue items', () {
      container
          .read(renewalStatusFilterProvider.notifier)
          .update(RenewalStatus.overdue);
      final filtered = container.read(filteredRenewalItemsProvider);
      expect(
        filtered.every((i) => i.status == RenewalStatus.overdue),
        isTrue,
      );
    });

    test('upToDate filter returns only up-to-date items', () {
      container
          .read(renewalStatusFilterProvider.notifier)
          .update(RenewalStatus.upToDate);
      final filtered = container.read(filteredRenewalItemsProvider);
      expect(
        filtered.every((i) => i.status == RenewalStatus.upToDate),
        isTrue,
      );
    });
  });

  group('renewalSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('contains required keys', () {
      final summary = container.read(renewalSummaryProvider);
      expect(summary.containsKey('total'), isTrue);
      expect(summary.containsKey('overdue'), isTrue);
      expect(summary.containsKey('dueSoon'), isTrue);
      expect(summary.containsKey('upToDate'), isTrue);
    });

    test('total matches all renewal items count', () {
      final all = container.read(allRenewalItemsProvider);
      final summary = container.read(renewalSummaryProvider);
      expect(summary['total'], all.length);
    });

    test('overdue and dueSoon are non-negative', () {
      final summary = container.read(renewalSummaryProvider);
      expect(summary['overdue']!, greaterThanOrEqualTo(0));
      expect(summary['dueSoon']!, greaterThanOrEqualTo(0));
    });

    test('overdue + dueSoon + upToDate does not exceed total', () {
      final summary = container.read(renewalSummaryProvider);
      expect(
        summary['overdue']! + summary['dueSoon']! + summary['upToDate']!,
        lessThanOrEqualTo(summary['total']!),
      );
    });
  });
}
