import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_112a.dart';
import 'package:ca_app/features/filing/domain/services/capital_gains_computation_service.dart';

void main() {
  group('CapitalGainsComputationService', () {
    group('computeStcg111ATax (Section 111A — 20%)', () {
      test('→ 20% on net STCG after set-off for listed equity', () {
        const entry = EquityStcgEntry(
          description: 'Nifty ETF',
          salePrice: 500000,
          costOfAcquisition: 300000,
          transferExpenses: 2000,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [entry],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // STCG = 500000 - 300000 - 2000 = 198000
        // Tax = 198000 * 20% = 39600
        final tax = CapitalGainsComputationService.computeStcg111ATax(schedule);
        expect(tax, 39600.0);
      });

      test('→ zero tax when STCG is zero', () {
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        final tax = CapitalGainsComputationService.computeStcg111ATax(schedule);
        expect(tax, 0.0);
      });

      test('→ zero tax when net STCG is negative (loss)', () {
        const entry = EquityStcgEntry(
          description: 'Loss trade',
          salePrice: 100000,
          costOfAcquisition: 150000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [entry],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        final tax = CapitalGainsComputationService.computeStcg111ATax(schedule);
        expect(tax, 0.0);
      });
    });

    group('computeLtcg112ATax (Section 112A — 12.5%)', () {
      test('→ 12.5% on gains above ₹1.25L exemption', () {
        const e = Schedule112aEntry(
          isin: 'ISIN001',
          assetName: 'Axis Index Fund',
          unitsOrShares: 1000,
          salePrice: 500000,
          costOfAcquisition: 200000,
          fmvOn31Jan2018: 180000,
          saleDate: '2025-01-15',
          acquisitionDate: '2015-06-01',
        );
        const schedule = Schedule112a(entries: [e]);
        // gain = 500000-200000 = 300000, taxable = 300000-125000 = 175000
        // tax = 175000 * 12.5% = 21875
        final tax = CapitalGainsComputationService.computeLtcg112ATax(schedule);
        expect(tax, 21875.0);
      });

      test('→ zero tax when total gain ≤ ₹1.25L', () {
        const e = Schedule112aEntry(
          isin: 'ISIN002',
          assetName: 'Small gain',
          unitsOrShares: 10,
          salePrice: 110000,
          costOfAcquisition: 100000,
          fmvOn31Jan2018: 90000,
          saleDate: '2025-02-01',
          acquisitionDate: '2016-01-01',
        );
        const schedule = Schedule112a(entries: [e]);
        final tax = CapitalGainsComputationService.computeLtcg112ATax(schedule);
        expect(tax, 0.0);
      });
    });

    group('computeLtcgOnPropertyTax (20%)', () {
      test('→ 20% on LTCG on property', () {
        final entry = PropertyLtcgEntry(
          description: 'Apartment',
          salePrice: 8000000,
          indexedCostOfAcquisition: 4000000,
          improvementCost: 200000,
          transferExpenses: 100000,
          acquisitionDate: DateTime(2018, 3, 1),
        );
        final schedule = ScheduleCg(
          equityStcgEntries: const [],
          equityLtcgEntries: const [],
          debtStcgEntries: const [],
          debtLtcgEntries: const [],
          propertyLtcgEntries: [entry],
          otherStcgEntries: const [],
          otherLtcgEntries: const [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // LTCG = 8000000 - 4000000 - 200000 - 100000 = 3700000
        // Tax = 3700000 * 20% = 740000
        final tax = CapitalGainsComputationService.computeLtcgOnPropertyTax(
          schedule,
        );
        expect(tax, 740000.0);
      });

      test('→ zero tax when property LTCG is zero', () {
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        final tax = CapitalGainsComputationService.computeLtcgOnPropertyTax(
          schedule,
        );
        expect(tax, 0.0);
      });
    });

    group('computeTotalCapitalGainsTax', () {
      test('→ aggregates all CG tax components', () {
        const stcgEntry = EquityStcgEntry(
          description: 'STCG stock',
          salePrice: 300000,
          costOfAcquisition: 200000,
          transferExpenses: 0,
        );
        const cg112aEntry = Schedule112aEntry(
          isin: 'ISIN001',
          assetName: 'Index Fund',
          unitsOrShares: 500,
          salePrice: 500000,
          costOfAcquisition: 100000,
          fmvOn31Jan2018: 80000,
          saleDate: '2025-01-01',
          acquisitionDate: '2015-01-01',
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [stcgEntry],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        const schedule112a = Schedule112a(entries: [cg112aEntry]);

        final result =
            CapitalGainsComputationService.computeTotalCapitalGainsTax(
              scheduleCg: schedule,
              schedule112a: schedule112a,
            );

        // STCG tax = 100000 * 20% = 20000
        // 112A gain = 400000, taxable = 275000, tax = 275000 * 12.5% = 34375
        // Total = 54375
        expect(result.stcg111ATax, 20000.0);
        expect(result.ltcg112ATax, 34375.0);
        expect(result.totalCgTax, 54375.0);
      });
    });
  });

  group('computeLtcgOtherTax (Section 112 — lower of 20%/10%)', () {
    test('→ zero tax for empty otherLtcgEntries', () {
      const schedule = ScheduleCg(
        equityStcgEntries: [],
        equityLtcgEntries: [],
        debtStcgEntries: [],
        debtLtcgEntries: [],
        propertyLtcgEntries: [],
        otherStcgEntries: [],
        otherLtcgEntries: [],
        broughtForwardStcl: 0,
        broughtForwardLtcl: 0,
      );
      final tax = CapitalGainsComputationService.computeLtcgOtherTax(schedule);
      expect(tax, 0.0);
    });

    test(
      '→ returns taxWith when taxWith < taxWithout (indexation saves tax)',
      () {
        // gainWithIndexation = 200000 - 190000 - 0 = 10000, taxWith = 2000
        // gainWithoutIndexation = 200000 - 100000 - 0 = 100000, taxWithout = 10000
        const entry = OtherLtcgEntry(
          description: 'Jewellery',
          salePrice: 200000,
          costOfAcquisition: 100000,
          indexedCostOfAcquisition: 190000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [entry],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // taxWith = 10000 * 20% = 2000 < taxWithout = 100000 * 10% = 10000
        final tax = CapitalGainsComputationService.computeLtcgOtherTax(
          schedule,
        );
        expect(tax, 2000.0);
      },
    );

    test(
      '→ returns taxWithout when taxWithout < taxWith (no indexation is lower)',
      () {
        // gainWithIndexation = 500000 - 100000 - 0 = 400000, taxWith = 80000
        // gainWithoutIndexation = 500000 - 450000 - 0 = 50000, taxWithout = 5000
        const entry = OtherLtcgEntry(
          description: 'Painting',
          salePrice: 500000,
          costOfAcquisition: 450000,
          indexedCostOfAcquisition: 100000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [entry],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // taxWith = 400000 * 20% = 80000 > taxWithout = 50000 * 10% = 5000
        final tax = CapitalGainsComputationService.computeLtcgOtherTax(
          schedule,
        );
        expect(tax, 5000.0);
      },
    );

    test('→ negative gains are clamped to zero', () {
      const entry = OtherLtcgEntry(
        description: 'Loss asset',
        salePrice: 50000,
        costOfAcquisition: 200000,
        indexedCostOfAcquisition: 250000,
        transferExpenses: 0,
      );
      const schedule = ScheduleCg(
        equityStcgEntries: [],
        equityLtcgEntries: [],
        debtStcgEntries: [],
        debtLtcgEntries: [],
        propertyLtcgEntries: [],
        otherStcgEntries: [],
        otherLtcgEntries: [entry],
        broughtForwardStcl: 0,
        broughtForwardLtcl: 0,
      );
      final tax = CapitalGainsComputationService.computeLtcgOtherTax(schedule);
      expect(tax, 0.0);
    });

    test(
      '→ multiple otherLtcgEntries are aggregated before choosing lower',
      () {
        // e1: gainWithIndex=100000, gainWithout=80000
        // e2: gainWithIndex=50000,  gainWithout=20000
        // taxWith  = (100000+50000)*20% = 30000
        // taxWithout = (80000+20000)*10% = 10000 → lower
        const e1 = OtherLtcgEntry(
          description: 'Asset 1',
          salePrice: 300000,
          costOfAcquisition: 220000,
          indexedCostOfAcquisition: 200000,
          transferExpenses: 0,
        );
        const e2 = OtherLtcgEntry(
          description: 'Asset 2',
          salePrice: 200000,
          costOfAcquisition: 180000,
          indexedCostOfAcquisition: 150000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [e1, e2],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        final tax = CapitalGainsComputationService.computeLtcgOtherTax(
          schedule,
        );
        expect(tax, 10000.0);
      },
    );
  });

  group('CapitalGainsTaxResult', () {
    test(
      'totalCgTax sums stcg111A + ltcg112A + property + other (slab excluded)',
      () {
        const result = CapitalGainsTaxResult(
          stcg111ATax: 10000,
          stcgOtherTax: 5000, // slab rate — excluded from totalCgTax
          ltcg112ATax: 20000,
          ltcgOnPropertyTax: 30000,
          ltcgOtherTax: 7000,
        );
        // 10000 + 20000 + 30000 + 7000 = 67000
        expect(result.totalCgTax, 67000.0);
      },
    );

    test('equality — same fields are equal', () {
      const a = CapitalGainsTaxResult(
        stcg111ATax: 10000,
        stcgOtherTax: 0,
        ltcg112ATax: 20000,
        ltcgOnPropertyTax: 30000,
        ltcgOtherTax: 7000,
      );
      const b = CapitalGainsTaxResult(
        stcg111ATax: 10000,
        stcgOtherTax: 0,
        ltcg112ATax: 20000,
        ltcgOnPropertyTax: 30000,
        ltcgOtherTax: 7000,
      );
      expect(a, equals(b));
    });

    test('inequality — different ltcgOtherTax', () {
      const a = CapitalGainsTaxResult(
        stcg111ATax: 10000,
        stcgOtherTax: 0,
        ltcg112ATax: 20000,
        ltcgOnPropertyTax: 30000,
        ltcgOtherTax: 7000,
      );
      const b = CapitalGainsTaxResult(
        stcg111ATax: 10000,
        stcgOtherTax: 0,
        ltcg112ATax: 20000,
        ltcgOnPropertyTax: 30000,
        ltcgOtherTax: 8000,
      );
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent for equal instances', () {
      const a = CapitalGainsTaxResult(
        stcg111ATax: 10000,
        stcgOtherTax: 0,
        ltcg112ATax: 20000,
        ltcgOnPropertyTax: 30000,
        ltcgOtherTax: 7000,
      );
      const b = CapitalGainsTaxResult(
        stcg111ATax: 10000,
        stcgOtherTax: 0,
        ltcg112ATax: 20000,
        ltcgOnPropertyTax: 30000,
        ltcgOtherTax: 7000,
      );
      expect(a.hashCode, b.hashCode);
    });
  });

  group(
    'computeTotalCapitalGainsTax — full aggregation with all components',
    () {
      test('→ includes property LTCG and other LTCG in total', () {
        const stcgEntry = EquityStcgEntry(
          description: 'Equity STCG',
          salePrice: 300000,
          costOfAcquisition: 200000,
          transferExpenses: 0,
        );
        const ltcg112aEntry = Schedule112aEntry(
          isin: 'ISIN001',
          assetName: 'Index Fund',
          unitsOrShares: 100,
          salePrice: 500000,
          costOfAcquisition: 200000,
          fmvOn31Jan2018: 150000,
          saleDate: '2025-01-01',
          acquisitionDate: '2014-01-01',
        );
        final propertyEntry = PropertyLtcgEntry(
          description: 'Flat in Pune',
          salePrice: 5000000,
          indexedCostOfAcquisition: 3000000,
          improvementCost: 0,
          transferExpenses: 0,
          acquisitionDate: DateTime(2010, 1, 1),
        );
        // otherLtcg: gainWithIndex=60000 → taxWith=12000
        //            gainWithout=100000 → taxWithout=10000 → lower=10000
        const otherEntry = OtherLtcgEntry(
          description: 'Jewellery',
          salePrice: 300000,
          costOfAcquisition: 200000,
          indexedCostOfAcquisition: 240000,
          transferExpenses: 0,
        );
        final scheduleCg = ScheduleCg(
          equityStcgEntries: [stcgEntry],
          equityLtcgEntries: const [],
          debtStcgEntries: const [],
          debtLtcgEntries: const [],
          propertyLtcgEntries: [propertyEntry],
          otherStcgEntries: const [],
          otherLtcgEntries: [otherEntry],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        const schedule112a = Schedule112a(entries: [ltcg112aEntry]);

        final result =
            CapitalGainsComputationService.computeTotalCapitalGainsTax(
              scheduleCg: scheduleCg,
              schedule112a: schedule112a,
            );

        // stcg111A: (300000-200000)*20% = 20000
        expect(result.stcg111ATax, 20000.0);
        // 112A: gain=300000, taxable=175000, tax=21875
        expect(result.ltcg112ATax, 21875.0);
        // property: (5000000-3000000)*20% = 400000
        expect(result.ltcgOnPropertyTax, 400000.0);
        // otherLtcg: taxWithout=100000*10%=10000 < taxWith=60000*20%=12000
        expect(result.ltcgOtherTax, 10000.0);
        // total = 20000 + 21875 + 400000 + 10000 = 451875
        expect(result.totalCgTax, 451875.0);
      });
    },
  );

  group('OtherLtcgEntry', () {
    test('gainWithIndexation uses indexedCost', () {
      const entry = OtherLtcgEntry(
        description: 'Test',
        salePrice: 300000,
        costOfAcquisition: 100000,
        indexedCostOfAcquisition: 200000,
        transferExpenses: 5000,
      );
      // 300000 - 200000 - 5000 = 95000
      expect(entry.gainWithIndexation, 95000.0);
    });

    test('gainWithoutIndexation uses actual cost', () {
      const entry = OtherLtcgEntry(
        description: 'Test',
        salePrice: 300000,
        costOfAcquisition: 100000,
        indexedCostOfAcquisition: 200000,
        transferExpenses: 5000,
      );
      // 300000 - 100000 - 5000 = 195000
      expect(entry.gainWithoutIndexation, 195000.0);
    });

    test('copyWith preserves unchanged fields', () {
      const original = OtherLtcgEntry(
        description: 'Original',
        salePrice: 300000,
        costOfAcquisition: 100000,
        indexedCostOfAcquisition: 200000,
        transferExpenses: 0,
      );
      final updated = original.copyWith(salePrice: 400000);
      expect(updated.salePrice, 400000);
      expect(updated.costOfAcquisition, original.costOfAcquisition);
      expect(updated.description, original.description);
    });

    test('equality — same fields are equal', () {
      const a = OtherLtcgEntry(
        description: 'Test',
        salePrice: 300000,
        costOfAcquisition: 100000,
        indexedCostOfAcquisition: 200000,
        transferExpenses: 0,
      );
      const b = OtherLtcgEntry(
        description: 'Test',
        salePrice: 300000,
        costOfAcquisition: 100000,
        indexedCostOfAcquisition: 200000,
        transferExpenses: 0,
      );
      expect(a, equals(b));
    });
  });
}
