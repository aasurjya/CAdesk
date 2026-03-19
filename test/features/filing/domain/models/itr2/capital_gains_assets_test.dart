import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';

void main() {
  // ---------------------------------------------------------------------------
  // EquityStcgEntry (Section 111A — 20% flat rate on equity STCG)
  // ---------------------------------------------------------------------------

  group('EquityStcgEntry', () {
    const entry = EquityStcgEntry(
      description: 'HDFC Bank shares',
      salePrice: 500000,
      costOfAcquisition: 300000,
      transferExpenses: 5000,
    );

    test('gain = salePrice - costOfAcquisition - transferExpenses', () {
      expect(entry.gain, equals(195000.0));
    });

    test('gain is negative when there is a loss', () {
      const loss = EquityStcgEntry(
        description: 'Infosys shares',
        salePrice: 80000,
        costOfAcquisition: 100000,
        transferExpenses: 500,
      );
      expect(loss.gain, equals(-20500.0));
    });

    test('copyWith updates only the specified fields', () {
      final updated = entry.copyWith(salePrice: 600000);
      expect(updated.salePrice, equals(600000.0));
      expect(updated.description, equals('HDFC Bank shares'));
      expect(updated.costOfAcquisition, equals(300000.0));
      expect(updated.transferExpenses, equals(5000.0));
    });

    test('copyWith returns a new object (immutable)', () {
      final updated = entry.copyWith(description: 'Changed');
      expect(identical(entry, updated), isFalse);
    });

    test('equality: same fields are equal', () {
      const b = EquityStcgEntry(
        description: 'HDFC Bank shares',
        salePrice: 500000,
        costOfAcquisition: 300000,
        transferExpenses: 5000,
      );
      expect(entry, equals(b));
      expect(entry.hashCode, equals(b.hashCode));
    });

    test('equality: different salePrice is not equal', () {
      final c = entry.copyWith(salePrice: 999);
      expect(c, isNot(equals(entry)));
    });
  });

  // ---------------------------------------------------------------------------
  // EquityLtcgEntry (Section 112A — 12.5% above ₹1.25L, with grandfathering)
  // ---------------------------------------------------------------------------

  group('EquityLtcgEntry', () {
    // Asset bought before 31-Jan-2018; FMV on that date is higher than cost
    const entry = EquityLtcgEntry(
      description: 'Nifty 50 ETF',
      salePrice: 1000000,
      costOfAcquisition: 500000,
      fmvOn31Jan2018: 700000, // grandfathered cost
      transferExpenses: 10000,
    );

    test('effectiveCostOfAcquisition uses max(cost, fmv)', () {
      expect(entry.effectiveCostOfAcquisition, equals(700000.0));
    });

    test('gain uses grandfathered cost of acquisition', () {
      // 1000000 - 700000 - 10000 = 290000
      expect(entry.gain, equals(290000.0));
    });

    test('when actual cost > FMV, actual cost is used', () {
      const higherCost = EquityLtcgEntry(
        description: 'SBI shares',
        salePrice: 800000,
        costOfAcquisition: 600000,
        fmvOn31Jan2018: 400000,
        transferExpenses: 5000,
      );
      expect(higherCost.effectiveCostOfAcquisition, equals(600000.0));
      // 800000 - 600000 - 5000 = 195000
      expect(higherCost.gain, equals(195000.0));
    });

    test('copyWith updates specified field only', () {
      final updated = entry.copyWith(salePrice: 1200000);
      // 1200000 - 700000 - 10000 = 490000
      expect(updated.gain, equals(490000.0));
      expect(updated.description, equals('Nifty 50 ETF'));
    });

    test('equality works correctly', () {
      const b = EquityLtcgEntry(
        description: 'Nifty 50 ETF',
        salePrice: 1000000,
        costOfAcquisition: 500000,
        fmvOn31Jan2018: 700000,
        transferExpenses: 10000,
      );
      expect(entry, equals(b));
    });
  });

  // ---------------------------------------------------------------------------
  // PropertyLtcgEntry (Section 112 — 20% with indexation)
  // ---------------------------------------------------------------------------

  group('PropertyLtcgEntry', () {
    final acqDate = DateTime(2010, 1, 1);
    final entry = PropertyLtcgEntry(
      description: 'Flat in Mumbai',
      salePrice: 8000000,
      indexedCostOfAcquisition: 3500000,
      improvementCost: 200000,
      transferExpenses: 100000,
      acquisitionDate: acqDate,
    );

    test(
      'gain = salePrice - indexedCost - improvementCost - transferExpenses',
      () {
        // 8000000 - 3500000 - 200000 - 100000 = 4200000
        expect(entry.gain, equals(4200000.0));
      },
    );

    test('gain can be positive with indexation', () {
      expect(entry.gain, greaterThan(0));
    });

    test('copyWith replaces fields immutably', () {
      final updated = entry.copyWith(salePrice: 10000000);
      expect(updated.salePrice, equals(10000000.0));
      expect(updated.description, equals('Flat in Mumbai'));
      expect(identical(entry, updated), isFalse);
    });

    test('acquisitionDate is preserved through copyWith', () {
      final updated = entry.copyWith(improvementCost: 500000);
      expect(updated.acquisitionDate, equals(acqDate));
    });
  });

  // ---------------------------------------------------------------------------
  // OtherLtcgEntry (Sec 112 — 20% with indexation vs 10% without)
  // ---------------------------------------------------------------------------

  group('OtherLtcgEntry', () {
    const entry = OtherLtcgEntry(
      description: 'Unlisted shares',
      salePrice: 500000,
      costOfAcquisition: 200000,
      indexedCostOfAcquisition: 280000,
      transferExpenses: 5000,
    );

    test('gainWithIndexation uses indexed cost', () {
      // 500000 - 280000 - 5000 = 215000
      expect(entry.gainWithIndexation, equals(215000.0));
    });

    test('gainWithoutIndexation uses actual cost', () {
      // 500000 - 200000 - 5000 = 295000
      expect(entry.gainWithoutIndexation, equals(295000.0));
    });

    test(
      'gainWithIndexation < gainWithoutIndexation when indexed cost > actual',
      () {
        expect(entry.gainWithIndexation, lessThan(entry.gainWithoutIndexation));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // ScheduleCg — aggregation and set-off rules
  // ---------------------------------------------------------------------------

  group('ScheduleCg', () {
    test('empty() has zero gains and zero losses', () {
      final cg = ScheduleCg.empty();
      expect(cg.netStcg, equals(0.0));
      expect(cg.netLtcg, equals(0.0));
      expect(cg.netStcgAfterSetOff, equals(0.0));
      expect(cg.netLtcgAfterSetOff, equals(0.0));
    });

    test('totalStcg111A sums equity STCG entries', () {
      final cg = ScheduleCg.empty().copyWith(
        equityStcgEntries: const [
          EquityStcgEntry(
            description: 'A',
            salePrice: 100000,
            costOfAcquisition: 80000,
            transferExpenses: 1000,
          ),
          EquityStcgEntry(
            description: 'B',
            salePrice: 50000,
            costOfAcquisition: 30000,
            transferExpenses: 500,
          ),
        ],
      );
      // (100000-80000-1000) + (50000-30000-500) = 19000 + 19500 = 38500
      expect(cg.totalStcg111A, equals(38500.0));
    });

    test(
      'netStcgAfterSetOff floors at zero when broughtForwardStcl exceeds',
      () {
        final cg = ScheduleCg.empty().copyWith(
          equityStcgEntries: const [
            EquityStcgEntry(
              description: 'Small gain',
              salePrice: 110000,
              costOfAcquisition: 100000,
              transferExpenses: 0,
            ),
          ],
          broughtForwardStcl: 50000, // larger than current STCG of 10000
        );
        expect(cg.netStcg, equals(10000.0));
        expect(cg.netStcgAfterSetOff, equals(0.0));
      },
    );

    test('excess STCL is applied against LTCG', () {
      // Current STCG = 10000, BF STCL = 30000 → excess 20000 applied to LTCG
      // Current LTCG = 50000 → LTCG after set-off = 50000 - 20000 = 30000
      final cg = ScheduleCg.empty().copyWith(
        equityStcgEntries: const [
          EquityStcgEntry(
            description: 'Equity gain',
            salePrice: 110000,
            costOfAcquisition: 100000,
            transferExpenses: 0,
          ),
        ],
        equityLtcgEntries: const [
          EquityLtcgEntry(
            description: 'LTCG',
            salePrice: 150000,
            costOfAcquisition: 100000,
            fmvOn31Jan2018: 100000,
            transferExpenses: 0,
          ),
        ],
        broughtForwardStcl: 30000,
      );
      expect(cg.netStcgAfterSetOff, equals(0.0));
      expect(cg.netLtcgAfterSetOff, equals(30000.0));
    });

    test('LTCL can only set off against LTCG, not STCG', () {
      final cg = ScheduleCg.empty().copyWith(
        equityStcgEntries: const [
          EquityStcgEntry(
            description: 'STCG',
            salePrice: 200000,
            costOfAcquisition: 150000,
            transferExpenses: 0,
          ),
        ],
        broughtForwardLtcl: 100000, // LTCL cannot touch STCG
      );
      // STCG is unaffected by LTCL
      expect(cg.netStcgAfterSetOff, equals(50000.0));
      // No LTCG to offset
      expect(cg.netLtcgAfterSetOff, equals(0.0));
    });

    test('copyWith returns a new object (immutable)', () {
      final original = ScheduleCg.empty();
      final updated = original.copyWith(broughtForwardStcl: 5000);
      expect(identical(original, updated), isFalse);
      expect(original.broughtForwardStcl, equals(0.0));
      expect(updated.broughtForwardStcl, equals(5000.0));
    });
  });
}
