import 'package:ca_app/features/tds/domain/services/tds_rate_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TdsRateData.fy202526', () {
    final rates = TdsRateData.fy202526;

    test('list is non-empty', () {
      expect(rates, isNotEmpty);
    });

    test('all entries belong to FY 2025-26', () {
      for (final rate in rates) {
        expect(rate.financialYear, '2025-26');
      }
    });

    test('contains section 192 (Salary) with no-PAN rate of 30%', () {
      final s192 = rates.firstWhere((r) => r.section == '192');
      expect(s192.rateNoPan, 30);
      expect(s192.thresholdSingle, 250000);
      expect(s192.notes, contains('Slab rates'));
    });

    test('contains section 193 (Interest on securities) at 10%', () {
      final s193 = rates.firstWhere((r) => r.section == '193');
      expect(s193.rateIndividualHuf, 10);
      expect(s193.rateOthers, 10);
      expect(s193.rateNoPan, 20);
      expect(s193.thresholdSingle, 10000);
    });

    test('contains section 194 (Dividends) at 10%, threshold 5000', () {
      final s194 = rates.firstWhere((r) => r.section == '194');
      expect(s194.rateIndividualHuf, 10);
      expect(s194.thresholdSingle, 5000);
    });

    test('contains section 194A (Interest other than securities) at 10%', () {
      final s194a = rates.firstWhere((r) => r.section == '194A');
      expect(s194a.rateIndividualHuf, 10);
      expect(s194a.thresholdSingle, 40000);
    });

    test('contains section 194B (Lottery) at 30%', () {
      final s194b = rates.firstWhere((r) => r.section == '194B');
      expect(s194b.rateIndividualHuf, 30);
      expect(s194b.thresholdSingle, 10000);
    });

    test('contains section 194BB (Horse race) at 30%', () {
      final s194bb = rates.firstWhere((r) => r.section == '194BB');
      expect(s194bb.rateIndividualHuf, 30);
      expect(s194bb.thresholdSingle, 10000);
    });

    test('contains section 194C (Contractors): 1% individual, 2% others', () {
      final s194c = rates.firstWhere((r) => r.section == '194C');
      expect(s194c.rateIndividualHuf, 1);
      expect(s194c.rateOthers, 2);
      expect(s194c.thresholdSingle, 30000);
      expect(s194c.thresholdAggregate, 100000);
    });

    test('contains section 194I(a) (Rent P&M) at 2% with aggregate threshold', () {
      final s194ia = rates.firstWhere((r) => r.section == '194I(a)');
      expect(s194ia.rateIndividualHuf, 2);
      expect(s194ia.thresholdAggregate, 600000);
    });

    test('contains section 194I(b) (Rent Land/Building) at 10%', () {
      final s194ib = rates.firstWhere((r) => r.section == '194I(b)');
      expect(s194ib.rateIndividualHuf, 10);
      expect(s194ib.thresholdAggregate, 600000);
    });

    test('contains section 194IA (Immovable property sale) at 1%', () {
      final s194ia2 = rates.firstWhere((r) => r.section == '194IA');
      expect(s194ia2.rateIndividualHuf, 1);
      expect(s194ia2.thresholdSingle, 5000000);
    });

    test('contains section 194J(a) (Technical services) at 2%', () {
      final s194ja = rates.firstWhere((r) => r.section == '194J(a)');
      expect(s194ja.rateIndividualHuf, 2);
      expect(s194ja.rateOthers, 2);
    });

    test('contains section 194J(b) (Professional fees) at 10%', () {
      final s194jb = rates.firstWhere((r) => r.section == '194J(b)');
      expect(s194jb.rateIndividualHuf, 10);
      expect(s194jb.thresholdSingle, 30000);
    });

    test('contains section 194Q (Purchase of goods) at 0.1%', () {
      final s194q = rates.firstWhere((r) => r.section == '194Q');
      expect(s194q.rateIndividualHuf, closeTo(0.1, 0.001));
      expect(s194q.thresholdAggregate, 5000000);
    });

    test('contains section 194S (VDA) at 1%, threshold 50000', () {
      final s194s = rates.firstWhere((r) => r.section == '194S');
      expect(s194s.rateIndividualHuf, 1);
      expect(s194s.thresholdSingle, 50000);
    });

    test('contains section 195 (NR payments) at 20%', () {
      final s195 = rates.firstWhere((r) => r.section == '195');
      expect(s195.rateIndividualHuf, 20);
      expect(s195.notes, contains('surcharge'));
    });

    test('contains section 206C(1H) (TCS on goods) at 0.1%', () {
      final s206c1h = rates.firstWhere((r) => r.section == '206C(1H)');
      expect(s206c1h.rateIndividualHuf, closeTo(0.1, 0.001));
      expect(s206c1h.thresholdAggregate, 5000000);
    });

    test('all rates have non-null rateNoPan', () {
      for (final rate in rates) {
        expect(rate.rateNoPan, isNotNull);
      }
    });

    test('all rates have non-null section', () {
      for (final rate in rates) {
        expect(rate.section, isNotEmpty);
      }
    });

    test('sections are unique', () {
      final sections = rates.map((r) => r.section).toList();
      final uniqueSections = sections.toSet();
      expect(sections.length, uniqueSections.length);
    });
  });
}
