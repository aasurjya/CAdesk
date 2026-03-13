import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_case.dart';
import 'package:ca_app/features/assessment/data/mappers/assessment_case_mapper.dart';

AppDatabase _createTestDatabase() =>
    AppDatabase(executor: NativeDatabase.memory());

void main() {
  late AppDatabase database;
  late int counter;

  setUpAll(() async {
    database = _createTestDatabase();
    counter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  AssessmentCase makeCase({
    String? id,
    String? clientId,
    String? assessmentYear,
    AssessmentType? caseType,
    AssessmentCaseStatus? status,
    DateTime? dueDate,
    String? demandAmount,
  }) {
    counter++;
    return AssessmentCase(
      id: id ?? 'ac-$counter',
      clientId: clientId ?? 'client-1',
      assessmentYear: assessmentYear ?? 'AY 2023-24',
      caseType: caseType ?? AssessmentType.intimation143_1,
      status: status ?? AssessmentCaseStatus.open,
      demandAmount: demandAmount ?? '10000.00',
      paidAmount: '0.00',
      dueDate: dueDate,
      notes: 'Test note $counter',
      createdAt: DateTime(2026, 1, counter),
      updatedAt: DateTime(2026, 1, counter),
    );
  }

  group('AssessmentDao', () {
    group('insertCase', () {
      test('returns the ID of the inserted case', () async {
        final c = makeCase();
        final id = await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        expect(id, c.id);
      });

      test('stored case has correct clientId', () async {
        final c = makeCase(clientId: 'client-check');
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        final row = await database.assessmentDao.getCaseById(c.id);
        expect(row?.clientId, 'client-check');
      });

      test('stored case has correct assessmentYear', () async {
        final c = makeCase(assessmentYear: 'AY 2022-23');
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        final row = await database.assessmentDao.getCaseById(c.id);
        expect(row?.assessmentYear, 'AY 2022-23');
      });

      test('stored case has correct caseType', () async {
        final c = makeCase(caseType: AssessmentType.scrutiny143_3);
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        final row = await database.assessmentDao.getCaseById(c.id);
        final domain = row != null ? AssessmentCaseMapper.fromRow(row) : null;
        expect(domain?.caseType, AssessmentType.scrutiny143_3);
      });

      test('stored case has correct demandAmount', () async {
        final c = makeCase(demandAmount: '250000.00');
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        final row = await database.assessmentDao.getCaseById(c.id);
        expect(row?.demandAmount, '250000.00');
      });
    });

    group('getByClient', () {
      test('returns cases for specific client', () async {
        final clientId = 'client-by-client-x';
        final c1 = makeCase(clientId: clientId);
        final c2 = makeCase(clientId: clientId);
        final other = makeCase(clientId: 'client-other');
        for (final c in [c1, c2, other]) {
          await database.assessmentDao.insertCase(
            AssessmentCaseMapper.toCompanion(c),
          );
        }

        final results = await database.assessmentDao.getByClient(clientId);
        final ids = results.map((r) => r.id).toSet();
        expect(ids, containsAll([c1.id, c2.id]));
        expect(ids.contains(other.id), isFalse);
      });

      test('returns empty list for non-existent client', () async {
        final results =
            await database.assessmentDao.getByClient('no-such-client');
        expect(results, isEmpty);
      });

      test('all returned rows have the matching clientId', () async {
        final clientId = 'client-filter-check';
        final c = makeCase(clientId: clientId);
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        final results = await database.assessmentDao.getByClient(clientId);
        expect(results.every((r) => r.clientId == clientId), isTrue);
      });
    });

    group('getByYear', () {
      test('returns cases matching the assessment year', () async {
        final c1 = makeCase(assessmentYear: 'AY 2024-25');
        final c2 = makeCase(assessmentYear: 'AY 2023-24');
        for (final c in [c1, c2]) {
          await database.assessmentDao.insertCase(
            AssessmentCaseMapper.toCompanion(c),
          );
        }

        final results =
            await database.assessmentDao.getByYear('AY 2024-25');
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(c1.id), isTrue);
        expect(ids.contains(c2.id), isFalse);
      });

      test('returns empty list for non-existent year', () async {
        final results =
            await database.assessmentDao.getByYear('AY 1990-91');
        expect(results, isEmpty);
      });
    });

    group('getByType', () {
      test('returns only cases of the given type', () async {
        final intimation = makeCase(caseType: AssessmentType.intimation143_1);
        final scrutiny = makeCase(caseType: AssessmentType.scrutiny143_3);
        for (final c in [intimation, scrutiny]) {
          await database.assessmentDao.insertCase(
            AssessmentCaseMapper.toCompanion(c),
          );
        }

        final results = await database.assessmentDao
            .getByType(AssessmentType.intimation143_1.name);
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(intimation.id), isTrue);
        expect(ids.contains(scrutiny.id), isFalse);
      });

      test('returns empty list for type with no cases', () async {
        final results =
            await database.assessmentDao.getByType(AssessmentType.itat.name);
        expect(results, isEmpty);
      });
    });

    group('getByStatus', () {
      test('returns only cases with the given status', () async {
        final open = makeCase(status: AssessmentCaseStatus.open);
        final closed = makeCase(status: AssessmentCaseStatus.closed);
        for (final c in [open, closed]) {
          await database.assessmentDao.insertCase(
            AssessmentCaseMapper.toCompanion(c),
          );
        }

        final results = await database.assessmentDao
            .getByStatus(AssessmentCaseStatus.open.name);
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(open.id), isTrue);
        expect(ids.contains(closed.id), isFalse);
      });
    });

    group('updateStatus', () {
      test('update returns true for existing case', () async {
        final c = makeCase(status: AssessmentCaseStatus.open);
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        final result = await database.assessmentDao.updateStatus(
          c.id,
          AssessmentCaseStatus.pending.name,
        );
        expect(result, isTrue);
      });

      test('status is updated after updateStatus', () async {
        final c = makeCase(status: AssessmentCaseStatus.open);
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(c),
        );
        await database.assessmentDao.updateStatus(
          c.id,
          AssessmentCaseStatus.closed.name,
        );
        final row = await database.assessmentDao.getCaseById(c.id);
        final domain = row != null ? AssessmentCaseMapper.fromRow(row) : null;
        expect(domain?.status, AssessmentCaseStatus.closed);
      });

      test('update returns false for non-existent case ID', () async {
        final result = await database.assessmentDao.updateStatus(
          'ghost-case-id',
          AssessmentCaseStatus.closed.name,
        );
        expect(result, isFalse);
      });
    });

    group('getOverdueDemands', () {
      test('returns open cases with dueDate in the past', () async {
        final overdue = makeCase(
          status: AssessmentCaseStatus.open,
          dueDate: DateTime(2020, 1, 1), // past
        );
        final future = makeCase(
          status: AssessmentCaseStatus.open,
          dueDate: DateTime(2030, 12, 31), // future
        );
        for (final c in [overdue, future]) {
          await database.assessmentDao.insertCase(
            AssessmentCaseMapper.toCompanion(c),
          );
        }

        final results =
            await database.assessmentDao.getOverdueDemands(DateTime.now());
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(overdue.id), isTrue);
        expect(ids.contains(future.id), isFalse);
      });

      test('does not return closed cases with past dueDate', () async {
        final closed = makeCase(
          status: AssessmentCaseStatus.closed,
          dueDate: DateTime(2020, 1, 1),
        );
        await database.assessmentDao.insertCase(
          AssessmentCaseMapper.toCompanion(closed),
        );

        final results =
            await database.assessmentDao.getOverdueDemands(DateTime.now());
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(closed.id), isFalse);
      });
    });

    group('Immutability', () {
      test('AssessmentCase has copyWith', () {
        final c1 = makeCase(status: AssessmentCaseStatus.open);
        final c2 = c1.copyWith(status: AssessmentCaseStatus.closed);
        expect(c1.status, AssessmentCaseStatus.open);
        expect(c2.status, AssessmentCaseStatus.closed);
        expect(c1.id, c2.id);
      });

      test('copyWith preserves all unchanged fields', () {
        final c1 = makeCase(
          clientId: 'client-keep',
          assessmentYear: 'AY 2023-24',
          demandAmount: '75000.00',
        );
        final c2 = c1.copyWith(status: AssessmentCaseStatus.pending);
        expect(c2.clientId, 'client-keep');
        expect(c2.assessmentYear, 'AY 2023-24');
        expect(c2.demandAmount, '75000.00');
      });

      test('AssessmentType enum names are non-empty', () {
        for (final type in AssessmentType.values) {
          expect(type.name, isNotEmpty);
          expect(type.label, isNotEmpty);
        }
      });

      test('AssessmentCaseStatus enum names are non-empty', () {
        for (final status in AssessmentCaseStatus.values) {
          expect(status.name, isNotEmpty);
          expect(status.label, isNotEmpty);
        }
      });
    });
  });
}
