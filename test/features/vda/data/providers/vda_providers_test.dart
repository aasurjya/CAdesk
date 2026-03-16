import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/vda/data/providers/vda_providers.dart';
import 'package:ca_app/features/vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/vda/domain/models/schedule_vda.dart';

void main() {
  group('VDA Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // vdaTransactionsProvider
    // -------------------------------------------------------------------------
    group('vdaTransactionsProvider', () {
      test('initial state is non-empty list', () {
        final txns = container.read(vdaTransactionsProvider);
        expect(txns, isNotEmpty);
        expect(txns.length, greaterThanOrEqualTo(3));
      });

      test('all items are VdaTransaction objects', () {
        final txns = container.read(vdaTransactionsProvider);
        expect(txns, everyElement(isA<VdaTransaction>()));
      });

      test('list is unmodifiable', () {
        final txns = container.read(vdaTransactionsProvider);
        expect(() => txns.add(txns.first), throwsA(anything));
      });

      test('all transactions have non-empty assetName', () {
        final txns = container.read(vdaTransactionsProvider);
        for (final txn in txns) {
          expect(txn.assetName, isNotEmpty);
        }
      });

      test('includes both gain and loss transactions', () {
        final txns = container.read(vdaTransactionsProvider);
        expect(txns.any((t) => t.gainPaise > 0), isTrue);
        expect(txns.any((t) => t.gainPaise < 0), isTrue);
      });

      test('VdaTransaction.gainPaise is sale minus acquisition', () {
        final txn = VdaTransaction(
          assetName: 'Test Coin',
          acquisitionDate: DateTime(2023, 1, 1),
          transferDate: DateTime(2025, 1, 1),
          acquisitionCostPaise: 100000,
          saleConsiderationPaise: 150000,
        );
        expect(txn.gainPaise, 50000);
      });

      test('VdaTransaction.gainPaise is negative for loss', () {
        final txn = VdaTransaction(
          assetName: 'Loss Coin',
          acquisitionDate: DateTime(2024, 1, 1),
          transferDate: DateTime(2025, 1, 1),
          acquisitionCostPaise: 200000,
          saleConsiderationPaise: 150000,
        );
        expect(txn.gainPaise, -50000);
      });

      test('period is longTerm when held more than 1095 days', () {
        final txn = VdaTransaction(
          assetName: 'Old Coin',
          acquisitionDate: DateTime(2019, 1, 1),
          transferDate: DateTime(2023, 1, 15),
          acquisitionCostPaise: 100000,
          saleConsiderationPaise: 200000,
        );
        expect(txn.period, VdaPeriod.longTerm);
      });

      test('period is shortTerm when held <= 1095 days', () {
        final txn = VdaTransaction(
          assetName: 'New Coin',
          acquisitionDate: DateTime(2024, 1, 1),
          transferDate: DateTime(2025, 1, 1),
          acquisitionCostPaise: 100000,
          saleConsiderationPaise: 120000,
        );
        expect(txn.period, VdaPeriod.shortTerm);
      });
    });

    // -------------------------------------------------------------------------
    // scheduleVdaProvider
    // -------------------------------------------------------------------------
    group('scheduleVdaProvider', () {
      test('returns a ScheduleVDA', () {
        final schedule = container.read(scheduleVdaProvider);
        expect(schedule, isA<ScheduleVDA>());
      });

      test('totalGainPaise is non-negative', () {
        final schedule = container.read(scheduleVdaProvider);
        expect(schedule.totalGainPaise, greaterThanOrEqualTo(0));
      });

      test('totalLossPaise is non-negative', () {
        final schedule = container.read(scheduleVdaProvider);
        expect(schedule.totalLossPaise, greaterThanOrEqualTo(0));
      });

      test('taxAtFlatRatePaise is non-negative', () {
        final schedule = container.read(scheduleVdaProvider);
        expect(schedule.taxAtFlatRatePaise, greaterThanOrEqualTo(0));
      });

      test('transactions in schedule matches provider transactions', () {
        final txns = container.read(vdaTransactionsProvider);
        final schedule = container.read(scheduleVdaProvider);
        expect(schedule.transactions.length, txns.length);
      });

      test('totalGainPaise matches sum of positive gains', () {
        final txns = container.read(vdaTransactionsProvider);
        final expectedGain = txns
            .where((t) => t.gainPaise > 0)
            .fold<int>(0, (sum, t) => sum + t.gainPaise);
        final schedule = container.read(scheduleVdaProvider);
        expect(schedule.totalGainPaise, expectedGain);
      });

      test('totalLossPaise matches sum of negative gains (absolute)', () {
        final txns = container.read(vdaTransactionsProvider);
        final expectedLoss = txns
            .where((t) => t.gainPaise < 0)
            .fold<int>(0, (sum, t) => sum + (-t.gainPaise));
        final schedule = container.read(scheduleVdaProvider);
        expect(schedule.totalLossPaise, expectedLoss);
      });
    });

    // -------------------------------------------------------------------------
    // vdaNetGainProvider
    // -------------------------------------------------------------------------
    group('vdaNetGainProvider', () {
      test('net gain is totalGain - totalLoss', () {
        final schedule = container.read(scheduleVdaProvider);
        final netGain = container.read(vdaNetGainProvider);
        expect(netGain, schedule.totalGainPaise - schedule.totalLossPaise);
      });
    });

    // -------------------------------------------------------------------------
    // vdaProfitableCountProvider
    // -------------------------------------------------------------------------
    group('vdaProfitableCountProvider', () {
      test('count matches profitable transactions', () {
        final txns = container.read(vdaTransactionsProvider);
        final expected = txns.where((t) => t.gainPaise > 0).length;
        expect(container.read(vdaProfitableCountProvider), expected);
      });
    });

    // -------------------------------------------------------------------------
    // vdaLossCountProvider
    // -------------------------------------------------------------------------
    group('vdaLossCountProvider', () {
      test('count matches loss-making transactions', () {
        final txns = container.read(vdaTransactionsProvider);
        final expected = txns.where((t) => t.gainPaise < 0).length;
        expect(container.read(vdaLossCountProvider), expected);
      });

      test('profitableCount + lossCount equals total transactions', () {
        final txns = container.read(vdaTransactionsProvider);
        final profitable = container.read(vdaProfitableCountProvider);
        final losses = container.read(vdaLossCountProvider);
        // neutral (gainPaise == 0) possible, so check <= total
        expect(profitable + losses, lessThanOrEqualTo(txns.length));
      });
    });

    // -------------------------------------------------------------------------
    // vdaTotalPortfolioProvider
    // -------------------------------------------------------------------------
    group('vdaTotalPortfolioProvider', () {
      test('total portfolio matches sum of all sale considerations', () {
        final txns = container.read(vdaTransactionsProvider);
        final expected = txns.fold<int>(
          0,
          (sum, t) => sum + t.saleConsiderationPaise,
        );
        expect(container.read(vdaTotalPortfolioProvider), expected);
      });

      test('total portfolio is positive', () {
        expect(container.read(vdaTotalPortfolioProvider), greaterThan(0));
      });
    });
  });
}
