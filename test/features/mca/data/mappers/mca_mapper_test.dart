import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca/data/mappers/mca_mapper.dart';
import 'package:ca_app/features/mca/domain/models/mca_filing_data.dart';

void main() {
  group('McaMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'mca-001',
          'client_id': 'client-001',
          'form_type': 'aoc4',
          'financial_year': '2024-25',
          'due_date': '2025-10-29T00:00:00.000Z',
          'filed_date': '2025-10-20T00:00:00.000Z',
          'status': 'filed',
          'filing_number': 'SRN/AOC4/123456',
          'remarks': 'Annual accounts filed on time',
        };

        final filing = McaMapper.fromJson(json);

        expect(filing.id, 'mca-001');
        expect(filing.clientId, 'client-001');
        expect(filing.formType, MCAFormType.aoc4);
        expect(filing.financialYear, '2024-25');
        expect(filing.dueDate.year, 2025);
        expect(filing.filedDate, isNotNull);
        expect(filing.status, 'filed');
        expect(filing.filingNumber, 'SRN/AOC4/123456');
        expect(filing.remarks, 'Annual accounts filed on time');
      });

      test('handles null filed_date, filing_number, and remarks', () {
        final json = {
          'id': 'mca-002',
          'client_id': 'client-002',
          'form_type': 'dir3',
          'financial_year': '2024-25',
          'due_date': '2025-09-30T00:00:00.000Z',
          'status': 'pending',
        };

        final filing = McaMapper.fromJson(json);
        expect(filing.filedDate, isNull);
        expect(filing.filingNumber, isNull);
        expect(filing.remarks, isNull);
        expect(filing.formType, MCAFormType.dir3);
      });

      test('defaults form_type to other for unknown value', () {
        final json = {
          'id': 'mca-003',
          'client_id': 'c1',
          'form_type': 'unknownForm',
          'financial_year': '2024-25',
          'due_date': '2025-10-30T00:00:00.000Z',
          'status': 'pending',
        };

        final filing = McaMapper.fromJson(json);
        expect(filing.formType, MCAFormType.other);
      });

      test('defaults status to pending when missing', () {
        final json = {
          'id': 'mca-004',
          'client_id': 'c1',
          'form_type': 'mbp1',
          'financial_year': '2024-25',
          'due_date': '2025-10-30T00:00:00.000Z',
        };

        final filing = McaMapper.fromJson(json);
        expect(filing.status, 'pending');
      });

      test('handles all MCAFormType values', () {
        for (final formType in MCAFormType.values) {
          final json = {
            'id': 'mca-form-${formType.name}',
            'client_id': 'c1',
            'form_type': formType.name,
            'financial_year': '2024-25',
            'due_date': '2025-10-30T00:00:00.000Z',
            'status': 'pending',
          };
          final filing = McaMapper.fromJson(json);
          expect(filing.formType, formType);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final filing = McaFilingData(
          id: 'mca-json-001',
          clientId: 'client-json-001',
          formType: MCAFormType.aoc4,
          financialYear: '2025-26',
          dueDate: DateTime.utc(2026, 10, 29),
          filedDate: DateTime.utc(2026, 10, 15),
          status: 'approved',
          filingNumber: 'SRN/AOC4/654321',
          remarks: 'Statutory filing completed',
        );

        final json = McaMapper.toJson(filing);

        expect(json['id'], 'mca-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['form_type'], 'aoc4');
        expect(json['financial_year'], '2025-26');
        expect(json['status'], 'approved');
        expect(json['filing_number'], 'SRN/AOC4/654321');
        expect(json['remarks'], 'Statutory filing completed');
        expect(json['filed_date'], isNotNull);

        final restored = McaMapper.fromJson(json);
        expect(restored.id, filing.id);
        expect(restored.formType, filing.formType);
        expect(restored.status, filing.status);
        expect(restored.remarks, filing.remarks);
      });

      test('serializes null optional fields as null', () {
        final filing = McaFilingData(
          id: 'mca-null',
          clientId: 'c1',
          formType: MCAFormType.dpt3,
          financialYear: '2024-25',
          dueDate: DateTime.utc(2025, 6, 30),
          status: 'pending',
        );

        final json = McaMapper.toJson(filing);
        expect(json['filed_date'], isNull);
        expect(json['filing_number'], isNull);
        expect(json['remarks'], isNull);
      });
    });
  });
}
