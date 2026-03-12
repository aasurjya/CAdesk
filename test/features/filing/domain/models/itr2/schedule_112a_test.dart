import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_112a.dart';

void main() {
  group('Schedule112aEntry', () {
    group('effectiveCostOfAcquisition (grandfathering)', () {
      test('→ uses FMV when FMV > actual cost', () {
        const entry = Schedule112aEntry(
          isin: 'INF123456789',
          assetName: 'HDFC Top 100 Fund',
          unitsOrShares: 100,
          salePrice: 50000,
          costOfAcquisition: 20000,
          fmvOn31Jan2018: 35000,
          saleDate: '2025-01-15',
          acquisitionDate: '2016-06-01',
        );
        expect(entry.effectiveCostOfAcquisition, 35000.0);
      });

      test('→ uses actual cost when actual cost > FMV', () {
        const entry = Schedule112aEntry(
          isin: 'INF987654321',
          assetName: 'SBI Blue Chip',
          unitsOrShares: 200,
          salePrice: 80000,
          costOfAcquisition: 60000,
          fmvOn31Jan2018: 30000,
          saleDate: '2025-03-10',
          acquisitionDate: '2015-01-01',
        );
        expect(entry.effectiveCostOfAcquisition, 60000.0);
      });

      test('→ gain uses effectiveCostOfAcquisition', () {
        const entry = Schedule112aEntry(
          isin: 'INF111222333',
          assetName: 'Axis Bluechip',
          unitsOrShares: 500,
          salePrice: 200000,
          costOfAcquisition: 80000,
          fmvOn31Jan2018: 120000,
          saleDate: '2025-02-20',
          acquisitionDate: '2017-05-01',
        );
        // effectiveCOA = max(80000, 120000) = 120000
        // gain = 200000 - 120000 = 80000
        expect(entry.gain, 80000.0);
      });
    });

    group('equality and copyWith', () {
      const a = Schedule112aEntry(
        isin: 'ISIN001',
        assetName: 'Fund A',
        unitsOrShares: 100,
        salePrice: 10000,
        costOfAcquisition: 8000,
        fmvOn31Jan2018: 7000,
        saleDate: '2025-01-01',
        acquisitionDate: '2016-01-01',
      );

      test('→ identical instances are equal', () {
        const b = Schedule112aEntry(
          isin: 'ISIN001',
          assetName: 'Fund A',
          unitsOrShares: 100,
          salePrice: 10000,
          costOfAcquisition: 8000,
          fmvOn31Jan2018: 7000,
          saleDate: '2025-01-01',
          acquisitionDate: '2016-01-01',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('→ copyWith changes specified field', () {
        final updated = a.copyWith(salePrice: 15000);
        expect(updated.salePrice, 15000);
        expect(updated.isin, a.isin);
      });
    });
  });

  group('Schedule112a', () {
    test('→ totalGain is sum of all entry gains', () {
      const e1 = Schedule112aEntry(
        isin: 'ISIN001',
        assetName: 'Fund A',
        unitsOrShares: 100,
        salePrice: 200000,
        costOfAcquisition: 100000,
        fmvOn31Jan2018: 120000,
        saleDate: '2025-01-01',
        acquisitionDate: '2016-01-01',
      );
      const e2 = Schedule112aEntry(
        isin: 'ISIN002',
        assetName: 'Fund B',
        unitsOrShares: 50,
        salePrice: 80000,
        costOfAcquisition: 50000,
        fmvOn31Jan2018: 30000,
        saleDate: '2025-03-01',
        acquisitionDate: '2015-06-01',
      );
      const schedule = Schedule112a(entries: [e1, e2]);
      // e1: max(100000,120000)=120000, gain=80000
      // e2: max(50000,30000)=50000, gain=30000
      expect(schedule.totalGain, 110000.0);
    });

    test('→ taxableGain applies ₹1.25L exemption', () {
      const e = Schedule112aEntry(
        isin: 'ISIN003',
        assetName: 'Index Fund',
        unitsOrShares: 1000,
        salePrice: 500000,
        costOfAcquisition: 200000,
        fmvOn31Jan2018: 180000,
        saleDate: '2025-02-01',
        acquisitionDate: '2015-01-01',
      );
      const schedule = Schedule112a(entries: [e]);
      // gain = 500000 - 200000 = 300000, taxable = 300000 - 125000 = 175000
      expect(schedule.taxableGain, 175000.0);
    });

    test('→ taxableGain floors at zero when gain ≤ ₹1.25L', () {
      const e = Schedule112aEntry(
        isin: 'ISIN004',
        assetName: 'Small gain fund',
        unitsOrShares: 100,
        salePrice: 110000,
        costOfAcquisition: 100000,
        fmvOn31Jan2018: 90000,
        saleDate: '2025-01-15',
        acquisitionDate: '2016-01-01',
      );
      const schedule = Schedule112a(entries: [e]);
      // gain = 10000, taxable = max(0, 10000 - 125000) = 0
      expect(schedule.taxableGain, 0.0);
    });

    test('→ empty schedule has zero totalGain and zero taxableGain', () {
      const schedule = Schedule112a(entries: []);
      expect(schedule.totalGain, 0.0);
      expect(schedule.taxableGain, 0.0);
    });

    test('→ copyWith and equality', () {
      const s1 = Schedule112a(entries: []);
      const s2 = Schedule112a(entries: []);
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
    });
  });
}
