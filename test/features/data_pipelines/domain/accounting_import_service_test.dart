import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/data_pipelines/domain/models/accounting_entry.dart';
import 'package:ca_app/features/data_pipelines/domain/models/import_error.dart';
import 'package:ca_app/features/data_pipelines/domain/services/accounting_import_service.dart';

void main() {
  late AccountingImportService service;

  setUp(() {
    service = AccountingImportService.instance;
  });

  group('AccountingImportService singleton', () {
    test('returns same instance', () {
      final a = AccountingImportService.instance;
      final b = AccountingImportService.instance;
      expect(identical(a, b), isTrue);
    });
  });

  group('parseTallyCsv', () {
    test('parses valid Tally CSV', () {
      const csv = '''Date,Voucher Type,Dr Account,Cr Account,Amount,Narration
2024-01-10,Payment,Office Rent,Bank Account,1500000,Monthly rent Jan 2024
2024-01-15,Receipt,Bank Account,Sales Account,5000000,Client payment''';

      final entries = service.parseTallyCsv(csv);

      expect(entries.length, equals(2));
    });

    test('parses Tally entry fields correctly', () {
      const csv = '''Date,Voucher Type,Dr Account,Cr Account,Amount,Narration
2024-01-10,Payment,Office Rent,Bank Account,1500000,Monthly rent Jan 2024''';

      final entries = service.parseTallyCsv(csv);
      final entry = entries.first;

      expect(entry.source, equals(AccountingSource.tally));
      expect(entry.date, equals(DateTime(2024, 1, 10)));
      expect(entry.voucherType, equals('Payment'));
      expect(entry.debitAccount, equals('Office Rent'));
      expect(entry.creditAccount, equals('Bank Account'));
      expect(entry.amount, equals(1500000));
      expect(entry.narration, equals('Monthly rent Jan 2024'));
      expect(entry.reference, isNull);
      expect(entry.entryId, isNotEmpty);
    });

    test('parses entry with optional Reference column', () {
      const csv =
          '''Date,Voucher Type,Dr Account,Cr Account,Amount,Narration,Reference
2024-01-10,Payment,Office Rent,Bank Account,1500000,Monthly rent,REF001''';

      final entries = service.parseTallyCsv(csv);
      expect(entries.first.reference, equals('REF001'));
    });

    test('handles empty Tally CSV (header only)', () {
      const csv = 'Date,Voucher Type,Dr Account,Cr Account,Amount,Narration';
      final entries = service.parseTallyCsv(csv);
      expect(entries, isEmpty);
    });

    test('skips rows with malformed amount (non-numeric)', () {
      const csv = '''Date,Voucher Type,Dr Account,Cr Account,Amount,Narration
2024-01-10,Payment,Office Rent,Bank Account,NOTANUMBER,Monthly rent Jan 2024''';

      expect(() => service.parseTallyCsv(csv), throwsA(isA<FormatException>()));
    });

    test('skips rows with malformed date', () {
      const csv = '''Date,Voucher Type,Dr Account,Cr Account,Amount,Narration
BADDATE,Payment,Office Rent,Bank Account,1500000,Monthly rent Jan 2024''';

      expect(() => service.parseTallyCsv(csv), throwsA(isA<FormatException>()));
    });
  });

  group('parseZohoBooksExport', () {
    test('parses valid Zoho Books export', () {
      const csv = '''Date,Voucher Type,Dr Account,Cr Account,Amount,Narration
2024-02-05,Invoice,Accounts Receivable,Sales,2000000,Invoice #1001
2024-02-10,Payment,Bank Account,Accounts Receivable,2000000,Payment for Invoice #1001''';

      final entries = service.parseZohoBooksExport(csv);

      expect(entries.length, equals(2));
    });

    test('parses Zoho entry source correctly', () {
      const csv = '''Date,Voucher Type,Dr Account,Cr Account,Amount,Narration
2024-02-05,Invoice,Accounts Receivable,Sales,2000000,Invoice #1001''';

      final entries = service.parseZohoBooksExport(csv);
      expect(entries.first.source, equals(AccountingSource.zoho));
    });

    test('handles empty Zoho CSV', () {
      const csv = 'Date,Voucher Type,Dr Account,Cr Account,Amount,Narration';
      final entries = service.parseZohoBooksExport(csv);
      expect(entries, isEmpty);
    });
  });

  group('validateDoubleEntry', () {
    test('returns no errors when debits equal credits', () {
      final entries = [
        _makeEntry(
          debit: 'Office Rent',
          credit: 'Bank Account',
          amount: 1500000,
        ),
        _makeEntry(debit: 'Utilities', credit: 'Bank Account', amount: 300000),
      ];

      // Double-entry is always balanced per entry (each entry has 1 debit and 1 credit)
      final errors = service.validateDoubleEntry(entries);
      expect(errors, isEmpty);
    });

    test('returns no errors for empty list', () {
      final errors = service.validateDoubleEntry([]);
      expect(errors, isEmpty);
    });

    test('returns error when debitAccount is empty', () {
      final entries = [
        _makeEntry(debit: '', credit: 'Bank Account', amount: 1500000),
      ];

      final errors = service.validateDoubleEntry(entries);
      expect(errors, isNotEmpty);
      expect(errors.first.field, equals('debitAccount'));
    });

    test('returns error when creditAccount is empty', () {
      final entries = [
        _makeEntry(debit: 'Office Rent', credit: '', amount: 1500000),
      ];

      final errors = service.validateDoubleEntry(entries);
      expect(errors, isNotEmpty);
      expect(errors.first.field, equals('creditAccount'));
    });

    test('returns error when amount is zero or negative', () {
      final entries = [
        _makeEntry(debit: 'Office Rent', credit: 'Bank Account', amount: 0),
      ];

      final errors = service.validateDoubleEntry(entries);
      expect(errors, isNotEmpty);
      expect(errors.first.field, equals('amount'));
    });

    test('returns error when amount is negative', () {
      final entries = [
        _makeEntry(debit: 'Office Rent', credit: 'Bank Account', amount: -100),
      ];

      final errors = service.validateDoubleEntry(entries);
      expect(errors, isNotEmpty);
    });

    test('returns errors for multiple invalid entries', () {
      final entries = [
        _makeEntry(debit: '', credit: 'Bank Account', amount: 1500000),
        _makeEntry(debit: 'Office Rent', credit: '', amount: 1500000),
        _makeEntry(debit: 'Office Rent', credit: 'Bank Account', amount: 0),
      ];

      final errors = service.validateDoubleEntry(entries);
      expect(errors.length, equals(3));
    });
  });

  group('AccountingEntry', () {
    test('equality and hashCode', () {
      final date = DateTime(2024, 1, 10);
      final e1 = AccountingEntry(
        entryId: 'E001',
        source: AccountingSource.tally,
        date: date,
        voucherType: 'Payment',
        debitAccount: 'Office Rent',
        creditAccount: 'Bank Account',
        amount: 1500000,
        narration: 'Monthly rent',
        reference: null,
      );
      final e2 = AccountingEntry(
        entryId: 'E001',
        source: AccountingSource.tally,
        date: date,
        voucherType: 'Payment',
        debitAccount: 'Office Rent',
        creditAccount: 'Bank Account',
        amount: 1500000,
        narration: 'Monthly rent',
        reference: null,
      );

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
    });

    test('copyWith changes field correctly', () {
      final date = DateTime(2024, 1, 10);
      final entry = AccountingEntry(
        entryId: 'E001',
        source: AccountingSource.tally,
        date: date,
        voucherType: 'Payment',
        debitAccount: 'Office Rent',
        creditAccount: 'Bank Account',
        amount: 1500000,
        narration: 'Monthly rent',
        reference: null,
      );
      final copy = entry.copyWith(amount: 2000000);

      expect(copy.amount, equals(2000000));
      expect(copy.entryId, equals(entry.entryId));
      expect(copy.narration, equals(entry.narration));
    });

    test('copyWith can set reference to non-null', () {
      final date = DateTime(2024, 1, 10);
      final entry = AccountingEntry(
        entryId: 'E001',
        source: AccountingSource.tally,
        date: date,
        voucherType: 'Payment',
        debitAccount: 'Office Rent',
        creditAccount: 'Bank Account',
        amount: 1500000,
        narration: 'Monthly rent',
        reference: null,
      );
      final copy = entry.copyWith(reference: 'REF999');
      expect(copy.reference, equals('REF999'));
    });
  });

  group('ImportError', () {
    test('equality and hashCode', () {
      const e1 = ImportError(
        rowNumber: 2,
        field: 'date',
        value: 'BADDATE',
        reason: 'Invalid date format',
      );
      const e2 = ImportError(
        rowNumber: 2,
        field: 'date',
        value: 'BADDATE',
        reason: 'Invalid date format',
      );

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
    });

    test('copyWith changes field', () {
      const error = ImportError(
        rowNumber: 2,
        field: 'date',
        value: 'BADDATE',
        reason: 'Invalid date format',
      );
      final copy = error.copyWith(rowNumber: 5);
      expect(copy.rowNumber, equals(5));
      expect(copy.field, equals(error.field));
    });
  });
}

// --- Helpers ---

AccountingEntry _makeEntry({
  required String debit,
  required String credit,
  required int amount,
}) {
  return AccountingEntry(
    entryId: 'E001',
    source: AccountingSource.tally,
    date: DateTime(2024, 1, 10),
    voucherType: 'Payment',
    debitAccount: debit,
    creditAccount: credit,
    amount: amount,
    narration: 'Test narration',
    reference: null,
  );
}
