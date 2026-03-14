import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/vda/domain/models/vda_record.dart';
import 'package:ca_app/features/vda/data/mappers/vda_record_mapper.dart';

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

  VdaRecord createRecord({
    String? id,
    String? clientId,
    DateTime? transactionDate,
    String? assetType,
    double? buyPrice,
    double? sellPrice,
    double? quantity,
    double? gainLoss,
    double? tdsDeducted,
    String? exchange,
    String? assessmentYear,
  }) {
    counter++;
    return VdaRecord(
      id: id ?? 'vda-$counter',
      clientId: clientId ?? 'client-$counter',
      transactionDate: transactionDate ?? DateTime(2024, 6, 1),
      assetType: assetType ?? 'Bitcoin',
      buyPrice: buyPrice ?? 2000000.0,
      sellPrice: sellPrice ?? 2500000.0,
      quantity: quantity ?? 1.0,
      gainLoss: gainLoss ?? 500000.0,
      tdsDeducted: tdsDeducted ?? 25000.0,
      exchange: exchange,
      assessmentYear: assessmentYear ?? '2024-25',
    );
  }

  group('VdaDao', () {
    group('insertRecord', () {
      test('inserts record and retrieves by ID', () async {
        final record = createRecord();
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row, isNotNull);
        expect(row!.id, record.id);
      });

      test('stored record has correct clientId', () async {
        final record = createRecord(clientId: 'vda-client-a');
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.clientId, 'vda-client-a');
      });

      test('stored record has correct assetType', () async {
        final record = createRecord(assetType: 'Ethereum');
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.assetType, 'Ethereum');
      });

      test('stored record preserves buyPrice and sellPrice', () async {
        final record = createRecord(buyPrice: 100.0, sellPrice: 200.0);
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.buyPrice, 100.0);
        expect(row?.sellPrice, 200.0);
      });

      test('stored record preserves gainLoss', () async {
        final record = createRecord(gainLoss: -75000.0);
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.gainLoss, -75000.0);
      });

      test('stored record preserves tdsDeducted', () async {
        final record = createRecord(tdsDeducted: 5000.0);
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.tdsDeducted, 5000.0);
      });

      test('stored record preserves exchange (nullable)', () async {
        final record = createRecord(exchange: 'WazirX');
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.exchange, 'WazirX');
      });

      test('stored record handles null exchange', () async {
        final record = createRecord(exchange: null);
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.exchange, isNull);
      });

      test('stored record has correct assessmentYear', () async {
        final record = createRecord(assessmentYear: '2025-26');
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final row = await database.vdaDao.getById(record.id);
        expect(row?.assessmentYear, '2025-26');
      });

      test('upsert replaces existing record with same ID', () async {
        final record = createRecord(gainLoss: 100.0);
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        final updated = record.copyWith(gainLoss: 999.0);
        await database.vdaDao.insertRecord(
          VdaRecordMapper.toCompanion(updated),
        );
        final row = await database.vdaDao.getById(record.id);
        expect(row?.gainLoss, 999.0);
      });
    });

    group('getByClient', () {
      test('returns records for specified client', () async {
        final clientId = 'vda-client-unique';
        final r1 = createRecord(clientId: clientId);
        final r2 = createRecord(clientId: clientId);
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(r1));
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(r2));
        final rows = await database.vdaDao.getByClient(clientId);
        expect(rows.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final rows = await database.vdaDao.getByClient('ghost-vda-client');
        expect(rows, isEmpty);
      });

      test('filters by client correctly', () async {
        final cA = 'vda-filter-a';
        final cB = 'vda-filter-b';
        await database.vdaDao.insertRecord(
          VdaRecordMapper.toCompanion(createRecord(clientId: cA)),
        );
        await database.vdaDao.insertRecord(
          VdaRecordMapper.toCompanion(createRecord(clientId: cB)),
        );
        final rows = await database.vdaDao.getByClient(cA);
        expect(rows.every((r) => r.clientId == cA), isTrue);
      });
    });

    group('getByYear', () {
      test('returns records for specified year', () async {
        final r = createRecord(assessmentYear: '2026-27');
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(r));
        final rows = await database.vdaDao.getByYear('2026-27');
        expect(rows.any((row) => row.id == r.id), isTrue);
      });

      test('returns empty for non-existent year', () async {
        final rows = await database.vdaDao.getByYear('1995-96');
        expect(rows, isEmpty);
      });
    });

    group('getTotalGainLoss', () {
      test('computes correct total gain/loss', () async {
        final clientId = 'vda-gain-client';
        final ay = '2024-25';
        final r1 = createRecord(
          clientId: clientId,
          assessmentYear: ay,
          gainLoss: 200000.0,
        );
        final r2 = createRecord(
          clientId: clientId,
          assessmentYear: ay,
          gainLoss: -50000.0,
        );
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(r1));
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(r2));
        final total = await database.vdaDao.getTotalGainLoss(clientId, ay);
        expect(total, closeTo(150000.0, 0.01));
      });

      test('returns 0 for client with no records', () async {
        final total = await database.vdaDao.getTotalGainLoss(
          'ghost-gain',
          '2024-25',
        );
        expect(total, 0.0);
      });
    });

    group('getTdsDeducted', () {
      test('computes correct total TDS deducted', () async {
        final clientId = 'vda-tds-client';
        final ay = '2024-25';
        final r1 = createRecord(
          clientId: clientId,
          assessmentYear: ay,
          tdsDeducted: 10000.0,
        );
        final r2 = createRecord(
          clientId: clientId,
          assessmentYear: ay,
          tdsDeducted: 20000.0,
        );
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(r1));
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(r2));
        final total = await database.vdaDao.getTdsDeducted(clientId, ay);
        expect(total, closeTo(30000.0, 0.01));
      });

      test('returns 0 for client with no records', () async {
        final total = await database.vdaDao.getTdsDeducted(
          'ghost-tds',
          '2024-25',
        );
        expect(total, 0.0);
      });
    });

    group('deleteRecord', () {
      test('deletes an existing record', () async {
        final record = createRecord();
        await database.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));
        await database.vdaDao.deleteRecord(record.id);
        final row = await database.vdaDao.getById(record.id);
        expect(row, isNull);
      });

      test('delete of non-existent ID does not throw', () async {
        await expectLater(
          database.vdaDao.deleteRecord('ghost-vda-delete'),
          completes,
        );
      });
    });

    group('Immutability', () {
      test('VdaRecord copyWith creates new instance', () {
        final r1 = createRecord(gainLoss: 100.0);
        final r2 = r1.copyWith(gainLoss: 200.0);
        expect(r1.gainLoss, 100.0);
        expect(r2.gainLoss, 200.0);
        expect(r1.id, r2.id);
      });

      test('copyWith preserves all unchanged fields', () {
        final r1 = createRecord(
          assetType: 'NFT',
          exchange: 'OpenSea',
          tdsDeducted: 5000.0,
        );
        final r2 = r1.copyWith(gainLoss: -10000.0);
        expect(r2.assetType, 'NFT');
        expect(r2.exchange, 'OpenSea');
        expect(r2.tdsDeducted, 5000.0);
        expect(r2.clientId, r1.clientId);
      });
    });
  });
}
