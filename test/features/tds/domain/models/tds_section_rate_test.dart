import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeducteeType enum', () {
    test('has correct labels for all values', () {
      expect(DeducteeType.individual.label, 'Individual');
      expect(DeducteeType.huf.label, 'HUF');
      expect(DeducteeType.company.label, 'Company');
      expect(DeducteeType.firm.label, 'Firm');
      expect(DeducteeType.aop.label, 'AOP/BOI');
      expect(DeducteeType.trust.label, 'Trust');
      expect(DeducteeType.government.label, 'Government');
      expect(DeducteeType.other.label, 'Other');
    });

    test('has 8 values', () {
      expect(DeducteeType.values.length, 8);
    });
  });

  group('TdsSectionRate', () {
    TdsSectionRate createRate({
      String section = '194C',
      String subSection = '',
      String description = 'Contractor payments',
      double rateIndividualHuf = 1.0,
      double rateOthers = 2.0,
      double rateNoPan = 20.0,
      double thresholdSingle = 30000,
      double thresholdAggregate = 100000,
      String financialYear = '2025-26',
      String notes = '',
    }) {
      return TdsSectionRate(
        section: section,
        subSection: subSection,
        description: description,
        rateIndividualHuf: rateIndividualHuf,
        rateOthers: rateOthers,
        rateNoPan: rateNoPan,
        thresholdSingle: thresholdSingle,
        thresholdAggregate: thresholdAggregate,
        financialYear: financialYear,
        notes: notes,
      );
    }

    test('creates with correct values', () {
      final rate = createRate();
      expect(rate.section, '194C');
      expect(rate.subSection, '');
      expect(rate.description, 'Contractor payments');
      expect(rate.rateIndividualHuf, 1.0);
      expect(rate.rateOthers, 2.0);
      expect(rate.rateNoPan, 20.0);
      expect(rate.thresholdSingle, 30000);
      expect(rate.thresholdAggregate, 100000);
      expect(rate.financialYear, '2025-26');
      expect(rate.notes, '');
    });

    test('copyWith replaces specified fields', () {
      final rate = createRate();
      final updated = rate.copyWith(section: '194J', rateIndividualHuf: 10.0);
      expect(updated.section, '194J');
      expect(updated.rateIndividualHuf, 10.0);
      // unchanged fields
      expect(updated.rateOthers, 2.0);
      expect(updated.description, 'Contractor payments');
    });

    test('copyWith with no arguments returns equal object', () {
      final rate = createRate();
      final copy = rate.copyWith();
      expect(copy, equals(rate));
    });

    test('equality → same values are equal', () {
      final a = createRate();
      final b = createRate();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → different values are not equal', () {
      final a = createRate(section: '194C');
      final b = createRate(section: '194J');
      expect(a, isNot(equals(b)));
    });
  });

  group('TdsComputationResult', () {
    TdsComputationResult createResult({
      String section = '194C',
      double grossAmount = 100000,
      double tdsRate = 1.0,
      double tdsAmount = 1000,
      double surcharge = 0,
      double educationCess = 0,
      double totalTds = 1000,
      bool thresholdApplied = false,
    }) {
      return TdsComputationResult(
        section: section,
        grossAmount: grossAmount,
        tdsRate: tdsRate,
        tdsAmount: tdsAmount,
        surcharge: surcharge,
        educationCess: educationCess,
        totalTds: totalTds,
        thresholdApplied: thresholdApplied,
      );
    }

    test('creates with correct values', () {
      final result = createResult();
      expect(result.section, '194C');
      expect(result.grossAmount, 100000);
      expect(result.tdsRate, 1.0);
      expect(result.tdsAmount, 1000);
      expect(result.surcharge, 0);
      expect(result.educationCess, 0);
      expect(result.totalTds, 1000);
      expect(result.thresholdApplied, false);
    });

    test('copyWith replaces specified fields', () {
      final result = createResult();
      final updated = result.copyWith(tdsAmount: 2000, totalTds: 2000);
      expect(updated.tdsAmount, 2000);
      expect(updated.totalTds, 2000);
      expect(updated.section, '194C');
    });

    test('equality → same values are equal', () {
      final a = createResult();
      final b = createResult();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → different values are not equal', () {
      final a = createResult(tdsAmount: 1000);
      final b = createResult(tdsAmount: 2000);
      expect(a, isNot(equals(b)));
    });
  });
}
