import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/services/vda_tax_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VdaTaxCalculator', () {
    group('taxOnVdaGains', () {
      test('applies 30% + 4% cess on positive gains', () {
        // 100000 * 0.30 * 1.04 = 31200
        final tax = VdaTaxCalculator.taxOnVdaGains(100000);
        expect(tax, closeTo(31200.0, 0.01));
      });

      test('returns 0 for zero gains', () {
        final tax = VdaTaxCalculator.taxOnVdaGains(0);
        expect(tax, 0.0);
      });

      test('returns 0 for negative gains (losses)', () {
        final tax = VdaTaxCalculator.taxOnVdaGains(-50000);
        expect(tax, 0.0);
      });

      test('correctly computes for large gains', () {
        // 1000000 * 0.30 * 1.04 = 312000
        final tax = VdaTaxCalculator.taxOnVdaGains(1000000);
        expect(tax, closeTo(312000.0, 0.01));
      });
    });

    group('tds194S', () {
      test('returns 0 when transaction value below threshold for normal person', () {
        final tds = VdaTaxCalculator.tds194S(
          transactionValue: 49999,
          isSpecifiedPerson: false,
        );
        expect(tds, 0.0);
      });

      test('deducts 1% TDS when transaction value at or above 50000 for normal', () {
        final tds = VdaTaxCalculator.tds194S(
          transactionValue: 50000,
          isSpecifiedPerson: false,
        );
        expect(tds, closeTo(500.0, 0.01));
      });

      test('returns 0 when transaction value below 10000 for specified person', () {
        final tds = VdaTaxCalculator.tds194S(
          transactionValue: 9999,
          isSpecifiedPerson: true,
        );
        expect(tds, 0.0);
      });

      test('deducts 1% TDS when transaction at or above 10000 for specified', () {
        final tds = VdaTaxCalculator.tds194S(
          transactionValue: 10000,
          isSpecifiedPerson: true,
        );
        expect(tds, closeTo(100.0, 0.01));
      });

      test('1% on full transaction value when above threshold', () {
        final tds = VdaTaxCalculator.tds194S(
          transactionValue: 200000,
          isSpecifiedPerson: false,
        );
        expect(tds, closeTo(2000.0, 0.01));
      });
    });

    group('netGain', () {
      test('subtracts cost of acquisition from sale price', () {
        final gain = VdaTaxCalculator.netGain(
          salePrice: 150000,
          costOfAcquisition: 100000,
        );
        expect(gain, closeTo(50000.0, 0.01));
      });

      test('returns negative value when sold at a loss', () {
        final gain = VdaTaxCalculator.netGain(
          salePrice: 80000,
          costOfAcquisition: 100000,
        );
        expect(gain, closeTo(-20000.0, 0.01));
      });

      test('returns zero when sold at cost', () {
        final gain = VdaTaxCalculator.netGain(
          salePrice: 100000,
          costOfAcquisition: 100000,
        );
        expect(gain, 0.0);
      });
    });

    group('computeScheduleVda', () {
      VdaTransaction makeTransaction({
        required double buyPrice,
        required double sellPrice,
        double tdsUnder194S = 0,
      }) {
        return VdaTransaction(
          id: 'txn-${buyPrice.toInt()}',
          clientId: 'C001',
          clientName: 'Test Client',
          assetType: VdaAssetType.crypto,
          assetName: 'Bitcoin',
          transactionType: VdaTransactionType.sell,
          quantity: 1,
          buyPrice: buyPrice,
          sellPrice: sellPrice,
          gainLoss: sellPrice - buyPrice,
          taxAt30Percent: (sellPrice - buyPrice) > 0
              ? (sellPrice - buyPrice) * 0.30
              : 0,
          tdsUnder194S: tdsUnder194S,
          exchange: 'WazirX',
          transactionDate: DateTime(2025, 6, 15),
        );
      }

      test('computes schedule with single profitable transaction', () {
        final txns = [
          makeTransaction(buyPrice: 100000, sellPrice: 200000, tdsUnder194S: 2000),
        ];
        final summary = VdaTaxCalculator.computeScheduleVda(txns);

        expect(summary.totalSaleValue, 200000.0);
        expect(summary.totalCost, 100000.0);
        expect(summary.totalNetGains, closeTo(100000.0, 0.01));
        expect(summary.totalLosses, 0.0);
        expect(summary.totalTaxPayable, closeTo(31200.0, 0.01)); // 100000*0.30*1.04
        expect(summary.totalTdsDeducted, 2000.0);
        expect(summary.netTaxAfterTds, closeTo(29200.0, 0.01));
        expect(summary.lossDisallowedNote, isNull);
      });

      test('computes schedule with single loss transaction', () {
        final txns = [
          makeTransaction(buyPrice: 200000, sellPrice: 100000),
        ];
        final summary = VdaTaxCalculator.computeScheduleVda(txns);

        expect(summary.totalSaleValue, 100000.0);
        expect(summary.totalCost, 200000.0);
        expect(summary.totalNetGains, 0.0);
        expect(summary.totalLosses, 100000.0);
        expect(summary.totalTaxPayable, 0.0);
        expect(summary.netTaxAfterTds, 0.0);
        expect(summary.lossDisallowedNote, isNotNull);
        expect(summary.lossDisallowedNote, contains('115BBH'));
      });

      test('loss note shows amount in lakhs', () {
        final txns = [
          makeTransaction(buyPrice: 500000, sellPrice: 400000), // 1L loss
        ];
        final summary = VdaTaxCalculator.computeScheduleVda(txns);
        expect(summary.lossDisallowedNote, contains('1.00L'));
      });

      test('handles mixed gain and loss transactions', () {
        final txns = [
          makeTransaction(buyPrice: 100000, sellPrice: 150000), // 50000 gain
          makeTransaction(buyPrice: 200000, sellPrice: 150000), // 50000 loss
        ];
        final summary = VdaTaxCalculator.computeScheduleVda(txns);

        expect(summary.totalNetGains, closeTo(50000.0, 0.01));
        expect(summary.totalLosses, closeTo(50000.0, 0.01));
        expect(summary.lossDisallowedNote, isNotNull);
      });

      test('returns empty summary for empty list', () {
        final summary = VdaTaxCalculator.computeScheduleVda([]);
        expect(summary.totalSaleValue, 0.0);
        expect(summary.totalCost, 0.0);
        expect(summary.totalNetGains, 0.0);
        expect(summary.totalLosses, 0.0);
        expect(summary.totalTaxPayable, 0.0);
        expect(summary.lossDisallowedNote, isNull);
      });

      test('net tax is clamped at zero when TDS exceeds tax', () {
        final txns = [
          makeTransaction(
            buyPrice: 100000,
            sellPrice: 110000,
            tdsUnder194S: 5000, // TDS = 5000 but tax ~ 3120
          ),
        ];
        final summary = VdaTaxCalculator.computeScheduleVda(txns);
        expect(summary.netTaxAfterTds, 0.0);
      });

      test('aggregates TDS from multiple transactions', () {
        final txns = [
          makeTransaction(
            buyPrice: 100000,
            sellPrice: 200000,
            tdsUnder194S: 1000,
          ),
          makeTransaction(
            buyPrice: 50000,
            sellPrice: 100000,
            tdsUnder194S: 500,
          ),
        ];
        final summary = VdaTaxCalculator.computeScheduleVda(txns);
        expect(summary.totalTdsDeducted, 1500.0);
      });
    });

    group('VdaScheduleSummary', () {
      test('creates immutable summary with correct fields', () {
        const summary = VdaScheduleSummary(
          totalSaleValue: 500000,
          totalCost: 300000,
          totalNetGains: 200000,
          totalLosses: 0,
          totalTaxPayable: 62400,
          totalTdsDeducted: 5000,
          netTaxAfterTds: 57400,
          lossDisallowedNote: null,
        );

        expect(summary.totalSaleValue, 500000.0);
        expect(summary.totalCost, 300000.0);
        expect(summary.totalNetGains, 200000.0);
        expect(summary.totalLosses, 0.0);
        expect(summary.totalTaxPayable, 62400.0);
        expect(summary.totalTdsDeducted, 5000.0);
        expect(summary.netTaxAfterTds, 57400.0);
        expect(summary.lossDisallowedNote, isNull);
      });
    });
  });
}
