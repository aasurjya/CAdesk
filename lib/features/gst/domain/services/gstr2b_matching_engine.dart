import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';

/// Static service for GSTR-2B reconciliation — matches portal entries
/// against books of accounts to identify discrepancies.
class Gstr2bMatchingEngine {
  Gstr2bMatchingEngine._();

  /// Reconcile a full set of GSTR-2B entries against books entries.
  ///
  /// [tolerancePercent] controls how close amounts must be for an exact match
  /// (default 1%). Partial matches use a 5% threshold.
  static Gstr2bReconciliationResult reconcile({
    required List<Gstr2bEntry> gstr2bEntries,
    required List<BooksPurchaseEntry> booksEntries,
    double tolerancePercent = 1.0,
  }) {
    if (gstr2bEntries.isEmpty && booksEntries.isEmpty) {
      return const Gstr2bReconciliationResult(
        exactMatches: [],
        partialMatches: [],
        unmatchedIn2b: [],
        unmatchedInBooks: [],
        totalItcIn2b: 0.0,
        totalItcInBooks: 0.0,
        reconciledItc: 0.0,
        unreconciledItc: 0.0,
        matchRate: 0.0,
      );
    }

    final matchedBooksIndices = <int>{};
    final exactMatches = <MatchResult>[];
    final partialMatches = <MatchResult>[];
    final unmatchedIn2b = <MatchResult>[];

    for (final entry2b in gstr2bEntries) {
      final result = _matchAgainstBooks(
        gstr2bEntry: entry2b,
        booksEntries: booksEntries,
        matchedIndices: matchedBooksIndices,
        tolerancePercent: tolerancePercent,
      );

      switch (result.matchType) {
        case MatchType.exactMatch:
          exactMatches.add(result);
        case MatchType.partialMatch:
          partialMatches.add(result);
        case MatchType.unmatchedIn2b:
          unmatchedIn2b.add(result);
        case MatchType.unmatchedInBooks:
          break; // Cannot happen from this direction
      }
    }

    // Books entries not matched to any 2B entry.
    final unmatchedInBooks = <MatchResult>[];
    for (var i = 0; i < booksEntries.length; i++) {
      if (!matchedBooksIndices.contains(i)) {
        unmatchedInBooks.add(
          MatchResult(
            gstr2bEntry: null,
            booksEntry: booksEntries[i],
            matchType: MatchType.unmatchedInBooks,
            discrepancies: const [],
            suggestedAction: 'Verify if supplier has filed',
          ),
        );
      }
    }

    // Compute ITC totals.
    final totalItcIn2b = gstr2bEntries.fold<double>(
      0.0,
      (sum, e) => sum + e.totalItc,
    );
    final totalItcInBooks = booksEntries.fold<double>(
      0.0,
      (sum, e) => sum + e.totalItc,
    );
    final reconciledItc = exactMatches.fold<double>(
      0.0,
      (sum, m) => sum + (m.gstr2bEntry?.totalItc ?? 0.0),
    );
    final unreconciledItc = totalItcIn2b - reconciledItc;

    final matchRate = gstr2bEntries.isEmpty
        ? 0.0
        : (exactMatches.length / gstr2bEntries.length) * 100.0;

    return Gstr2bReconciliationResult(
      exactMatches: exactMatches,
      partialMatches: partialMatches,
      unmatchedIn2b: unmatchedIn2b,
      unmatchedInBooks: unmatchedInBooks,
      totalItcIn2b: totalItcIn2b,
      totalItcInBooks: totalItcInBooks,
      reconciledItc: reconciledItc,
      unreconciledItc: unreconciledItc,
      matchRate: matchRate,
    );
  }

  /// Match a single GSTR-2B entry against a list of books entries.
  static MatchResult matchSingle({
    required Gstr2bEntry gstr2bEntry,
    required List<BooksPurchaseEntry> booksEntries,
    double tolerancePercent = 1.0,
  }) {
    return _matchAgainstBooks(
      gstr2bEntry: gstr2bEntry,
      booksEntries: booksEntries,
      matchedIndices: null,
      tolerancePercent: tolerancePercent,
    );
  }

  /// Internal matching logic for a single 2B entry.
  ///
  /// If [matchedIndices] is provided, matched books entries are tracked
  /// and skipped in subsequent calls (used during full reconciliation).
  static MatchResult _matchAgainstBooks({
    required Gstr2bEntry gstr2bEntry,
    required List<BooksPurchaseEntry> booksEntries,
    required Set<int>? matchedIndices,
    required double tolerancePercent,
  }) {
    final norm2b = _normalizeInvoiceNumber(gstr2bEntry.invoiceNumber);

    for (var i = 0; i < booksEntries.length; i++) {
      if (matchedIndices != null && matchedIndices.contains(i)) {
        continue;
      }

      final books = booksEntries[i];
      if (books.supplierGstin != gstr2bEntry.supplierGstin) {
        continue;
      }

      final normBooks = _normalizeInvoiceNumber(books.invoiceNumber);
      final invoiceNumberMatch = norm2b == normBooks;
      final amountWithinTolerance = _isAmountWithinTolerance(
        gstr2bEntry.invoiceValue,
        books.invoiceValue,
        tolerancePercent,
      );

      // Exact match: normalized invoice number matches + amount within
      // tolerance.
      if (invoiceNumberMatch && amountWithinTolerance) {
        matchedIndices?.add(i);
        return MatchResult(
          gstr2bEntry: gstr2bEntry,
          booksEntry: books,
          matchType: MatchType.exactMatch,
          discrepancies: const [],
          suggestedAction: 'No action needed',
        );
      }

      // Partial match criteria: same GSTIN + (fuzzy invoice number OR
      // amount within 5% OR date within 7 days).
      final amountWithin5 = _isAmountWithinTolerance(
        gstr2bEntry.invoiceValue,
        books.invoiceValue,
        5.0,
      );
      final dateWithin7Days =
          gstr2bEntry.invoiceDate.difference(books.invoiceDate).inDays.abs() <=
          7;

      if (invoiceNumberMatch || amountWithin5 || dateWithin7Days) {
        final discrepancies = <MatchDiscrepancy>[];

        if (!amountWithinTolerance) {
          discrepancies.add(MatchDiscrepancy.amountMismatch);
        }
        if (!invoiceNumberMatch) {
          discrepancies.add(MatchDiscrepancy.invoiceNumberFormat);
        }
        if (gstr2bEntry.invoiceDate != books.invoiceDate) {
          discrepancies.add(MatchDiscrepancy.dateMismatch);
        }

        matchedIndices?.add(i);
        return MatchResult(
          gstr2bEntry: gstr2bEntry,
          booksEntry: books,
          matchType: MatchType.partialMatch,
          discrepancies: discrepancies,
          suggestedAction: 'Review discrepancies and reconcile',
        );
      }
    }

    // No match found.
    return MatchResult(
      gstr2bEntry: gstr2bEntry,
      booksEntry: null,
      matchType: MatchType.unmatchedIn2b,
      discrepancies: const [],
      suggestedAction: 'Record purchase in books',
    );
  }

  /// Normalize an invoice number for comparison by stripping hyphens,
  /// slashes, spaces, and leading zeros, then uppercasing.
  static String _normalizeInvoiceNumber(String invoiceNumber) {
    final stripped = invoiceNumber
        .replaceAll(RegExp(r'[-/\s]'), '')
        .toUpperCase();
    // Remove leading zeros from any numeric segments.
    return stripped.replaceAllMapped(RegExp(r'(?<=\D)0+(?=\d)'), (m) => '');
  }

  /// Check if two amounts are within a given tolerance percentage.
  static bool _isAmountWithinTolerance(
    double a,
    double b,
    double tolerancePercent,
  ) {
    if (a == 0 && b == 0) return true;
    final maxVal = a.abs() > b.abs() ? a.abs() : b.abs();
    if (maxVal == 0) return true;
    final diff = (a - b).abs();
    return (diff / maxVal) * 100.0 <= tolerancePercent;
  }
}
