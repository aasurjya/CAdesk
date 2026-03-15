import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/industry_playbooks/data/providers/industry_playbooks_providers.dart';

void main() {
  group('allPlaybooksProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns exactly 10 playbooks', () {
      final playbooks = container.read(allPlaybooksProvider);
      expect(playbooks.length, 10);
    });

    test('all playbooks have non-empty ids', () {
      final playbooks = container.read(allPlaybooksProvider);
      expect(playbooks.every((p) => p.id.isNotEmpty), isTrue);
    });

    test('all playbooks have non-empty verticals', () {
      final playbooks = container.read(allPlaybooksProvider);
      expect(playbooks.every((p) => p.vertical.isNotEmpty), isTrue);
    });
  });

  group('allServiceBundlesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns exactly 8 service bundles', () {
      final bundles = container.read(allServiceBundlesProvider);
      expect(bundles.length, 8);
    });

    test('all bundles have non-empty ids', () {
      final bundles = container.read(allServiceBundlesProvider);
      expect(bundles.every((b) => b.id.isNotEmpty), isTrue);
    });

    test('all bundles have positive price', () {
      final bundles = container.read(allServiceBundlesProvider);
      expect(bundles.every((b) => b.pricePerMonth > 0), isTrue);
    });
  });

  group('SelectedVerticalNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedVerticalProvider), isNull);
    });

    test('can be updated to a vertical', () {
      container.read(selectedVerticalProvider.notifier).select('e-commerce');
      expect(container.read(selectedVerticalProvider), 'e-commerce');
    });

    test('can be reset to null', () {
      container.read(selectedVerticalProvider.notifier).select('doctors');
      container.read(selectedVerticalProvider.notifier).select(null);
      expect(container.read(selectedVerticalProvider), isNull);
    });
  });

  group('filteredPlaybooksProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all playbooks when no filter', () {
      final all = container.read(allPlaybooksProvider);
      final filtered = container.read(filteredPlaybooksProvider);
      expect(filtered.length, all.length);
    });

    test('returns only matching vertical', () {
      container.read(selectedVerticalProvider.notifier).select('doctors');
      final filtered = container.read(filteredPlaybooksProvider);
      expect(filtered.every((p) => p.vertical == 'doctors'), isTrue);
    });

    test('returns empty for unknown vertical', () {
      container.read(selectedVerticalProvider.notifier).select('nonexistent');
      final filtered = container.read(filteredPlaybooksProvider);
      expect(filtered, isEmpty);
    });

    test('clearing filter restores all results', () {
      container.read(selectedVerticalProvider.notifier).select('saas');
      container.read(selectedVerticalProvider.notifier).select(null);
      final all = container.read(allPlaybooksProvider);
      final filtered = container.read(filteredPlaybooksProvider);
      expect(filtered.length, all.length);
    });
  });

  group('bundlesForVerticalProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns bundles only for requested vertical', () {
      final bundles = container.read(
        bundlesForVerticalProvider('vp-ecommerce'),
      );
      expect(bundles.every((b) => b.verticalId == 'vp-ecommerce'), isTrue);
    });

    test('returns non-empty list for vp-ecommerce', () {
      final bundles = container.read(
        bundlesForVerticalProvider('vp-ecommerce'),
      );
      expect(bundles, isNotEmpty);
    });

    test('returns empty for unknown vertical', () {
      final bundles = container.read(
        bundlesForVerticalProvider('vp-unknown-999'),
      );
      expect(bundles, isEmpty);
    });
  });
}
