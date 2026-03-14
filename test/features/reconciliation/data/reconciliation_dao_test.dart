import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/reconciliation/data/daos/reconciliation_dao.dart';
import 'package:ca_app/features/reconciliation/data/mappers/reconciliation_mapper.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  late ReconciliationDao dao;
  int testCounter = 0;

  setUpAll(() async {
    database = _createTestDatabase();
    dao = ReconciliationDao(database);
  });

  tearDownAll(() async {
    await database.close();
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  ReconciliationResult makeResult({
    String? id,
    String? clientId,
    ReconciliationType? type,
    String? period,
    int? totalMatched,
    int? totalUnmatched,
    List<Discrepancy>? discrepancies,
    ReconciliationStatus? status,
    String? reviewedBy,
    DateTime? reviewedDate,
  }) {
    testCounter++;
    final rid = id ?? 'result-$testCounter';
    return ReconciliationResult(
      id: rid,
      clientId: clientId ?? 'client-$testCounter',
      reconciliationType: type ?? ReconciliationType.tds26as,
      period: period ?? 'FY 2024-25',
      totalMatched: totalMatched ?? 10,
      totalUnmatched: totalUnmatched ?? 2,
      discrepancies: discrepancies ?? const [],
      status: status ?? ReconciliationStatus.pending,
      reviewedBy: reviewedBy,
      reviewedDate: reviewedDate,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );
  }

  Discrepancy makeDiscrepancy({
    required String resultId,
    String? id,
    bool resolved = false,
  }) {
    testCounter++;
    return Discrepancy(
      id: id ?? 'disc-$testCounter',
      resultId: resultId,
      field: 'tds_amount',
      expectedValue: '50000',
      actualValue: '48000',
      source: '26AS',
      resolved: resolved,
    );
  }

  // ---------------------------------------------------------------------------
  // insertReconciliationResult
  // ---------------------------------------------------------------------------

  group('insertReconciliationResult', () {
    test('inserts result and returns non-empty ID', () async {
      final result = makeResult();
      final companion = ReconciliationMapper.toCompanion(result);
      final id = await dao.insertReconciliationResult(companion);
      expect(id, isNotEmpty);
      expect(id, equals(result.id));
    });

    test('inserted result can be retrieved by ID', () async {
      final result = makeResult();
      final companion = ReconciliationMapper.toCompanion(result);
      await dao.insertReconciliationResult(companion);
      final row = await dao.getReconciliationById(result.id);
      expect(row, isNotNull);
      expect(row!.id, equals(result.id));
    });

    test('stored result has correct client ID', () async {
      final result = makeResult(clientId: 'client-insert-test');
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );
      final row = await dao.getReconciliationById(result.id);
      expect(row?.clientId, equals('client-insert-test'));
    });

    test('stored result has correct reconciliation type', () async {
      final result = makeResult(type: ReconciliationType.gstr2b);
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );
      final row = await dao.getReconciliationById(result.id);
      expect(row?.reconciliationType, equals(ReconciliationType.gstr2b.name));
    });

    test('stored result has correct period', () async {
      final result = makeResult(period: 'Mar 2025');
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );
      final row = await dao.getReconciliationById(result.id);
      expect(row?.period, equals('Mar 2025'));
    });

    test('stored result has correct totals', () async {
      final result = makeResult(totalMatched: 25, totalUnmatched: 5);
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );
      final row = await dao.getReconciliationById(result.id);
      expect(row?.totalMatched, equals(25));
      expect(row?.totalUnmatched, equals(5));
    });
  });

  // ---------------------------------------------------------------------------
  // getReconciliationsByClient
  // ---------------------------------------------------------------------------

  group('getReconciliationsByClient', () {
    test('returns results for specific client', () async {
      const clientId = 'client-getbyclient';
      final result1 = makeResult(clientId: clientId);
      final result2 = makeResult(clientId: clientId);
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result1),
      );
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result2),
      );

      final rows = await dao.getReconciliationsByClient(clientId);
      expect(rows.length, greaterThanOrEqualTo(2));
      expect(rows.every((r) => r.clientId == clientId), isTrue);
    });

    test('returns empty list for unknown client', () async {
      final rows = await dao.getReconciliationsByClient('no-such-client-xyz');
      expect(rows, isEmpty);
    });

    test('filters by client correctly — excludes other clients', () async {
      const clientA = 'client-filter-a';
      const clientB = 'client-filter-b';
      final resultA = makeResult(clientId: clientA);
      final resultB = makeResult(clientId: clientB);
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(resultA),
      );
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(resultB),
      );

      final rows = await dao.getReconciliationsByClient(clientA);
      expect(rows.every((r) => r.clientId == clientA), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getReconciliationByType
  // ---------------------------------------------------------------------------

  group('getReconciliationByType', () {
    test('returns results filtered by type and client', () async {
      const clientId = 'client-bytype';
      final r1 = makeResult(
        clientId: clientId,
        type: ReconciliationType.tds26as,
      );
      final r2 = makeResult(
        clientId: clientId,
        type: ReconciliationType.gstr2b,
      );
      final r3 = makeResult(
        clientId: clientId,
        type: ReconciliationType.tds26as,
      );
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(r1),
      );
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(r2),
      );
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(r3),
      );

      final rows = await dao.getReconciliationByType(
        ReconciliationType.tds26as.name,
        clientId,
      );
      expect(rows.length, greaterThanOrEqualTo(2));
      expect(
        rows.every(
          (r) => r.reconciliationType == ReconciliationType.tds26as.name,
        ),
        isTrue,
      );
    });

    test('returns empty list for a type with no results', () async {
      final rows = await dao.getReconciliationByType(
        ReconciliationType.bankRecon.name,
        'no-such-client-type',
      );
      expect(rows, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getReconciliationById
  // ---------------------------------------------------------------------------

  group('getReconciliationById', () {
    test('returns result by ID', () async {
      final result = makeResult();
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );
      final row = await dao.getReconciliationById(result.id);
      expect(row, isNotNull);
      expect(row!.id, equals(result.id));
    });

    test('returns null for non-existent ID', () async {
      final row = await dao.getReconciliationById('does-not-exist');
      expect(row, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // updateReconciliationStatus
  // ---------------------------------------------------------------------------

  group('updateReconciliationStatus', () {
    test('updates status and returns true', () async {
      final result = makeResult(status: ReconciliationStatus.pending);
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );

      final success = await dao.updateReconciliationStatus(
        result.id,
        ReconciliationStatus.completed.name,
      );
      expect(success, isTrue);

      final row = await dao.getReconciliationById(result.id);
      expect(row?.status, equals(ReconciliationStatus.completed.name));
    });

    test('updates status from pending to reviewed', () async {
      final result = makeResult(status: ReconciliationStatus.pending);
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );
      await dao.updateReconciliationStatus(
        result.id,
        ReconciliationStatus.reviewed.name,
      );
      final row = await dao.getReconciliationById(result.id);
      expect(row?.status, equals(ReconciliationStatus.reviewed.name));
    });

    test('returns false for non-existent result ID', () async {
      final success = await dao.updateReconciliationStatus(
        'non-existent-id',
        ReconciliationStatus.completed.name,
      );
      expect(success, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // updateDiscrepanciesJson
  // ---------------------------------------------------------------------------

  group('updateDiscrepanciesJson', () {
    test('updates discrepancies JSON successfully', () async {
      final result = makeResult();
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );

      final success = await dao.updateDiscrepanciesJson(
        result.id,
        '[{"id":"d1","result_id":"${result.id}","field":"f","expected_value":"10","actual_value":"9","source":"src","resolved":true}]',
      );
      expect(success, isTrue);

      final row = await dao.getReconciliationById(result.id);
      expect(row?.discrepancies, contains('"resolved":true'));
    });

    test('returns false for non-existent result ID', () async {
      final success = await dao.updateDiscrepanciesJson('no-such-result', '[]');
      expect(success, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // getAllResults
  // ---------------------------------------------------------------------------

  group('getAllResults', () {
    test('returns all inserted results', () async {
      // Insert a few results to ensure there is data.
      final r1 = makeResult();
      final r2 = makeResult();
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(r1),
      );
      await dao.insertReconciliationResult(
        ReconciliationMapper.toCompanion(r2),
      );

      final all = await dao.getAllResults();
      expect(all.length, greaterThanOrEqualTo(2));
    });
  });

  // ---------------------------------------------------------------------------
  // upsertReconciliationResult
  // ---------------------------------------------------------------------------

  group('upsertReconciliationResult', () {
    test('upsert inserts new result', () async {
      final result = makeResult();
      await dao.upsertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );
      final row = await dao.getReconciliationById(result.id);
      expect(row, isNotNull);
    });

    test('upsert updates existing result', () async {
      final result = makeResult(status: ReconciliationStatus.pending);
      await dao.upsertReconciliationResult(
        ReconciliationMapper.toCompanion(result),
      );

      final updated = result.copyWith(status: ReconciliationStatus.completed);
      await dao.upsertReconciliationResult(
        ReconciliationMapper.toCompanion(updated),
      );

      final row = await dao.getReconciliationById(result.id);
      expect(row?.status, equals(ReconciliationStatus.completed.name));
    });
  });

  // ---------------------------------------------------------------------------
  // Mapper round-trips
  // ---------------------------------------------------------------------------

  group('ReconciliationMapper', () {
    test('fromJson → toJson round-trip preserves fields', () {
      final json = {
        'id': 'json-round-1',
        'client_id': 'c-1',
        'reconciliation_type': 'gstr2b',
        'period': 'Apr 2025',
        'total_matched': 10,
        'total_unmatched': 2,
        'discrepancies':
            '[{"id":"d1","result_id":"json-round-1","field":"igst",'
            '"expected_value":"5000","actual_value":"4000","source":"GSTR-2B","resolved":false}]',
        'status': 'inProgress',
        'reviewed_by': null,
        'reviewed_date': null,
        'created_at': '2025-04-01T00:00:00.000',
        'updated_at': '2025-04-01T00:00:00.000',
      };

      final result = ReconciliationMapper.fromJson(json);
      expect(result.id, equals('json-round-1'));
      expect(result.reconciliationType, equals(ReconciliationType.gstr2b));
      expect(result.period, equals('Apr 2025'));
      expect(result.totalMatched, equals(10));
      expect(result.discrepancies.length, equals(1));
      expect(result.discrepancies.first.field, equals('igst'));
      expect(result.discrepancies.first.resolved, isFalse);
    });

    test('fromRow round-trip preserves discrepancies', () async {
      final disc = makeDiscrepancy(resultId: 'row-rt-1');
      final result = makeResult(id: 'row-rt-1', discrepancies: [disc]);
      final companion = ReconciliationMapper.toCompanion(result);
      await dao.insertReconciliationResult(companion);

      final row = await dao.getReconciliationById(result.id);
      expect(row, isNotNull);
      final domain = ReconciliationMapper.fromRow(row!);
      expect(domain.discrepancies.length, equals(1));
      expect(domain.discrepancies.first.id, equals(disc.id));
      expect(domain.discrepancies.first.field, equals(disc.field));
    });

    test('unknown reconciliationType falls back to tds26as', () {
      final json = {
        'id': 'fallback-1',
        'client_id': 'c-1',
        'reconciliation_type': 'unknown_type',
        'period': 'Q1',
        'total_matched': 0,
        'total_unmatched': 0,
        'discrepancies': null,
        'status': 'pending',
        'reviewed_by': null,
        'reviewed_date': null,
        'created_at': '2025-01-01T00:00:00.000',
        'updated_at': '2025-01-01T00:00:00.000',
      };
      final result = ReconciliationMapper.fromJson(json);
      expect(result.reconciliationType, equals(ReconciliationType.tds26as));
    });

    test('unknown status falls back to pending', () {
      final json = {
        'id': 'fallback-2',
        'client_id': 'c-1',
        'reconciliation_type': 'bankRecon',
        'period': 'Q1',
        'total_matched': 0,
        'total_unmatched': 0,
        'discrepancies': null,
        'status': 'unknownStatus',
        'reviewed_by': null,
        'reviewed_date': null,
        'created_at': '2025-01-01T00:00:00.000',
        'updated_at': '2025-01-01T00:00:00.000',
      };
      final result = ReconciliationMapper.fromJson(json);
      expect(result.status, equals(ReconciliationStatus.pending));
    });
  });

  // ---------------------------------------------------------------------------
  // Immutability
  // ---------------------------------------------------------------------------

  group('Immutability', () {
    test('ReconciliationResult.copyWith creates new instance', () {
      final original = makeResult(status: ReconciliationStatus.pending);
      final updated = original.copyWith(status: ReconciliationStatus.reviewed);

      expect(original.status, equals(ReconciliationStatus.pending));
      expect(updated.status, equals(ReconciliationStatus.reviewed));
      expect(original.id, equals(updated.id));
    });

    test('copyWith preserves all unchanged fields', () {
      final original = makeResult(totalMatched: 42, period: 'FY 2024-25');
      final updated = original.copyWith(status: ReconciliationStatus.completed);

      expect(updated.totalMatched, equals(42));
      expect(updated.period, equals('FY 2024-25'));
      expect(updated.clientId, equals(original.clientId));
    });

    test('Discrepancy.copyWith creates new instance', () {
      const disc = Discrepancy(
        id: 'imm-disc-1',
        resultId: 'imm-res-1',
        field: 'amount',
        expectedValue: '100',
        actualValue: '90',
        source: 'source',
        resolved: false,
      );
      final resolved = disc.copyWith(resolved: true);

      expect(disc.resolved, isFalse);
      expect(resolved.resolved, isTrue);
      expect(disc.id, equals(resolved.id));
    });

    test('Discrepancy.copyWith preserves all unchanged fields', () {
      const disc = Discrepancy(
        id: 'imm-disc-2',
        resultId: 'imm-res-2',
        field: 'igst',
        expectedValue: '18000',
        actualValue: '17000',
        source: 'GSTR-2B',
      );
      final updated = disc.copyWith(resolved: true);

      expect(updated.field, equals('igst'));
      expect(updated.expectedValue, equals('18000'));
      expect(updated.actualValue, equals('17000'));
      expect(updated.source, equals('GSTR-2B'));
    });
  });

  // ---------------------------------------------------------------------------
  // Domain model helpers
  // ---------------------------------------------------------------------------

  group('ReconciliationResult computed properties', () {
    test('hasUnresolvedDiscrepancies returns true when unresolved exist', () {
      final result = makeResult(
        discrepancies: [
          const Discrepancy(
            id: 'd-unresolved',
            resultId: 'r-x',
            field: 'f',
            expectedValue: 'e',
            actualValue: 'a',
            source: 's',
          ),
        ],
      );
      expect(result.hasUnresolvedDiscrepancies, isTrue);
    });

    test('hasUnresolvedDiscrepancies returns false when all resolved', () {
      final result = makeResult(
        discrepancies: [
          const Discrepancy(
            id: 'd-resolved',
            resultId: 'r-y',
            field: 'f',
            expectedValue: 'e',
            actualValue: 'a',
            source: 's',
            resolved: true,
          ),
        ],
      );
      expect(result.hasUnresolvedDiscrepancies, isFalse);
    });

    test('unresolvedCount counts only unresolved discrepancies', () {
      final result = makeResult(
        discrepancies: [
          const Discrepancy(
            id: 'd-u1',
            resultId: 'r-count',
            field: 'f1',
            expectedValue: 'e',
            actualValue: 'a',
            source: 's',
            resolved: false,
          ),
          const Discrepancy(
            id: 'd-u2',
            resultId: 'r-count',
            field: 'f2',
            expectedValue: 'e',
            actualValue: 'a',
            source: 's',
            resolved: true,
          ),
          const Discrepancy(
            id: 'd-u3',
            resultId: 'r-count',
            field: 'f3',
            expectedValue: 'e',
            actualValue: 'a',
            source: 's',
            resolved: false,
          ),
        ],
      );
      expect(result.unresolvedCount, equals(2));
    });

    test('equality is by ID', () {
      final r1 = makeResult(id: 'same-id');
      final r2 = r1.copyWith(status: ReconciliationStatus.completed);
      expect(r1, equals(r2));
    });

    test('Discrepancy equality is by ID', () {
      const d1 = Discrepancy(
        id: 'eq-disc-1',
        resultId: 'r',
        field: 'f',
        expectedValue: 'e',
        actualValue: 'a',
        source: 's',
      );
      final d2 = d1.copyWith(resolved: true);
      expect(d1, equals(d2));
    });
  });
}
