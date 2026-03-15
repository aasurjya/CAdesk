import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/audit/data/mappers/audit_mapper.dart';
import 'package:ca_app/features/audit/domain/models/audit_assignment.dart';
import 'package:ca_app/features/audit/domain/models/audit_report.dart';

void main() {
  group('AuditMapper', () {
    // -------------------------------------------------------------------------
    // AuditAssignment
    // -------------------------------------------------------------------------
    group('assignmentFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'aa-001',
          'client_id': 'client-001',
          'auditor_id': 'auditor-001',
          'financial_year': '2024-25',
          'start_date': '2025-04-01T00:00:00.000Z',
          'end_date': '2025-09-30T00:00:00.000Z',
          'status': 'inProgress',
          'fee': '50000.00',
        };

        final assignment = AuditMapper.assignmentFromJson(json);

        expect(assignment.id, 'aa-001');
        expect(assignment.clientId, 'client-001');
        expect(assignment.auditorId, 'auditor-001');
        expect(assignment.financialYear, '2024-25');
        expect(assignment.startDate, isNotNull);
        expect(assignment.endDate, isNotNull);
        expect(assignment.status, AuditAssignmentStatus.inProgress);
        expect(assignment.fee, '50000.00');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'aa-002',
          'client_id': 'client-002',
          'status': 'scheduled',
        };

        final assignment = AuditMapper.assignmentFromJson(json);
        expect(assignment.auditorId, isNull);
        expect(assignment.financialYear, isNull);
        expect(assignment.startDate, isNull);
        expect(assignment.endDate, isNull);
        expect(assignment.fee, isNull);
      });

      test('defaults status to scheduled for unknown value', () {
        final json = {
          'id': 'aa-003',
          'client_id': 'c1',
          'status': 'unknownStatus',
        };

        final assignment = AuditMapper.assignmentFromJson(json);
        expect(assignment.status, AuditAssignmentStatus.scheduled);
      });

      test('defaults status to scheduled when status key is absent', () {
        final json = {
          'id': 'aa-004',
          'client_id': 'c1',
        };

        final assignment = AuditMapper.assignmentFromJson(json);
        expect(assignment.status, AuditAssignmentStatus.scheduled);
      });

      test('handles all AuditAssignmentStatus values', () {
        for (final status in AuditAssignmentStatus.values) {
          final json = {
            'id': 'aa-status-${status.name}',
            'client_id': 'c1',
            'status': status.name,
          };
          final assignment = AuditMapper.assignmentFromJson(json);
          expect(assignment.status, status);
        }
      });
    });

    group('assignmentToJson', () {
      late AuditAssignment sampleAssignment;

      setUp(() {
        sampleAssignment = const AuditAssignment(
          id: 'aa-json-001',
          clientId: 'client-json-001',
          auditorId: 'auditor-json-001',
          financialYear: '2024-25',
          startDate: null,
          endDate: null,
          status: AuditAssignmentStatus.completed,
          fee: '75000.00',
        );
      });

      test('includes all fields', () {
        final json = AuditMapper.assignmentToJson(sampleAssignment);

        expect(json['id'], 'aa-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['auditor_id'], 'auditor-json-001');
        expect(json['financial_year'], '2024-25');
        expect(json['status'], 'completed');
        expect(json['fee'], '75000.00');
      });

      test('serializes null dates as null', () {
        final json = AuditMapper.assignmentToJson(sampleAssignment);
        expect(json['start_date'], isNull);
        expect(json['end_date'], isNull);
      });

      test('serializes dates as ISO strings when present', () {
        final withDates = AuditAssignment(
          id: 'aa-dates',
          clientId: 'c1',
          startDate: DateTime(2025, 4, 1),
          endDate: DateTime(2025, 9, 30),
          status: AuditAssignmentStatus.inProgress,
        );
        final json = AuditMapper.assignmentToJson(withDates);
        expect(json['start_date'], startsWith('2025-04-01'));
        expect(json['end_date'], startsWith('2025-09-30'));
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = AuditMapper.assignmentToJson(sampleAssignment);
        final restored = AuditMapper.assignmentFromJson(json);

        expect(restored.id, sampleAssignment.id);
        expect(restored.clientId, sampleAssignment.clientId);
        expect(restored.auditorId, sampleAssignment.auditorId);
        expect(restored.financialYear, sampleAssignment.financialYear);
        expect(restored.status, sampleAssignment.status);
        expect(restored.fee, sampleAssignment.fee);
      });
    });

    // -------------------------------------------------------------------------
    // AuditReport
    // -------------------------------------------------------------------------
    group('reportFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'ar-001',
          'client_id': 'client-001',
          'year': 2024,
          'sa_report_number': '3CD/2024/001',
          'report_date': '2025-09-30T00:00:00.000Z',
          'reported_by': 'CA Mehta',
          'audit_findings': {'section_40A': 'Compliant', 'section_32': 'Depreciation claimed'},
        };

        final report = AuditMapper.reportFromJson(json);

        expect(report.id, 'ar-001');
        expect(report.clientId, 'client-001');
        expect(report.year, 2024);
        expect(report.saReportNumber, '3CD/2024/001');
        expect(report.reportDate, isNotNull);
        expect(report.reportedBy, 'CA Mehta');
        expect(report.auditFindings, isNotNull);
        expect(report.auditFindings!['section_40A'], 'Compliant');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'ar-002',
          'client_id': 'client-002',
          'year': 2023,
        };

        final report = AuditMapper.reportFromJson(json);
        expect(report.saReportNumber, isNull);
        expect(report.reportDate, isNull);
        expect(report.reportedBy, isNull);
        expect(report.auditFindings, isNull);
      });

      test('handles null audit_findings', () {
        final json = {
          'id': 'ar-003',
          'client_id': 'c1',
          'year': 2025,
          'audit_findings': null,
        };

        final report = AuditMapper.reportFromJson(json);
        expect(report.auditFindings, isNull);
      });

      test('parses audit_findings from Map directly', () {
        final findings = {'finding_1': 'value_1', 'finding_2': 42};
        final json = {
          'id': 'ar-004',
          'client_id': 'c1',
          'year': 2025,
          'audit_findings': findings,
        };

        final report = AuditMapper.reportFromJson(json);
        expect(report.auditFindings, equals(findings));
      });
    });

    group('reportToJson', () {
      late AuditReport sampleReport;

      setUp(() {
        sampleReport = AuditReport(
          id: 'ar-json-001',
          clientId: 'client-json-001',
          year: 2024,
          saReportNumber: '3CD/2024/002',
          reportDate: DateTime(2025, 9, 28),
          reportedBy: 'CA Sharma',
          auditFindings: {'compliance': 'Full', 'penalty': 'None'},
        );
      });

      test('includes all fields', () {
        final json = AuditMapper.reportToJson(sampleReport);

        expect(json['id'], 'ar-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['year'], 2024);
        expect(json['sa_report_number'], '3CD/2024/002');
        expect(json['reported_by'], 'CA Sharma');
        expect(json['audit_findings'], isA<Map>());
      });

      test('serializes report_date as ISO string', () {
        final json = AuditMapper.reportToJson(sampleReport);
        expect(json['report_date'], startsWith('2025-09-28'));
      });

      test('serializes null report_date as null', () {
        final noDate = sampleReport.copyWith(reportDate: null, saReportNumber: null);
        // copyWith doesn't accept null override for reportDate, create fresh:
        final noDateReport = AuditReport(
          id: sampleReport.id,
          clientId: sampleReport.clientId,
          year: sampleReport.year,
        );
        final json = AuditMapper.reportToJson(noDateReport);
        expect(json['report_date'], isNull);
      });

      test('serializes null audit_findings as null', () {
        final noFindings = AuditReport(
          id: 'ar-nofindings',
          clientId: 'c1',
          year: 2025,
        );
        final json = AuditMapper.reportToJson(noFindings);
        expect(json['audit_findings'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = AuditMapper.reportToJson(sampleReport);
        final restored = AuditMapper.reportFromJson(json);

        expect(restored.id, sampleReport.id);
        expect(restored.clientId, sampleReport.clientId);
        expect(restored.year, sampleReport.year);
        expect(restored.saReportNumber, sampleReport.saReportNumber);
        expect(restored.reportedBy, sampleReport.reportedBy);
        expect(restored.auditFindings, equals(sampleReport.auditFindings));
      });
    });
  });
}
