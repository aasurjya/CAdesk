import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_transaction.dart';
import 'package:ca_app/features/data_pipelines/domain/models/import_result.dart';
import 'package:ca_app/features/data_pipelines/domain/services/zerodha_import_service.dart';

void main() {
  late ZerodhaCamsImportService service;

  setUp(() {
    service = ZerodhaCamsImportService.instance;
  });

  group('ZerodhaCamsImportService.parseZerodhaTradeBook', () {
    test('returns singleton instance', () {
      final a = ZerodhaCamsImportService.instance;
      final b = ZerodhaCamsImportService.instance;
      expect(identical(a, b), isTrue);
    });

    test('parses valid Zerodha CSV with buy and sell rows', () {
      const csv = '''Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time
2024-01-05,RELIANCE,INE002A01018,NSE,EQ,EQ,buy,10,2500.00,ORD001,TRD001,2024-01-05 10:30:00
2024-06-10,RELIANCE,INE002A01018,NSE,EQ,EQ,sell,10,2800.00,ORD002,TRD002,2024-06-10 14:00:00''';

      final result = service.parseZerodhaTradeBook(csv);

      expect(result.totalRecords, equals(2));
      expect(result.successCount, equals(2));
      expect(result.errorCount, equals(0));
      expect(result.transactions.length, equals(2));
    });

    test('parses buy transaction fields correctly', () {
      const csv = '''Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time
2024-01-05,RELIANCE,INE002A01018,NSE,EQ,EQ,buy,10,2500.00,ORD001,TRD001,2024-01-05 10:30:00''';

      final result = service.parseZerodhaTradeBook(csv);
      final tx = result.transactions.first;

      expect(tx.broker, equals(Broker.zerodha));
      expect(tx.assetType, equals(AssetType.equity));
      expect(tx.isin, equals('INE002A01018'));
      expect(tx.scripName, equals('RELIANCE'));
      expect(tx.transactionType, equals(TransactionType.buy));
      expect(tx.date, equals(DateTime(2024, 1, 5)));
      expect(tx.quantity, equals(10.0));
      expect(tx.price, equals(250000)); // 2500.00 rupees = 250000 paise
      expect(tx.amount, equals(2500000)); // 10 * 250000
      expect(tx.exchange, equals('NSE'));
    });

    test('parses sell transaction type correctly', () {
      const csv = '''Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time
2024-06-10,RELIANCE,INE002A01018,NSE,EQ,EQ,sell,10,2800.00,ORD002,TRD002,2024-06-10 14:00:00''';

      final result = service.parseZerodhaTradeBook(csv);
      final tx = result.transactions.first;

      expect(tx.transactionType, equals(TransactionType.sell));
      expect(tx.price, equals(280000)); // 2800 rupees in paise
    });

    test('handles empty CSV (header only)', () {
      const csv =
          'Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time';

      final result = service.parseZerodhaTradeBook(csv);

      expect(result.totalRecords, equals(0));
      expect(result.successCount, equals(0));
      expect(result.errorCount, equals(0));
      expect(result.transactions, isEmpty);
    });

    test('records error for malformed row', () {
      const csv = '''Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time
BADDATE,RELIANCE,INE002A01018,NSE,EQ,EQ,buy,10,2500.00,ORD001,TRD001,2024-01-05 10:30:00''';

      final result = service.parseZerodhaTradeBook(csv);

      expect(result.errorCount, greaterThan(0));
      expect(result.errors.first.rowNumber, equals(2));
    });

    test('records error for invalid price', () {
      const csv = '''Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time
2024-01-05,RELIANCE,INE002A01018,NSE,EQ,EQ,buy,10,NOTANUMBER,ORD001,TRD001,2024-01-05 10:30:00''';

      final result = service.parseZerodhaTradeBook(csv);

      expect(result.errorCount, greaterThan(0));
    });

    test('records error for invalid quantity', () {
      const csv = '''Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time
2024-01-05,RELIANCE,INE002A01018,NSE,EQ,EQ,buy,NOTANUMBER,2500.00,ORD001,TRD001,2024-01-05 10:30:00''';

      final result = service.parseZerodhaTradeBook(csv);

      expect(result.errorCount, greaterThan(0));
    });

    test('generates unique importId', () {
      const csv =
          'Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time';
      final r1 = service.parseZerodhaTradeBook(csv);
      final r2 = service.parseZerodhaTradeBook(csv);

      expect(r1.importId, isNotEmpty);
      expect(r2.importId, isNotEmpty);
    });

    test('ImportResult source is zerodha', () {
      const csv =
          'Date,Tradingsymbol,ISIN,Exchange,Segment,Series,Trade Type,Quantity,Price,Order ID,Trade ID,Order Execution Time';
      final result = service.parseZerodhaTradeBook(csv);

      expect(result.source, equals(ImportSource.zerodha));
    });
  });

  group('ZerodhaCamsImportService.parseCamsStatement', () {
    test('parses valid CAMS mutual fund statement', () {
      const csv = '''Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount
2024-01-10,HDFC Mid-Cap Opportunities Fund,INF179KB1HD1,Purchase,100.00,45.50,4550.00
2024-06-15,HDFC Mid-Cap Opportunities Fund,INF179KB1HD1,Redemption,50.00,55.00,2750.00''';

      final result = service.parseCamsStatement(csv);

      expect(result.totalRecords, equals(2));
      expect(result.successCount, equals(2));
      expect(result.errorCount, equals(0));
    });

    test('parses CAMS purchase as buy transaction', () {
      const csv = '''Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount
2024-01-10,HDFC Mid-Cap Opportunities Fund,INF179KB1HD1,Purchase,100.00,45.50,4550.00''';

      final result = service.parseCamsStatement(csv);
      final tx = result.transactions.first;

      expect(tx.broker, equals(Broker.cams));
      expect(tx.assetType, equals(AssetType.mutualFund));
      expect(tx.isin, equals('INF179KB1HD1'));
      expect(tx.scripName, equals('HDFC Mid-Cap Opportunities Fund'));
      expect(tx.transactionType, equals(TransactionType.buy));
      expect(tx.date, equals(DateTime(2024, 1, 10)));
      expect(tx.quantity, equals(100.0));
      expect(tx.price, equals(4550)); // 45.50 rupees in paise
      expect(tx.amount, equals(455000)); // 4550.00 rupees in paise
    });

    test('parses CAMS Redemption as sell transaction', () {
      const csv = '''Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount
2024-06-15,HDFC Mid-Cap Opportunities Fund,INF179KB1HD1,Redemption,50.00,55.00,2750.00''';

      final result = service.parseCamsStatement(csv);
      final tx = result.transactions.first;

      expect(tx.transactionType, equals(TransactionType.sell));
    });

    test('parses CAMS Dividend transaction type', () {
      const csv = '''Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount
2024-03-20,ICICI Prudential Bluechip Fund,INF109K01Z21,Dividend,0.00,100.00,500.00''';

      final result = service.parseCamsStatement(csv);
      final tx = result.transactions.first;

      expect(tx.transactionType, equals(TransactionType.dividend));
    });

    test('records error for malformed CAMS row', () {
      const csv = '''Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount
BADDATE,HDFC Mid-Cap Opportunities Fund,INF179KB1HD1,Purchase,100.00,45.50,4550.00''';

      final result = service.parseCamsStatement(csv);

      expect(result.errorCount, greaterThan(0));
    });

    test('ImportResult source is cams', () {
      const csv = 'Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount';
      final result = service.parseCamsStatement(csv);

      expect(result.source, equals(ImportSource.cams));
    });
  });

  group('ZerodhaCamsImportService.parseKfintechStatement', () {
    test('parses KFintech statement same format as CAMS', () {
      const csv = '''Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount
2024-02-12,Mirae Asset Large Cap Fund,INF769K01EI4,Purchase,200.00,80.00,16000.00''';

      final result = service.parseKfintechStatement(csv);

      expect(result.totalRecords, equals(1));
      expect(result.successCount, equals(1));
      expect(result.transactions.first.broker, equals(Broker.kfintech));
      expect(result.transactions.first.assetType, equals(AssetType.mutualFund));
    });

    test('ImportResult source is kfintech', () {
      const csv = 'Date,Scheme,ISIN,Transaction Type,Units,NAV,Amount';
      final result = service.parseKfintechStatement(csv);

      expect(result.source, equals(ImportSource.kfintech));
    });
  });

  group('ImportResult', () {
    test('equality and hashCode', () {
      final now = DateTime(2024, 1, 1);
      final r1 = ImportResult(
        importId: 'id1',
        source: ImportSource.zerodha,
        importedAt: now,
        totalRecords: 1,
        successCount: 1,
        errorCount: 0,
        errors: const [],
        transactions: const [],
      );
      final r2 = ImportResult(
        importId: 'id1',
        source: ImportSource.zerodha,
        importedAt: now,
        totalRecords: 1,
        successCount: 1,
        errorCount: 0,
        errors: const [],
        transactions: const [],
      );

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
    });

    test('copyWith changes fields correctly', () {
      final now = DateTime(2024, 1, 1);
      final original = ImportResult(
        importId: 'id1',
        source: ImportSource.zerodha,
        importedAt: now,
        totalRecords: 1,
        successCount: 1,
        errorCount: 0,
        errors: const [],
        transactions: const [],
      );
      final copy = original.copyWith(successCount: 5);

      expect(copy.successCount, equals(5));
      expect(copy.importId, equals(original.importId));
      expect(copy.source, equals(original.source));
    });
  });

  group('BrokerTransaction', () {
    test('equality and hashCode', () {
      final date = DateTime(2024, 1, 5);
      final t1 = BrokerTransaction(
        transactionId: 'TRD001',
        broker: Broker.zerodha,
        assetType: AssetType.equity,
        isin: 'INE002A01018',
        scripName: 'RELIANCE',
        transactionType: TransactionType.buy,
        date: date,
        quantity: 10.0,
        price: 250000,
        amount: 2500000,
        brokerage: 0,
        stt: 0,
        otherCharges: 0,
        exchange: 'NSE',
      );
      final t2 = BrokerTransaction(
        transactionId: 'TRD001',
        broker: Broker.zerodha,
        assetType: AssetType.equity,
        isin: 'INE002A01018',
        scripName: 'RELIANCE',
        transactionType: TransactionType.buy,
        date: date,
        quantity: 10.0,
        price: 250000,
        amount: 2500000,
        brokerage: 0,
        stt: 0,
        otherCharges: 0,
        exchange: 'NSE',
      );

      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
    });

    test('copyWith preserves unchanged fields', () {
      final date = DateTime(2024, 1, 5);
      final tx = BrokerTransaction(
        transactionId: 'TRD001',
        broker: Broker.zerodha,
        assetType: AssetType.equity,
        isin: 'INE002A01018',
        scripName: 'RELIANCE',
        transactionType: TransactionType.buy,
        date: date,
        quantity: 10.0,
        price: 250000,
        amount: 2500000,
        brokerage: 0,
        stt: 0,
        otherCharges: 0,
        exchange: 'NSE',
      );
      final copy = tx.copyWith(quantity: 20.0);

      expect(copy.quantity, equals(20.0));
      expect(copy.transactionId, equals(tx.transactionId));
      expect(copy.broker, equals(tx.broker));
    });
  });
}
