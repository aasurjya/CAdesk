import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/llp/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp/data/mappers/llp_mapper.dart';

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

  group('LlpDao', () {
    LlpFiling createTestFiling({
      String? id,
      String? clientId,
      LlpFormType? formType,
      String? financialYear,
      DateTime? dueDate,
      String? status,
      String? filingNumber,
    }) {
      testCounter++;
      return LlpFiling(
        id: id ?? 'llp-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        formType: formType ?? LlpFormType.form11,
        financialYear: financialYear ?? '2024-25',
        dueDate: dueDate ?? DateTime(2025, 9, 30),
        status: status ?? 'pending',
        filingNumber: filingNumber,
      );
    }

    group('insertLlpFiling', () {
      test('inserts filing and returns non-empty ID', () async {
        final filing = createTestFiling();
        final companion = LlpMapper.toCompanion(filing);
        final id = await database.llpDao.insertLlpFiling(companion);
        expect(id, isNotEmpty);
      });

      test('stored filing has correct clientId', () async {
        final filing = createTestFiling(clientId: 'insert-client-a');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));
        final rows =
            await database.llpDao.getLlpFilingsByClient('insert-client-a');
        expect(rows.any((r) => r.id == filing.id), isTrue);
      });

      test('stored filing has correct formType', () async {
        final filing =
            createTestFiling(formType: LlpFormType.form8);
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));
        final rows =
            await database.llpDao.getLlpFilingsByClient(filing.clientId);
        final row = rows.firstWhere((r) => r.id == filing.id);
        final domain = LlpMapper.fromRow(row);
        expect(domain.formType, LlpFormType.form8);
      });

      test('stored filing has correct financialYear', () async {
        final filing = createTestFiling(financialYear: '2023-24');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));
        final rows =
            await database.llpDao.getLlpFilingsByClient(filing.clientId);
        final row = rows.firstWhere((r) => r.id == filing.id);
        expect(row.financialYear, '2023-24');
      });
    });

    group('getLlpFilingsByClient', () {
      test('returns filings for specific client', () async {
        final clientId = 'client-by-client-llp-a';
        final f1 = createTestFiling(clientId: clientId);
        final f2 = createTestFiling(clientId: clientId);
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(f1));
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(f2));

        final results =
            await database.llpDao.getLlpFilingsByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results =
            await database.llpDao.getLlpFilingsByClient('non-existent');
        expect(results, isEmpty);
      });

      test('filters filings by client correctly', () async {
        final clientA = 'llp-filter-a';
        final clientB = 'llp-filter-b';
        await database.llpDao
            .insertLlpFiling(LlpMapper.toCompanion(createTestFiling(clientId: clientA)));
        await database.llpDao
            .insertLlpFiling(LlpMapper.toCompanion(createTestFiling(clientId: clientB)));

        final results =
            await database.llpDao.getLlpFilingsByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getLlpFilingsByYear', () {
      test('returns filings for matching client and year', () async {
        final clientId = 'llp-year-client';
        final f = createTestFiling(clientId: clientId, financialYear: '2024-25');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(f));

        final results =
            await database.llpDao.getLlpFilingsByYear(clientId, '2024-25');
        expect(results.any((r) => r.id == f.id), isTrue);
      });

      test('excludes filings from different year', () async {
        final clientId = 'llp-year-diff-client';
        final f = createTestFiling(clientId: clientId, financialYear: '2022-23');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(f));

        final results =
            await database.llpDao.getLlpFilingsByYear(clientId, '2024-25');
        expect(results.where((r) => r.id == f.id), isEmpty);
      });
    });

    group('updateLlpFilingStatus', () {
      test('updates status from pending to filed', () async {
        final filing = createTestFiling(status: 'pending');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));

        final success =
            await database.llpDao.updateLlpFilingStatus(filing.id, 'filed');
        expect(success, isTrue);

        final rows =
            await database.llpDao.getLlpFilingsByClient(filing.clientId);
        final updated = rows.firstWhere((r) => r.id == filing.id);
        expect(updated.status, 'filed');
      });

      test('returns false for non-existent filing ID', () async {
        final success = await database.llpDao.updateLlpFilingStatus(
          'non-existent-id',
          'filed',
        );
        expect(success, isFalse);
      });

      test('updates status to approved', () async {
        final filing = createTestFiling(status: 'pending');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));
        await database.llpDao.updateLlpFilingStatus(filing.id, 'approved');

        final rows =
            await database.llpDao.getLlpFilingsByClient(filing.clientId);
        final updated = rows.firstWhere((r) => r.id == filing.id);
        expect(updated.status, 'approved');
      });
    });

    group('getOverdueLlpFilings', () {
      test('returns filings with past due date and pending status', () async {
        final past = DateTime.now().subtract(const Duration(days: 10));
        final filing = createTestFiling(dueDate: past, status: 'pending');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));

        final results = await database.llpDao.getOverdueLlpFilings();
        expect(results.any((r) => r.id == filing.id), isTrue);
      });

      test('does not return future-dated filings as overdue', () async {
        final future = DateTime.now().add(const Duration(days: 30));
        final filing = createTestFiling(dueDate: future, status: 'pending');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));

        final results = await database.llpDao.getOverdueLlpFilings();
        expect(results.where((r) => r.id == filing.id), isEmpty);
      });

      test('does not return filed filings as overdue', () async {
        final past = DateTime.now().subtract(const Duration(days: 5));
        final filing = createTestFiling(dueDate: past, status: 'filed');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));

        final results = await database.llpDao.getOverdueLlpFilings();
        expect(results.where((r) => r.id == filing.id), isEmpty);
      });
    });

    group('getDueLlpFilings', () {
      test('returns filings due within daysAhead window', () async {
        final soon = DateTime.now().add(const Duration(days: 15));
        final filing = createTestFiling(dueDate: soon, status: 'pending');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));

        final results = await database.llpDao.getDueLlpFilings(30);
        expect(results.any((r) => r.id == filing.id), isTrue);
      });

      test('excludes filings beyond daysAhead window', () async {
        final far = DateTime.now().add(const Duration(days: 90));
        final filing = createTestFiling(dueDate: far, status: 'pending');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));

        final results = await database.llpDao.getDueLlpFilings(30);
        expect(results.where((r) => r.id == filing.id), isEmpty);
      });

      test('excludes approved filings from due list', () async {
        final soon = DateTime.now().add(const Duration(days: 5));
        final filing = createTestFiling(dueDate: soon, status: 'approved');
        await database.llpDao.insertLlpFiling(LlpMapper.toCompanion(filing));

        final results = await database.llpDao.getDueLlpFilings(30);
        expect(results.where((r) => r.id == filing.id), isEmpty);
      });
    });

    group('Immutability', () {
      test('LlpFiling has copyWith for immutable updates', () {
        final f1 = createTestFiling(status: 'pending');
        final f2 = f1.copyWith(status: 'filed');

        expect(f1.status, 'pending');
        expect(f2.status, 'filed');
        expect(f1.id, f2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final f1 = createTestFiling(
          financialYear: '2024-25',
          formType: LlpFormType.form3,
        );
        final f2 = f1.copyWith(status: 'approved');

        expect(f2.clientId, f1.clientId);
        expect(f2.financialYear, '2024-25');
        expect(f2.formType, LlpFormType.form3);
      });

      test('LlpFormType enum round-trips through mapper', () {
        for (final type in LlpFormType.values) {
          final filing = createTestFiling(formType: type);
          final companion = LlpMapper.toCompanion(filing);
          expect(companion.formType.value, type.name);
        }
      });
    });
  });
}
