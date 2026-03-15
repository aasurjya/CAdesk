import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/data/mappers/tds_return_mapper.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

void main() {
  group('TdsReturnMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'tds-001',
          'deductor_id': 'deductor-001',
          'tan': 'MUMR12345A',
          'form_type': 'form26Q',
          'quarter': 'q1',
          'financial_year': '2025-26',
          'filing_status': 'filed',
          'total_deductions': 500000.0,
          'total_tax_deducted': 50000.0,
          'total_deposited': 50000.0,
          'filed_date': '2025-07-31T00:00:00.000Z',
          'token_number': 'TKN2025001',
        };

        final tdsReturn = TdsReturnMapper.fromJson(json);

        expect(tdsReturn.id, 'tds-001');
        expect(tdsReturn.deductorId, 'deductor-001');
        expect(tdsReturn.tan, 'MUMR12345A');
        expect(tdsReturn.formType, TdsFormType.form26Q);
        expect(tdsReturn.quarter, TdsQuarter.q1);
        expect(tdsReturn.financialYear, '2025-26');
        expect(tdsReturn.status, TdsReturnStatus.filed);
        expect(tdsReturn.totalDeductions, 500000.0);
        expect(tdsReturn.totalTaxDeducted, 50000.0);
        expect(tdsReturn.totalDeposited, 50000.0);
        expect(tdsReturn.filedDate, isNotNull);
        expect(tdsReturn.tokenNumber, 'TKN2025001');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'tds-002',
          'deductor_id': 'deductor-002',
          'tan': 'BLRR54321B',
          'form_type': 'form24Q',
          'quarter': 'q2',
          'financial_year': '2025-26',
          'filing_status': 'pending',
          'total_deductions': 0.0,
          'total_tax_deducted': 0.0,
          'total_deposited': 0.0,
        };

        final tdsReturn = TdsReturnMapper.fromJson(json);
        expect(tdsReturn.filedDate, isNull);
        expect(tdsReturn.tokenNumber, isNull);
      });

      test('defaults form_type to form26Q for unknown value', () {
        final json = {
          'id': 'tds-003',
          'deductor_id': 'd1',
          'tan': 'MUMR12345A',
          'form_type': 'unknownForm',
          'quarter': 'q1',
          'financial_year': '2025-26',
          'filing_status': 'pending',
          'total_deductions': 0.0,
          'total_tax_deducted': 0.0,
          'total_deposited': 0.0,
        };

        final tdsReturn = TdsReturnMapper.fromJson(json);
        expect(tdsReturn.formType, TdsFormType.form26Q);
      });

      test('defaults quarter to q1 for unknown value', () {
        final json = {
          'id': 'tds-004',
          'deductor_id': 'd1',
          'tan': 'MUMR12345A',
          'form_type': 'form26Q',
          'quarter': 'unknownQ',
          'financial_year': '2025-26',
          'filing_status': 'pending',
          'total_deductions': 0.0,
          'total_tax_deducted': 0.0,
          'total_deposited': 0.0,
        };

        final tdsReturn = TdsReturnMapper.fromJson(json);
        expect(tdsReturn.quarter, TdsQuarter.q1);
      });

      test('defaults status to pending for unknown value', () {
        final json = {
          'id': 'tds-005',
          'deductor_id': 'd1',
          'tan': 'MUMR12345A',
          'form_type': 'form26Q',
          'quarter': 'q3',
          'financial_year': '2025-26',
          'filing_status': 'unknownStatus',
          'total_deductions': 0.0,
          'total_tax_deducted': 0.0,
          'total_deposited': 0.0,
        };

        final tdsReturn = TdsReturnMapper.fromJson(json);
        expect(tdsReturn.status, TdsReturnStatus.pending);
      });

      test('handles all TdsFormType values', () {
        for (final formType in TdsFormType.values) {
          final json = {
            'id': 'tds-form-${formType.name}',
            'deductor_id': 'd1',
            'tan': 'MUMR12345A',
            'form_type': formType.name,
            'quarter': 'q1',
            'financial_year': '2025-26',
            'filing_status': 'pending',
            'total_deductions': 0.0,
            'total_tax_deducted': 0.0,
            'total_deposited': 0.0,
          };
          final tdsReturn = TdsReturnMapper.fromJson(json);
          expect(tdsReturn.formType, formType);
        }
      });

      test('handles all TdsQuarter values', () {
        for (final quarter in TdsQuarter.values) {
          final json = {
            'id': 'tds-quarter-${quarter.name}',
            'deductor_id': 'd1',
            'tan': 'MUMR12345A',
            'form_type': 'form26Q',
            'quarter': quarter.name,
            'financial_year': '2025-26',
            'filing_status': 'pending',
            'total_deductions': 0.0,
            'total_tax_deducted': 0.0,
            'total_deposited': 0.0,
          };
          final tdsReturn = TdsReturnMapper.fromJson(json);
          expect(tdsReturn.quarter, quarter);
        }
      });

      test('handles all TdsReturnStatus values', () {
        for (final status in TdsReturnStatus.values) {
          final json = {
            'id': 'tds-status-${status.name}',
            'deductor_id': 'd1',
            'tan': 'MUMR12345A',
            'form_type': 'form26Q',
            'quarter': 'q1',
            'financial_year': '2025-26',
            'filing_status': status.name,
            'total_deductions': 0.0,
            'total_tax_deducted': 0.0,
            'total_deposited': 0.0,
          };
          final tdsReturn = TdsReturnMapper.fromJson(json);
          expect(tdsReturn.status, status);
        }
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late TdsReturn sampleReturn;

      setUp(() {
        sampleReturn = TdsReturn(
          id: 'tds-json-001',
          deductorId: 'deductor-json-001',
          tan: 'MUMR12345A',
          formType: TdsFormType.form24Q,
          quarter: TdsQuarter.q4,
          financialYear: '2025-26',
          status: TdsReturnStatus.filed,
          totalDeductions: 1000000.0,
          totalTaxDeducted: 100000.0,
          totalDeposited: 100000.0,
          filedDate: DateTime(2025, 5, 31),
          tokenNumber: 'TKN2025Q4',
        );
      });

      test('includes all fields', () {
        final json = TdsReturnMapper.toJson(sampleReturn);

        expect(json['id'], 'tds-json-001');
        expect(json['deductor_id'], 'deductor-json-001');
        expect(json['tan'], 'MUMR12345A');
        expect(json['form_type'], 'form24Q');
        expect(json['quarter'], 'q4');
        expect(json['financial_year'], '2025-26');
        expect(json['filing_status'], 'filed');
        expect(json['total_deductions'], 1000000.0);
        expect(json['total_tax_deducted'], 100000.0);
        expect(json['total_deposited'], 100000.0);
        expect(json['token_number'], 'TKN2025Q4');
      });

      test('serializes filed_date as ISO string', () {
        final json = TdsReturnMapper.toJson(sampleReturn);
        expect(json['filed_date'], startsWith('2025-05-31'));
      });

      test('serializes null filed_date as null', () {
        final pendingReturn = TdsReturn(
          id: 'tds-pending',
          deductorId: 'd1',
          tan: 'MUMR12345A',
          formType: TdsFormType.form26Q,
          quarter: TdsQuarter.q2,
          financialYear: '2025-26',
          status: TdsReturnStatus.pending,
          totalDeductions: 0.0,
          totalTaxDeducted: 0.0,
          totalDeposited: 0.0,
        );
        final json = TdsReturnMapper.toJson(pendingReturn);
        expect(json['filed_date'], isNull);
        expect(json['token_number'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = TdsReturnMapper.toJson(sampleReturn);
        final restored = TdsReturnMapper.fromJson(json);

        expect(restored.id, sampleReturn.id);
        expect(restored.deductorId, sampleReturn.deductorId);
        expect(restored.tan, sampleReturn.tan);
        expect(restored.formType, sampleReturn.formType);
        expect(restored.quarter, sampleReturn.quarter);
        expect(restored.financialYear, sampleReturn.financialYear);
        expect(restored.status, sampleReturn.status);
        expect(restored.totalDeductions, sampleReturn.totalDeductions);
        expect(restored.tokenNumber, sampleReturn.tokenNumber);
      });

      test('handles zero financial values', () {
        final zeroReturn = TdsReturn(
          id: 'tds-zero',
          deductorId: 'd1',
          tan: 'MUMR12345A',
          formType: TdsFormType.form26Q,
          quarter: TdsQuarter.q1,
          financialYear: '2025-26',
          status: TdsReturnStatus.prepared,
          totalDeductions: 0.0,
          totalTaxDeducted: 0.0,
          totalDeposited: 0.0,
        );
        final json = TdsReturnMapper.toJson(zeroReturn);
        expect(json['total_deductions'], 0.0);
        expect(json['total_tax_deducted'], 0.0);
        expect(json['total_deposited'], 0.0);
      });
    });
  });
}
