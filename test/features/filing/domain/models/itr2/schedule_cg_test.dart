import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';

void main() {
  group('ScheduleCg', () {
    group('computeShortTermGains', () {
      test('→ sums 111A STCG from listed equity entries', () {
        const entry1 = EquityStcgEntry(
          description: 'HDFC Bank shares',
          salePrice: 300000,
          costOfAcquisition: 200000,
          transferExpenses: 1000,
        );
        const entry2 = EquityStcgEntry(
          description: 'Reliance shares',
          salePrice: 150000,
          costOfAcquisition: 120000,
          transferExpenses: 500,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [entry1, entry2],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // (300000 - 200000 - 1000) + (150000 - 120000 - 500) = 99000 + 29500
        expect(schedule.totalStcg111A, 128500.0);
      });

      test('→ sums STCG on other assets (slab rate)', () {
        const entry = OtherStcgEntry(
          description: 'Unlisted shares',
          salePrice: 500000,
          costOfAcquisition: 300000,
          transferExpenses: 2000,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [entry],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        expect(schedule.totalStcgOther, 198000.0);
      });

      test('→ netStcg aggregates 111A and other STCG', () {
        const equity = EquityStcgEntry(
          description: 'Stock A',
          salePrice: 100000,
          costOfAcquisition: 60000,
          transferExpenses: 0,
        );
        const other = OtherStcgEntry(
          description: 'Unlisted debenture',
          salePrice: 50000,
          costOfAcquisition: 30000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [equity],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [other],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        expect(schedule.netStcg, 60000.0); // 40000 + 20000
      });
    });

    group('computeLongTermGains', () {
      test('→ sums 112A LTCG from listed equity', () {
        const entry = EquityLtcgEntry(
          description: 'HDFC MF units',
          salePrice: 500000,
          costOfAcquisition: 200000,
          fmvOn31Jan2018: 250000,
          transferExpenses: 1000,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [entry],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // CoA = max(200000, 250000) = 250000 (grandfathering applies)
        // Gain = 500000 - 250000 - 1000 = 249000
        expect(schedule.totalLtcg112A, 249000.0);
      });

      test('→ grandfathering: uses actual cost when higher than FMV', () {
        const entry = EquityLtcgEntry(
          description: 'Stock acquired at peak',
          salePrice: 400000,
          costOfAcquisition: 350000,
          fmvOn31Jan2018: 200000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [entry],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // CoA = max(350000, 200000) = 350000 (actual cost is higher)
        // Gain = 400000 - 350000 - 0 = 50000
        expect(schedule.totalLtcg112A, 50000.0);
      });

      test('→ sums property LTCG with indexation', () {
        final entry = PropertyLtcgEntry(
          description: 'Flat in Mumbai',
          salePrice: 5000000,
          indexedCostOfAcquisition: 2500000,
          improvementCost: 100000,
          transferExpenses: 50000,
          acquisitionDate: DateTime(2018, 1, 1),
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
        // 5000000 - 2500000 - 100000 - 50000 = 2350000
        expect(schedule.totalLtcgOnProperty, 2350000.0);
      });
    });

    group('set-off rules', () {
      test('→ STCL can set off against STCG', () {
        const lossMaker = EquityStcgEntry(
          description: 'Loss stock',
          salePrice: 50000,
          costOfAcquisition: 100000,
          transferExpenses: 0,
        );
        const gainer = OtherStcgEntry(
          description: 'Gain asset',
          salePrice: 200000,
          costOfAcquisition: 100000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [lossMaker],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [gainer],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        );
        // 111A: -50000 (loss), Other: +100000
        // netStcg = -50000 + 100000 = 50000
        expect(schedule.netStcg, 50000.0);
      });

      test('→ broughtForwardStcl reduces netStcg', () {
        const gainer = EquityStcgEntry(
          description: 'Profit stock',
          salePrice: 200000,
          costOfAcquisition: 100000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [gainer],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 30000,
          broughtForwardLtcl: 0,
        );
        // netStcg before BF = 100000, after BF offset = 70000
        expect(schedule.netStcgAfterSetOff, 70000.0);
      });

      test('→ broughtForwardLtcl reduces netLtcg112A', () {
        const entry = EquityLtcgEntry(
          description: 'MF units',
          salePrice: 300000,
          costOfAcquisition: 100000,
          fmvOn31Jan2018: 80000,
          transferExpenses: 0,
        );
        const schedule = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [entry],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 50000,
        );
        // LTCG112A = 200000, after BF LTCL = 150000
        expect(schedule.netLtcgAfterSetOff, 150000.0);
      });

      test(
        '→ netStcgAfterSetOff floors at zero (excess loss carried forward)',
        () {
          const entry = EquityStcgEntry(
            description: 'Small gain',
            salePrice: 110000,
            costOfAcquisition: 100000,
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
            broughtForwardStcl: 50000, // larger than gain
            broughtForwardLtcl: 0,
          );
          expect(schedule.netStcgAfterSetOff, 0.0);
        },
      );
    });

    group('copyWith and equality', () {
      const base = ScheduleCg(
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

      test('→ copyWith returns new instance with changed field', () {
        final updated = base.copyWith(broughtForwardStcl: 10000);
        expect(updated.broughtForwardStcl, 10000);
        expect(updated, isNot(same(base)));
      });

      test('→ equal ScheduleCg instances satisfy == and hashCode', () {
        const a = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 5000,
          broughtForwardLtcl: 0,
        );
        const b = ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 5000,
          broughtForwardLtcl: 0,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
