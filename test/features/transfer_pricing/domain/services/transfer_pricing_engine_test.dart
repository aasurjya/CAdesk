import 'package:ca_app/features/transfer_pricing/domain/models/alp_benchmark.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/international_transaction.dart';
import 'package:ca_app/features/transfer_pricing/domain/services/transfer_pricing_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = TransferPricingEngine.instance;

  InternationalTransaction makeTransaction({
    TransactionNature nature = TransactionNature.sale,
    int amountPaise = 10000000, // Rs 1,00,000
  }) {
    return InternationalTransaction(
      description: 'Test transaction',
      associatedEnterprise: 'AE Corp',
      nature: nature,
      amountPaise: amountPaise,
      currency: 'INR',
      armLengthPaise: 10000000,
      method: AlpMethod.cup,
      adjustmentPaise: 0,
    );
  }

  group('TransferPricingEngine.instance', () {
    test('singleton returns same instance', () {
      expect(identical(TransferPricingEngine.instance, engine), isTrue);
    });
  });

  group('TransferPricingEngine.determineMethod', () {
    test('sale transaction → CUP method', () {
      final t = makeTransaction(nature: TransactionNature.sale);
      expect(engine.determineMethod(t), AlpMethod.cup);
    });

    test('purchase transaction → CUP method', () {
      final t = makeTransaction(nature: TransactionNature.purchase);
      expect(engine.determineMethod(t), AlpMethod.cup);
    });

    test('loan transaction → CUP method', () {
      final t = makeTransaction(nature: TransactionNature.loan);
      expect(engine.determineMethod(t), AlpMethod.cup);
    });

    test('royalty transaction → TNMM method', () {
      final t = makeTransaction(nature: TransactionNature.royalty);
      expect(engine.determineMethod(t), AlpMethod.tnmm);
    });

    test('service transaction → TNMM method', () {
      final t = makeTransaction(nature: TransactionNature.service);
      expect(engine.determineMethod(t), AlpMethod.tnmm);
    });
  });

  group('TransferPricingEngine.computeArmLengthPrice', () {
    test(
      'returns transaction amount as benchmark when comparables is empty',
      () {
        final t = makeTransaction(amountPaise: 10000000);
        final benchmark = engine.computeArmLengthPrice(t, []);

        expect(benchmark.comparableCount, 0);
        expect(benchmark.selectedAlpPaise, 10000000);
        expect(benchmark.interquartileMedianPaise, 10000000);
        expect(benchmark.searchCriteria, 'No comparables');
      },
    );

    test('computes IQR from comparables with single item', () {
      final t = makeTransaction();
      final comparables = [
        const ComparableData(name: 'Corp A', valuePaise: 12000000),
      ];
      final benchmark = engine.computeArmLengthPrice(t, comparables);

      expect(benchmark.comparableCount, 1);
      expect(benchmark.selectedAlpPaise, 12000000);
      expect(benchmark.interquartileMedianPaise, 12000000);
    });

    test('computes IQR from multiple comparables correctly', () {
      final t = makeTransaction();
      final comparables = [
        const ComparableData(name: 'Corp A', valuePaise: 8000000),
        const ComparableData(name: 'Corp B', valuePaise: 10000000),
        const ComparableData(name: 'Corp C', valuePaise: 12000000),
        const ComparableData(name: 'Corp D', valuePaise: 14000000),
      ];
      final benchmark = engine.computeArmLengthPrice(t, comparables);

      // sorted: [8M, 10M, 12M, 14M]
      // p25 index = (25/100 * 3).round() = 1 → 10000000
      // p50 index = (50/100 * 3).round() = 2 → 12000000
      // p75 index = (75/100 * 3).round() = 2 → 12000000
      expect(benchmark.comparableCount, 4);
      expect(benchmark.searchCriteria, 'Comparable database search');
      expect(benchmark.selectedAlpPaise, benchmark.interquartileMedianPaise);
    });

    test('selected ALP is always the median', () {
      final t = makeTransaction();
      final comparables = [
        const ComparableData(name: 'A', valuePaise: 9000000),
        const ComparableData(name: 'B', valuePaise: 10000000),
        const ComparableData(name: 'C', valuePaise: 11000000),
      ];
      final benchmark = engine.computeArmLengthPrice(t, comparables);

      expect(benchmark.selectedAlpPaise, benchmark.interquartileMedianPaise);
    });

    test('uses the method from the transaction', () {
      final t = makeTransaction(nature: TransactionNature.sale);
      final benchmark = engine.computeArmLengthPrice(t, []);
      expect(benchmark.method, AlpMethod.cup); // CUP from transaction
    });
  });

  group('TransferPricingEngine.computeTransferPricingAdjustment', () {
    AlpBenchmark makeBenchmark({
      required int lower,
      required int median,
      required int upper,
    }) {
      return AlpBenchmark(
        method: AlpMethod.cup,
        searchCriteria: 'Test',
        comparableCount: 3,
        interquartileLowerPaise: lower,
        interquartileMedianPaise: median,
        interquartileUpperPaise: upper,
        selectedAlpPaise: median,
      );
    }

    test('returns 0 when actual price is within tolerance range for sale', () {
      final t = makeTransaction(
        nature: TransactionNature.sale,
        amountPaise: 10000000, // Rs 1L = median
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, 0);
    });

    test('sale below lower bound → upward adjustment = median - actual', () {
      // actual = 7M, lower = 9M, median = 10M
      // tolerance = 10M * 3% = 300000, adjustedLower = 9M - 300000 = 8700000
      // actual (7M) < adjustedLower (8.7M) → adjustment = median - actual = 3M
      final t = makeTransaction(
        nature: TransactionNature.sale,
        amountPaise: 7000000,
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, 3000000); // median(10M) - actual(7M)
    });

    test('purchase above upper bound → upward adjustment = actual - median', () {
      // actual = 14M, upper = 11M, median = 10M
      // tolerance = 10M * 3% = 300000, adjustedUpper = 11M + 300000 = 11300000
      // actual (14M) > adjustedUpper (11.3M) → adjustment = actual - median = 4M
      final t = makeTransaction(
        nature: TransactionNature.purchase,
        amountPaise: 14000000,
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, 4000000); // actual(14M) - median(10M)
    });

    test('sale within tolerance (3% above median) → no adjustment', () {
      // median = 10M, tolerance = 300000, adjustedUpper = 11M + 300000 = 11.3M
      // actual = 10.2M → within range → 0
      final t = makeTransaction(
        nature: TransactionNature.sale,
        amountPaise: 10200000,
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, 0);
    });

    test('service transaction below lower → adjustment returned', () {
      final t = makeTransaction(
        nature: TransactionNature.service,
        amountPaise: 5000000,
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, greaterThan(0));
    });

    test('loan transaction above upper → adjustment returned', () {
      final t = makeTransaction(
        nature: TransactionNature.loan,
        amountPaise: 15000000,
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, greaterThan(0));
    });

    test('purchase within tolerance → no adjustment', () {
      final t = makeTransaction(
        nature: TransactionNature.purchase,
        amountPaise: 11000000, // upper bound exactly
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, 0);
    });

    test('returns 0 when sale actual is above lower but below upper', () {
      final t = makeTransaction(
        nature: TransactionNature.sale,
        amountPaise: 9500000, // between lower(9M) and upper(11M)
      );
      final benchmark = makeBenchmark(
        lower: 9000000,
        median: 10000000,
        upper: 11000000,
      );

      final adj = engine.computeTransferPricingAdjustment(t, benchmark);
      expect(adj, 0);
    });
  });

  group('ComparableData', () {
    test('creates with correct name and value', () {
      const data = ComparableData(name: 'ABC Corp', valuePaise: 10000000);
      expect(data.name, 'ABC Corp');
      expect(data.valuePaise, 10000000);
    });
  });
}
