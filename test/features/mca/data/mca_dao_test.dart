import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/mca/domain/models/mca_filing_data.dart';
import 'package:ca_app/features/mca/data/mappers/mca_mapper.dart';

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

  group('McaDao', () {
    McaFilingData createTestFiling({
      String? id,
      String? clientId,
      MCAFormType? formType,
      String? financialYear,
      DateTime? dueDate,
      DateTime? filedDate,
      String? status,
      String? filingNumber,
      String? remarks,
    }) {
      testCounter++;
      return McaFilingData(
        id: id ?? 'mca-test-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        formType: formType ?? MCAFormType.aoc4,
        financialYear: financialYear ?? '2024-25',
        dueDate: dueDate ?? DateTime(2025, 10, 31),
        filedDate: filedDate,
        status: status ?? 'pending',
        filingNumber: filingNumber,
        remarks: remarks,
      );
    }

    // -------------------------------------------------------------------------
    // insertMCAFiling
    // -------------------------------------------------------------------------

    group('insertMCAFiling', () {
      test('inserts filing and returns non-empty ID', () async {
        final filing = createTestFiling();
        final companion = McaMapper.toCompanion(filing);
        final id = await database.mcaDao.insertMCAFiling(companion);
        expect(id, isNotEmpty);
      });

      test('stored filing has correct formType', () async {
        final filing = createTestFiling(formType: MCAFormType.inc22a);
        final companion = McaMapper.toCompanion(filing);
        await database.mcaDao.insertMCAFiling(companion);
        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.formType, 'inc22a');
      });

      test('stored filing has correct clientId', () async {
        final filing = createTestFiling();
        final companion = McaMapper.toCompanion(filing);
        await database.mcaDao.insertMCAFiling(companion);
        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.clientId, filing.clientId);
      });

      test('stored filing has correct financialYear', () async {
        final filing = createTestFiling(financialYear: '2025-26');
        final companion = McaMapper.toCompanion(filing);
        await database.mcaDao.insertMCAFiling(companion);
        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.financialYear, '2025-26');
      });

      test('stored filing preserves optional filedDate', () async {
        final filed = DateTime(2025, 10, 20);
        final filing = createTestFiling(filedDate: filed, status: 'filed');
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));
        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.filedDate, filed);
      });

      test('stored filing has correct filingNumber', () async {
        final filing = createTestFiling(
          filingNumber: 'G99887766',
          status: 'approved',
        );
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));
        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.filingNumber, 'G99887766');
      });
    });

    // -------------------------------------------------------------------------
    // getMCAFilingsByClient
    // -------------------------------------------------------------------------

    group('getMCAFilingsByClient', () {
      test('returns filings for specific client', () async {
        final f1 = createTestFiling();
        final f2 = createTestFiling(clientId: f1.clientId);

        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f1));
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f2));

        final results = await database.mcaDao.getMCAFilingsByClient(
          f1.clientId,
        );
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.mcaDao.getMCAFilingsByClient(
          'non-existent-client',
        );
        expect(results, isEmpty);
      });

      test('filters filings by clientId correctly', () async {
        const client1 = 'client-filter-mca-1';
        const client2 = 'client-filter-mca-2';
        final f1 = createTestFiling(clientId: client1);
        final f2 = createTestFiling(clientId: client2);

        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f1));
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f2));

        final results = await database.mcaDao.getMCAFilingsByClient(client1);
        expect(results.every((r) => r.clientId == client1), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // getMCAFilingsByYear
    // -------------------------------------------------------------------------

    group('getMCAFilingsByYear', () {
      test('returns filings for client and year', () async {
        const client = 'client-year-mca';
        final f1 = createTestFiling(clientId: client, financialYear: '2023-24');
        final f2 = createTestFiling(clientId: client, financialYear: '2024-25');
        final f3 = createTestFiling(clientId: client, financialYear: '2024-25');

        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f1));
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f2));
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f3));

        final results = await database.mcaDao.getMCAFilingsByYear(
          client,
          '2024-25',
        );
        expect(results.length, greaterThanOrEqualTo(2));
        expect(results.every((r) => r.financialYear == '2024-25'), isTrue);
      });

      test('returns empty list when no filings match year', () async {
        const client = 'client-year-none-mca';
        final results = await database.mcaDao.getMCAFilingsByYear(
          client,
          '1999-00',
        );
        expect(results, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // getMCAFilingsByStatus
    // -------------------------------------------------------------------------

    group('getMCAFilingsByStatus', () {
      test('returns filings with given status', () async {
        final f1 = createTestFiling(status: 'approved');
        final f2 = createTestFiling(status: 'approved');
        final f3 = createTestFiling(status: 'pending');

        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f1));
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f2));
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f3));

        final results = await database.mcaDao.getMCAFilingsByStatus('approved');
        expect(results.length, greaterThanOrEqualTo(2));
        expect(results.every((r) => r.status == 'approved'), isTrue);
      });

      test('returns empty list for status with no filings', () async {
        final results = await database.mcaDao.getMCAFilingsByStatus(
          'nonexistent_status',
        );
        expect(results, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // getDueMCAFilings
    // -------------------------------------------------------------------------

    group('getDueMCAFilings', () {
      test('returns filings due within specified days', () async {
        final today = DateTime.now();
        final inThreeDays = today.add(const Duration(days: 3));
        final inEightDays = today.add(const Duration(days: 8));

        final f1 = createTestFiling(dueDate: inThreeDays, status: 'pending');
        final f2 = createTestFiling(dueDate: inEightDays, status: 'pending');

        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f1));
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(f2));

        final due = await database.mcaDao.getDueMCAFilings(7);
        expect(due.any((r) => r.id == f1.id), isTrue);
        expect(due.any((r) => r.id == f2.id), isFalse);
      });

      test('excludes filed filings from due results', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final filing = createTestFiling(dueDate: tomorrow, status: 'filed');
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));

        final due = await database.mcaDao.getDueMCAFilings(7);
        expect(due.any((r) => r.id == filing.id), isFalse);
      });

      test('excludes approved filings from due results', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final filing = createTestFiling(dueDate: tomorrow, status: 'approved');
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));

        final due = await database.mcaDao.getDueMCAFilings(7);
        expect(due.any((r) => r.id == filing.id), isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // getMCAFilingById
    // -------------------------------------------------------------------------

    group('getMCAFilingById', () {
      test('retrieves filing by ID', () async {
        final filing = createTestFiling();
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));

        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved, isNotNull);
        expect(retrieved?.id, filing.id);
      });

      test('returns null for non-existent ID', () async {
        final retrieved = await database.mcaDao.getMCAFilingById(
          'non-existent-mca-id',
        );
        expect(retrieved, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // updateMCAFiling
    // -------------------------------------------------------------------------

    group('updateMCAFiling', () {
      test('updates filing status successfully', () async {
        final filing = createTestFiling(status: 'pending');
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));

        final updated = filing.copyWith(
          status: 'filed',
          filingNumber: 'G55556666',
          filedDate: DateTime(2025, 10, 28),
        );
        final success = await database.mcaDao.updateMCAFiling(
          McaMapper.toCompanion(updated),
        );
        expect(success, isTrue);

        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.status, 'filed');
        expect(retrieved?.filingNumber, 'G55556666');
      });

      test('updates formType successfully', () async {
        final filing = createTestFiling(formType: MCAFormType.aoc4);
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));

        final updated = filing.copyWith(formType: MCAFormType.dpt3);
        await database.mcaDao.updateMCAFiling(McaMapper.toCompanion(updated));

        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.formType, MCAFormType.dpt3.name);
      });

      test('updates remarks successfully', () async {
        final filing = createTestFiling();
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));

        final updated = filing.copyWith(remarks: 'Updated remarks');
        await database.mcaDao.updateMCAFiling(McaMapper.toCompanion(updated));

        final retrieved = await database.mcaDao.getMCAFilingById(filing.id);
        expect(retrieved?.remarks, 'Updated remarks');
      });
    });

    // -------------------------------------------------------------------------
    // watchMCAFilingsByClient
    // -------------------------------------------------------------------------

    group('watchMCAFilingsByClient', () {
      test('emits filings for client on watch', () async {
        final filing = createTestFiling();
        await database.mcaDao.insertMCAFiling(McaMapper.toCompanion(filing));

        final stream = database.mcaDao.watchMCAFilingsByClient(filing.clientId);
        expect(
          stream,
          emits(
            isA<List<MCAFilingsTableData>>().having(
              (rows) => rows.isNotEmpty,
              'has filings',
              true,
            ),
          ),
        );
      });
    });

    // -------------------------------------------------------------------------
    // MCAFormType enum safety
    // -------------------------------------------------------------------------

    group('MCAFormType enum safety', () {
      test('_safeFormType falls back to other for unknown value', () {
        final result = McaMapper.fromJson({
          'id': 'safe-test-001',
          'client_id': 'client-safe',
          'form_type': 'unknown_form_xyz',
          'financial_year': '2024-25',
          'due_date': DateTime(2025, 10, 31).toIso8601String(),
          'status': 'pending',
        });
        expect(result.formType, MCAFormType.other);
      });

      test('all valid MCAFormType names round-trip through mapper', () {
        for (final formType in MCAFormType.values) {
          final filing = McaFilingData(
            id: 'round-trip-${formType.name}',
            clientId: 'client-rt',
            formType: formType,
            financialYear: '2024-25',
            dueDate: DateTime(2025, 10, 31),
            status: 'pending',
          );
          final json = McaMapper.toJson(filing);
          final restored = McaMapper.fromJson({
            ...json,
            'client_id': json['client_id'],
            'form_type': json['form_type'],
            'financial_year': json['financial_year'],
            'due_date': json['due_date'],
            'status': json['status'],
          });
          expect(restored.formType, formType);
        }
      });
    });

    // -------------------------------------------------------------------------
    // Immutability
    // -------------------------------------------------------------------------

    group('Immutability', () {
      test('McaFilingData has copyWith for immutable updates', () {
        final f1 = createTestFiling();
        final f2 = f1.copyWith(status: 'filed');

        expect(f1.status, 'pending');
        expect(f2.status, 'filed');
        expect(f1.id, f2.id);
      });

      test('copyWith preserves all unmodified fields', () {
        final f1 = createTestFiling(
          formType: MCAFormType.dir3,
          financialYear: '2024-25',
          remarks: 'Original remark',
        );
        final f2 = f1.copyWith(status: 'approved');

        expect(f2.clientId, f1.clientId);
        expect(f2.formType, MCAFormType.dir3);
        expect(f2.financialYear, '2024-25');
        expect(f2.remarks, 'Original remark');
      });

      test('copyWith can update filedDate without affecting other fields', () {
        final filed = DateTime(2025, 11, 1);
        final f1 = createTestFiling();
        final f2 = f1.copyWith(filedDate: filed, status: 'filed');

        expect(f2.filedDate, filed);
        expect(f2.id, f1.id);
        expect(f2.formType, f1.formType);
      });
    });
  });
}
