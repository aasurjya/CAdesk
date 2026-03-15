import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/assessment/data/mappers/assessment_case_mapper.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_case.dart';

void main() {
  group('AssessmentCaseMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'ac-001',
          'client_id': 'client-001',
          'assessment_year': 'AY 2022-23',
          'case_type': 'scrutiny143_3',
          'status': 'open',
          'demand_amount': '250000.00',
          'paid_amount': '0.00',
          'due_date': '2026-06-30T00:00:00.000Z',
          'notes': 'Documents pending',
          'created_at': '2025-09-01T00:00:00.000Z',
          'updated_at': '2025-09-01T00:00:00.000Z',
        };

        final assessmentCase = AssessmentCaseMapper.fromJson(json);

        expect(assessmentCase.id, 'ac-001');
        expect(assessmentCase.clientId, 'client-001');
        expect(assessmentCase.assessmentYear, 'AY 2022-23');
        expect(assessmentCase.caseType, AssessmentType.scrutiny143_3);
        expect(assessmentCase.status, AssessmentCaseStatus.open);
        expect(assessmentCase.demandAmount, '250000.00');
        expect(assessmentCase.paidAmount, '0.00');
        expect(assessmentCase.dueDate, isNotNull);
        expect(assessmentCase.notes, 'Documents pending');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'ac-002',
          'client_id': 'client-002',
          'assessment_year': 'AY 2023-24',
          'case_type': 'intimation143_1',
          'status': 'closed',
          'demand_amount': '5000.00',
          'paid_amount': '5000.00',
          'created_at': '2025-10-01T00:00:00.000Z',
          'updated_at': '2025-11-01T00:00:00.000Z',
        };

        final assessmentCase = AssessmentCaseMapper.fromJson(json);
        expect(assessmentCase.dueDate, isNull);
        expect(assessmentCase.notes, isNull);
      });

      test('defaults demand_amount and paid_amount to 0.00 when null', () {
        final json = {
          'id': 'ac-003',
          'client_id': 'c1',
          'assessment_year': 'AY 2023-24',
          'case_type': 'intimation143_1',
          'status': 'pending',
          'created_at': '2025-10-01T00:00:00.000Z',
          'updated_at': '2025-10-01T00:00:00.000Z',
        };

        final assessmentCase = AssessmentCaseMapper.fromJson(json);
        expect(assessmentCase.demandAmount, '0.00');
        expect(assessmentCase.paidAmount, '0.00');
      });

      test('defaults case_type to intimation143_1 for unknown value', () {
        final json = {
          'id': 'ac-004',
          'client_id': 'c1',
          'assessment_year': 'AY 2023-24',
          'case_type': 'unknownType',
          'status': 'open',
          'demand_amount': '0.00',
          'paid_amount': '0.00',
          'created_at': '2025-10-01T00:00:00.000Z',
          'updated_at': '2025-10-01T00:00:00.000Z',
        };

        final assessmentCase = AssessmentCaseMapper.fromJson(json);
        expect(assessmentCase.caseType, AssessmentType.intimation143_1);
      });

      test('defaults status to open for unknown value', () {
        final json = {
          'id': 'ac-005',
          'client_id': 'c1',
          'assessment_year': 'AY 2023-24',
          'case_type': 'itat',
          'status': 'unknownStatus',
          'demand_amount': '0.00',
          'paid_amount': '0.00',
          'created_at': '2025-10-01T00:00:00.000Z',
          'updated_at': '2025-10-01T00:00:00.000Z',
        };

        final assessmentCase = AssessmentCaseMapper.fromJson(json);
        expect(assessmentCase.status, AssessmentCaseStatus.open);
      });

      test('handles all AssessmentType values', () {
        for (final type in AssessmentType.values) {
          final json = {
            'id': 'ac-type-${type.name}',
            'client_id': 'c1',
            'assessment_year': 'AY 2023-24',
            'case_type': type.name,
            'status': 'open',
            'demand_amount': '0.00',
            'paid_amount': '0.00',
            'created_at': '2025-10-01T00:00:00.000Z',
            'updated_at': '2025-10-01T00:00:00.000Z',
          };
          final assessmentCase = AssessmentCaseMapper.fromJson(json);
          expect(assessmentCase.caseType, type);
        }
      });

      test('handles all AssessmentCaseStatus values', () {
        for (final status in AssessmentCaseStatus.values) {
          final json = {
            'id': 'ac-status-${status.name}',
            'client_id': 'c1',
            'assessment_year': 'AY 2023-24',
            'case_type': 'intimation143_1',
            'status': status.name,
            'demand_amount': '0.00',
            'paid_amount': '0.00',
            'created_at': '2025-10-01T00:00:00.000Z',
            'updated_at': '2025-10-01T00:00:00.000Z',
          };
          final assessmentCase = AssessmentCaseMapper.fromJson(json);
          expect(assessmentCase.status, status);
        }
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late AssessmentCase sampleCase;

      setUp(() {
        sampleCase = AssessmentCase(
          id: 'ac-json-001',
          clientId: 'client-json-001',
          assessmentYear: 'AY 2021-22',
          caseType: AssessmentType.appealCit,
          status: AssessmentCaseStatus.appealed,
          demandAmount: '500000.00',
          paidAmount: '100000.00',
          dueDate: DateTime(2026, 12, 31),
          notes: 'Submitted Form 35',
          createdAt: DateTime(2025, 9, 1),
          updatedAt: DateTime(2025, 12, 1),
        );
      });

      test('includes all fields', () {
        final json = AssessmentCaseMapper.toJson(sampleCase);

        expect(json['id'], 'ac-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['assessment_year'], 'AY 2021-22');
        expect(json['case_type'], 'appealCit');
        expect(json['status'], 'appealed');
        expect(json['demand_amount'], '500000.00');
        expect(json['paid_amount'], '100000.00');
        expect(json['notes'], 'Submitted Form 35');
      });

      test('serializes due_date as ISO string', () {
        final json = AssessmentCaseMapper.toJson(sampleCase);
        expect(json['due_date'], startsWith('2026-12-31'));
      });

      test('serializes null due_date and notes as null', () {
        final caseNoDate = AssessmentCase(
          id: 'ac-nodate',
          clientId: 'c1',
          assessmentYear: 'AY 2023-24',
          caseType: AssessmentType.intimation143_1,
          status: AssessmentCaseStatus.closed,
          demandAmount: '0.00',
          paidAmount: '0.00',
          createdAt: DateTime(2025, 10, 1),
          updatedAt: DateTime(2025, 10, 1),
        );
        final json = AssessmentCaseMapper.toJson(caseNoDate);
        expect(json['due_date'], isNull);
        expect(json['notes'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = AssessmentCaseMapper.toJson(sampleCase);
        json['created_at'] = sampleCase.createdAt.toIso8601String();
        json['updated_at'] = sampleCase.updatedAt.toIso8601String();

        final restored = AssessmentCaseMapper.fromJson(json);

        expect(restored.id, sampleCase.id);
        expect(restored.clientId, sampleCase.clientId);
        expect(restored.assessmentYear, sampleCase.assessmentYear);
        expect(restored.caseType, sampleCase.caseType);
        expect(restored.status, sampleCase.status);
        expect(restored.demandAmount, sampleCase.demandAmount);
        expect(restored.paidAmount, sampleCase.paidAmount);
        expect(restored.notes, sampleCase.notes);
      });

      test('handles large demand amount as string', () {
        final highDemand = sampleCase.copyWith(demandAmount: '99999999.99');
        final json = AssessmentCaseMapper.toJson(highDemand);
        expect(json['demand_amount'], '99999999.99');
      });
    });
  });
}
