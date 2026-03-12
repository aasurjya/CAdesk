import 'package:ca_app/features/data_pipelines/domain/models/broker_transaction.dart';
import 'package:ca_app/features/data_pipelines/domain/models/import_error.dart';
import 'package:ca_app/features/data_pipelines/domain/models/import_result.dart';

/// Service for importing capital gains transaction data from Zerodha, CAMS,
/// and KFintech statement formats.
///
/// All parse methods are pure functions (no I/O) that accept raw CSV content
/// as a [String] and return an [ImportResult] containing parsed transactions
/// and any row-level errors.
///
/// Singleton — access via [ZerodhaCamsImportService.instance].
class ZerodhaCamsImportService {
  ZerodhaCamsImportService._();

  static final ZerodhaCamsImportService instance = ZerodhaCamsImportService._();

  // ---------------------------------------------------------------------------
  // Zerodha Trade Book
  // ---------------------------------------------------------------------------

  /// Parses a Zerodha trade book CSV export.
  ///
  /// Expected columns (1-indexed):
  /// 1: Date (yyyy-MM-dd)
  /// 2: Tradingsymbol
  /// 3: ISIN
  /// 4: Exchange
  /// 5: Segment
  /// 6: Series
  /// 7: Trade Type (buy / sell)
  /// 8: Quantity
  /// 9: Price (rupees, may be decimal)
  /// 10: Order ID
  /// 11: Trade ID
  /// 12: Order Execution Time
  ///
  /// Returns an [ImportResult] with [ImportSource.zerodha].
  ImportResult parseZerodhaTradeBook(String csvContent) {
    final lines = _splitLines(csvContent);
    if (lines.length <= 1) {
      return _emptyResult(ImportSource.zerodha);
    }

    final dataLines = lines.sublist(1);
    final transactions = <BrokerTransaction>[];
    final errors = <ImportError>[];

    for (var i = 0; i < dataLines.length; i++) {
      final rowNumber = i + 2; // 1-based, row 1 is header
      final fields = _splitCsv(dataLines[i]);
      if (fields.length < 9) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'row',
            value: dataLines[i],
            reason: 'Insufficient columns (expected at least 9)',
          ),
        );
        continue;
      }

      final dateStr = fields[0].trim();
      final symbol = fields[1].trim();
      final isin = fields[2].trim();
      final exchange = fields[3].trim();
      final tradeType = fields[6].trim().toLowerCase();
      final quantityStr = fields[7].trim();
      final priceStr = fields[8].trim();
      final tradeId = fields.length > 10 ? fields[10].trim() : _generateId();

      // Parse date
      final date = _tryParseDate(dateStr);
      if (date == null) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'Date',
            value: dateStr,
            reason: 'Invalid date format; expected yyyy-MM-dd',
          ),
        );
        continue;
      }

      // Parse quantity
      final quantity = double.tryParse(quantityStr);
      if (quantity == null) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'Quantity',
            value: quantityStr,
            reason: 'Not a valid number',
          ),
        );
        continue;
      }

      // Parse price (rupees → paise)
      final priceRupees = double.tryParse(priceStr);
      if (priceRupees == null) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'Price',
            value: priceStr,
            reason: 'Not a valid number',
          ),
        );
        continue;
      }

      final pricePaise = (priceRupees * 100).round();
      final amountPaise = (pricePaise * quantity).round();

      final txType = _parseZerodhaTradeType(tradeType);
      transactions.add(
        BrokerTransaction(
          transactionId: tradeId.isEmpty ? _generateId() : tradeId,
          broker: Broker.zerodha,
          assetType: AssetType.equity,
          isin: isin.isEmpty ? null : isin,
          scripName: symbol,
          transactionType: txType,
          date: date,
          quantity: quantity,
          price: pricePaise,
          amount: amountPaise,
          brokerage: 0,
          stt: 0,
          otherCharges: 0,
          exchange: exchange.isEmpty ? null : exchange,
        ),
      );
    }

    return ImportResult(
      importId: _generateId(),
      source: ImportSource.zerodha,
      importedAt: DateTime.now(),
      totalRecords: dataLines.length,
      successCount: transactions.length,
      errorCount: errors.length,
      errors: errors,
      transactions: transactions,
    );
  }

  // ---------------------------------------------------------------------------
  // CAMS Mutual Fund Statement
  // ---------------------------------------------------------------------------

  /// Parses a CAMS consolidated account statement CSV export.
  ///
  /// Expected columns (1-indexed):
  /// 1: Date (yyyy-MM-dd)
  /// 2: Scheme
  /// 3: ISIN
  /// 4: Transaction Type (Purchase / Redemption / Dividend / ...)
  /// 5: Units
  /// 6: NAV (rupees, may be decimal)
  /// 7: Amount (rupees, may be decimal)
  ///
  /// Returns an [ImportResult] with [ImportSource.cams].
  ImportResult parseCamsStatement(String csvContent) {
    return _parseMfStatement(csvContent, Broker.cams, ImportSource.cams);
  }

  // ---------------------------------------------------------------------------
  // KFintech Mutual Fund Statement
  // ---------------------------------------------------------------------------

  /// Parses a KFintech (formerly Karvy) account statement CSV export.
  ///
  /// Uses the same column layout as [parseCamsStatement].
  ///
  /// Returns an [ImportResult] with [ImportSource.kfintech].
  ImportResult parseKfintechStatement(String csvContent) {
    return _parseMfStatement(
      csvContent,
      Broker.kfintech,
      ImportSource.kfintech,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Shared parser for CAMS / KFintech — both use an identical CSV schema.
  ImportResult _parseMfStatement(
    String csvContent,
    Broker broker,
    ImportSource source,
  ) {
    final lines = _splitLines(csvContent);
    if (lines.length <= 1) {
      return _emptyResult(source);
    }

    final dataLines = lines.sublist(1);
    final transactions = <BrokerTransaction>[];
    final errors = <ImportError>[];

    for (var i = 0; i < dataLines.length; i++) {
      final rowNumber = i + 2;
      final fields = _splitCsv(dataLines[i]);
      if (fields.length < 7) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'row',
            value: dataLines[i],
            reason: 'Insufficient columns (expected at least 7)',
          ),
        );
        continue;
      }

      final dateStr = fields[0].trim();
      final scheme = fields[1].trim();
      final isin = fields[2].trim();
      final txTypeStr = fields[3].trim();
      final unitsStr = fields[4].trim();
      final navStr = fields[5].trim();
      final amountStr = fields[6].trim();

      final date = _tryParseDate(dateStr);
      if (date == null) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'Date',
            value: dateStr,
            reason: 'Invalid date format; expected yyyy-MM-dd',
          ),
        );
        continue;
      }

      final units = double.tryParse(unitsStr);
      if (units == null) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'Units',
            value: unitsStr,
            reason: 'Not a valid number',
          ),
        );
        continue;
      }

      final nav = double.tryParse(navStr);
      if (nav == null) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'NAV',
            value: navStr,
            reason: 'Not a valid number',
          ),
        );
        continue;
      }

      final amount = double.tryParse(amountStr);
      if (amount == null) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'Amount',
            value: amountStr,
            reason: 'Not a valid number',
          ),
        );
        continue;
      }

      final navPaise = (nav * 100).round();
      final amountPaise = (amount * 100).round();
      final txType = _parseMfTransactionType(txTypeStr);

      transactions.add(
        BrokerTransaction(
          transactionId: _generateId(),
          broker: broker,
          assetType: AssetType.mutualFund,
          isin: isin.isEmpty ? null : isin,
          scripName: scheme,
          transactionType: txType,
          date: date,
          quantity: units,
          price: navPaise,
          amount: amountPaise,
          brokerage: 0,
          stt: 0,
          otherCharges: 0,
          exchange: null,
        ),
      );
    }

    return ImportResult(
      importId: _generateId(),
      source: source,
      importedAt: DateTime.now(),
      totalRecords: dataLines.length,
      successCount: transactions.length,
      errorCount: errors.length,
      errors: errors,
      transactions: transactions,
    );
  }

  /// Splits CSV content into non-empty lines.
  List<String> _splitLines(String content) {
    return content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  /// Splits a single CSV row, handling quoted fields.
  List<String> _splitCsv(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString());
    return result;
  }

  /// Tries to parse a date string in `yyyy-MM-dd` format.
  DateTime? _tryParseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Maps Zerodha trade type string to [TransactionType].
  TransactionType _parseZerodhaTradeType(String type) {
    switch (type) {
      case 'buy':
        return TransactionType.buy;
      case 'sell':
        return TransactionType.sell;
      default:
        return TransactionType.buy;
    }
  }

  /// Maps CAMS / KFintech transaction type string to [TransactionType].
  TransactionType _parseMfTransactionType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('redemption')) return TransactionType.sell;
    if (lower.contains('dividend')) return TransactionType.dividend;
    if (lower.contains('bonus')) return TransactionType.bonus;
    if (lower.contains('purchase') || lower.contains('sip')) {
      return TransactionType.buy;
    }
    return TransactionType.buy;
  }

  ImportResult _emptyResult(ImportSource source) {
    return ImportResult(
      importId: _generateId(),
      source: source,
      importedAt: DateTime.now(),
      totalRecords: 0,
      successCount: 0,
      errorCount: 0,
      errors: const [],
      transactions: const [],
    );
  }

  /// Generates a simple unique ID based on current timestamp and a counter.
  static int _counter = 0;

  String _generateId() {
    _counter++;
    return 'import_${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }
}
