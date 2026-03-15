import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/reconciliation/data/providers/reconciliation_providers.dart';
import 'package:ca_app/features/reconciliation/data/providers/reconciliation_repository_providers.dart';
import 'package:ca_app/features/reconciliation/data/repositories/mock_reconciliation_repository.dart';
import 'package:ca_app/features/reconciliation/domain/services/bank_reconciliation_service.dart';
import 'package:ca_app/features/reconciliation/domain/services/three_way_reconciliation_service.dart';

ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      reconciliationRepositoryProvider.overrideWithValue(
        MockReconciliationRepository(),
      ),
    ],
  );
}

void main() {
  group('Service providers', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('threeWayReconServiceProvider returns correct type', () {
      final service = container.read(threeWayReconServiceProvider);
      expect(service, isA<ThreeWayReconciliationService>());
    });

    test('bankReconServiceProvider returns correct type', () {
      final service = container.read(bankReconServiceProvider);
      expect(service, isA<BankReconciliationService>());
    });
  });

  group('ReconResultsNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('loads 12 mock recon entries', () async {
      final entries = await container.read(reconResultsProvider.future);
      expect(entries.length, 12);
    });

    test('all entries have non-empty ids', () async {
      final entries = await container.read(reconResultsProvider.future);
      expect(entries.every((e) => e.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () async {
      final entries = await container.read(reconResultsProvider.future);
      expect(() => (entries as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('ReconFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(reconFilterProvider), isNull);
    });

    test('can be set to matched', () {
      container
          .read(reconFilterProvider.notifier)
          .select(ReconEntryStatus.matched);
      expect(container.read(reconFilterProvider), ReconEntryStatus.matched);
    });

    test('can be set to mismatched', () {
      container
          .read(reconFilterProvider.notifier)
          .select(ReconEntryStatus.mismatched);
      expect(container.read(reconFilterProvider), ReconEntryStatus.mismatched);
    });

    test('can be reset to null', () {
      container
          .read(reconFilterProvider.notifier)
          .select(ReconEntryStatus.matched);
      container.read(reconFilterProvider.notifier).select(null);
      expect(container.read(reconFilterProvider), isNull);
    });
  });

  group('filteredReconEntriesProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns all entries when no filter', () async {
      final all = await container.read(reconResultsProvider.future);
      final filtered = container.read(filteredReconEntriesProvider);
      expect(filtered.length, all.length);
    });

    test('matched filter returns only matched entries', () async {
      await container.read(reconResultsProvider.future);
      container
          .read(reconFilterProvider.notifier)
          .select(ReconEntryStatus.matched);
      final filtered = container.read(filteredReconEntriesProvider);
      expect(
        filtered.every((e) => e.status == ReconEntryStatus.matched),
        isTrue,
      );
    });
  });

  group('reconSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('total matches entries count', () async {
      final entries = await container.read(reconResultsProvider.future);
      final summary = container.read(reconSummaryProvider);
      expect(summary.total, entries.length);
    });

    test('matched + mismatched + missing equals total', () async {
      await container.read(reconResultsProvider.future);
      final summary = container.read(reconSummaryProvider);
      final computed = summary.matched +
          summary.mismatched +
          summary.missingIn26as +
          summary.missingInAis +
          summary.missingInItr;
      expect(computed, summary.total);
    });

    test('matchedPercent is between 0 and 100', () async {
      await container.read(reconResultsProvider.future);
      final summary = container.read(reconSummaryProvider);
      expect(summary.matchedPercent, greaterThanOrEqualTo(0));
      expect(summary.matchedPercent, lessThanOrEqualTo(100));
    });
  });

  group('threeWayMatchResultProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns result with non-empty PAN', () {
      final result = container.read(threeWayMatchResultProvider);
      expect(result.pan.isNotEmpty, isTrue);
    });

    test('returns result with non-empty assessmentYear', () {
      final result = container.read(threeWayMatchResultProvider);
      expect(result.assessmentYear.isNotEmpty, isTrue);
    });
  });
}
