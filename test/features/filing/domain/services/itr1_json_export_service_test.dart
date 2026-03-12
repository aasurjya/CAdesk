import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/services/itr1_json_export_service.dart';
import 'package:ca_app/features/filing/domain/services/tax_computation_engine.dart';

void main() {
  late Itr1FormData formData;
  late Map<String, dynamic> exported;

  setUp(() {
    formData = Itr1FormData.empty().copyWith(
      personalInfo: PersonalInfo.empty().copyWith(
        firstName: 'Ramesh',
        lastName: 'Kumar',
        pan: 'ABCPK1234F',
        email: 'ramesh@example.com',
        mobile: '9876543210',
        city: 'Mumbai',
      ),
      salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 1000000),
    );
    final taxResult = TaxComputationEngine.compare(formData);
    exported = Itr1JsonExportService.export(
      formData: formData,
      taxResult: taxResult,
      assessmentYear: 'AY 2026-27',
      filingType: 'Original',
    );
  });

  group('Itr1JsonExportService — structure', () {
    test('has ITR.ITR1 root', () {
      expect(exported.containsKey('ITR'), isTrue);
      final itr = exported['ITR'] as Map<String, dynamic>;
      expect(itr.containsKey('ITR1'), isTrue);
    });

    test('has all required sections', () {
      final itr1 = (exported['ITR'] as Map)['ITR1'] as Map<String, dynamic>;
      expect(itr1.containsKey('CreationInfo'), isTrue);
      expect(itr1.containsKey('PartA_GEN1'), isTrue);
      expect(itr1.containsKey('ScheduleS'), isTrue);
      expect(itr1.containsKey('ScheduleHP'), isTrue);
      expect(itr1.containsKey('ScheduleOS'), isTrue);
      expect(itr1.containsKey('ScheduleVIA'), isTrue);
      expect(itr1.containsKey('PartBTI'), isTrue);
      expect(itr1.containsKey('PartBTTI'), isTrue);
      expect(itr1.containsKey('Verification'), isTrue);
    });
  });

  group('Itr1JsonExportService — CreationInfo', () {
    test('has assessment year and filing type', () {
      final itr1 = (exported['ITR'] as Map)['ITR1'] as Map;
      final info = itr1['CreationInfo'] as Map;
      expect(info['Aboression'], 'AY 2026-27');
      expect(info['FilingType'], 'Original');
      expect(info['SWVersionNo'], contains('CADesk'));
    });
  });

  group('Itr1JsonExportService — Personal Info', () {
    test('exports PAN and name', () {
      final itr1 = (exported['ITR'] as Map)['ITR1'] as Map;
      final gen = itr1['PartA_GEN1'] as Map;
      final pi = gen['PersonalInfo'] as Map;
      expect(pi['PAN'], 'ABCPK1234F');
      expect((pi['AssesseeName'] as Map)['FirstName'], 'Ramesh');
    });
  });

  group('Itr1JsonExportService — Salary Schedule', () {
    test('exports gross salary and net salary', () {
      final itr1 = (exported['ITR'] as Map)['ITR1'] as Map;
      final sched = itr1['ScheduleS'] as Map;
      expect(sched['Salaries'], 1000000);
      expect(sched['NetSalary'], isA<double>());
    });
  });

  group('Itr1JsonExportService — Tax Computation', () {
    test('has both regime breakdowns', () {
      final itr1 = (exported['ITR'] as Map)['ITR1'] as Map;
      final btti = itr1['PartBTTI'] as Map;
      expect(btti.containsKey('OldRegime'), isTrue);
      expect(btti.containsKey('NewRegime'), isTrue);
      expect(btti.containsKey('RecommendedRegime'), isTrue);
    });
  });
}
