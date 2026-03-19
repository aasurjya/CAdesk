import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains.dart';

void main() {
  group('CapitalGainEntry', () {
    test('gain = salePrice - purchasePrice - expenses', () {
      const entry = CapitalGainEntry(
        description: 'Equity shares',
        salePrice: 500000,
        purchasePrice: 300000,
        expenses: 5000,
        gainType: CapitalGainType.stcg111A,
        holdingPeriodMonths: 6,
      );
      expect(entry.gain, 195000.0);
    });

    test('gain can be negative (loss)', () {
      const loss = CapitalGainEntry(
        description: 'MF units',
        salePrice: 80000,
        purchasePrice: 100000,
        expenses: 1000,
        gainType: CapitalGainType.ltcg112A,
        holdingPeriodMonths: 18,
      );
      expect(loss.gain, -21000.0);
    });
  });

  group('CapitalGainsSummary', () {
    const stcgEntry = CapitalGainEntry(
      description: 'Stock A',
      salePrice: 200000,
      purchasePrice: 150000,
      expenses: 2000,
      gainType: CapitalGainType.stcg111A,
      holdingPeriodMonths: 3,
    );
    const ltcgEntry = CapitalGainEntry(
      description: 'Property',
      salePrice: 1000000,
      purchasePrice: 600000,
      expenses: 10000,
      gainType: CapitalGainType.ltcg112,
      holdingPeriodMonths: 36,
    );
    const summary = CapitalGainsSummary(entries: [stcgEntry, ltcgEntry]);

    test('totalSTCG sums short-term gains', () {
      expect(summary.totalSTCG, 48000.0); // 200000 - 150000 - 2000
    });

    test('totalLTCG sums long-term gains', () {
      expect(summary.totalLTCG, 390000.0); // 1000000 - 600000 - 10000
    });

    test('netCapitalGains = totalSTCG + totalLTCG', () {
      expect(summary.netCapitalGains, 438000.0);
    });
  });

  group('CapitalGainEntry equality', () {
    const a = CapitalGainEntry(
      description: 'X',
      salePrice: 100,
      purchasePrice: 50,
      expenses: 0,
      gainType: CapitalGainType.stcgOther,
      holdingPeriodMonths: 1,
    );
    const b = CapitalGainEntry(
      description: 'X',
      salePrice: 100,
      purchasePrice: 50,
      expenses: 0,
      gainType: CapitalGainType.stcgOther,
      holdingPeriodMonths: 1,
    );

    test('equal entries have same == and hashCode', () {
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different entries are not equal', () {
      final c = a.copyWith(salePrice: 999);
      expect(c, isNot(equals(a)));
    });
  });
}
