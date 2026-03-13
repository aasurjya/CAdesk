import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_transaction.dart';
import 'package:ca_app/features/transfer_pricing/data/mappers/tp_transaction_mapper.dart';

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

  TpTransaction createTransaction({
    String? id,
    String? clientId,
    String? assessmentYear,
    String? relatedParty,
    String? transactionType,
    double? transactionValue,
    TpMethod? tpMethod,
    DateTime? documentationDue,
    TpStatus? status,
  }) {
    counter++;
    return TpTransaction(
      id: id ?? 'tp-$counter',
      clientId: clientId ?? 'client-$counter',
      assessmentYear: assessmentYear ?? '2024-25',
      relatedParty: relatedParty ?? 'Related Corp $counter',
      transactionType: transactionType ?? 'Service',
      transactionValue: transactionValue ?? 1000000.0,
      tpMethod: tpMethod ?? TpMethod.tnmm,
      documentationDue: documentationDue,
      status: status ?? TpStatus.draft,
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
    );
  }

  group('TpDao', () {
    group('insertTransaction', () {
      test('inserts transaction and retrieves it by ID', () async {
        final tx = createTransaction();
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final row = await database.tpDao.getById(tx.id);
        expect(row, isNotNull);
        expect(row!.id, tx.id);
      });

      test('stored transaction has correct clientId', () async {
        final tx = createTransaction(clientId: 'tp-client-a');
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final row = await database.tpDao.getById(tx.id);
        expect(row?.clientId, 'tp-client-a');
      });

      test('stored transaction has correct assessmentYear', () async {
        final tx = createTransaction(assessmentYear: '2023-24');
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final row = await database.tpDao.getById(tx.id);
        expect(row?.assessmentYear, '2023-24');
      });

      test('stored transaction has correct relatedParty', () async {
        final tx = createTransaction(relatedParty: 'XYZ Singapore Ltd');
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final row = await database.tpDao.getById(tx.id);
        expect(row?.relatedParty, 'XYZ Singapore Ltd');
      });

      test('stored transaction has correct transactionValue', () async {
        final tx = createTransaction(transactionValue: 50000000.0);
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final row = await database.tpDao.getById(tx.id);
        expect(row?.transactionValue, 50000000.0);
      });

      test('stored transaction has correct tpMethod', () async {
        final tx = createTransaction(tpMethod: TpMethod.cup);
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final row = await database.tpDao.getById(tx.id);
        final domain = TpTransactionMapper.fromRow(row!);
        expect(domain.tpMethod, TpMethod.cup);
      });

      test('stored transaction preserves documentationDue', () async {
        final dueDate = DateTime(2025, 9, 30);
        final tx = createTransaction(documentationDue: dueDate);
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final row = await database.tpDao.getById(tx.id);
        final domain = TpTransactionMapper.fromRow(row!);
        expect(domain.documentationDue?.year, 2025);
        expect(domain.documentationDue?.month, 9);
      });

      test('upsert replaces existing record with same ID', () async {
        final tx = createTransaction(status: TpStatus.draft);
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final updated = tx.copyWith(status: TpStatus.filed);
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(updated),
        );
        final row = await database.tpDao.getById(tx.id);
        expect(row?.status, 'filed');
      });
    });

    group('getByClient', () {
      test('returns transactions for specified client', () async {
        final clientId = 'tp-client-unique-b';
        final t1 = createTransaction(clientId: clientId);
        final t2 = createTransaction(clientId: clientId);
        await database.tpDao.insertTransaction(TpTransactionMapper.toCompanion(t1));
        await database.tpDao.insertTransaction(TpTransactionMapper.toCompanion(t2));
        final rows = await database.tpDao.getByClient(clientId);
        expect(rows.length, greaterThanOrEqualTo(2));
      });

      test('returns empty for non-existent client', () async {
        final rows = await database.tpDao.getByClient('ghost-tp-client');
        expect(rows, isEmpty);
      });

      test('filters by client correctly', () async {
        final cA = 'tp-filter-client-a';
        final cB = 'tp-filter-client-b';
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(createTransaction(clientId: cA)),
        );
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(createTransaction(clientId: cB)),
        );
        final rows = await database.tpDao.getByClient(cA);
        expect(rows.every((r) => r.clientId == cA), isTrue);
      });
    });

    group('getByYear', () {
      test('returns transactions for specified year', () async {
        final tx = createTransaction(assessmentYear: '2026-27');
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final rows = await database.tpDao.getByYear('2026-27');
        expect(rows.any((r) => r.id == tx.id), isTrue);
      });

      test('returns empty for non-existent year', () async {
        final rows = await database.tpDao.getByYear('1980-81');
        expect(rows, isEmpty);
      });
    });

    group('updateStatus', () {
      test('updates status to filed successfully', () async {
        final tx = createTransaction(status: TpStatus.draft);
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final ok = await database.tpDao.updateStatus(tx.id, 'filed');
        expect(ok, isTrue);
        final row = await database.tpDao.getById(tx.id);
        expect(row?.status, 'filed');
      });

      test('returns false for non-existent ID', () async {
        final ok = await database.tpDao.updateStatus('ghost', 'filed');
        expect(ok, isFalse);
      });

      test('updateStatus marks isDirty', () async {
        final tx = createTransaction();
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        await database.tpDao.updateStatus(tx.id, TpStatus.underReview.name);
        final row = await database.tpDao.getById(tx.id);
        expect(row?.isDirty, isTrue);
      });
    });

    group('getByMethod', () {
      test('returns only transactions with specified method', () async {
        final tx = createTransaction(tpMethod: TpMethod.psm);
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        final rows = await database.tpDao.getByMethod(TpMethod.psm.name);
        expect(rows.any((r) => r.id == tx.id), isTrue);
        expect(rows.every((r) => r.tpMethod == 'psm'), isTrue);
      });

      test('returns empty for method with no records', () async {
        final rows = await database.tpDao.getByMethod(TpMethod.other.name);
        expect(rows, isEmpty);
      });
    });

    group('deleteTransaction', () {
      test('deletes an existing transaction', () async {
        final tx = createTransaction();
        await database.tpDao.insertTransaction(
          TpTransactionMapper.toCompanion(tx),
        );
        await database.tpDao.deleteTransaction(tx.id);
        final row = await database.tpDao.getById(tx.id);
        expect(row, isNull);
      });

      test('delete non-existent ID does not throw', () async {
        await expectLater(
          database.tpDao.deleteTransaction('ghost-tp'),
          completes,
        );
      });
    });

    group('Immutability', () {
      test('TpTransaction copyWith creates new instance', () {
        final t1 = createTransaction(status: TpStatus.draft);
        final t2 = t1.copyWith(status: TpStatus.filed);
        expect(t1.status, TpStatus.draft);
        expect(t2.status, TpStatus.filed);
        expect(t1.id, t2.id);
      });

      test('copyWith preserves all unchanged fields', () {
        final t1 = createTransaction(
          relatedParty: 'ABC Corp',
          transactionValue: 9999999.0,
          tpMethod: TpMethod.cpm,
        );
        final t2 = t1.copyWith(status: TpStatus.underReview);
        expect(t2.relatedParty, 'ABC Corp');
        expect(t2.transactionValue, 9999999.0);
        expect(t2.tpMethod, TpMethod.cpm);
        expect(t2.clientId, t1.clientId);
      });
    });
  });
}
