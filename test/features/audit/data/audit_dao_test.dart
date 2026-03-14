import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/audit/domain/models/audit_assignment.dart';
import 'package:ca_app/features/audit/domain/models/audit_report.dart';
import 'package:ca_app/features/audit/data/mappers/audit_mapper.dart';

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

  group('AuditDao', () {
    AuditAssignment createTestAssignment({
      String? id,
      String? clientId,
      String? auditorId,
      String? financialYear,
      DateTime? startDate,
      DateTime? endDate,
      AuditAssignmentStatus? status,
      String? fee,
    }) {
      testCounter++;
      return AuditAssignment(
        id: id ?? 'assignment-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        auditorId: auditorId ?? 'auditor-1',
        financialYear: financialYear ?? '2024-25',
        startDate: startDate ?? DateTime(2024, 4, 1),
        endDate: endDate,
        status: status ?? AuditAssignmentStatus.scheduled,
        fee: fee ?? '50000.00',
      );
    }

    AuditReport createTestReport({
      String? id,
      String? clientId,
      int? year,
      String? saReportNumber,
      DateTime? reportDate,
      String? reportedBy,
      Map<String, dynamic>? auditFindings,
    }) {
      testCounter++;
      return AuditReport(
        id: id ?? 'report-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        year: year ?? 2024,
        saReportNumber: saReportNumber ?? 'SA/2024/$testCounter',
        reportDate: reportDate ?? DateTime(2024, 9, 30),
        reportedBy: reportedBy ?? 'CA Ram Prasad',
        auditFindings: auditFindings ?? {'finding1': 'No discrepancies found'},
      );
    }

    group('insertAuditAssignment', () {
      test('inserts assignment and returns non-empty ID', () async {
        final assignment = createTestAssignment();
        final companion = AuditMapper.assignmentToCompanion(assignment);
        final id = await database.auditDao.insertAuditAssignment(companion);
        expect(id, isNotEmpty);
      });

      test('stored assignment has correct clientId', () async {
        final assignment = createTestAssignment();
        final companion = AuditMapper.assignmentToCompanion(assignment);
        await database.auditDao.insertAuditAssignment(companion);
        final retrieved = await database.auditDao.getAssignmentById(
          assignment.id,
        );
        expect(retrieved?.clientId, assignment.clientId);
      });

      test('stored assignment has correct status', () async {
        final assignment = createTestAssignment(
          status: AuditAssignmentStatus.inProgress,
        );
        final companion = AuditMapper.assignmentToCompanion(assignment);
        await database.auditDao.insertAuditAssignment(companion);
        final row = await database.auditDao.getAssignmentById(assignment.id);
        final retrieved = row != null
            ? AuditMapper.assignmentFromRow(row)
            : null;
        expect(retrieved?.status, AuditAssignmentStatus.inProgress);
      });

      test('stored assignment has correct financialYear', () async {
        final assignment = createTestAssignment(financialYear: '2023-24');
        final companion = AuditMapper.assignmentToCompanion(assignment);
        await database.auditDao.insertAuditAssignment(companion);
        final retrieved = await database.auditDao.getAssignmentById(
          assignment.id,
        );
        expect(retrieved?.financialYear, '2023-24');
      });
    });

    group('getAuditsByClient', () {
      test('returns assignments for specific client', () async {
        final clientId = 'test-client-by-client-a';
        final a1 = createTestAssignment(clientId: clientId);
        final a2 = createTestAssignment(clientId: clientId);
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a1),
        );
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a2),
        );

        final results = await database.auditDao.getAuditsByClient(clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.auditDao.getAuditsByClient(
          'non-existent-client',
        );
        expect(results, isEmpty);
      });

      test('filters assignments by client correctly', () async {
        final clientA = 'client-filter-a';
        final clientB = 'client-filter-b';
        final a1 = createTestAssignment(clientId: clientA);
        final a2 = createTestAssignment(clientId: clientB);
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a1),
        );
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a2),
        );

        final results = await database.auditDao.getAuditsByClient(clientA);
        expect(results.every((r) => r.clientId == clientA), isTrue);
      });
    });

    group('getAuditsByAuditor', () {
      test('returns assignments for specific auditor', () async {
        final auditorId = 'auditor-unique-x1';
        final a1 = createTestAssignment(auditorId: auditorId);
        final a2 = createTestAssignment(auditorId: auditorId);
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a1),
        );
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a2),
        );

        final results = await database.auditDao.getAuditsByAuditor(auditorId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent auditor', () async {
        final results = await database.auditDao.getAuditsByAuditor(
          'non-existent-auditor',
        );
        expect(results, isEmpty);
      });

      test('filters assignments by auditor correctly', () async {
        final auditorA = 'auditor-filter-p1';
        final auditorB = 'auditor-filter-p2';
        final a1 = createTestAssignment(auditorId: auditorA);
        final a2 = createTestAssignment(auditorId: auditorB);
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a1),
        );
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(a2),
        );

        final results = await database.auditDao.getAuditsByAuditor(auditorA);
        expect(results.every((r) => r.auditorId == auditorA), isTrue);
      });
    });

    group('updateAuditStatus', () {
      test('updates status from scheduled to inProgress', () async {
        final assignment = createTestAssignment(
          status: AuditAssignmentStatus.scheduled,
        );
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(assignment),
        );

        final success = await database.auditDao.updateAuditStatus(
          assignment.id,
          AuditAssignmentStatus.inProgress.name,
        );
        expect(success, isTrue);

        final updatedRow = await database.auditDao.getAssignmentById(
          assignment.id,
        );
        final retrieved = updatedRow != null
            ? AuditMapper.assignmentFromRow(updatedRow)
            : null;
        expect(retrieved?.status, AuditAssignmentStatus.inProgress);
      });

      test('updates status to completed', () async {
        final assignment = createTestAssignment();
        await database.auditDao.insertAuditAssignment(
          AuditMapper.assignmentToCompanion(assignment),
        );

        await database.auditDao.updateAuditStatus(
          assignment.id,
          AuditAssignmentStatus.completed.name,
        );

        final completedRow = await database.auditDao.getAssignmentById(
          assignment.id,
        );
        final retrieved = completedRow != null
            ? AuditMapper.assignmentFromRow(completedRow)
            : null;
        expect(retrieved?.status, AuditAssignmentStatus.completed);
      });

      test('returns false for non-existent audit ID', () async {
        final success = await database.auditDao.updateAuditStatus(
          'non-existent-id',
          AuditAssignmentStatus.completed.name,
        );
        expect(success, isFalse);
      });
    });

    group('insertAuditReport', () {
      test('inserts report and returns non-empty ID', () async {
        final report = createTestReport();
        final companion = AuditMapper.reportToCompanion(report);
        final id = await database.auditDao.insertAuditReport(companion);
        expect(id, isNotEmpty);
      });

      test('stored report has correct clientId', () async {
        final report = createTestReport();
        await database.auditDao.insertAuditReport(
          AuditMapper.reportToCompanion(report),
        );
        final retrieved = await database.auditDao.getReportById(report.id);
        expect(retrieved?.clientId, report.clientId);
      });

      test('stored report has correct year', () async {
        final report = createTestReport(year: 2023);
        await database.auditDao.insertAuditReport(
          AuditMapper.reportToCompanion(report),
        );
        final retrieved = await database.auditDao.getReportById(report.id);
        expect(retrieved?.year, 2023);
      });

      test('stored report preserves auditFindings JSON', () async {
        final findings = {'finding1': 'Income understated', 'clause': '44AB'};
        final report = createTestReport(auditFindings: findings);
        await database.auditDao.insertAuditReport(
          AuditMapper.reportToCompanion(report),
        );
        final retrieved = await database.auditDao.getReportById(report.id);
        final domain = retrieved != null
            ? AuditMapper.reportFromRow(retrieved)
            : null;
        final retrievedFindings = domain?.auditFindings;
        expect(retrievedFindings == null, isFalse);
        expect(retrievedFindings!['finding1'], 'Income understated');
        expect(retrievedFindings['clause'], '44AB');
      });

      test('stored report handles null auditFindings', () async {
        testCounter++;
        final report = AuditReport(
          id: 'report-null-findings-$testCounter',
          clientId: 'client-$testCounter',
          year: 2024,
          saReportNumber: 'SA/NULL/$testCounter',
          reportDate: DateTime(2024, 9, 30),
          reportedBy: 'CA Test',
          auditFindings: null,
        );
        await database.auditDao.insertAuditReport(
          AuditMapper.reportToCompanion(report),
        );
        final retrieved = await database.auditDao.getReportById(report.id);
        expect(retrieved?.auditFindings, isNull);
      });
    });

    group('getAuditReportByClient', () {
      test('returns report for matching client and year', () async {
        final clientId = 'client-report-lookup';
        final report = createTestReport(clientId: clientId, year: 2024);
        await database.auditDao.insertAuditReport(
          AuditMapper.reportToCompanion(report),
        );

        final retrieved = await database.auditDao.getAuditReportByClient(
          clientId,
          2024,
        );
        expect(retrieved != null, isTrue);
        expect(retrieved?.clientId, clientId);
        expect(retrieved?.year, 2024);
      });

      test('returns null for non-existent client', () async {
        final retrieved = await database.auditDao.getAuditReportByClient(
          'non-existent',
          2024,
        );
        expect(retrieved == null, isTrue);
      });

      test('returns null for correct client but wrong year', () async {
        final clientId = 'client-wrong-year';
        final report = createTestReport(clientId: clientId, year: 2024);
        await database.auditDao.insertAuditReport(
          AuditMapper.reportToCompanion(report),
        );

        final retrieved = await database.auditDao.getAuditReportByClient(
          clientId,
          2023,
        );
        expect(retrieved == null, isTrue);
      });
    });

    group('Immutability', () {
      test('AuditAssignment has copyWith for immutable updates', () {
        final a1 = createTestAssignment();
        final a2 = a1.copyWith(status: AuditAssignmentStatus.completed);

        expect(a1.status, AuditAssignmentStatus.scheduled);
        expect(a2.status, AuditAssignmentStatus.completed);
        expect(a1.id, a2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final a1 = createTestAssignment(financialYear: '2024-25', fee: '75000');
        final a2 = a1.copyWith(status: AuditAssignmentStatus.inProgress);

        expect(a2.clientId, a1.clientId);
        expect(a2.auditorId, a1.auditorId);
        expect(a2.financialYear, '2024-25');
        expect(a2.fee, '75000');
      });

      test('AuditReport has copyWith for immutable updates', () {
        final r1 = createTestReport();
        final r2 = r1.copyWith(saReportNumber: 'SA/NEW/001');

        expect(r1.saReportNumber, isNot('SA/NEW/001'));
        expect(r2.saReportNumber, 'SA/NEW/001');
        expect(r1.id, r2.id);
      });

      test('AuditReport copyWith preserves all fields when not updated', () {
        final r1 = createTestReport(year: 2024, reportedBy: 'CA Test');
        final r2 = r1.copyWith(saReportNumber: 'SA/2025/001');

        expect(r2.clientId, r1.clientId);
        expect(r2.year, 2024);
        expect(r2.reportedBy, 'CA Test');
      });
    });
  });
}
