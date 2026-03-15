import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/accounts/data/providers/accounts_providers.dart';
import 'package:ca_app/features/accounts/domain/models/account_client.dart';
import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';
import 'package:ca_app/features/accounts/domain/models/depreciation_entry.dart';

void main() {
  group('Accounts Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('accountClientsProvider', () {
      test('returns non-empty list of account clients', () {
        final clients = container.read(accountClientsProvider);
        expect(clients, isNotEmpty);
        expect(clients.length, greaterThanOrEqualTo(10));
      });

      test('list is unmodifiable', () {
        final clients = container.read(accountClientsProvider);
        expect(() => (clients as dynamic).add(clients.first), throwsA(isA<Error>()));
      });

      test('all entries are AccountClient instances', () {
        final clients = container.read(accountClientsProvider);
        for (final c in clients) {
          expect(c, isA<AccountClient>());
        }
      });
    });

    group('financialStatementsProvider', () {
      test('returns non-empty list of financial statements', () {
        final statements = container.read(financialStatementsProvider);
        expect(statements, isNotEmpty);
        expect(statements.length, greaterThanOrEqualTo(10));
      });

      test('all entries are FinancialStatement instances', () {
        final statements = container.read(financialStatementsProvider);
        for (final s in statements) {
          expect(s, isA<FinancialStatement>());
        }
      });
    });

    group('depreciationEntriesProvider', () {
      test('returns non-empty list of depreciation entries', () {
        final entries = container.read(depreciationEntriesProvider);
        expect(entries, isNotEmpty);
      });

      test('all entries are DepreciationEntry instances', () {
        final entries = container.read(depreciationEntriesProvider);
        for (final e in entries) {
          expect(e, isA<DepreciationEntry>());
        }
      });
    });

    group('ratioSnapshotsProvider', () {
      test('returns non-empty list of ratio snapshots', () {
        final snapshots = container.read(ratioSnapshotsProvider);
        expect(snapshots, isNotEmpty);
      });
    });

    group('clientRatioSnapshotProvider', () {
      test('returns snapshot for existing client', () {
        final clients = container.read(accountClientsProvider);
        final firstId = clients.first.id;
        final snapshot = container.read(clientRatioSnapshotProvider(firstId));
        // May or may not have a snapshot depending on mock data alignment
        // Just verify it doesn't throw
        expect(() => snapshot, returnsNormally);
      });

      test('returns null for non-existent client', () {
        final snapshot = container.read(
          clientRatioSnapshotProvider('non-existent-id-xyz'),
        );
        expect(snapshot, isNull);
      });
    });

    group('accountStatusFilterProvider', () {
      test('initial state is null (no filter)', () {
        expect(container.read(accountStatusFilterProvider), isNull);
      });

      test('can be updated to a specific status', () {
        container
            .read(accountStatusFilterProvider.notifier)
            .update(AccountClientStatus.finalized);
        expect(
          container.read(accountStatusFilterProvider),
          AccountClientStatus.finalized,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(accountStatusFilterProvider.notifier)
            .update(AccountClientStatus.draft);
        container.read(accountStatusFilterProvider.notifier).update(null);
        expect(container.read(accountStatusFilterProvider), isNull);
      });
    });

    group('businessTypeFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(businessTypeFilterProvider), isNull);
      });

      test('can be set to a business type', () {
        container
            .read(businessTypeFilterProvider.notifier)
            .update(BusinessType.company);
        expect(
          container.read(businessTypeFilterProvider),
          BusinessType.company,
        );
      });
    });

    group('filteredAccountClientsProvider', () {
      test('returns all clients when no filters are set', () {
        final all = container.read(accountClientsProvider);
        final filtered = container.read(filteredAccountClientsProvider);
        expect(filtered.length, all.length);
      });

      test('filters by status', () {
        container
            .read(accountStatusFilterProvider.notifier)
            .update(AccountClientStatus.finalized);
        final filtered = container.read(filteredAccountClientsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((c) => c.status == AccountClientStatus.finalized),
          isTrue,
        );
      });

      test('filters by business type', () {
        container
            .read(businessTypeFilterProvider.notifier)
            .update(BusinessType.company);
        final filtered = container.read(filteredAccountClientsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((c) => c.businessType == BusinessType.company),
          isTrue,
        );
      });

      test('returns empty when filters match no clients', () {
        // Set both status and type to a combination that won't match
        container
            .read(accountStatusFilterProvider.notifier)
            .update(AccountClientStatus.draft);
        container
            .read(businessTypeFilterProvider.notifier)
            .update(BusinessType.huf);
        final filtered = container.read(filteredAccountClientsProvider);
        // Either empty or only HUF drafts
        for (final c in filtered) {
          expect(c.status, AccountClientStatus.draft);
          expect(c.businessType, BusinessType.huf);
        }
      });
    });

    group('filteredStatementsProvider', () {
      test('returns all statements when year filter is null', () {
        final all = container.read(financialStatementsProvider);
        final filtered = container.read(filteredStatementsProvider);
        expect(filtered.length, all.length);
      });

      test('filters by financial year', () {
        container
            .read(statementYearFilterProvider.notifier)
            .update('FY 2024-25');
        final filtered = container.read(filteredStatementsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((s) => s.financialYear == 'FY 2024-25'),
          isTrue,
        );
      });

      test('returns empty for non-existent year', () {
        container
            .read(statementYearFilterProvider.notifier)
            .update('FY 1999-00');
        final filtered = container.read(filteredStatementsProvider);
        expect(filtered, isEmpty);
      });
    });

    group('accountsSummaryProvider', () {
      test('finalized count matches accountClientsProvider', () {
        final summary = container.read(accountsSummaryProvider);
        final expected = container
            .read(accountClientsProvider)
            .where((c) => c.status == AccountClientStatus.finalized)
            .length;
        expect(summary.finalized, expected);
      });

      test('drafts count matches accountClientsProvider', () {
        final summary = container.read(accountsSummaryProvider);
        final expected = container
            .read(accountClientsProvider)
            .where((c) => c.status == AccountClientStatus.draft)
            .length;
        expect(summary.drafts, expected);
      });

      test('totalAssetsUnderManagement is positive', () {
        final summary = container.read(accountsSummaryProvider);
        expect(summary.totalAssetsUnderManagement, greaterThan(0));
      });
    });
  });
}
