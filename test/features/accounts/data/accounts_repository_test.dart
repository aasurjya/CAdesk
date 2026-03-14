import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';
import 'package:ca_app/features/accounts/data/repositories/mock_accounts_repository.dart';

void main() {
  group('MockAccountsRepository', () {
    late MockAccountsRepository repo;

    setUp(() {
      repo = MockAccountsRepository();
    });

    group('getStatementsByClient', () {
      test('returns seeded statements for mock-client-001', () async {
        final results = await repo.getStatementsByClient(
          'mock-client-001',
          'FY 2024-25',
        );
        expect(results, isNotEmpty);
        expect(results.every((s) => s.clientId == 'mock-client-001'), isTrue);
      });

      test('returns empty list for unknown client', () async {
        final results = await repo.getStatementsByClient(
          'unknown',
          'FY 2024-25',
        );
        expect(results, isEmpty);
      });

      test('filters by financial year', () async {
        final results = await repo.getStatementsByClient(
          'mock-client-001',
          'FY 2024-25',
        );
        expect(results.every((s) => s.financialYear == 'FY 2024-25'), isTrue);
      });
    });

    group('getStatementById', () {
      test('returns statement for valid ID', () async {
        final statement = await repo.getStatementById('mock-stmt-001');
        expect(statement, isNotNull);
        expect(statement!.id, 'mock-stmt-001');
      });

      test('returns null for unknown ID', () async {
        final statement = await repo.getStatementById('no-such-id');
        expect(statement, isNull);
      });
    });

    group('insertStatement', () {
      test('inserts and returns new statement ID', () async {
        final newStatement = FinancialStatement(
          id: 'new-stmt-001',
          clientId: 'client-x',
          clientName: 'Client X',
          statementType: StatementType.balanceSheet,
          financialYear: 'FY 2025-26',
          format: StatementFormat.vertical,
          preparedBy: 'CA Sharma',
          preparedDate: DateTime(2026, 3, 1),
          status: StatementStatus.draft,
          totalAssets: 1000000,
          totalLiabilities: 600000,
          netProfit: 200000,
        );
        final id = await repo.insertStatement(newStatement);
        expect(id, 'new-stmt-001');

        final fetched = await repo.getStatementById('new-stmt-001');
        expect(fetched, isNotNull);
        expect(fetched!.clientName, 'Client X');
      });
    });

    group('updateStatement', () {
      test('updates existing statement and returns true', () async {
        final existing = await repo.getStatementById('mock-stmt-001');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(status: StatementStatus.approved);
        final success = await repo.updateStatement(updated);
        expect(success, isTrue);

        final fetched = await repo.getStatementById('mock-stmt-001');
        expect(fetched!.status, StatementStatus.approved);
      });

      test('returns false for non-existent statement', () async {
        final ghost = FinancialStatement(
          id: 'ghost-stmt',
          clientId: 'c',
          clientName: 'Ghost',
          statementType: StatementType.trialBalance,
          financialYear: 'FY 2024-25',
          format: StatementFormat.horizontal,
          preparedBy: 'CA Test',
          preparedDate: DateTime(2026, 1, 1),
          status: StatementStatus.draft,
          totalAssets: 0,
          totalLiabilities: 0,
          netProfit: 0,
        );
        final success = await repo.updateStatement(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteStatement', () {
      test('deletes statement and returns true', () async {
        final id = await repo.insertStatement(
          FinancialStatement(
            id: 'to-delete-stmt',
            clientId: 'client-del',
            clientName: 'Del Client',
            statementType: StatementType.cashFlow,
            financialYear: 'FY 2023-24',
            format: StatementFormat.vertical,
            preparedBy: 'CA Delete',
            preparedDate: DateTime(2025, 1, 1),
            status: StatementStatus.draft,
            totalAssets: 0,
            totalLiabilities: 0,
            netProfit: 0,
          ),
        );

        final success = await repo.deleteStatement(id);
        expect(success, isTrue);

        final fetched = await repo.getStatementById(id);
        expect(fetched, isNull);
      });

      test('returns false for non-existent statement ID', () async {
        final success = await repo.deleteStatement('no-such-stmt');
        expect(success, isFalse);
      });
    });

    group('getAllStatements', () {
      test('returns all seeded statements', () async {
        final all = await repo.getAllStatements();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAllStatements();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });
  });
}
