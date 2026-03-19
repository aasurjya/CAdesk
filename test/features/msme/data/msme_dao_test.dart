import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/msme/domain/models/msme_record.dart';
import 'package:ca_app/features/msme/data/mappers/msme_mapper.dart';

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

  group('MsmeDao', () {
    MsmeRecord createTestRecord({
      String? id,
      String? clientId,
      String? udyamNumber,
      MsmeCategory? category,
      String? status,
    }) {
      testCounter++;
      return MsmeRecord(
        id: id ?? 'msme-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        udyamNumber: udyamNumber ?? 'UDYAM-MH-01-$testCounter',
        registrationDate: DateTime(2022, 4, 1),
        category: category ?? MsmeCategory.micro,
        annualTurnover: '5000000',
        employeeCount: 10,
        status: status ?? 'active',
      );
    }

    group('insertMsmeRecord', () {
      test('inserts record and returns non-empty ID', () async {
        final record = createTestRecord();
        final id = await database.msmeDao.insertMsmeRecord(
          MsmeMapper.toCompanion(record),
        );
        expect(id, isNotEmpty);
      });

      test('stored record has correct clientId', () async {
        final record = createTestRecord(clientId: 'msme-insert-client');
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));
        final rows = await database.msmeDao.getMsmeRecordsByClient(
          'msme-insert-client',
        );
        expect(rows.any((r) => r.id == record.id), isTrue);
      });

      test('stored record has correct udyamNumber', () async {
        final record = createTestRecord(udyamNumber: 'UDYAM-DL-07-0099999');
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));
        final rows = await database.msmeDao.getMsmeRecordsByClient(
          record.clientId,
        );
        final row = rows.firstWhere((r) => r.id == record.id);
        expect(row.udyamNumber, 'UDYAM-DL-07-0099999');
      });

      test('stored record has correct category', () async {
        final record = createTestRecord(category: MsmeCategory.medium);
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));
        final rows = await database.msmeDao.getMsmeRecordsByClient(
          record.clientId,
        );
        final row = rows.firstWhere((r) => r.id == record.id);
        final domain = MsmeMapper.fromRow(row);
        expect(domain.category, MsmeCategory.medium);
      });
    });

    group('getMsmeRecordsByClient', () {
      test('returns records for specific client', () async {
        const clientId = 'msme-by-client-x';
        final r1 = createTestRecord(clientId: clientId);
        final r2 = createTestRecord(clientId: clientId);
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(r1));
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(r2));

        final results = await database.msmeDao.getMsmeRecordsByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.msmeDao.getMsmeRecordsByClient(
          'no-such-client',
        );
        expect(results, isEmpty);
      });

      test('filters records by client correctly', () async {
        const clientA = 'msme-filter-a';
        const clientB = 'msme-filter-b';
        await database.msmeDao.insertMsmeRecord(
          MsmeMapper.toCompanion(createTestRecord(clientId: clientA)),
        );
        await database.msmeDao.insertMsmeRecord(
          MsmeMapper.toCompanion(createTestRecord(clientId: clientB)),
        );

        final results = await database.msmeDao.getMsmeRecordsByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getMsmeRecordsByCategory', () {
      test('returns records with matching category', () async {
        final record = createTestRecord(category: MsmeCategory.small);
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));

        final results = await database.msmeDao.getMsmeRecordsByCategory(
          MsmeCategory.small.name,
        );
        expect(results.any((r) => r.id == record.id), isTrue);
      });

      test('excludes records with different category', () async {
        final record = createTestRecord(category: MsmeCategory.medium);
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));

        final results = await database.msmeDao.getMsmeRecordsByCategory(
          MsmeCategory.micro.name,
        );
        expect(results.where((r) => r.id == record.id), isEmpty);
      });
    });

    group('getMsmeRecordsByStatus', () {
      test('returns records with matching status', () async {
        final record = createTestRecord(status: 'active');
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));

        final results = await database.msmeDao.getMsmeRecordsByStatus('active');
        expect(results.any((r) => r.id == record.id), isTrue);
      });

      test('returns empty for non-existent status', () async {
        final results = await database.msmeDao.getMsmeRecordsByStatus(
          'xyz-unknown',
        );
        expect(results, isEmpty);
      });
    });

    group('updateMsmeRecord', () {
      test('updates record fields correctly', () async {
        final record = createTestRecord(status: 'active');
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));

        final updated = record.copyWith(status: 'cancelled');
        final success = await database.msmeDao.updateMsmeRecord(
          MsmeMapper.toCompanion(updated),
        );
        expect(success, isTrue);

        final rows = await database.msmeDao.getMsmeRecordsByClient(
          record.clientId,
        );
        final row = rows.firstWhere((r) => r.id == record.id);
        expect(row.status, 'cancelled');
      });

      test('updates category correctly', () async {
        final record = createTestRecord(category: MsmeCategory.micro);
        await database.msmeDao.insertMsmeRecord(MsmeMapper.toCompanion(record));

        final updated = record.copyWith(category: MsmeCategory.small);
        await database.msmeDao.updateMsmeRecord(
          MsmeMapper.toCompanion(updated),
        );

        final rows = await database.msmeDao.getMsmeRecordsByClient(
          record.clientId,
        );
        final row = rows.firstWhere((r) => r.id == record.id);
        final domain = MsmeMapper.fromRow(row);
        expect(domain.category, MsmeCategory.small);
      });
    });

    group('Immutability', () {
      test('MsmeRecord has copyWith for immutable updates', () {
        final r1 = createTestRecord(status: 'active');
        final r2 = r1.copyWith(status: 'cancelled');

        expect(r1.status, 'active');
        expect(r2.status, 'cancelled');
        expect(r1.id, r2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final r1 = createTestRecord(
          udyamNumber: 'UDYAM-TEST-001',
          category: MsmeCategory.small,
        );
        final r2 = r1.copyWith(status: 'suspended');

        expect(r2.clientId, r1.clientId);
        expect(r2.udyamNumber, 'UDYAM-TEST-001');
        expect(r2.category, MsmeCategory.small);
      });

      test('MsmeCategory enum round-trips through mapper', () {
        for (final cat in MsmeCategory.values) {
          final record = createTestRecord(category: cat);
          final companion = MsmeMapper.toCompanion(record);
          expect(companion.category.value, cat.name);
        }
      });
    });
  });
}
