import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/payroll/data/mappers/payroll_mapper.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_entry.dart';

void main() {
  group('PayrollMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'pay-001',
          'client_id': 'client-001',
          'employee_id': 'emp-001',
          'month': 4,
          'year': 2025,
          'basic_salary': '25000.00',
          'allowances': '5000.00',
          'deductions': '1000.00',
          'tds_deducted': '2000.00',
          'pf_deducted': '1800.00',
          'esi_deducted': '375.00',
          'net_salary': '24825.00',
          'status': 'paid',
        };

        final entry = PayrollMapper.fromJson(json);

        expect(entry.id, 'pay-001');
        expect(entry.clientId, 'client-001');
        expect(entry.employeeId, 'emp-001');
        expect(entry.month, 4);
        expect(entry.year, 2025);
        expect(entry.basicSalary, '25000.00');
        expect(entry.allowances, '5000.00');
        expect(entry.deductions, '1000.00');
        expect(entry.tdsDeducted, '2000.00');
        expect(entry.pfDeducted, '1800.00');
        expect(entry.esiDeducted, '375.00');
        expect(entry.netSalary, '24825.00');
        expect(entry.status, 'paid');
      });

      test('handles null monetary fields with 0.00 default', () {
        final json = {
          'id': 'pay-002',
          'client_id': 'client-002',
          'employee_id': 'emp-002',
          'month': 5,
          'year': 2025,
          'basic_salary': null,
          'allowances': null,
          'deductions': null,
          'tds_deducted': null,
          'pf_deducted': null,
          'esi_deducted': null,
          'net_salary': null,
          'status': 'draft',
        };

        final entry = PayrollMapper.fromJson(json);
        expect(entry.basicSalary, '0.00');
        expect(entry.allowances, '0.00');
        expect(entry.deductions, '0.00');
        expect(entry.tdsDeducted, '0.00');
        expect(entry.pfDeducted, '0.00');
        expect(entry.esiDeducted, '0.00');
        expect(entry.netSalary, '0.00');
      });

      test('converts numeric monetary values to string with 2 decimal places',
          () {
        final json = {
          'id': 'pay-003',
          'client_id': 'client-003',
          'employee_id': 'emp-003',
          'month': 6,
          'year': 2025,
          'basic_salary': 30000,
          'allowances': 7500,
          'deductions': 500,
          'tds_deducted': 3000,
          'pf_deducted': 2160,
          'esi_deducted': 450,
          'net_salary': 31390,
          'status': 'approved',
        };

        final entry = PayrollMapper.fromJson(json);
        expect(entry.basicSalary, '30000.00');
        expect(entry.allowances, '7500.00');
        expect(entry.netSalary, '31390.00');
      });

      test('handles null employee_id as empty string', () {
        final json = {
          'id': 'pay-004',
          'client_id': 'client-004',
          'month': 4,
          'year': 2025,
          'basic_salary': '10000.00',
          'allowances': '2000.00',
          'deductions': '0.00',
          'tds_deducted': '0.00',
          'pf_deducted': '0.00',
          'esi_deducted': '0.00',
          'net_salary': '12000.00',
          'status': 'draft',
        };

        final entry = PayrollMapper.fromJson(json);
        expect(entry.employeeId, '');
      });

      test('defaults status to draft when absent', () {
        final json = {
          'id': 'pay-005',
          'client_id': 'client-005',
          'employee_id': 'emp-005',
          'month': 4,
          'year': 2025,
          'basic_salary': '20000.00',
          'allowances': '0.00',
          'deductions': '0.00',
          'tds_deducted': '0.00',
          'pf_deducted': '0.00',
          'esi_deducted': '0.00',
          'net_salary': '20000.00',
        };

        final entry = PayrollMapper.fromJson(json);
        expect(entry.status, 'draft');
      });

      test('handles decimal float monetary values', () {
        final json = {
          'id': 'pay-006',
          'client_id': 'c1',
          'employee_id': 'e1',
          'month': 4,
          'year': 2025,
          'basic_salary': 25000.5,
          'allowances': '3000.75',
          'deductions': '0.00',
          'tds_deducted': '0.00',
          'pf_deducted': '0.00',
          'esi_deducted': '0.00',
          'net_salary': '28001.25',
          'status': 'draft',
        };

        final entry = PayrollMapper.fromJson(json);
        expect(entry.basicSalary, '25000.50');
        expect(entry.allowances, '3000.75');
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late PayrollEntry sampleEntry;

      setUp(() {
        sampleEntry = const PayrollEntry(
          id: 'pay-json-001',
          clientId: 'client-json-001',
          employeeId: 'emp-json-001',
          month: 3,
          year: 2026,
          basicSalary: '40000.00',
          allowances: '10000.00',
          deductions: '2000.00',
          tdsDeducted: '5000.00',
          pfDeducted: '2880.00',
          esiDeducted: '600.00',
          netSalary: '39520.00',
          status: 'paid',
        );
      });

      test('includes all fields', () {
        final json = PayrollMapper.toJson(sampleEntry);

        expect(json['id'], 'pay-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['employee_id'], 'emp-json-001');
        expect(json['month'], 3);
        expect(json['year'], 2026);
        expect(json['basic_salary'], '40000.00');
        expect(json['allowances'], '10000.00');
        expect(json['deductions'], '2000.00');
        expect(json['tds_deducted'], '5000.00');
        expect(json['pf_deducted'], '2880.00');
        expect(json['esi_deducted'], '600.00');
        expect(json['net_salary'], '39520.00');
        expect(json['status'], 'paid');
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = PayrollMapper.toJson(sampleEntry);
        final restored = PayrollMapper.fromJson(json);

        expect(restored.id, sampleEntry.id);
        expect(restored.clientId, sampleEntry.clientId);
        expect(restored.employeeId, sampleEntry.employeeId);
        expect(restored.month, sampleEntry.month);
        expect(restored.year, sampleEntry.year);
        expect(restored.basicSalary, sampleEntry.basicSalary);
        expect(restored.netSalary, sampleEntry.netSalary);
        expect(restored.status, sampleEntry.status);
      });

      test('serializes all monetary amounts as strings', () {
        final json = PayrollMapper.toJson(sampleEntry);
        expect(json['basic_salary'], isA<String>());
        expect(json['net_salary'], isA<String>());
        expect(json['tds_deducted'], isA<String>());
      });

      test('handles zero deductions', () {
        final zeroDeductEntry = sampleEntry.copyWith(
          deductions: '0.00',
          tdsDeducted: '0.00',
          pfDeducted: '0.00',
          esiDeducted: '0.00',
        );
        final json = PayrollMapper.toJson(zeroDeductEntry);
        expect(json['deductions'], '0.00');
        expect(json['tds_deducted'], '0.00');
        expect(json['pf_deducted'], '0.00');
        expect(json['esi_deducted'], '0.00');
      });

      test('preserves approved status', () {
        final approvedEntry = sampleEntry.copyWith(status: 'approved');
        final json = PayrollMapper.toJson(approvedEntry);
        expect(json['status'], 'approved');
      });
    });
  });
}
