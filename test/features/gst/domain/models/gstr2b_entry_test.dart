import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItcAvailability enum', () {
    test('yes → has correct label', () {
      expect(ItcAvailability.yes.label, 'Available');
    });

    test('no → has correct label', () {
      expect(ItcAvailability.no.label, 'Not Available');
    });

    test('partial → has correct label', () {
      expect(ItcAvailability.partial.label, 'Partially Available');
    });
  });

  group('MatchType enum', () {
    test('exactMatch → has correct label', () {
      expect(MatchType.exactMatch.label, 'Exact Match');
    });

    test('partialMatch → has correct label', () {
      expect(MatchType.partialMatch.label, 'Partial Match');
    });

    test('unmatchedIn2b → has correct label', () {
      expect(MatchType.unmatchedIn2b.label, 'Only in GSTR-2B');
    });

    test('unmatchedInBooks → has correct label', () {
      expect(MatchType.unmatchedInBooks.label, 'Only in Books');
    });
  });

  group('MatchDiscrepancy enum', () {
    test('amountMismatch → has correct label', () {
      expect(MatchDiscrepancy.amountMismatch.label, 'Amount Mismatch');
    });

    test('dateMismatch → has correct label', () {
      expect(MatchDiscrepancy.dateMismatch.label, 'Date Mismatch');
    });

    test('gstinMismatch → has correct label', () {
      expect(MatchDiscrepancy.gstinMismatch.label, 'GSTIN Mismatch');
    });

    test('invoiceNumberFormat → has correct label', () {
      expect(
        MatchDiscrepancy.invoiceNumberFormat.label,
        'Invoice Number Format',
      );
    });

    test('taxRateMismatch → has correct label', () {
      expect(MatchDiscrepancy.taxRateMismatch.label, 'Tax Rate Mismatch');
    });
  });

  group('Gstr2bEntry', () {
    Gstr2bEntry createEntry({
      String supplierGstin = '27AABCU9603R1ZM',
      String supplierName = 'Test Supplier',
      String invoiceNumber = 'INV-001',
      DateTime? invoiceDate,
      double invoiceValue = 11800.0,
      double taxableValue = 10000.0,
      double igst = 1800.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      String placeOfSupply = '27',
      bool reverseCharge = false,
      ItcAvailability itcAvailable = ItcAvailability.yes,
      String? itcReason,
    }) {
      return Gstr2bEntry(
        supplierGstin: supplierGstin,
        supplierName: supplierName,
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate ?? DateTime(2026, 1, 15),
        invoiceValue: invoiceValue,
        taxableValue: taxableValue,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        placeOfSupply: placeOfSupply,
        reverseCharge: reverseCharge,
        itcAvailable: itcAvailable,
        itcReason: itcReason,
      );
    }

    test('creates with const constructor and correct field values', () {
      final entry = createEntry();

      expect(entry.supplierGstin, '27AABCU9603R1ZM');
      expect(entry.supplierName, 'Test Supplier');
      expect(entry.invoiceNumber, 'INV-001');
      expect(entry.invoiceDate, DateTime(2026, 1, 15));
      expect(entry.invoiceValue, 11800.0);
      expect(entry.taxableValue, 10000.0);
      expect(entry.igst, 1800.0);
      expect(entry.cgst, 0.0);
      expect(entry.sgst, 0.0);
      expect(entry.cess, 0.0);
      expect(entry.placeOfSupply, '27');
      expect(entry.reverseCharge, false);
      expect(entry.itcAvailable, ItcAvailability.yes);
      expect(entry.itcReason, isNull);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createEntry();
      final updated = original.copyWith(
        invoiceValue: 23600.0,
        taxableValue: 20000.0,
        itcAvailable: ItcAvailability.no,
        itcReason: 'Blocked ITC',
      );

      expect(updated.invoiceValue, 23600.0);
      expect(updated.taxableValue, 20000.0);
      expect(updated.itcAvailable, ItcAvailability.no);
      expect(updated.itcReason, 'Blocked ITC');
      // Unchanged fields
      expect(updated.supplierGstin, original.supplierGstin);
      expect(updated.invoiceNumber, original.invoiceNumber);
    });

    test('copyWith → returns equal instance when no arguments provided', () {
      final original = createEntry();
      final copy = original.copyWith();

      expect(copy, equals(original));
    });

    test('equality → equal when same supplierGstin and invoiceNumber', () {
      final a = createEntry(invoiceValue: 100.0);
      final b = createEntry(invoiceValue: 200.0);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different supplierGstin', () {
      final a = createEntry(supplierGstin: '27AABCU9603R1ZM');
      final b = createEntry(supplierGstin: '29AABCU9603R1ZN');

      expect(a, isNot(equals(b)));
    });

    test('equality → not equal when different invoiceNumber', () {
      final a = createEntry(invoiceNumber: 'INV-001');
      final b = createEntry(invoiceNumber: 'INV-002');

      expect(a, isNot(equals(b)));
    });
  });

  group('BooksPurchaseEntry', () {
    BooksPurchaseEntry createEntry({
      String supplierGstin = '27AABCU9603R1ZM',
      String supplierName = 'Test Supplier',
      String invoiceNumber = 'INV-001',
      DateTime? invoiceDate,
      double invoiceValue = 11800.0,
      double taxableValue = 10000.0,
      double igst = 1800.0,
      double cgst = 0.0,
      double sgst = 0.0,
      double cess = 0.0,
      String? hsnCode,
      bool reverseCharge = false,
    }) {
      return BooksPurchaseEntry(
        supplierGstin: supplierGstin,
        supplierName: supplierName,
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate ?? DateTime(2026, 1, 15),
        invoiceValue: invoiceValue,
        taxableValue: taxableValue,
        igst: igst,
        cgst: cgst,
        sgst: sgst,
        cess: cess,
        hsnCode: hsnCode,
        reverseCharge: reverseCharge,
      );
    }

    test('creates with const constructor and correct field values', () {
      final entry = createEntry(hsnCode: '8471');

      expect(entry.supplierGstin, '27AABCU9603R1ZM');
      expect(entry.supplierName, 'Test Supplier');
      expect(entry.invoiceNumber, 'INV-001');
      expect(entry.invoiceDate, DateTime(2026, 1, 15));
      expect(entry.invoiceValue, 11800.0);
      expect(entry.taxableValue, 10000.0);
      expect(entry.igst, 1800.0);
      expect(entry.cgst, 0.0);
      expect(entry.sgst, 0.0);
      expect(entry.cess, 0.0);
      expect(entry.hsnCode, '8471');
      expect(entry.reverseCharge, false);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createEntry();
      final updated = original.copyWith(invoiceValue: 23600.0, hsnCode: '9954');

      expect(updated.invoiceValue, 23600.0);
      expect(updated.hsnCode, '9954');
      expect(updated.supplierGstin, original.supplierGstin);
    });

    test('equality → equal when same supplierGstin and invoiceNumber', () {
      final a = createEntry(invoiceValue: 100.0);
      final b = createEntry(invoiceValue: 200.0);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when different invoiceNumber', () {
      final a = createEntry(invoiceNumber: 'INV-001');
      final b = createEntry(invoiceNumber: 'INV-002');

      expect(a, isNot(equals(b)));
    });
  });

  group('MatchResult', () {
    test('creates with correct field values', () {
      final gstr2bEntry = Gstr2bEntry(
        supplierGstin: '27AABCU9603R1ZM',
        supplierName: 'Supplier',
        invoiceNumber: 'INV-001',
        invoiceDate: DateTime(2026, 1, 15),
        invoiceValue: 11800.0,
        taxableValue: 10000.0,
        igst: 1800.0,
        cgst: 0.0,
        sgst: 0.0,
        cess: 0.0,
        placeOfSupply: '27',
        reverseCharge: false,
        itcAvailable: ItcAvailability.yes,
      );

      final result = MatchResult(
        gstr2bEntry: gstr2bEntry,
        booksEntry: null,
        matchType: MatchType.unmatchedIn2b,
        discrepancies: const [],
        suggestedAction: 'Record purchase in books',
      );

      expect(result.gstr2bEntry, isNotNull);
      expect(result.booksEntry, isNull);
      expect(result.matchType, MatchType.unmatchedIn2b);
      expect(result.discrepancies, isEmpty);
      expect(result.suggestedAction, 'Record purchase in books');
    });

    test('copyWith → returns new instance with updated matchType', () {
      final result = MatchResult(
        gstr2bEntry: null,
        booksEntry: null,
        matchType: MatchType.exactMatch,
        discrepancies: const [],
        suggestedAction: 'No action needed',
      );

      final updated = result.copyWith(
        matchType: MatchType.partialMatch,
        discrepancies: [MatchDiscrepancy.amountMismatch],
      );

      expect(updated.matchType, MatchType.partialMatch);
      expect(updated.discrepancies, [MatchDiscrepancy.amountMismatch]);
    });
  });

  group('Gstr2bReconciliationResult', () {
    test('creates with correct field values', () {
      final result = Gstr2bReconciliationResult(
        exactMatches: const [],
        partialMatches: const [],
        unmatchedIn2b: const [],
        unmatchedInBooks: const [],
        totalItcIn2b: 50000.0,
        totalItcInBooks: 48000.0,
        reconciledItc: 45000.0,
        unreconciledItc: 5000.0,
        matchRate: 90.0,
      );

      expect(result.exactMatches, isEmpty);
      expect(result.partialMatches, isEmpty);
      expect(result.unmatchedIn2b, isEmpty);
      expect(result.unmatchedInBooks, isEmpty);
      expect(result.totalItcIn2b, 50000.0);
      expect(result.totalItcInBooks, 48000.0);
      expect(result.reconciledItc, 45000.0);
      expect(result.unreconciledItc, 5000.0);
      expect(result.matchRate, 90.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = Gstr2bReconciliationResult(
        exactMatches: const [],
        partialMatches: const [],
        unmatchedIn2b: const [],
        unmatchedInBooks: const [],
        totalItcIn2b: 50000.0,
        totalItcInBooks: 48000.0,
        reconciledItc: 45000.0,
        unreconciledItc: 5000.0,
        matchRate: 90.0,
      );

      final updated = original.copyWith(matchRate: 95.0);

      expect(updated.matchRate, 95.0);
      expect(updated.totalItcIn2b, 50000.0);
    });
  });
}
