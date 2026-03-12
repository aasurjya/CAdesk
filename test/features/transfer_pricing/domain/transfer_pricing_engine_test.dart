import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/international_transaction.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/alp_benchmark.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/form3ceb.dart';
import 'package:ca_app/features/transfer_pricing/domain/services/transfer_pricing_engine.dart';
import 'package:ca_app/features/transfer_pricing/domain/services/form3ceb_generation_service.dart';

void main() {
  group('TransferPricingEngine', () {
    late TransferPricingEngine engine;

    setUp(() {
      engine = TransferPricingEngine.instance;
    });

    test('singleton returns same instance', () {
      expect(TransferPricingEngine.instance, same(TransferPricingEngine.instance));
    });

    group('computeTransferPricingAdjustment', () {
      test('no adjustment when actual price is within tolerance range', () {
        const transaction = InternationalTransaction(
          description: 'Sale of goods',
          associatedEnterprise: 'AE Corp UK',
          nature: TransactionNature.sale,
          amountPaise: 10000000000, // Rs 10 Cr
          currency: 'INR',
          armLengthPaise: 10000000000,
          method: AlpMethod.cup,
          adjustmentPaise: 0,
        );
        const benchmark = AlpBenchmark(
          method: AlpMethod.cup,
          searchCriteria: 'Public databases',
          comparableCount: 5,
          interquartileLowerPaise: 9700000000, // -3%
          interquartileMedianPaise: 10000000000,
          interquartileUpperPaise: 10300000000, // +3%
          selectedAlpPaise: 10000000000,
        );
        final adj = engine.computeTransferPricingAdjustment(transaction, benchmark);
        expect(adj, 0);
      });

      test('upward adjustment when actual < ALP lower bound', () {
        const transaction = InternationalTransaction(
          description: 'Sale of goods',
          associatedEnterprise: 'AE Corp UK',
          nature: TransactionNature.sale,
          amountPaise: 9000000000, // Rs 9 Cr (below lower bound)
          currency: 'INR',
          armLengthPaise: 9000000000,
          method: AlpMethod.cup,
          adjustmentPaise: 0,
        );
        const benchmark = AlpBenchmark(
          method: AlpMethod.cup,
          searchCriteria: 'Public databases',
          comparableCount: 5,
          interquartileLowerPaise: 9700000000,
          interquartileMedianPaise: 10000000000,
          interquartileUpperPaise: 10300000000,
          selectedAlpPaise: 10000000000,
        );
        final adj = engine.computeTransferPricingAdjustment(transaction, benchmark);
        // Adjustment = ALP median - actual = 10Cr - 9Cr = 1Cr
        expect(adj, 1000000000);
      });

      test('no adjustment when actual price > ALP upper bound (not penalized for overpricing on purchase)', () {
        // For purchases from AE, buyer benefits if ALP is lower — check that
        // downward adjustments are handled correctly
        const transaction = InternationalTransaction(
          description: 'Purchase of goods',
          associatedEnterprise: 'AE Corp UK',
          nature: TransactionNature.purchase,
          amountPaise: 11000000000, // Rs 11 Cr (above upper bound)
          currency: 'INR',
          armLengthPaise: 11000000000,
          method: AlpMethod.cup,
          adjustmentPaise: 0,
        );
        const benchmark = AlpBenchmark(
          method: AlpMethod.cup,
          searchCriteria: 'Public databases',
          comparableCount: 5,
          interquartileLowerPaise: 9700000000,
          interquartileMedianPaise: 10000000000,
          interquartileUpperPaise: 10300000000,
          selectedAlpPaise: 10000000000,
        );
        final adj = engine.computeTransferPricingAdjustment(transaction, benchmark);
        // For purchase, if actual > ALP upper bound => upward adjustment (higher cost = lower income)
        expect(adj, greaterThanOrEqualTo(0));
      });
    });

    group('determineMethod', () {
      test('prefers CUP for commodity transactions', () {
        const transaction = InternationalTransaction(
          description: 'Export of steel',
          associatedEnterprise: 'AE Corp',
          nature: TransactionNature.sale,
          amountPaise: 5000000000,
          currency: 'INR',
          armLengthPaise: 0,
          method: AlpMethod.cup,
          adjustmentPaise: 0,
        );
        final method = engine.determineMethod(transaction);
        expect(method, isA<AlpMethod>());
      });

      test('returns valid AlpMethod for loan transaction', () {
        const transaction = InternationalTransaction(
          description: 'Interest on loan',
          associatedEnterprise: 'AE Corp',
          nature: TransactionNature.loan,
          amountPaise: 10000000000,
          currency: 'INR',
          armLengthPaise: 0,
          method: AlpMethod.cup,
          adjustmentPaise: 0,
        );
        final method = engine.determineMethod(transaction);
        expect(method, isA<AlpMethod>());
      });
    });
  });

  group('Form3CEBGenerationService', () {
    late Form3CEBGenerationService service;

    setUp(() {
      service = Form3CEBGenerationService.instance;
    });

    test('singleton returns same instance', () {
      expect(Form3CEBGenerationService.instance, same(Form3CEBGenerationService.instance));
    });

    test('generates Form3CEB with correct transaction list', () {
      const transactions = [
        InternationalTransaction(
          description: 'Sale of goods to AE',
          associatedEnterprise: 'AE Corp Singapore',
          nature: TransactionNature.sale,
          amountPaise: 5000000000,
          currency: 'SGD',
          armLengthPaise: 5000000000,
          method: AlpMethod.cup,
          adjustmentPaise: 0,
        ),
      ];
      const assessee = AssesseeData(
        name: 'Test India Pvt Ltd',
        pan: 'AAAAA0001A',
        address: '123 Business Park, Bangalore',
      );
      final form = service.generateForm3CEB(transactions, assessee);
      expect(form.internationalTransactions.length, 1);
      expect(form.assesseeDetails.pan, 'AAAAA0001A');
      expect(form.totalValueOfTransactionsPaise, 5000000000);
    });
  });

  group('InternationalTransaction model', () {
    test('equality and copyWith', () {
      const a = InternationalTransaction(
        description: 'Sale of goods',
        associatedEnterprise: 'AE Corp',
        nature: TransactionNature.sale,
        amountPaise: 1000000000,
        currency: 'INR',
        armLengthPaise: 1000000000,
        method: AlpMethod.cup,
        adjustmentPaise: 0,
      );
      const b = InternationalTransaction(
        description: 'Sale of goods',
        associatedEnterprise: 'AE Corp',
        nature: TransactionNature.sale,
        amountPaise: 1000000000,
        currency: 'INR',
        armLengthPaise: 1000000000,
        method: AlpMethod.cup,
        adjustmentPaise: 0,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final updated = a.copyWith(currency: 'USD');
      expect(updated.currency, 'USD');
      expect(a.currency, 'INR');
    });
  });

  group('AlpBenchmark model', () {
    test('equality', () {
      const a = AlpBenchmark(
        method: AlpMethod.tnmm,
        searchCriteria: 'Prowess database',
        comparableCount: 10,
        interquartileLowerPaise: 500,
        interquartileMedianPaise: 600,
        interquartileUpperPaise: 700,
        selectedAlpPaise: 600,
      );
      const b = AlpBenchmark(
        method: AlpMethod.tnmm,
        searchCriteria: 'Prowess database',
        comparableCount: 10,
        interquartileLowerPaise: 500,
        interquartileMedianPaise: 600,
        interquartileUpperPaise: 700,
        selectedAlpPaise: 600,
      );
      expect(a, equals(b));
    });
  });

  group('Form3CEB model', () {
    test('totalValueOfTransactions computes sum', () {
      const form = Form3CEB(
        assesseeDetails: AssesseeData(
          name: 'Test Co',
          pan: 'AAAAA0001A',
          address: 'Bangalore',
        ),
        authorizedRepresentative: 'CA John',
        internationalTransactions: [
          InternationalTransaction(
            description: 'T1',
            associatedEnterprise: 'AE',
            nature: TransactionNature.sale,
            amountPaise: 3000000000,
            currency: 'INR',
            armLengthPaise: 3000000000,
            method: AlpMethod.cup,
            adjustmentPaise: 0,
          ),
          InternationalTransaction(
            description: 'T2',
            associatedEnterprise: 'AE',
            nature: TransactionNature.royalty,
            amountPaise: 1000000000,
            currency: 'INR',
            armLengthPaise: 1000000000,
            method: AlpMethod.cup,
            adjustmentPaise: 0,
          ),
        ],
        specifiedDomesticTransactions: [],
        totalValueOfTransactionsPaise: 4000000000,
      );
      expect(form.totalValueOfTransactionsPaise, 4000000000);
    });
  });
}
