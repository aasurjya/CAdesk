import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_112a.dart';
import 'package:ca_app/features/filing/domain/services/capital_gains_computation_service.dart';

void main() {
  group('CapitalGainsComputationService', () {
    group('computeStcg111ATax (Section 111A — 20%)', () {
      test('→ 20% on net STCG after set-off for listed equity', () {
        final entry = EquityStcgEntry(
          description: 'Nifty ETF',
          salePrice: 500000,
          costOfAcquisition: 300000,
          transferExpenses: 2000,
        );
        final schedule = ScheduleCg(
          equityStcgEntries: [entry],
          equityLtcgEntries: const [],
          debtStcgEntries: const [],
          debtLtcgEntries: const [],
          propertyLtcgEntries: const [],
          otherStcgEntries: const [],
          otherLtcgEntries: const [],
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
        final entry = EquityStcgEntry(
          description: 'Loss trade',
          salePrice: 100000,
          costOfAcquisition: 150000,
          transferExpenses: 0,
        );
        final schedule = ScheduleCg(
          equityStcgEntries: [entry],
          equityLtcgEntries: const [],
          debtStcgEntries: const [],
          debtLtcgEntries: const [],
          propertyLtcgEntries: const [],
          otherStcgEntries: const [],
          otherLtcgEntries: const [],
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
        final stcgEntry = EquityStcgEntry(
          description: 'STCG stock',
          salePrice: 300000,
          costOfAcquisition: 200000,
          transferExpenses: 0,
        );
        final cg112aEntry = const Schedule112aEntry(
          isin: 'ISIN001',
          assetName: 'Index Fund',
          unitsOrShares: 500,
          salePrice: 500000,
          costOfAcquisition: 100000,
          fmvOn31Jan2018: 80000,
          saleDate: '2025-01-01',
          acquisitionDate: '2015-01-01',
        );
        final schedule = ScheduleCg(
          equityStcgEntries: [stcgEntry],
          equityLtcgEntries: const [],
          debtStcgEntries: const [],
          debtLtcgEntries: const [],
          propertyLtcgEntries: const [],
          otherStcgEntries: const [],
          otherLtcgEntries: const [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        final schedule112a = Schedule112a(entries: [cg112aEntry]);

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
}
