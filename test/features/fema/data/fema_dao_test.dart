import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing_data.dart';
import 'package:ca_app/features/fema/data/mappers/fema_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  late int testCounter;

  setUpAll(() async {
    database = _createTestDatabase();
    testCounter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  group('FemaDao', () {
    FemaFilingData createTestFiling({
      String? id,
      String? clientId,
      FemaType? filingType,
      DateTime? transactionDate,
      String? amount,
      String? currency,
      String? status,
      bool? approvalRequired,
    }) {
      testCounter++;
      return FemaFilingData(
        id: id ?? 'fema-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        filingType: filingType ?? FemaType.fdi,
        transactionDate: transactionDate ?? DateTime(2024, 6, 15),
        amount: amount ?? '1000000',
        currency: currency ?? 'USD',
        approvalRequired: approvalRequired ?? false,
        status: status ?? 'pending',
      );
    }

    group('insertFemaFiling', () {
      test('inserts filing and returns non-empty ID', () async {
        final filing = createTestFiling();
        final id = await database.femaDao.insertFemaFiling(
          FemaMapper.toCompanion(filing),
        );
        expect(id, isNotEmpty);
      });

      test('stored filing has correct clientId', () async {
        final filing = createTestFiling(clientId: 'fema-insert-client');
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));
        final rows = await database.femaDao.getFemaFilingsByClient(
          'fema-insert-client',
        );
        expect(rows.any((r) => r.id == filing.id), isTrue);
      });

      test('stored filing has correct filingType', () async {
        final filing = createTestFiling(filingType: FemaType.ecb);
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));
        final rows = await database.femaDao.getFemaFilingsByClient(
          filing.clientId,
        );
        final row = rows.firstWhere((r) => r.id == filing.id);
        final domain = FemaMapper.fromRow(row);
        expect(domain.filingType, FemaType.ecb);
      });

      test('stored filing has correct currency', () async {
        final filing = createTestFiling(currency: 'EUR');
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));
        final rows = await database.femaDao.getFemaFilingsByClient(
          filing.clientId,
        );
        final row = rows.firstWhere((r) => r.id == filing.id);
        expect(row.currency, 'EUR');
      });

      test('stored filing preserves approvalRequired flag', () async {
        final filing = createTestFiling(approvalRequired: true);
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));
        final rows = await database.femaDao.getFemaFilingsByClient(
          filing.clientId,
        );
        final row = rows.firstWhere((r) => r.id == filing.id);
        expect(row.approvalRequired, isTrue);
      });
    });

    group('getFemaFilingsByClient', () {
      test('returns filings for specific client', () async {
        const clientId = 'fema-by-client-x';
        final f1 = createTestFiling(clientId: clientId);
        final f2 = createTestFiling(clientId: clientId);
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(f1));
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(f2));

        final results = await database.femaDao.getFemaFilingsByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.femaDao.getFemaFilingsByClient(
          'no-such-client',
        );
        expect(results, isEmpty);
      });

      test('filters filings by client correctly', () async {
        const clientA = 'fema-filter-a';
        const clientB = 'fema-filter-b';
        await database.femaDao.insertFemaFiling(
          FemaMapper.toCompanion(createTestFiling(clientId: clientA)),
        );
        await database.femaDao.insertFemaFiling(
          FemaMapper.toCompanion(createTestFiling(clientId: clientB)),
        );

        final results = await database.femaDao.getFemaFilingsByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getFemaFilingsByType', () {
      test('returns filings with matching type', () async {
        final filing = createTestFiling(filingType: FemaType.odi);
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));

        final results = await database.femaDao.getFemaFilingsByType(
          FemaType.odi.name,
        );
        expect(results.any((r) => r.id == filing.id), isTrue);
      });

      test('excludes filings with different type', () async {
        final filing = createTestFiling(filingType: FemaType.compounding);
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));

        final results = await database.femaDao.getFemaFilingsByType(
          FemaType.odi.name,
        );
        expect(results.where((r) => r.id == filing.id), isEmpty);
      });
    });

    group('updateFemaFilingStatus', () {
      test('updates status from pending to filed', () async {
        final filing = createTestFiling(status: 'pending');
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));

        final success = await database.femaDao.updateFemaFilingStatus(
          filing.id,
          'filed',
        );
        expect(success, isTrue);

        final rows = await database.femaDao.getFemaFilingsByClient(
          filing.clientId,
        );
        final updated = rows.firstWhere((r) => r.id == filing.id);
        expect(updated.status, 'filed');
      });

      test('returns false for non-existent filing ID', () async {
        final success = await database.femaDao.updateFemaFilingStatus(
          'non-existent-id',
          'filed',
        );
        expect(success, isFalse);
      });

      test('updates status to compounding', () async {
        final filing = createTestFiling(status: 'pending');
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));
        await database.femaDao.updateFemaFilingStatus(filing.id, 'compounding');

        final rows = await database.femaDao.getFemaFilingsByClient(
          filing.clientId,
        );
        final updated = rows.firstWhere((r) => r.id == filing.id);
        expect(updated.status, 'compounding');
      });
    });

    group('getFemaFilingsByYear', () {
      test('returns filings in the specified calendar year', () async {
        final date = DateTime(2024, 7, 1);
        final filing = createTestFiling(transactionDate: date);
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));

        final results = await database.femaDao.getFemaFilingsByYear(
          filing.clientId,
          2024,
        );
        expect(results.any((r) => r.id == filing.id), isTrue);
      });

      test('excludes filings from different year', () async {
        final date = DateTime(2022, 3, 15);
        final filing = createTestFiling(transactionDate: date);
        await database.femaDao.insertFemaFiling(FemaMapper.toCompanion(filing));

        final results = await database.femaDao.getFemaFilingsByYear(
          filing.clientId,
          2024,
        );
        expect(results.where((r) => r.id == filing.id), isEmpty);
      });
    });

    group('Immutability', () {
      test('FemaFilingData has copyWith for immutable updates', () {
        final f1 = createTestFiling(status: 'pending');
        final f2 = f1.copyWith(status: 'filed');

        expect(f1.status, 'pending');
        expect(f2.status, 'filed');
        expect(f1.id, f2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final f1 = createTestFiling(
          amount: '5000000',
          currency: 'USD',
          filingType: FemaType.form15ca,
        );
        final f2 = f1.copyWith(status: 'approved');

        expect(f2.clientId, f1.clientId);
        expect(f2.amount, '5000000');
        expect(f2.currency, 'USD');
        expect(f2.filingType, FemaType.form15ca);
      });

      test('FemaType enum round-trips through mapper', () {
        for (final type in FemaType.values) {
          final filing = createTestFiling(filingType: type);
          final companion = FemaMapper.toCompanion(filing);
          expect(companion.filingType.value, type.name);
        }
      });
    });
  });
}
