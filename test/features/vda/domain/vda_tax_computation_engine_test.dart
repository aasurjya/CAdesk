import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/vda/domain/models/schedule_vda.dart';
import 'package:ca_app/features/vda/domain/services/vda_tax_computation_engine.dart';

void main() {
  group('VdaTaxComputationEngine', () {
    late VdaTaxComputationEngine engine;

    setUp(() {
      engine = VdaTaxComputationEngine.instance;
    });

    test('singleton returns same instance', () {
      expect(
        VdaTaxComputationEngine.instance,
        same(VdaTaxComputationEngine.instance),
      );
    });

    group('computeVdaTax', () {
      test('30% flat tax on gains', () {
        // Buy 1 BTC at Rs 10L, sell at Rs 15L => gain Rs 5L = 50000000 paise
        // Tax = 30% of 50000000 = 15000000 paise
        final transactions = [
          VdaTransaction(
            assetName: 'Bitcoin',
            acquisitionDate: DateTime(2023, 1, 1),
            transferDate: DateTime(2023, 12, 1),
            acquisitionCostPaise: 100000000, // Rs 10L
            saleConsiderationPaise: 150000000, // Rs 15L
          ),
        ];
        final result = engine.computeVdaTax(transactions);
        expect(result.totalGainPaise, 50000000);
        expect(result.taxAtFlatRatePaise, 15000000); // 30%
      });

      test('loss is not offset against gain', () {
        // Two transactions: one gain, one loss
        final transactions = [
          VdaTransaction(
            assetName: 'Bitcoin',
            acquisitionDate: DateTime(2023, 1, 1),
            transferDate: DateTime(2023, 6, 1),
            acquisitionCostPaise: 100000000,
            saleConsiderationPaise: 150000000, // +50L gain
          ),
          VdaTransaction(
            assetName: 'Ethereum',
            acquisitionDate: DateTime(2023, 1, 1),
            transferDate: DateTime(2023, 8, 1),
            acquisitionCostPaise: 80000000,
            saleConsiderationPaise: 50000000, // -30L loss
          ),
        ];
        final result = engine.computeVdaTax(transactions);
        // Gain = 50L, Tax = 30% of 50L (loss cannot offset gain)
        expect(result.totalGainPaise, 50000000);
        expect(result.totalLossPaise, 30000000);
        expect(result.taxAtFlatRatePaise, 15000000); // only on gains
      });

      test('zero tax for zero gain transactions', () {
        final transactions = [
          VdaTransaction(
            assetName: 'Bitcoin',
            acquisitionDate: DateTime(2023, 1, 1),
            transferDate: DateTime(2023, 6, 1),
            acquisitionCostPaise: 100000000,
            saleConsiderationPaise: 80000000, // loss
          ),
        ];
        final result = engine.computeVdaTax(transactions);
        expect(result.totalGainPaise, 0);
        expect(result.taxAtFlatRatePaise, 0);
        expect(result.totalLossPaise, 20000000);
      });

      test('empty transactions produces zero tax', () {
        final result = engine.computeVdaTax([]);
        expect(result.totalGainPaise, 0);
        expect(result.taxAtFlatRatePaise, 0);
        expect(result.totalLossPaise, 0);
      });

      test('multiple gains are summed', () {
        final transactions = [
          VdaTransaction(
            assetName: 'Bitcoin',
            acquisitionDate: DateTime(2023, 1, 1),
            transferDate: DateTime(2023, 6, 1),
            acquisitionCostPaise: 50000000,
            saleConsiderationPaise: 70000000, // 20L gain
          ),
          VdaTransaction(
            assetName: 'Ethereum',
            acquisitionDate: DateTime(2023, 2, 1),
            transferDate: DateTime(2023, 7, 1),
            acquisitionCostPaise: 20000000,
            saleConsiderationPaise: 30000000, // 10L gain
          ),
        ];
        final result = engine.computeVdaTax(transactions);
        expect(result.totalGainPaise, 30000000); // 20L + 10L
        expect(result.taxAtFlatRatePaise, 9000000); // 30% of 30L
      });
    });

    group('VdaTransaction gain computation', () {
      test('gain = saleConsideration - acquisitionCost', () {
        final tx = VdaTransaction(
          assetName: 'Bitcoin',
          acquisitionDate: DateTime(2023, 1, 1),
          transferDate: DateTime(2023, 6, 1),
          acquisitionCostPaise: 100000000,
          saleConsiderationPaise: 150000000,
        );
        expect(tx.gainPaise, 50000000);
      });

      test('negative gain = loss', () {
        final tx = VdaTransaction(
          assetName: 'Ethereum',
          acquisitionDate: DateTime(2023, 1, 1),
          transferDate: DateTime(2023, 6, 1),
          acquisitionCostPaise: 80000000,
          saleConsiderationPaise: 60000000,
        );
        expect(tx.gainPaise, -20000000);
      });
    });

    group('VdaTransaction model', () {
      test('equality and copyWith', () {
        final a = VdaTransaction(
          assetName: 'Bitcoin',
          acquisitionDate: DateTime(2023, 1, 1),
          transferDate: DateTime(2023, 6, 1),
          acquisitionCostPaise: 100000000,
          saleConsiderationPaise: 150000000,
        );
        final b = VdaTransaction(
          assetName: 'Bitcoin',
          acquisitionDate: DateTime(2023, 1, 1),
          transferDate: DateTime(2023, 6, 1),
          acquisitionCostPaise: 100000000,
          saleConsiderationPaise: 150000000,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));

        final updated = a.copyWith(assetName: 'Ethereum');
        expect(updated.assetName, 'Ethereum');
        expect(a.assetName, 'Bitcoin');
      });
    });

    group('ScheduleVDA model', () {
      test('equality', () {
        const a = ScheduleVDA(
          transactions: [],
          totalGainPaise: 50000000,
          totalLossPaise: 0,
          taxAtFlatRatePaise: 15000000,
          tdsDeducted1PercentPaise: 1500000,
        );
        const b = ScheduleVDA(
          transactions: [],
          totalGainPaise: 50000000,
          totalLossPaise: 0,
          taxAtFlatRatePaise: 15000000,
          tdsDeducted1PercentPaise: 1500000,
        );
        expect(a, equals(b));
      });
    });
  });
}
