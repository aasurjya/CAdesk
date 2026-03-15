import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca/data/providers/mca_providers.dart';
import 'package:ca_app/features/mca/data/providers/mca_repository_providers.dart';
import 'package:ca_app/features/mca/data/repositories/mock_mca_repository.dart';
import 'package:ca_app/features/mca/domain/models/mca_filing.dart';

ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      mcaRepositoryProvider.overrideWithValue(MockMcaRepository()),
    ],
  );
}

void main() {
  group('McaCompaniesNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('loads 8 mock companies', () async {
      final companies = await container.read(mcaCompaniesProvider.future);
      expect(companies.length, 8);
    });

    test('all companies have non-empty CINs', () async {
      final companies = await container.read(mcaCompaniesProvider.future);
      expect(companies.every((c) => c.cin.isNotEmpty), isTrue);
    });
  });

  group('McaFilingsNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('loads 20 mock filings', () async {
      final filings = await container.read(mcaFilingsProvider.future);
      expect(filings.length, 20);
    });

    test('all filings have non-empty ids', () async {
      final filings = await container.read(mcaFilingsProvider.future);
      expect(filings.every((f) => f.id.isNotEmpty), isTrue);
    });
  });

  group('McaStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(mcaStatusFilterProvider), isNull);
    });

    test('can be set to approved', () {
      container
          .read(mcaStatusFilterProvider.notifier)
          .update(McaFilingStatus.approved);
      expect(container.read(mcaStatusFilterProvider), McaFilingStatus.approved);
    });

    test('can be cleared to null', () {
      container
          .read(mcaStatusFilterProvider.notifier)
          .update(McaFilingStatus.pending);
      container.read(mcaStatusFilterProvider.notifier).update(null);
      expect(container.read(mcaStatusFilterProvider), isNull);
    });
  });

  group('McaFormTypeFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(mcaFormTypeFilterProvider), isNull);
    });

    test('can be set to mgt7', () {
      container.read(mcaFormTypeFilterProvider.notifier).update(McaFormType.mgt7);
      expect(container.read(mcaFormTypeFilterProvider), McaFormType.mgt7);
    });
  });

  group('McaRocFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(mcaRocFilterProvider), isNull);
    });

    test('can be set to ROC Mumbai', () {
      container.read(mcaRocFilterProvider.notifier).update('ROC Mumbai');
      expect(container.read(mcaRocFilterProvider), 'ROC Mumbai');
    });
  });

  group('mcaFilteredFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns all filings when no filters set', () async {
      final all = await container.read(mcaFilingsProvider.future);
      final filtered = container.read(mcaFilteredFilingsProvider);
      expect(filtered.length, all.length);
    });

    test('status filter narrows results', () async {
      await container.read(mcaFilingsProvider.future);
      container
          .read(mcaStatusFilterProvider.notifier)
          .update(McaFilingStatus.approved);
      final filtered = container.read(mcaFilteredFilingsProvider);
      expect(
        filtered.every((f) => f.status == McaFilingStatus.approved),
        isTrue,
      );
    });

    test('form type filter narrows results', () async {
      await container.read(mcaFilingsProvider.future);
      container.read(mcaFormTypeFilterProvider.notifier).update(McaFormType.aoc4);
      final filtered = container.read(mcaFilteredFilingsProvider);
      expect(filtered.every((f) => f.formType == McaFormType.aoc4), isTrue);
    });
  });

  group('mcaFilingsByCompanyProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns filings only for requested company', () async {
      await container.read(mcaFilingsProvider.future);
      final filings = container.read(mcaFilingsByCompanyProvider('co-001'));
      expect(filings.every((f) => f.companyId == 'co-001'), isTrue);
    });

    test('returns empty for unknown company', () async {
      await container.read(mcaFilingsProvider.future);
      final filings = container.read(mcaFilingsByCompanyProvider('co-999'));
      expect(filings, isEmpty);
    });
  });
}
