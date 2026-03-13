import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_transaction.dart';
import 'package:ca_app/features/data_pipelines/domain/models/capital_gains_position.dart';
import 'package:ca_app/features/data_pipelines/domain/services/capital_gains_pipeline_service.dart';

void main() {
  late CapitalGainsPipelineService service;

  setUp(() {
    service = CapitalGainsPipelineService.instance;
  });

  group('CapitalGainsPipelineService singleton', () {
    test('returns same instance', () {
      final a = CapitalGainsPipelineService.instance;
      final b = CapitalGainsPipelineService.instance;
      expect(identical(a, b), isTrue);
    });
  });

  group('computeIndexedCost', () {
    test('returns original cost when purchase and sale year same', () {
      // CII 2024-25: 363, 2024-25: 363 → factor 1
      final indexed = service.computeIndexedCost(100000, 2024, 2024);
      expect(indexed, equals(100000));
    });

    test('computes indexed cost correctly from 2001-02 to 2024-25', () {
      // CII 2001-02 = 100, CII 2024-25 = 363
      // Indexed = 100000 * 363 / 100 = 363000
      final indexed = service.computeIndexedCost(100000, 2001, 2024);
      expect(indexed, equals(363000));
    });

    test('computes indexed cost from 2020-21 to 2024-25', () {
      // CII 2020-21 = 301, CII 2024-25 = 363
      // Indexed = 1000000 * 363 / 301 = 1205980 (truncated integer division)
      final indexed = service.computeIndexedCost(1000000, 2020, 2024);
      expect(indexed, equals(1000000 * 363 ~/ 301));
    });

    test('falls back gracefully for unknown year (uses nearest known)', () {
      // 2025 is beyond table — should not throw
      expect(
        () => service.computeIndexedCost(100000, 2001, 2025),
        returnsNormally,
      );
    });
  });

  group('classifyGain', () {
    test('equity short term (<= 12 months) → stcg111a', () {
      final pos = _makePosition(
        assetType: AssetType.equity,
        holdingDays: 180,
        isLongTerm: false,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.stcg111a));
    });

    test('equity long term (> 12 months) → ltcg112a', () {
      final pos = _makePosition(
        assetType: AssetType.equity,
        holdingDays: 400,
        isLongTerm: true,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.ltcg112a));
    });

    test('ETF short term → stcg111a', () {
      final pos = _makePosition(
        assetType: AssetType.etf,
        holdingDays: 300,
        isLongTerm: false,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.stcg111a));
    });

    test('ETF long term → ltcg112a', () {
      final pos = _makePosition(
        assetType: AssetType.etf,
        holdingDays: 400,
        isLongTerm: true,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.ltcg112a));
    });

    test('mutual fund short term (<= 12 months) → stcg111a', () {
      final pos = _makePosition(
        assetType: AssetType.mutualFund,
        holdingDays: 300,
        isLongTerm: false,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.stcg111a));
    });

    test('mutual fund long term (> 12 months) → ltcg112a', () {
      final pos = _makePosition(
        assetType: AssetType.mutualFund,
        holdingDays: 400,
        isLongTerm: true,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.ltcg112a));
    });

    test('debt MF short term → stcgOther (post April 2023)', () {
      // Debt MF LTCG abolished from April 2023, so all are stcgOther
      final pos = _makePosition(
        assetType: AssetType.bond,
        holdingDays: 400,
        isLongTerm: false,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.stcgOther));
    });

    test('NCD short term → stcgOther', () {
      final pos = _makePosition(
        assetType: AssetType.ncd,
        holdingDays: 200,
        isLongTerm: false,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.stcgOther));
    });

    test('NCD long term → ltcgOther', () {
      final pos = _makePosition(
        assetType: AssetType.ncd,
        holdingDays: 800,
        isLongTerm: true,
      );
      final category = service.classifyGain(pos);
      expect(category, equals(TaxCategory.ltcgOther));
    });
  });

  group('applyFifo', () {
    test('simple single buy single sell FIFO', () {
      final buy = _makeTx(
        id: 'B1',
        type: TransactionType.buy,
        date: DateTime(2024, 1, 5),
        quantity: 10,
        price: 250000,
        amount: 2500000,
      );
      final sell = _makeTx(
        id: 'S1',
        type: TransactionType.sell,
        date: DateTime(2024, 6, 10),
        quantity: 10,
        price: 280000,
        amount: 2800000,
      );

      final positions = service.applyFifo([buy], [sell]);

      expect(positions.length, equals(1));
      expect(positions.first.acquisitionCost, equals(2500000));
      expect(positions.first.saleProceeds, equals(2800000));
      expect(positions.first.gainLoss, equals(300000)); // 2800000 - 2500000
      expect(positions.first.quantity, equals(10.0));
    });

    test('FIFO partial sell consumes oldest lot first', () {
      final buy1 = _makeTx(
        id: 'B1',
        type: TransactionType.buy,
        date: DateTime(2023, 1, 1),
        quantity: 10,
        price: 100000,
        amount: 1000000,
      );
      final buy2 = _makeTx(
        id: 'B2',
        type: TransactionType.buy,
        date: DateTime(2024, 1, 1),
        quantity: 10,
        price: 150000,
        amount: 1500000,
      );
      // Sell 10 units: should consume buy1 first
      final sell = _makeTx(
        id: 'S1',
        type: TransactionType.sell,
        date: DateTime(2024, 6, 1),
        quantity: 10,
        price: 200000,
        amount: 2000000,
      );

      final positions = service.applyFifo([buy1, buy2], [sell]);

      expect(positions.length, equals(1));
      // Gain = 2000000 - 1000000 = 1000000 (used buy1 price)
      expect(positions.first.acquisitionCost, equals(1000000));
      expect(positions.first.gainLoss, equals(1000000));
    });

    test('FIFO sell spanning two lots', () {
      final buy1 = _makeTx(
        id: 'B1',
        type: TransactionType.buy,
        date: DateTime(2023, 1, 1),
        quantity: 5,
        price: 100000,
        amount: 500000,
      );
      final buy2 = _makeTx(
        id: 'B2',
        type: TransactionType.buy,
        date: DateTime(2024, 1, 1),
        quantity: 5,
        price: 150000,
        amount: 750000,
      );
      // Sell 8 units: consume all 5 from buy1, then 3 from buy2
      final sell = _makeTx(
        id: 'S1',
        type: TransactionType.sell,
        date: DateTime(2024, 6, 1),
        quantity: 8,
        price: 200000,
        amount: 1600000,
      );

      final positions = service.applyFifo([buy1, buy2], [sell]);

      // Should produce 2 positions (one per consumed lot)
      expect(positions.length, equals(2));

      // First position: 5 units from buy1
      final pos1 = positions.firstWhere((p) => p.quantity == 5.0);
      expect(pos1.acquisitionCost, equals(500000)); // 5 * 100000
      expect(pos1.saleProceeds, equals(1000000)); // 5 * 200000
      expect(pos1.gainLoss, equals(500000));

      // Second position: 3 units from buy2
      final pos2 = positions.firstWhere((p) => p.quantity == 3.0);
      expect(pos2.acquisitionCost, equals(450000)); // 3 * 150000
      expect(pos2.saleProceeds, equals(600000)); // 3 * 200000
      expect(pos2.gainLoss, equals(150000));
    });

    test('holding period calculated correctly', () {
      final buyDate = DateTime(2023, 1, 1);
      final sellDate = DateTime(2024, 2, 1);
      final buy = _makeTx(
        id: 'B1',
        type: TransactionType.buy,
        date: buyDate,
        quantity: 10,
        price: 100000,
        amount: 1000000,
      );
      final sell = _makeTx(
        id: 'S1',
        type: TransactionType.sell,
        date: sellDate,
        quantity: 10,
        price: 120000,
        amount: 1200000,
      );

      final positions = service.applyFifo([buy], [sell]);
      expect(
        positions.first.holdingPeriod,
        equals(sellDate.difference(buyDate).inDays),
      );
    });

    test('equity held >12 months marked isLongTerm', () {
      final buy = _makeTx(
        id: 'B1',
        type: TransactionType.buy,
        date: DateTime(2023, 1, 1),
        quantity: 10,
        price: 100000,
        amount: 1000000,
      );
      final sell = _makeTx(
        id: 'S1',
        type: TransactionType.sell,
        date: DateTime(2024, 6, 1),
        quantity: 10,
        price: 120000,
        amount: 1200000,
      );

      final positions = service.applyFifo([buy], [sell]);
      expect(positions.first.isLongTerm, isTrue);
    });

    test('equity held <=12 months marked not isLongTerm', () {
      final buy = _makeTx(
        id: 'B1',
        type: TransactionType.buy,
        date: DateTime(2024, 1, 1),
        quantity: 10,
        price: 100000,
        amount: 1000000,
      );
      final sell = _makeTx(
        id: 'S1',
        type: TransactionType.sell,
        date: DateTime(2024, 6, 1),
        quantity: 10,
        price: 120000,
        amount: 1200000,
      );

      final positions = service.applyFifo([buy], [sell]);
      expect(positions.first.isLongTerm, isFalse);
    });

    test('returns empty list when buys is empty', () {
      final sell = _makeTx(
        id: 'S1',
        type: TransactionType.sell,
        date: DateTime(2024, 6, 1),
        quantity: 10,
        price: 120000,
        amount: 1200000,
      );
      final positions = service.applyFifo([], [sell]);
      expect(positions, isEmpty);
    });

    test('returns empty list when sells is empty', () {
      final buy = _makeTx(
        id: 'B1',
        type: TransactionType.buy,
        date: DateTime(2024, 1, 1),
        quantity: 10,
        price: 100000,
        amount: 1000000,
      );
      final positions = service.applyFifo([buy], []);
      expect(positions, isEmpty);
    });
  });

  group('computeCapGains', () {
    test('groups by ISIN and applies FIFO', () {
      final transactions = [
        _makeTxWithIsin(
          id: 'B1',
          type: TransactionType.buy,
          date: DateTime(2024, 1, 1),
          quantity: 10,
          price: 100000,
          amount: 1000000,
          isin: 'INE002A01018',
          scripName: 'RELIANCE',
        ),
        _makeTxWithIsin(
          id: 'S1',
          type: TransactionType.sell,
          date: DateTime(2024, 6, 1),
          quantity: 5,
          price: 120000,
          amount: 600000,
          isin: 'INE002A01018',
          scripName: 'RELIANCE',
        ),
      ];

      final positions = service.computeCapGains(transactions);

      expect(positions.length, equals(1));
      expect(positions.first.isin, equals('INE002A01018'));
      expect(positions.first.gainLoss, equals(100000)); // 5*(120000-100000)
    });

    test('handles multiple ISINs independently', () {
      final transactions = [
        _makeTxWithIsin(
          id: 'B1',
          type: TransactionType.buy,
          date: DateTime(2024, 1, 1),
          quantity: 10,
          price: 100000,
          amount: 1000000,
          isin: 'INE002A01018',
          scripName: 'RELIANCE',
        ),
        _makeTxWithIsin(
          id: 'S1',
          type: TransactionType.sell,
          date: DateTime(2024, 6, 1),
          quantity: 10,
          price: 120000,
          amount: 1200000,
          isin: 'INE002A01018',
          scripName: 'RELIANCE',
        ),
        _makeTxWithIsin(
          id: 'B2',
          type: TransactionType.buy,
          date: DateTime(2024, 2, 1),
          quantity: 20,
          price: 50000,
          amount: 1000000,
          isin: 'INF179KB1HD1',
          scripName: 'HDFC MF',
        ),
        _makeTxWithIsin(
          id: 'S2',
          type: TransactionType.sell,
          date: DateTime(2024, 7, 1),
          quantity: 20,
          price: 60000,
          amount: 1200000,
          isin: 'INF179KB1HD1',
          scripName: 'HDFC MF',
        ),
      ];

      final positions = service.computeCapGains(transactions);

      expect(positions.length, equals(2));
    });

    test('ignores non-buy/sell transactions in FIFO computation', () {
      final transactions = [
        _makeTxWithIsin(
          id: 'B1',
          type: TransactionType.buy,
          date: DateTime(2024, 1, 1),
          quantity: 10,
          price: 100000,
          amount: 1000000,
          isin: 'INE002A01018',
          scripName: 'RELIANCE',
        ),
        _makeTxWithIsin(
          id: 'D1',
          type: TransactionType.dividend,
          date: DateTime(2024, 3, 1),
          quantity: 0,
          price: 0,
          amount: 5000,
          isin: 'INE002A01018',
          scripName: 'RELIANCE',
        ),
        _makeTxWithIsin(
          id: 'S1',
          type: TransactionType.sell,
          date: DateTime(2024, 6, 1),
          quantity: 10,
          price: 120000,
          amount: 1200000,
          isin: 'INE002A01018',
          scripName: 'RELIANCE',
        ),
      ];

      final positions = service.computeCapGains(transactions);

      // Dividend does not affect FIFO positions
      expect(positions.length, equals(1));
    });
  });

  group('CapitalGainsPosition', () {
    test('equality and hashCode', () {
      final pos1 = _makePosition(
        assetType: AssetType.equity,
        holdingDays: 400,
        isLongTerm: true,
      );
      final pos2 = _makePosition(
        assetType: AssetType.equity,
        holdingDays: 400,
        isLongTerm: true,
      );
      expect(pos1, equals(pos2));
      expect(pos1.hashCode, equals(pos2.hashCode));
    });

    test('copyWith changes field correctly', () {
      final pos = _makePosition(
        assetType: AssetType.equity,
        holdingDays: 400,
        isLongTerm: true,
      );
      final copy = pos.copyWith(gainLoss: 99999);
      expect(copy.gainLoss, equals(99999));
      expect(copy.isin, equals(pos.isin));
    });
  });
}

// --- Helpers ---

CapitalGainsPosition _makePosition({
  required AssetType assetType,
  required int holdingDays,
  required bool isLongTerm,
}) {
  final acquisition = DateTime(2023, 1, 1);
  final sale = acquisition.add(Duration(days: holdingDays));
  return CapitalGainsPosition(
    isin: 'INE002A01018',
    scripName: 'RELIANCE',
    assetType: assetType,
    acquisitionDate: acquisition,
    acquisitionCost: 1000000,
    saleDate: sale,
    saleProceeds: 1200000,
    quantity: 10.0,
    indexedCost: null,
    gainLoss: 200000,
    holdingPeriod: holdingDays,
    isLongTerm: isLongTerm,
    taxCategory: TaxCategory.stcg111a,
  );
}

BrokerTransaction _makeTx({
  required String id,
  required TransactionType type,
  required DateTime date,
  required double quantity,
  required int price,
  required int amount,
}) {
  return BrokerTransaction(
    transactionId: id,
    broker: Broker.zerodha,
    assetType: AssetType.equity,
    isin: 'INE002A01018',
    scripName: 'RELIANCE',
    transactionType: type,
    date: date,
    quantity: quantity,
    price: price,
    amount: amount,
    brokerage: 0,
    stt: 0,
    otherCharges: 0,
    exchange: 'NSE',
  );
}

BrokerTransaction _makeTxWithIsin({
  required String id,
  required TransactionType type,
  required DateTime date,
  required double quantity,
  required int price,
  required int amount,
  required String isin,
  required String scripName,
}) {
  return BrokerTransaction(
    transactionId: id,
    broker: Broker.zerodha,
    assetType: AssetType.equity,
    isin: isin,
    scripName: scripName,
    transactionType: type,
    date: date,
    quantity: quantity,
    price: price,
    amount: amount,
    brokerage: 0,
    stt: 0,
    otherCharges: 0,
    exchange: 'NSE',
  );
}
