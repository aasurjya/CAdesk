import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';
import 'package:ca_app/features/gst/domain/services/gstr2b_matching_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────

  Gstr2bEntry make2bEntry({
    String gstin = '27AABCU9603R1ZM',
    String invoiceNumber = 'INV-001',
    DateTime? invoiceDate,
    double invoiceValue = 11800.0,
    double taxableValue = 10000.0,
    double igst = 1800.0,
    double cgst = 0.0,
    double sgst = 0.0,
  }) {
    return Gstr2bEntry(
      supplierGstin: gstin,
      supplierName: 'Supplier',
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate ?? DateTime(2026, 1, 15),
      invoiceValue: invoiceValue,
      taxableValue: taxableValue,
      igst: igst,
      cgst: cgst,
      sgst: sgst,
      cess: 0.0,
      placeOfSupply: '27',
      reverseCharge: false,
      itcAvailable: ItcAvailability.yes,
    );
  }

  BooksPurchaseEntry makeBooksEntry({
    String gstin = '27AABCU9603R1ZM',
    String invoiceNumber = 'INV-001',
    DateTime? invoiceDate,
    double invoiceValue = 11800.0,
    double taxableValue = 10000.0,
    double igst = 1800.0,
    double cgst = 0.0,
    double sgst = 0.0,
  }) {
    return BooksPurchaseEntry(
      supplierGstin: gstin,
      supplierName: 'Supplier',
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate ?? DateTime(2026, 1, 15),
      invoiceValue: invoiceValue,
      taxableValue: taxableValue,
      igst: igst,
      cgst: cgst,
      sgst: sgst,
      cess: 0.0,
      reverseCharge: false,
    );
  }

  // ── matchSingle ─────────────────────────────────────────────────────

  group('Gstr2bMatchingEngine.matchSingle', () {
    test('exact match → same GSTIN, invoice number, amount', () {
      final entry2b = make2bEntry();
      final books = [makeBooksEntry()];

      final result = Gstr2bMatchingEngine.matchSingle(
        gstr2bEntry: entry2b,
        booksEntries: books,
      );

      expect(result.matchType, MatchType.exactMatch);
      expect(result.discrepancies, isEmpty);
      expect(result.gstr2bEntry, entry2b);
      expect(result.booksEntry, books.first);
    });

    test('exact match → amount within 1% tolerance', () {
      final entry2b = make2bEntry(invoiceValue: 11800.0);
      final books = [makeBooksEntry(invoiceValue: 11700.0)]; // ~0.85% diff

      final result = Gstr2bMatchingEngine.matchSingle(
        gstr2bEntry: entry2b,
        booksEntries: books,
      );

      expect(result.matchType, MatchType.exactMatch);
    });

    test('partial match → same GSTIN, amount differs beyond 1% within 5%', () {
      final entry2b = make2bEntry(invoiceValue: 11800.0);
      final books = [makeBooksEntry(invoiceValue: 11300.0)]; // ~4.2% diff

      final result = Gstr2bMatchingEngine.matchSingle(
        gstr2bEntry: entry2b,
        booksEntries: books,
      );

      expect(result.matchType, MatchType.partialMatch);
      expect(result.discrepancies, contains(MatchDiscrepancy.amountMismatch));
    });

    test('partial match → same GSTIN, invoice number format differs '
        '(INV-001 vs INV001)', () {
      final entry2b = make2bEntry(invoiceNumber: 'INV-001');
      final books = [makeBooksEntry(invoiceNumber: 'INV001')];

      final result = Gstr2bMatchingEngine.matchSingle(
        gstr2bEntry: entry2b,
        booksEntries: books,
      );

      // Should match because normalized invoice numbers are equal
      expect(result.matchType, MatchType.exactMatch);
    });

    test('partial match → same GSTIN, date within 7 days', () {
      final entry2b = make2bEntry(
        invoiceNumber: 'INV-999',
        invoiceDate: DateTime(2026, 1, 15),
        invoiceValue: 50000.0,
      );
      final books = [
        makeBooksEntry(
          invoiceNumber: 'INV-888',
          invoiceDate: DateTime(2026, 1, 20),
          invoiceValue: 50000.0,
        ),
      ];

      final result = Gstr2bMatchingEngine.matchSingle(
        gstr2bEntry: entry2b,
        booksEntries: books,
      );

      expect(result.matchType, MatchType.partialMatch);
      expect(
        result.discrepancies,
        contains(MatchDiscrepancy.invoiceNumberFormat),
      );
    });

    test('unmatched in 2B → no books entry matches', () {
      final entry2b = make2bEntry(gstin: '29BBCDE1234F1Z5');
      final books = [makeBooksEntry(gstin: '27AABCU9603R1ZM')];

      final result = Gstr2bMatchingEngine.matchSingle(
        gstr2bEntry: entry2b,
        booksEntries: books,
      );

      expect(result.matchType, MatchType.unmatchedIn2b);
      expect(result.booksEntry, isNull);
    });

    test('unmatched in 2B → empty books list', () {
      final entry2b = make2bEntry();

      final result = Gstr2bMatchingEngine.matchSingle(
        gstr2bEntry: entry2b,
        booksEntries: const [],
      );

      expect(result.matchType, MatchType.unmatchedIn2b);
    });
  });

  // ── reconcile ───────────────────────────────────────────────────────

  group('Gstr2bMatchingEngine.reconcile', () {
    test('empty inputs → empty results with zero totals', () {
      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: const [],
        booksEntries: const [],
      );

      expect(result.exactMatches, isEmpty);
      expect(result.partialMatches, isEmpty);
      expect(result.unmatchedIn2b, isEmpty);
      expect(result.unmatchedInBooks, isEmpty);
      expect(result.totalItcIn2b, 0.0);
      expect(result.totalItcInBooks, 0.0);
      expect(result.reconciledItc, 0.0);
      expect(result.unreconciledItc, 0.0);
      expect(result.matchRate, 0.0);
    });

    test('all exact matches → 100% match rate', () {
      final entries2b = [
        make2bEntry(invoiceNumber: 'INV-001', igst: 1800.0),
        make2bEntry(invoiceNumber: 'INV-002', igst: 900.0),
      ];
      final books = [
        makeBooksEntry(invoiceNumber: 'INV-001', igst: 1800.0),
        makeBooksEntry(invoiceNumber: 'INV-002', igst: 900.0),
      ];

      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: entries2b,
        booksEntries: books,
      );

      expect(result.exactMatches.length, 2);
      expect(result.partialMatches, isEmpty);
      expect(result.unmatchedIn2b, isEmpty);
      expect(result.unmatchedInBooks, isEmpty);
      expect(result.matchRate, 100.0);
    });

    test('mix of match types → correct categorization', () {
      final entries2b = [
        make2bEntry(invoiceNumber: 'INV-001'), // exact
        make2bEntry(
          invoiceNumber: 'INV-002',
          invoiceValue: 25000.0,
        ), // partial (amount diff)
        make2bEntry(
          invoiceNumber: 'INV-003',
          gstin: '29XYZAB1234C1D2',
        ), // unmatched
      ];
      final books = [
        makeBooksEntry(invoiceNumber: 'INV-001'), // exact
        makeBooksEntry(
          invoiceNumber: 'INV-002',
          invoiceValue: 24000.0,
        ), // partial
        makeBooksEntry(invoiceNumber: 'INV-004'), // unmatched in books
      ];

      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: entries2b,
        booksEntries: books,
      );

      expect(result.exactMatches.length, 1);
      expect(result.partialMatches.length, 1);
      expect(result.unmatchedIn2b.length, 1);
      expect(result.unmatchedInBooks.length, 1);
    });

    test('unmatched in books → books entries with no 2B match', () {
      final entries2b = <Gstr2bEntry>[];
      final books = [
        makeBooksEntry(invoiceNumber: 'INV-001'),
        makeBooksEntry(invoiceNumber: 'INV-002'),
      ];

      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: entries2b,
        booksEntries: books,
      );

      expect(result.unmatchedInBooks.length, 2);
      expect(result.matchRate, 0.0);
    });

    test('ITC computation → totalItcIn2b sums IGST+CGST+SGST from 2B', () {
      final entries2b = [
        make2bEntry(invoiceNumber: 'INV-001', igst: 1800.0, cgst: 0, sgst: 0),
        make2bEntry(invoiceNumber: 'INV-002', igst: 0, cgst: 900.0, sgst: 900),
      ];
      final books = [
        makeBooksEntry(invoiceNumber: 'INV-001'),
        makeBooksEntry(invoiceNumber: 'INV-002'),
      ];

      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: entries2b,
        booksEntries: books,
      );

      expect(result.totalItcIn2b, 3600.0); // 1800 + 900 + 900
    });

    test('reconciledItc → sum of ITC from exact matches only', () {
      final entries2b = [
        make2bEntry(invoiceNumber: 'INV-001', igst: 1800.0),
        make2bEntry(
          invoiceNumber: 'INV-002',
          igst: 900.0,
          invoiceValue: 25000.0,
        ), // partial
      ];
      final books = [
        makeBooksEntry(invoiceNumber: 'INV-001', igst: 1800.0),
        makeBooksEntry(
          invoiceNumber: 'INV-002',
          igst: 900.0,
          invoiceValue: 24000.0,
        ),
      ];

      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: entries2b,
        booksEntries: books,
      );

      expect(result.reconciledItc, 1800.0); // only exact match ITC
    });

    test('matchRate → (exact matches / total 2B entries) * 100', () {
      final entries2b = [
        make2bEntry(invoiceNumber: 'INV-001'),
        make2bEntry(invoiceNumber: 'INV-002', gstin: '29XYZAB1234C1D2'),
        make2bEntry(invoiceNumber: 'INV-003', gstin: '06ABCDE1234F1G5'),
        make2bEntry(invoiceNumber: 'INV-004'),
      ];
      final books = [
        makeBooksEntry(invoiceNumber: 'INV-001'),
        makeBooksEntry(invoiceNumber: 'INV-004'),
      ];

      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: entries2b,
        booksEntries: books,
      );

      expect(result.exactMatches.length, 2);
      expect(result.matchRate, 50.0);
    });

    test('custom tolerance → 2% tolerance applied to exact matching', () {
      final entry2b = make2bEntry(invoiceValue: 10000.0);
      // 1.5% difference — outside default 1% but within 2%
      final books = [makeBooksEntry(invoiceValue: 9850.0)];

      final result = Gstr2bMatchingEngine.reconcile(
        gstr2bEntries: [entry2b],
        booksEntries: books,
        tolerancePercent: 2.0,
      );

      expect(result.exactMatches.length, 1);
    });
  });
}
