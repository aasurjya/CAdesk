import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/startup/domain/models/startup_record.dart';
import 'package:ca_app/features/startup/data/mappers/startup_mapper.dart';

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

  group('StartupDao', () {
    StartupRecord createTestRecord({
      String? id,
      String? clientId,
      String? dpiitNumber,
      String? recognitionStatus,
      bool? section80IacEligible,
      bool? section56ExemptEligible,
      String? sectorCategory,
    }) {
      testCounter++;
      return StartupRecord(
        id: id ?? 'startup-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        dpiitNumber: dpiitNumber ?? 'DIPP$testCounter',
        incorporationDate: DateTime(2020, 1, 1),
        sectorCategory: sectorCategory ?? 'fintech',
        recognitionStatus: recognitionStatus ?? 'recognised',
        section80IacEligible: section80IacEligible ?? false,
        section56ExemptEligible: section56ExemptEligible ?? false,
      );
    }

    group('insertStartupRecord', () {
      test('inserts record and returns non-empty ID', () async {
        final record = createTestRecord();
        final id = await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));
        expect(id, isNotEmpty);
      });

      test('stored record has correct clientId', () async {
        final record =
            createTestRecord(clientId: 'startup-insert-client');
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));
        final rows = await database.startupDao
            .getStartupRecordsByClient('startup-insert-client');
        expect(rows.any((r) => r.id == record.id), isTrue);
      });

      test('stored record has correct dpiitNumber', () async {
        final record = createTestRecord(dpiitNumber: 'DIPP99999');
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));
        final rows = await database.startupDao
            .getStartupRecordsByClient(record.clientId);
        final row = rows.firstWhere((r) => r.id == record.id);
        expect(row.dpiitNumber, 'DIPP99999');
      });

      test('stored record preserves section80IacEligible flag', () async {
        final record = createTestRecord(section80IacEligible: true);
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));
        final rows = await database.startupDao
            .getStartupRecordsByClient(record.clientId);
        final row = rows.firstWhere((r) => r.id == record.id);
        expect(row.section80IacEligible, isTrue);
      });

      test('stored record preserves section56ExemptEligible flag', () async {
        final record = createTestRecord(section56ExemptEligible: true);
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));
        final rows = await database.startupDao
            .getStartupRecordsByClient(record.clientId);
        final row = rows.firstWhere((r) => r.id == record.id);
        expect(row.section56ExemptEligible, isTrue);
      });
    });

    group('getStartupRecordsByClient', () {
      test('returns records for specific client', () async {
        final clientId = 'startup-by-client-x';
        final r1 = createTestRecord(clientId: clientId);
        final r2 = createTestRecord(clientId: clientId);
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(r1));
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(r2));

        final results =
            await database.startupDao.getStartupRecordsByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.startupDao
            .getStartupRecordsByClient('no-such-client');
        expect(results, isEmpty);
      });

      test('filters records by client correctly', () async {
        final clientA = 'startup-filter-a';
        final clientB = 'startup-filter-b';
        await database.startupDao.insertStartupRecord(
          StartupMapper.toCompanion(createTestRecord(clientId: clientA)),
        );
        await database.startupDao.insertStartupRecord(
          StartupMapper.toCompanion(createTestRecord(clientId: clientB)),
        );

        final results =
            await database.startupDao.getStartupRecordsByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getStartupRecordsByStatus', () {
      test('returns records with matching status', () async {
        final record =
            createTestRecord(recognitionStatus: 'recognised');
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));

        final results = await database.startupDao
            .getStartupRecordsByStatus('recognised');
        expect(results.any((r) => r.id == record.id), isTrue);
      });

      test('excludes records with different status', () async {
        final record =
            createTestRecord(recognitionStatus: 'pending');
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));

        final results = await database.startupDao
            .getStartupRecordsByStatus('recognised');
        expect(results.where((r) => r.id == record.id), isEmpty);
      });
    });

    group('getEligibleForExemptions', () {
      test('returns records with section80IacEligible=true', () async {
        final record = createTestRecord(
          section80IacEligible: true,
          section56ExemptEligible: false,
        );
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));

        final results =
            await database.startupDao.getEligibleForExemptions();
        expect(results.any((r) => r.id == record.id), isTrue);
      });

      test('returns records with section56ExemptEligible=true', () async {
        final record = createTestRecord(
          section80IacEligible: false,
          section56ExemptEligible: true,
        );
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));

        final results =
            await database.startupDao.getEligibleForExemptions();
        expect(results.any((r) => r.id == record.id), isTrue);
      });

      test('excludes records with both flags false', () async {
        final record = createTestRecord(
          section80IacEligible: false,
          section56ExemptEligible: false,
        );
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));

        final results =
            await database.startupDao.getEligibleForExemptions();
        // The record should not be in the results (unless it was inserted as
        // eligible previously — use unique IDs to verify)
        expect(
          results.where((r) => r.id == record.id),
          isEmpty,
        );
      });
    });

    group('updateStartupRecord', () {
      test('updates recognitionStatus correctly', () async {
        final record = createTestRecord(recognitionStatus: 'pending');
        await database.startupDao
            .insertStartupRecord(StartupMapper.toCompanion(record));

        final updated = record.copyWith(recognitionStatus: 'recognised');
        final success = await database.startupDao
            .updateStartupRecord(StartupMapper.toCompanion(updated));
        expect(success, isTrue);

        final rows = await database.startupDao
            .getStartupRecordsByClient(record.clientId);
        final row = rows.firstWhere((r) => r.id == record.id);
        expect(row.recognitionStatus, 'recognised');
      });
    });

    group('Immutability', () {
      test('StartupRecord has copyWith for immutable updates', () {
        final r1 = createTestRecord(recognitionStatus: 'pending');
        final r2 = r1.copyWith(recognitionStatus: 'recognised');

        expect(r1.recognitionStatus, 'pending');
        expect(r2.recognitionStatus, 'recognised');
        expect(r1.id, r2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final r1 = createTestRecord(
          dpiitNumber: 'DIPP00042',
          sectorCategory: 'agritech',
        );
        final r2 = r1.copyWith(recognitionStatus: 'expired');

        expect(r2.clientId, r1.clientId);
        expect(r2.dpiitNumber, 'DIPP00042');
        expect(r2.sectorCategory, 'agritech');
      });
    });
  });
}
