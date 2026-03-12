import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_ii_depreciation.dart';
import 'package:ca_app/features/accounts/domain/services/schedule_ii_depreciation_service.dart';

void main() {
  group('ScheduleIIDepreciationService', () {
    group('computeDepreciation - SLM method', () {
      test('computers use 3-year useful life under Schedule II', () {
        const block = AssetBlock(
          id: 'asset-1',
          assetName: 'Server',
          category: AssetCategory.computerAndPeripherals,
          openingWdvPaise: 30000000, // 3 lakh in paise
          additionsPaise: 0,
          disposalsPaise: 0,
          additionDate: null,
          disposalDate: null,
          depreciationMethod: DepreciationMethod.slm,
        );

        final result = ScheduleIIDepreciationService.computeDepreciation(
          block: block,
          financialYear: 2025,
        );

        // SLM: 30,00,000 / 3 years = 10,00,000 per year
        expect(result.depreciationForYearPaise, equals(10000000));
        expect(result.closingWdvPaise, equals(20000000));
      });

      test('buildings use 30-year useful life under Schedule II', () {
        const block = AssetBlock(
          id: 'asset-2',
          assetName: 'Office Building',
          category: AssetCategory.building,
          openingWdvPaise: 300000000, // 30 lakh in paise
          additionsPaise: 0,
          disposalsPaise: 0,
          additionDate: null,
          disposalDate: null,
          depreciationMethod: DepreciationMethod.slm,
        );

        final result = ScheduleIIDepreciationService.computeDepreciation(
          block: block,
          financialYear: 2025,
        );

        // SLM: 30,00,000 / 30 years = 1,00,000 per year
        expect(result.depreciationForYearPaise, equals(10000000));
        expect(result.closingWdvPaise, equals(290000000));
      });

      test('plant and machinery uses 15-year useful life under Schedule II', () {
        const block = AssetBlock(
          id: 'asset-3',
          assetName: 'Manufacturing Plant',
          category: AssetCategory.plantAndMachinery,
          openingWdvPaise: 150000000, // 15 lakh in paise
          additionsPaise: 0,
          disposalsPaise: 0,
          additionDate: null,
          disposalDate: null,
          depreciationMethod: DepreciationMethod.slm,
        );

        final result = ScheduleIIDepreciationService.computeDepreciation(
          block: block,
          financialYear: 2025,
        );

        // SLM: 15,00,000 / 15 years = 1,00,000 per year
        expect(result.depreciationForYearPaise, equals(10000000));
        expect(result.closingWdvPaise, equals(140000000));
      });

      test('pro-rata depreciation for addition mid-year (after Oct 3)', () {
        // Addition on Oct 15 = 168 days remaining out of 365
        final block = AssetBlock(
          id: 'asset-4',
          assetName: 'Laptop',
          category: AssetCategory.computerAndPeripherals,
          openingWdvPaise: 0,
          additionsPaise: 36500000, // 3,65,000 in paise for easy math
          additionDate: DateTime(2024, 10, 15),
          disposalsPaise: 0,
          disposalDate: null,
          depreciationMethod: DepreciationMethod.slm,
        );

        final result = ScheduleIIDepreciationService.computeDepreciation(
          block: block,
          financialYear: 2025,
        );

        // 3-year life, SLM rate = 36500000/3 = ~12166666 per year
        // Days remaining = Oct 15 to Mar 31 = 168 days
        // Pro-rata = 12166666 * 168 / 365
        final fullYearDepr = 36500000 ~/ 3;
        final daysRemaining = DateTime(2025, 3, 31)
            .difference(DateTime(2024, 10, 15))
            .inDays;
        final proRata = (fullYearDepr * daysRemaining) ~/ 365;
        expect(result.depreciationForYearPaise, equals(proRata));
      });

      test('disposal mid-year reduces depreciation pro-rata', () {
        final block = AssetBlock(
          id: 'asset-5',
          assetName: 'Old Computer',
          category: AssetCategory.computerAndPeripherals,
          openingWdvPaise: 30000000,
          additionsPaise: 0,
          additionDate: null,
          disposalsPaise: 15000000,
          disposalDate: DateTime(2024, 9, 30), // disposed after 6 months
          depreciationMethod: DepreciationMethod.slm,
        );

        final result = ScheduleIIDepreciationService.computeDepreciation(
          block: block,
          financialYear: 2025,
        );

        // Depreciation only till disposal date: Apr 1 to Sep 30 = 183 days
        // Full year depr on original: 30000000 / 3 = 10000000
        // Pro-rata: 10000000 * 183 / 365
        final fullYearDepr = 30000000 ~/ 3;
        final daysUsed = DateTime(2024, 9, 30)
            .difference(DateTime(2024, 4, 1))
            .inDays;
        final proRata = (fullYearDepr * daysUsed) ~/ 365;
        expect(result.depreciationForYearPaise, equals(proRata));
      });

      test('closing WDV cannot go below zero', () {
        const block = AssetBlock(
          id: 'asset-6',
          assetName: 'Fully Depreciated Asset',
          category: AssetCategory.computerAndPeripherals,
          openingWdvPaise: 100,
          additionsPaise: 0,
          additionDate: null,
          disposalsPaise: 0,
          disposalDate: null,
          depreciationMethod: DepreciationMethod.slm,
        );

        final result = ScheduleIIDepreciationService.computeDepreciation(
          block: block,
          financialYear: 2025,
        );

        expect(result.closingWdvPaise, greaterThanOrEqualTo(0));
      });
    });

    group('computeDepreciation - WDV method', () {
      test('WDV method reduces balance by rate each year', () {
        const block = AssetBlock(
          id: 'asset-7',
          assetName: 'Vehicle',
          category: AssetCategory.motorVehicle,
          openingWdvPaise: 10000000,
          additionsPaise: 0,
          additionDate: null,
          disposalsPaise: 0,
          disposalDate: null,
          depreciationMethod: DepreciationMethod.wdv,
        );

        final result = ScheduleIIDepreciationService.computeDepreciation(
          block: block,
          financialYear: 2025,
        );

        // Vehicle WDV rate typically 25.89% per Schedule II
        // Just verify the depreciation is positive and closing < opening
        expect(result.depreciationForYearPaise, greaterThan(0));
        expect(result.closingWdvPaise, lessThan(10000000));
        expect(result.closingWdvPaise, greaterThan(0));
      });
    });

    group('ScheduleIIDepreciation model', () {
      test('copyWith returns new instance with updated fields', () {
        const original = ScheduleIIDepreciation(
          assetBlock: AssetBlock(
            id: 'x',
            assetName: 'Test',
            category: AssetCategory.computerAndPeripherals,
            openingWdvPaise: 1000,
            additionsPaise: 0,
            additionDate: null,
            disposalsPaise: 0,
            disposalDate: null,
            depreciationMethod: DepreciationMethod.slm,
          ),
          depreciationForYearPaise: 333,
          closingWdvPaise: 667,
          financialYear: 2025,
          usefulLifeYears: 3,
          slmRatePercent: 33.33,
        );

        final updated = original.copyWith(financialYear: 2026);
        expect(updated.financialYear, equals(2026));
        expect(original.financialYear, equals(2025));
      });

      test('equality is value-based', () {
        const block = AssetBlock(
          id: 'x',
          assetName: 'Test',
          category: AssetCategory.computerAndPeripherals,
          openingWdvPaise: 1000,
          additionsPaise: 0,
          additionDate: null,
          disposalsPaise: 0,
          disposalDate: null,
          depreciationMethod: DepreciationMethod.slm,
        );
        const a = ScheduleIIDepreciation(
          assetBlock: block,
          depreciationForYearPaise: 333,
          closingWdvPaise: 667,
          financialYear: 2025,
          usefulLifeYears: 3,
          slmRatePercent: 33.33,
        );
        const b = ScheduleIIDepreciation(
          assetBlock: block,
          depreciationForYearPaise: 333,
          closingWdvPaise: 667,
          financialYear: 2025,
          usefulLifeYears: 3,
          slmRatePercent: 33.33,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
