import 'dart:convert';

import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/tds_payment_summary.dart';
import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr1_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Itr1ExportService', () {
    late Itr1FormData sampleData;

    setUp(() {
      sampleData = Itr1FormData(
        personalInfo: PersonalInfo(
          firstName: 'Rahul',
          middleName: '',
          lastName: 'Sharma',
          pan: 'ABCDE1234F',
          aadhaarNumber: '123412341234',
          dateOfBirth: DateTime(1990, 5, 15),
          email: 'rahul@example.com',
          mobile: '9876543210',
          flatDoorBlock: '101',
          street: 'MG Road',
          city: 'Mumbai',
          state: 'MH',
          pincode: '400001',
          employerName: 'TechCorp',
          employerTan: 'MUMB12345A',
          bankAccountNumber: '1234567890',
          bankIfsc: 'HDFC0001234',
          bankName: 'HDFC Bank',
        ),
        salaryIncome: const SalaryIncome(
          grossSalary: 1000000,
          allowancesExemptUnderSection10: 100000,
          valueOfPerquisites: 0,
          profitsInLieuOfSalary: 0,
          standardDeduction: 75000,
        ),
        housePropertyIncome: HousePropertyIncome.empty(),
        otherSourceIncome: OtherSourceIncome.empty(),
        deductions: ChapterViaDeductions.empty(),
        selectedRegime: TaxRegime.newRegime,
        tdsPaymentSummary: TdsPaymentSummary.empty(),
      );
    });

    test('returns ItrExportResult with itrType itr1', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      expect(result.itrType, ItrType.itr1);
    });

    test('result has valid assessment year', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      expect(result.assessmentYear, '2024-25');
    });

    test('result has PAN from personal info', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      expect(result.panNumber, 'ABCDE1234F');
    });

    test('result has non-empty JSON payload', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      expect(result.jsonPayload.isNotEmpty, isTrue);
    });

    test('JSON payload is valid JSON', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      expect(() => jsonDecode(result.jsonPayload), returnsNormally);
    });

    test('JSON has ITR.ITR1 structure', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
      expect(decoded['ITR'], isA<Map>());
      final itr = decoded['ITR'] as Map<String, dynamic>;
      expect(itr['ITR1'], isA<Map>());
    });

    test('JSON contains PersonalInfo with correct PAN', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
      final itr1 =
          (decoded['ITR'] as Map<String, dynamic>)['ITR1']
              as Map<String, dynamic>;
      final personalInfo = itr1['PersonalInfo'] as Map<String, dynamic>;
      expect(personalInfo['PAN'], 'ABCDE1234F');
    });

    test('JSON contains FilingStatus', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
      final itr1 =
          (decoded['ITR'] as Map<String, dynamic>)['ITR1']
              as Map<String, dynamic>;
      expect(itr1.containsKey('FilingStatus'), isTrue);
    });

    test('JSON contains ITR1_IncomeDeductions', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
      final itr1 =
          (decoded['ITR'] as Map<String, dynamic>)['ITR1']
              as Map<String, dynamic>;
      expect(itr1.containsKey('ITR1_IncomeDeductions'), isTrue);
    });

    test('JSON contains TaxComputation', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
      final itr1 =
          (decoded['ITR'] as Map<String, dynamic>)['ITR1']
              as Map<String, dynamic>;
      expect(itr1.containsKey('TaxComputation'), isTrue);
    });

    test('income amounts are integers in JSON', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
      final itr1 =
          (decoded['ITR'] as Map<String, dynamic>)['ITR1']
              as Map<String, dynamic>;
      final incomeDeductions =
          itr1['ITR1_IncomeDeductions'] as Map<String, dynamic>;
      expect(incomeDeductions['GrossSalary'], isA<int>());
      expect(incomeDeductions['NetSalary'], isA<int>());
    });

    test('checksum is 64-character hex', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      expect(result.checksum.length, 64);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(result.checksum), isTrue);
    });

    test('validation errors list is empty for valid data', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      expect(result.validationErrors, isEmpty);
    });

    test('exportedAt is set to a recent DateTime', () {
      final before = DateTime.now();
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final after = DateTime.now();
      expect(
        result.exportedAt.isAfter(before) ||
            result.exportedAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        result.exportedAt.isBefore(after) ||
            result.exportedAt.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('GrossSalary in JSON matches gross salary from form (rupees)', () {
      final result = Itr1ExportService.export(sampleData, '2024-25');
      final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
      final itr1 =
          (decoded['ITR'] as Map<String, dynamic>)['ITR1']
              as Map<String, dynamic>;
      final incomeDeductions =
          itr1['ITR1_IncomeDeductions'] as Map<String, dynamic>;
      // grossSalary = 1000000, stored as integer rupees
      expect(incomeDeductions['GrossSalary'], 1000000);
    });
  });
}
