import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/fema/data/providers/fema_providers.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing.dart';
import 'package:ca_app/features/fema/domain/models/fdi_transaction.dart';

void main() {
  group('FEMA Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('femaFilingsProvider', () {
      test('returns non-empty list of FEMA filings', () {
        final filings = container.read(femaFilingsProvider);
        expect(filings, isNotEmpty);
        expect(filings.length, greaterThanOrEqualTo(5));
      });

      test('list is unmodifiable', () {
        final filings = container.read(femaFilingsProvider);
        expect(
          () => (filings as dynamic).add(filings.first),
          throwsA(isA<Error>()),
        );
      });

      test('all entries are FemaFiling instances', () {
        final filings = container.read(femaFilingsProvider);
        for (final f in filings) {
          expect(f, isA<FemaFiling>());
        }
      });

      test('all filings have positive amounts', () {
        final filings = container.read(femaFilingsProvider);
        for (final f in filings) {
          expect(f.amount, greaterThan(0));
        }
      });
    });

    group('fdiTransactionsProvider', () {
      test('returns non-empty list of FDI transactions', () {
        final transactions = container.read(fdiTransactionsProvider);
        expect(transactions, isNotEmpty);
        expect(transactions.length, greaterThanOrEqualTo(4));
      });

      test('all entries are FdiTransaction instances', () {
        final transactions = container.read(fdiTransactionsProvider);
        for (final t in transactions) {
          expect(t, isA<FdiTransaction>());
        }
      });
    });

    group('femaStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(femaStatusFilterProvider), isNull);
      });

      test('can be set to submitted status', () {
        container
            .read(femaStatusFilterProvider.notifier)
            .update(FemaFilingStatus.submitted);
        expect(
          container.read(femaStatusFilterProvider),
          FemaFilingStatus.submitted,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(femaStatusFilterProvider.notifier)
            .update(FemaFilingStatus.draft);
        container.read(femaStatusFilterProvider.notifier).update(null);
        expect(container.read(femaStatusFilterProvider), isNull);
      });
    });

    group('fdiStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(fdiStatusFilterProvider), isNull);
      });

      test('can be set to completed status', () {
        container
            .read(fdiStatusFilterProvider.notifier)
            .update(FdiTransactionStatus.completed);
        expect(
          container.read(fdiStatusFilterProvider),
          FdiTransactionStatus.completed,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(fdiStatusFilterProvider.notifier)
            .update(FdiTransactionStatus.underReview);
        container.read(fdiStatusFilterProvider.notifier).update(null);
        expect(container.read(fdiStatusFilterProvider), isNull);
      });
    });

    group('filteredFemaFilingsProvider', () {
      test('returns all filings when no filter is set', () {
        final all = container.read(femaFilingsProvider);
        final filtered = container.read(filteredFemaFilingsProvider);
        expect(filtered.length, all.length);
      });

      test('filters to submitted filings only', () {
        container
            .read(femaStatusFilterProvider.notifier)
            .update(FemaFilingStatus.submitted);
        final filtered = container.read(filteredFemaFilingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((f) => f.status == FemaFilingStatus.submitted),
          isTrue,
        );
      });

      test('filters to draft filings only', () {
        container
            .read(femaStatusFilterProvider.notifier)
            .update(FemaFilingStatus.draft);
        final filtered = container.read(filteredFemaFilingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((f) => f.status == FemaFilingStatus.draft),
          isTrue,
        );
      });
    });

    group('filteredFdiTransactionsProvider', () {
      test('returns all transactions when no filter is set', () {
        final all = container.read(fdiTransactionsProvider);
        final filtered = container.read(filteredFdiTransactionsProvider);
        expect(filtered.length, all.length);
      });

      test('filters to completed transactions only', () {
        container
            .read(fdiStatusFilterProvider.notifier)
            .update(FdiTransactionStatus.completed);
        final filtered = container.read(filteredFdiTransactionsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((t) => t.status == FdiTransactionStatus.completed),
          isTrue,
        );
      });
    });

    group('femaSummaryProvider', () {
      test('totalFilings matches femaFilingsProvider length', () {
        final summary = container.read(femaSummaryProvider);
        expect(summary.totalFilings, container.read(femaFilingsProvider).length);
      });

      test('pendingFilings is non-negative', () {
        final summary = container.read(femaSummaryProvider);
        expect(summary.pendingFilings, greaterThanOrEqualTo(0));
      });

      test('overdueFilings is non-negative', () {
        final summary = container.read(femaSummaryProvider);
        expect(summary.overdueFilings, greaterThanOrEqualTo(0));
      });

      test('activeFdiTransactions is non-negative', () {
        final summary = container.read(femaSummaryProvider);
        expect(summary.activeFdiTransactions, greaterThanOrEqualTo(0));
      });

      test('activeFdiTransactions <= fdiTransactionsProvider length', () {
        final summary = container.read(femaSummaryProvider);
        expect(
          summary.activeFdiTransactions,
          lessThanOrEqualTo(
            container.read(fdiTransactionsProvider).length,
          ),
        );
      });
    });
  });
}
