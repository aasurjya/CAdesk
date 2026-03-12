import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_112a.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/services/itr2_json_export_service.dart';
import 'package:ca_app/features/filing/domain/services/capital_gains_computation_service.dart';

void main() {
  group('Itr2JsonExportService', () {
    Itr2FormData buildMinimalForm() {
      return Itr2FormData.empty().copyWith(
        personalInfo: PersonalInfo.empty().copyWith(
          firstName: 'Suresh',
          lastName: 'Mehta',
          pan: 'ABCPK1234F',
          aadhaarNumber: '',
          mobile: '9876543210',
          email: 'suresh@example.com',
          bankIfsc: 'SBIN0001234',
          employerTan: 'ABCD12345E',
          pincode: '400001',
          city: 'Mumbai',
        ),
      );
    }

    test('→ export returns map with top-level ITR key', () {
      final form = buildMinimalForm();
      const schedule112a = Schedule112a(entries: []);
      final cgResult =
          CapitalGainsComputationService.computeTotalCapitalGainsTax(
            scheduleCg: form.scheduleCg,
            schedule112a: schedule112a,
          );

      final json = Itr2JsonExportService.export(
        formData: form,
        cgTaxResult: cgResult,
        schedule112a: schedule112a,
        assessmentYear: 'AY 2026-27',
        filingType: 'Original',
      );

      expect(json.containsKey('ITR'), isTrue);
      expect((json['ITR'] as Map<String, dynamic>).containsKey('ITR2'), isTrue);
    });

    test('→ exported JSON contains PersonalInfo section', () {
      final form = buildMinimalForm();
      const schedule112a = Schedule112a(entries: []);
      final cgResult =
          CapitalGainsComputationService.computeTotalCapitalGainsTax(
            scheduleCg: form.scheduleCg,
            schedule112a: schedule112a,
          );

      final json = Itr2JsonExportService.export(
        formData: form,
        cgTaxResult: cgResult,
        schedule112a: schedule112a,
        assessmentYear: 'AY 2026-27',
        filingType: 'Original',
      );

      final itr2 = json['ITR']['ITR2'] as Map<String, dynamic>;
      expect(itr2.containsKey('PartA_GEN1'), isTrue);
    });

    test('→ exported JSON contains ScheduleCG section', () {
      final stcgEntry = EquityStcgEntry(
        description: 'HDFC shares',
        salePrice: 500000,
        costOfAcquisition: 300000,
        transferExpenses: 5000,
      );
      final form = buildMinimalForm().copyWith(
        scheduleCg: ScheduleCg(
          equityStcgEntries: [stcgEntry],
          equityLtcgEntries: const [],
          debtStcgEntries: const [],
          debtLtcgEntries: const [],
          propertyLtcgEntries: const [],
          otherStcgEntries: const [],
          otherLtcgEntries: const [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        ),
      );
      const schedule112a = Schedule112a(entries: []);
      final cgResult =
          CapitalGainsComputationService.computeTotalCapitalGainsTax(
            scheduleCg: form.scheduleCg,
            schedule112a: schedule112a,
          );

      final json = Itr2JsonExportService.export(
        formData: form,
        cgTaxResult: cgResult,
        schedule112a: schedule112a,
        assessmentYear: 'AY 2026-27',
        filingType: 'Original',
      );

      final itr2 = json['ITR']['ITR2'] as Map<String, dynamic>;
      expect(itr2.containsKey('ScheduleCG'), isTrue);
    });

    test('→ exported JSON contains Schedule112A section', () {
      const e = Schedule112aEntry(
        isin: 'INF123456789',
        assetName: 'Axis Index Fund',
        unitsOrShares: 100,
        salePrice: 200000,
        costOfAcquisition: 100000,
        fmvOn31Jan2018: 80000,
        saleDate: '2025-01-15',
        acquisitionDate: '2016-06-01',
      );
      const schedule112a = Schedule112a(entries: [e]);
      final form = buildMinimalForm();
      final cgResult =
          CapitalGainsComputationService.computeTotalCapitalGainsTax(
            scheduleCg: form.scheduleCg,
            schedule112a: schedule112a,
          );

      final json = Itr2JsonExportService.export(
        formData: form,
        cgTaxResult: cgResult,
        schedule112a: schedule112a,
        assessmentYear: 'AY 2026-27',
        filingType: 'Original',
      );

      final itr2 = json['ITR']['ITR2'] as Map<String, dynamic>;
      expect(itr2.containsKey('Schedule112A'), isTrue);
    });

    test('→ PAN is present in exported JSON', () {
      final form = buildMinimalForm();
      const schedule112a = Schedule112a(entries: []);
      final cgResult =
          CapitalGainsComputationService.computeTotalCapitalGainsTax(
            scheduleCg: form.scheduleCg,
            schedule112a: schedule112a,
          );

      final json = Itr2JsonExportService.export(
        formData: form,
        cgTaxResult: cgResult,
        schedule112a: schedule112a,
        assessmentYear: 'AY 2026-27',
        filingType: 'Original',
      );

      final itr2 = json['ITR']['ITR2'] as Map<String, dynamic>;
      final partA = itr2['PartA_GEN1'] as Map<String, dynamic>;
      final personalInfo = partA['PersonalInfo'] as Map<String, dynamic>;
      expect(personalInfo['PAN'], 'ABCPK1234F');
    });
  });
}
