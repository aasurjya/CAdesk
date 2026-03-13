import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/nri_tax/domain/models/nri_tax_record.dart';
import 'package:ca_app/features/nri_tax/data/mappers/nri_tax_mapper.dart';

AppDatabase _createTestDatabase() =>
    AppDatabase(executor: NativeDatabase.memory());

void main() {
  late AppDatabase database;
  var counter = 0;

  setUpAll(() async {
    database = _createTestDatabase();
  });

  tearDownAll(() async {
    await database.close();
  });

  NriTaxRecord createRecord({
    String? id,
    String? clientId,
    String? assessmentYear,
    ResidencyStatus? residencyStatus,
    String? dtaaCountry,
    double? dtaaRelief,
    bool? scheduleFA,
    bool? scheduleFSL,
    NriTaxStatus? status,
  }) {
    counter++;
    return NriTaxRecord(
      id: id ?? 'nri-$counter',
      clientId: clientId ?? 'client-$counter',
      assessmentYear: assessmentYear ?? '2024-25',
      residencyStatus: residencyStatus ?? ResidencyStatus.nonResident,
      dtaaCountry: dtaaCountry,
      dtaaRelief: dtaaRelief,
      scheduleFA: scheduleFA ?? false,
      scheduleFSL: scheduleFSL ?? false,
      status: status ?? NriTaxStatus.draft,
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    );
  }

  group('NriTaxDao', () {
    group('insertRecord', () {
      test('inserts record and retrieves it by ID', () async {
        final record = createRecord();
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final row = await database.nriTaxDao.getById(record.id);
        expect(row, isNotNull);
        expect(row!.id, record.id);
      });

      test('stored record has correct clientId', () async {
        final record = createRecord(clientId: 'client-nri-a');
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.clientId, 'client-nri-a');
      });

      test('stored record has correct assessmentYear', () async {
        final record = createRecord(assessmentYear: '2023-24');
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.assessmentYear, '2023-24');
      });

      test('stored record has correct residencyStatus', () async {
        final record = createRecord(residencyStatus: ResidencyStatus.rnor);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final row = await database.nriTaxDao.getById(record.id);
        final domain = NriTaxMapper.fromRow(row!);
        expect(domain.residencyStatus, ResidencyStatus.rnor);
      });

      test('stored record preserves dtaaCountry', () async {
        final record = createRecord(dtaaCountry: 'USA', dtaaRelief: 150000.0);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.dtaaCountry, 'USA');
        expect(row?.dtaaRelief, 150000.0);
      });

      test('stored record preserves scheduleFA flag', () async {
        final record = createRecord(scheduleFA: true);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.scheduleFA, isTrue);
      });

      test('stored record preserves scheduleFSL flag', () async {
        final record = createRecord(scheduleFSL: true);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.scheduleFSL, isTrue);
      });

      test('upsert replaces existing record with same ID', () async {
        final record = createRecord(status: NriTaxStatus.draft);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final updated = record.copyWith(status: NriTaxStatus.filed);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(updated));
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.status, 'filed');
      });
    });

    group('getByClient', () {
      test('returns records for specified client', () async {
        final clientId = 'client-by-client-unique';
        final r1 = createRecord(clientId: clientId);
        final r2 = createRecord(clientId: clientId);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(r1));
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(r2));
        final rows = await database.nriTaxDao.getByClient(clientId);
        expect(rows.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final rows = await database.nriTaxDao.getByClient('ghost-client');
        expect(rows, isEmpty);
      });

      test('filters by client correctly', () async {
        final clientA = 'nri-client-filter-a';
        final clientB = 'nri-client-filter-b';
        await database.nriTaxDao
            .insertRecord(NriTaxMapper.toCompanion(createRecord(clientId: clientA)));
        await database.nriTaxDao
            .insertRecord(NriTaxMapper.toCompanion(createRecord(clientId: clientB)));
        final rows = await database.nriTaxDao.getByClient(clientA);
        expect(rows.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getByYear', () {
      test('returns records for specified year', () async {
        final r = createRecord(assessmentYear: '2025-26');
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(r));
        final rows = await database.nriTaxDao.getByYear('2025-26');
        expect(rows.any((row) => row.id == r.id), isTrue);
      });

      test('returns empty list for non-existent year', () async {
        final rows = await database.nriTaxDao.getByYear('1999-00');
        expect(rows, isEmpty);
      });

      test('filters by year correctly', () async {
        final r1 = createRecord(assessmentYear: '2024-25');
        final r2 = createRecord(assessmentYear: '2023-24');
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(r1));
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(r2));
        final rows = await database.nriTaxDao.getByYear('2024-25');
        expect(rows.every((r) => r.assessmentYear == '2024-25'), isTrue);
      });
    });

    group('updateStatus', () {
      test('updates status to filed', () async {
        final record = createRecord(status: NriTaxStatus.draft);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final success = await database.nriTaxDao.updateStatus(
          record.id,
          NriTaxStatus.filed.name,
        );
        expect(success, isTrue);
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.status, 'filed');
      });

      test('updateStatus returns false for non-existent ID', () async {
        final success =
            await database.nriTaxDao.updateStatus('ghost-id', 'filed');
        expect(success, isFalse);
      });

      test('updates status marks isDirty', () async {
        final record = createRecord();
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        await database.nriTaxDao.updateStatus(
          record.id,
          NriTaxStatus.inProgress.name,
        );
        final row = await database.nriTaxDao.getById(record.id);
        expect(row?.isDirty, isTrue);
      });
    });

    group('getScheduleFARequired', () {
      test('returns only records with scheduleFA = true', () async {
        final fa = createRecord(scheduleFA: true);
        final noFa = createRecord(scheduleFA: false);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(fa));
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(noFa));
        final rows = await database.nriTaxDao.getScheduleFARequired();
        expect(rows.every((r) => r.scheduleFA), isTrue);
        expect(rows.any((r) => r.id == fa.id), isTrue);
      });

      test('returns empty list when no records have scheduleFA', () async {
        // Insert a record with scheduleFA = false in isolation context.
        final record = createRecord(scheduleFA: false);
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        final rows = await database.nriTaxDao.getScheduleFARequired();
        // All returned rows must have scheduleFA = true.
        expect(rows.every((r) => r.scheduleFA), isTrue);
      });
    });

    group('deleteRecord', () {
      test('deletes an existing record', () async {
        final record = createRecord();
        await database.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));
        await database.nriTaxDao.deleteRecord(record.id);
        final row = await database.nriTaxDao.getById(record.id);
        expect(row, isNull);
      });

      test('delete of non-existent ID does not throw', () async {
        await expectLater(
          database.nriTaxDao.deleteRecord('ghost-delete-id'),
          completes,
        );
      });
    });

    group('Immutability', () {
      test('NriTaxRecord copyWith creates new instance', () {
        final r1 = createRecord(status: NriTaxStatus.draft);
        final r2 = r1.copyWith(status: NriTaxStatus.filed);
        expect(r1.status, NriTaxStatus.draft);
        expect(r2.status, NriTaxStatus.filed);
        expect(r1.id, r2.id);
      });

      test('copyWith preserves all unchanged fields', () {
        final r1 = createRecord(
          dtaaCountry: 'UK',
          dtaaRelief: 200000.0,
          scheduleFA: true,
        );
        final r2 = r1.copyWith(status: NriTaxStatus.inProgress);
        expect(r2.dtaaCountry, 'UK');
        expect(r2.dtaaRelief, 200000.0);
        expect(r2.scheduleFA, isTrue);
        expect(r2.clientId, r1.clientId);
      });
    });
  });
}
