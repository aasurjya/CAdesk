import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/crypto_vda/data/providers/crypto_vda_providers.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

void main() {
  group('Crypto VDA Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('allVdaTransactionsProvider', () {
      test('returns non-empty list of VDA transactions', () {
        final txns = container.read(allVdaTransactionsProvider);
        expect(txns, isNotEmpty);
      });

      test('list is unmodifiable', () {
        final txns = container.read(allVdaTransactionsProvider);
        expect(() => (txns as dynamic).add(txns.first), throwsA(isA<Error>()));
      });

      test('all entries are VdaTransaction instances', () {
        final txns = container.read(allVdaTransactionsProvider);
        for (final t in txns) {
          expect(t, isA<VdaTransaction>());
        }
      });
    });

    group('vdaTransactionsProvider (alias)', () {
      test('returns same data as allVdaTransactionsProvider', () {
        final all = container.read(allVdaTransactionsProvider);
        final alias = container.read(vdaTransactionsProvider);
        expect(alias.length, all.length);
      });
    });

    group('vdaSummariesProvider', () {
      test('returns non-empty list of VDA summaries', () {
        final summaries = container.read(vdaSummariesProvider);
        expect(summaries, isNotEmpty);
      });

      test('all entries are VdaSummary instances', () {
        final summaries = container.read(vdaSummariesProvider);
        for (final s in summaries) {
          expect(s, isA<VdaSummary>());
        }
      });
    });

    group('selectedVdaClientProvider', () {
      test('initial state is null', () {
        expect(container.read(selectedVdaClientProvider), isNull);
      });

      test('can be set to a client ID', () {
        container.read(selectedVdaClientProvider.notifier).update('client-1');
        expect(container.read(selectedVdaClientProvider), 'client-1');
      });

      test('can be cleared back to null', () {
        container.read(selectedVdaClientProvider.notifier).update('client-2');
        container.read(selectedVdaClientProvider.notifier).update(null);
        expect(container.read(selectedVdaClientProvider), isNull);
      });
    });

    group('selectedAssetTypeProvider', () {
      test('initial state is null', () {
        expect(container.read(selectedAssetTypeProvider), isNull);
      });

      test('can be set to an asset type', () {
        container
            .read(selectedAssetTypeProvider.notifier)
            .update(VdaAssetType.crypto);
        expect(container.read(selectedAssetTypeProvider), VdaAssetType.crypto);
      });
    });

    group('selectedTransactionTypeProvider', () {
      test('initial state is null', () {
        expect(container.read(selectedTransactionTypeProvider), isNull);
      });

      test('can be set to a transaction type', () {
        container
            .read(selectedTransactionTypeProvider.notifier)
            .update(VdaTransactionType.sell);
        expect(
          container.read(selectedTransactionTypeProvider),
          VdaTransactionType.sell,
        );
      });
    });

    group('selectedVdaTabProvider', () {
      test('initial state is 0', () {
        expect(container.read(selectedVdaTabProvider), 0);
      });

      test('can be updated to any tab index', () {
        container.read(selectedVdaTabProvider.notifier).update(2);
        expect(container.read(selectedVdaTabProvider), 2);
      });
    });

    group('filteredVdaTransactionsProvider', () {
      test('returns all transactions when no filters are set', () {
        final all = container.read(allVdaTransactionsProvider);
        final filtered = container.read(filteredVdaTransactionsProvider);
        expect(filtered.length, all.length);
      });

      test('filters by client ID', () {
        final txns = container.read(allVdaTransactionsProvider);
        final firstClientId = txns.first.clientId;
        container
            .read(selectedVdaClientProvider.notifier)
            .update(firstClientId);
        final filtered = container.read(filteredVdaTransactionsProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((t) => t.clientId == firstClientId), isTrue);
      });

      test('filters by asset type', () {
        container
            .read(selectedAssetTypeProvider.notifier)
            .update(VdaAssetType.crypto);
        final filtered = container.read(filteredVdaTransactionsProvider);
        for (final t in filtered) {
          expect(t.assetType, VdaAssetType.crypto);
        }
      });
    });

    group('vdaClientNamesProvider', () {
      test('returns non-empty list of client name records', () {
        final clients = container.read(vdaClientNamesProvider);
        expect(clients, isNotEmpty);
      });

      test('each client entry has both id and name', () {
        final clients = container.read(vdaClientNamesProvider);
        for (final c in clients) {
          expect(c.id, isNotEmpty);
          expect(c.name, isNotEmpty);
        }
      });

      test('client IDs are unique', () {
        final clients = container.read(vdaClientNamesProvider);
        final ids = clients.map((c) => c.id).toSet();
        expect(ids.length, clients.length);
      });
    });

    group('vdaTaxOverviewProvider', () {
      test('totalGains is non-negative', () {
        final overview = container.read(vdaTaxOverviewProvider);
        expect(overview.totalGains, greaterThanOrEqualTo(0));
      });

      test('totalTaxLiability is non-negative', () {
        final overview = container.read(vdaTaxOverviewProvider);
        expect(overview.totalTaxLiability, greaterThanOrEqualTo(0));
      });

      test('lossRestrictionViolations is non-negative', () {
        final overview = container.read(vdaTaxOverviewProvider);
        expect(overview.lossRestrictionViolations, greaterThanOrEqualTo(0));
      });
    });

    group('vdaScheduleSummaryProvider', () {
      test('returns a VdaScheduleSummary for an existing client', () {
        final txns = container.read(allVdaTransactionsProvider);
        final clientId = txns.first.clientId;
        final summary = container.read(vdaScheduleSummaryProvider(clientId));
        expect(summary, isNotNull);
      });

      test('returns empty summary for non-existent client', () {
        final summary = container.read(
          vdaScheduleSummaryProvider('no-such-client-xyz'),
        );
        expect(summary.totalNetGains, 0);
        expect(summary.totalTaxPayable, 0);
      });
    });
  });
}
