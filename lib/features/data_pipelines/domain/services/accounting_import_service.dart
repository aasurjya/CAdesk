import 'package:ca_app/features/data_pipelines/domain/models/accounting_entry.dart';
import 'package:ca_app/features/data_pipelines/domain/models/import_error.dart';

/// Service for importing accounting data from Tally, Zoho Books, and SAP.
///
/// Parse methods are pure functions that accept raw CSV content and return
/// strongly-typed [AccountingEntry] objects or validation errors.
///
/// Singleton — access via [AccountingImportService.instance].
class AccountingImportService {
  AccountingImportService._();

  static final AccountingImportService instance = AccountingImportService._();

  // ---------------------------------------------------------------------------
  // Tally CSV Import
  // ---------------------------------------------------------------------------

  /// Parses a Tally ERP CSV export.
  ///
  /// Expected columns (1-indexed):
  /// 1: Date (yyyy-MM-dd)
  /// 2: Voucher Type
  /// 3: Dr Account
  /// 4: Cr Account
  /// 5: Amount (paise integer or rupees — see note)
  /// 6: Narration
  /// 7: Reference (optional)
  ///
  /// Note: Amount is expected as an integer in paise. If the source uses
  /// rupees (decimal), the caller must pre-convert.
  ///
  /// Throws [FormatException] if any data row has an unparsable date or amount.
  List<AccountingEntry> parseTallyCsv(String csvContent) {
    return _parseAccountingCsv(csvContent, AccountingSource.tally);
  }

  // ---------------------------------------------------------------------------
  // Zoho Books Export
  // ---------------------------------------------------------------------------

  /// Parses a Zoho Books journal/ledger CSV export.
  ///
  /// Uses the same column layout as [parseTallyCsv].
  ///
  /// Throws [FormatException] if any data row has an unparsable date or amount.
  List<AccountingEntry> parseZohoBooksExport(String csvContent) {
    return _parseAccountingCsv(csvContent, AccountingSource.zoho);
  }

  // ---------------------------------------------------------------------------
  // Validation — Double-Entry Check
  // ---------------------------------------------------------------------------

  /// Validates a list of [AccountingEntry] records for structural correctness.
  ///
  /// Each entry must satisfy all of:
  /// - [AccountingEntry.debitAccount] is non-empty
  /// - [AccountingEntry.creditAccount] is non-empty
  /// - [AccountingEntry.amount] is positive (> 0)
  ///
  /// Returns a list of [ImportError] objects for every failing entry.
  /// Returns an empty list if all entries are valid.
  List<ImportError> validateDoubleEntry(List<AccountingEntry> entries) {
    final errors = <ImportError>[];

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final rowNumber = i + 1;

      if (entry.debitAccount.trim().isEmpty) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'debitAccount',
            value: entry.debitAccount,
            reason: 'Debit account must not be empty',
          ),
        );
      }

      if (entry.creditAccount.trim().isEmpty) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'creditAccount',
            value: entry.creditAccount,
            reason: 'Credit account must not be empty',
          ),
        );
      }

      if (entry.amount <= 0) {
        errors.add(
          ImportError(
            rowNumber: rowNumber,
            field: 'amount',
            value: entry.amount.toString(),
            reason: 'Amount must be positive (> 0 paise)',
          ),
        );
      }
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Shared parser for Tally and Zoho (identical CSV schema).
  ///
  /// Column layout:
  /// 0: Date, 1: Voucher Type, 2: Dr Account, 3: Cr Account,
  /// 4: Amount (paise), 5: Narration, 6: Reference (optional)
  List<AccountingEntry> _parseAccountingCsv(
    String csvContent,
    AccountingSource source,
  ) {
    final lines = _splitLines(csvContent);
    if (lines.length <= 1) return const [];

    final hasReferenceColumn = _detectReferenceColumn(lines[0]);
    final dataLines = lines.sublist(1);
    final entries = <AccountingEntry>[];

    for (final line in dataLines) {
      final fields = _splitCsv(line);
      if (fields.length < 6) {
        throw FormatException('Insufficient columns in row: $line');
      }

      final dateStr = fields[0].trim();
      final voucherType = fields[1].trim();
      final debitAccount = fields[2].trim();
      final creditAccount = fields[3].trim();
      final amountStr = fields[4].trim();
      final narration = fields[5].trim();
      final reference =
          hasReferenceColumn && fields.length > 6
              ? fields[6].trim()
              : null;

      final date = DateTime.tryParse(dateStr);
      if (date == null) {
        throw FormatException(
          'Invalid date "$dateStr"; expected yyyy-MM-dd',
        );
      }

      final amount = int.tryParse(amountStr);
      if (amount == null) {
        throw FormatException(
          'Invalid amount "$amountStr"; expected integer paise',
        );
      }

      entries.add(
        AccountingEntry(
          entryId: _generateId(),
          source: source,
          date: date,
          voucherType: voucherType,
          debitAccount: debitAccount,
          creditAccount: creditAccount,
          amount: amount,
          narration: narration,
          reference: (reference?.isEmpty ?? true) ? null : reference,
        ),
      );
    }

    return entries;
  }

  /// Returns true if the header row contains a 'Reference' column (7th column).
  bool _detectReferenceColumn(String headerLine) {
    final headers = _splitCsv(headerLine).map((h) => h.trim().toLowerCase());
    return headers.any((h) => h == 'reference' || h == 'ref');
  }

  /// Splits CSV content into non-empty trimmed lines.
  List<String> _splitLines(String content) {
    return content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  /// Splits a single CSV row respecting quoted fields.
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

  static int _idCounter = 0;

  String _generateId() {
    _idCounter++;
    return 'acc_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }
}
