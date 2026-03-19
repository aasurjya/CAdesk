import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/filing/domain/models/filing_record.dart';
import 'package:ca_app/features/filing/data/mappers/filing_record_mapper.dart';

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

  group('FilingRecordsDao', () {
    FilingRecord createTestRecord({
      String? id,
      String? clientId,
      FilingType? filingType,
      String? financialYear,
      FilingStatus? status,
      DateTime? filedDate,
      String? acknowledgementNumber,
      String? remarks,
      DateTime? createdAt,
    }) {
      testCounter++;
      return FilingRecord(
        id: id ?? 'fr-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        filingType: filingType ?? FilingType.itr1,
        financialYear: financialYear ?? '2024-25',
        status: status ?? FilingStatus.pending,
        filedDate: filedDate,
        acknowledgementNumber: acknowledgementNumber,
        remarks: remarks,
        createdAt: createdAt ?? DateTime(2025, 4, 1),
        updatedAt: DateTime(2025, 4, 1),
      );
    }

    group('insertRecord', () {
      test('inserts record and returns non-empty ID', () async {
        final record = createTestRecord();
        final companion = FilingRecordMapper.toCompanion(record);
        final id = await database.filingRecordsDao.insertRecord(companion);
        expect(id, isNotEmpty);
      });

      test('stored record has correct clientId', () async {
        final record = createTestRecord();
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.filingRecordsDao.getById(record.id);
        expect(retrieved?.clientId, record.clientId);
      });

      test('stored record has correct filingType', () async {
        final record = createTestRecord(filingType: FilingType.gstr3b);
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.filingRecordsDao.getById(record.id);
        final domain = retrieved != null
            ? FilingRecordMapper.fromRow(retrieved)
            : null;
        expect(domain?.filingType, FilingType.gstr3b);
      });

      test('stored record has correct financialYear', () async {
        final record = createTestRecord(financialYear: '2023-24');
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.filingRecordsDao.getById(record.id);
        expect(retrieved?.financialYear, '2023-24');
      });

      test('stored record has correct status', () async {
        final record = createTestRecord(status: FilingStatus.filed);
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.filingRecordsDao.getById(record.id);
        final domain = retrieved != null
            ? FilingRecordMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, FilingStatus.filed);
      });

      test('stored record preserves optional acknowledgementNumber', () async {
        final record = createTestRecord(
          acknowledgementNumber: 'ITR-ACK-2025-999',
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );
        final retrieved = await database.filingRecordsDao.getById(record.id);
        expect(retrieved?.acknowledgementNumber, 'ITR-ACK-2025-999');
      });
    });

    group('getByClient', () {
      test('returns records for specific client', () async {
        const clientId = 'test-client-get-by-client-a';
        final r1 = createTestRecord(clientId: clientId);
        final r2 = createTestRecord(clientId: clientId);
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r1),
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r2),
        );

        final results = await database.filingRecordsDao.getByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.filingRecordsDao.getByClient(
          'non-existent-client-xyz',
        );
        expect(results, isEmpty);
      });

      test('filters records by client correctly', () async {
        const clientA = 'client-filter-fa-1';
        const clientB = 'client-filter-fb-1';
        final r1 = createTestRecord(clientId: clientA);
        final r2 = createTestRecord(clientId: clientB);
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r1),
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r2),
        );

        final results = await database.filingRecordsDao.getByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getByType', () {
      test('returns records of specific filing type', () async {
        final r1 = createTestRecord(filingType: FilingType.itr2);
        final r2 = createTestRecord(filingType: FilingType.itr2);
        final r3 = createTestRecord(filingType: FilingType.gstr1);
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r1),
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r2),
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r3),
        );

        final results = await database.filingRecordsDao.getByType(
          FilingType.itr2.name,
        );
        expect(results.length, greaterThanOrEqualTo(2));
        expect(
          results.every((r) => r.filingType == FilingType.itr2.name),
          isTrue,
        );
      });

      test('returns empty list for type with no records', () async {
        final results = await database.filingRecordsDao.getByType(
          FilingType.itr7.name,
        );
        expect(results, isEmpty);
      });
    });

    group('getByStatus', () {
      test('returns records with specific status', () async {
        final r1 = createTestRecord(status: FilingStatus.verified);
        final r2 = createTestRecord(status: FilingStatus.verified);
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r1),
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(r2),
        );

        final results = await database.filingRecordsDao.getByStatus(
          FilingStatus.verified.name,
        );
        expect(results.length, greaterThanOrEqualTo(2));
        expect(
          results.every((r) => r.status == FilingStatus.verified.name),
          isTrue,
        );
      });
    });

    group('updateStatus', () {
      test('updates status from pending to filed', () async {
        final record = createTestRecord(status: FilingStatus.pending);
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );

        final success = await database.filingRecordsDao.updateStatus(
          record.id,
          FilingStatus.filed.name,
        );
        expect(success, isTrue);

        final retrieved = await database.filingRecordsDao.getById(record.id);
        final domain = retrieved != null
            ? FilingRecordMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, FilingStatus.filed);
      });

      test('updates status to rejected', () async {
        final record = createTestRecord();
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );

        await database.filingRecordsDao.updateStatus(
          record.id,
          FilingStatus.rejected.name,
        );

        final retrieved = await database.filingRecordsDao.getById(record.id);
        final domain = retrieved != null
            ? FilingRecordMapper.fromRow(retrieved)
            : null;
        expect(domain?.status, FilingStatus.rejected);
      });

      test('returns false for non-existent ID', () async {
        final success = await database.filingRecordsDao.updateStatus(
          'non-existent-id-xyz',
          FilingStatus.filed.name,
        );
        expect(success, isFalse);
      });
    });

    group('getOverdue', () {
      test('returns records with no filedDate and old createdAt', () async {
        final oldDate = DateTime.now().subtract(const Duration(days: 45));
        final record = createTestRecord(
          status: FilingStatus.pending,
          createdAt: oldDate,
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );

        final overdue = await database.filingRecordsDao.getOverdue();
        expect(overdue.where((r) => r.id == record.id).isNotEmpty, isTrue);
      });

      test('excludes records with filedDate set', () async {
        final oldDate = DateTime.now().subtract(const Duration(days: 45));
        final record = createTestRecord(
          status: FilingStatus.filed,
          filedDate: DateTime(2025, 7, 15),
          createdAt: oldDate,
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );

        final overdue = await database.filingRecordsDao.getOverdue();
        expect(overdue.where((r) => r.id == record.id).isEmpty, isTrue);
      });

      test('excludes recent pending records (within 30 days)', () async {
        final record = createTestRecord(
          status: FilingStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        );
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );

        final overdue = await database.filingRecordsDao.getOverdue();
        expect(overdue.where((r) => r.id == record.id).isEmpty, isTrue);
      });
    });

    group('getById', () {
      test('retrieves record by ID', () async {
        final record = createTestRecord();
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );

        final retrieved = await database.filingRecordsDao.getById(record.id);
        expect(retrieved != null, isTrue);
        expect(retrieved?.id, record.id);
      });

      test('returns null for non-existent ID', () async {
        final retrieved = await database.filingRecordsDao.getById(
          'non-existent-id-abc',
        );
        expect(retrieved == null, isTrue);
      });
    });

    group('watchByClient', () {
      test('emits records for client on watch', () async {
        final record = createTestRecord();
        await database.filingRecordsDao.insertRecord(
          FilingRecordMapper.toCompanion(record),
        );

        final stream = database.filingRecordsDao.watchByClient(record.clientId);
        expect(
          stream,
          emits(
            isA<List<FilingRecordRow>>().having(
              (rows) => rows.isNotEmpty,
              'has records',
              true,
            ),
          ),
        );
      });
    });

    group('Immutability', () {
      test('FilingRecord has copyWith for immutable updates', () {
        final r1 = createTestRecord();
        final r2 = r1.copyWith(status: FilingStatus.filed);

        expect(r1.status, FilingStatus.pending);
        expect(r2.status, FilingStatus.filed);
        expect(r1.id, r2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final r1 = createTestRecord(
          financialYear: '2024-25',
          filingType: FilingType.itr3,
        );
        final r2 = r1.copyWith(status: FilingStatus.inProgress);

        expect(r2.clientId, r1.clientId);
        expect(r2.financialYear, '2024-25');
        expect(r2.filingType, FilingType.itr3);
      });

      test('FilingRecord equality is based on id', () {
        testCounter++;
        final r1 = FilingRecord(
          id: 'same-id',
          clientId: 'c1',
          filingType: FilingType.itr1,
          financialYear: '2024-25',
          status: FilingStatus.pending,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
        );
        final r2 = FilingRecord(
          id: 'same-id',
          clientId: 'c2',
          filingType: FilingType.gstr1,
          financialYear: '2023-24',
          status: FilingStatus.filed,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );
        expect(r1, equals(r2));
        expect(r1.hashCode, equals(r2.hashCode));
      });
    });
  });
}
