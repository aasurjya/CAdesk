import '../models/pan_tds_consolidation.dart';
import 'three_way_reconciliation_service.dart' show Form26AsData, Form26AsEntry;

/// Stateless service for consolidating PAN-level TDS data from Form 26AS.
///
/// Groups TDS entries by deductor (TAN), aggregates totals, and identifies
/// short-credit situations where a deductor has deducted TDS from the
/// assessee's income but has not deposited it against the correct PAN.
///
/// ### Short-Credit Scenario
/// A "short credit" occurs when:
/// - The deductor filed the TDS return with a wrong PAN, OR
/// - The deductor deducted TDS but never deposited it to the government.
///
/// Resolution: The assessee must request the deductor to file a
/// correction statement (revised TDS return) with the correct PAN.
///
/// ### Usage
/// ```dart
/// final consolidation = PanTdsConsolidationService.instance.consolidate(
///   form26asData, 'ABCDE1234F', '2025-26',
/// );
/// final shorts = PanTdsConsolidationService.instance.detectShortCredits(consolidation);
/// ```
class PanTdsConsolidationService {
  PanTdsConsolidationService._();

  static final PanTdsConsolidationService instance =
      PanTdsConsolidationService._();

  /// Consolidates Form 26AS data into a [PanTdsConsolidation] for [pan].
  ///
  /// Groups all entries by deductor TAN, then computes totals across all
  /// deductors for this PAN.
  PanTdsConsolidation consolidate(
    Form26AsData form26as,
    String pan,
    String assessmentYear,
  ) {
    final grouped = groupByDeductor(form26as);
    final summaries = grouped.values.toList();

    var totalTdsDeducted = 0;
    var totalTdsCredited = 0;

    for (final s in summaries) {
      totalTdsDeducted += s.totalTdsDeducted;
      totalTdsCredited += s.totalTdsCredited;
    }

    return PanTdsConsolidation(
      pan: pan,
      assessmentYear: assessmentYear,
      deductorWiseSummary: summaries,
      totalIncome: form26as.totalIncome,
      totalTdsDeducted: totalTdsDeducted,
      totalTdsCredited: totalTdsCredited,
      shortfall: totalTdsDeducted - totalTdsCredited,
    );
  }

  /// Groups Form 26AS entries by deductor TAN and aggregates amounts.
  ///
  /// Returns a map of TAN → [DeductorTdsSummary].
  Map<String, DeductorTdsSummary> groupByDeductor(Form26AsData data) {
    final map = <String, _MutableSummary>{};

    for (final entry in data.entries) {
      final existing = map[entry.deductorTan];
      if (existing == null) {
        map[entry.deductorTan] = _MutableSummary(
          deductorName: entry.deductorName,
          deductorTan: entry.deductorTan,
          totalGrossAmount: entry.grossAmount,
          totalTdsDeducted: entry.tdsDeducted,
          totalTdsCredited: entry.tdsCredited,
        );
      } else {
        map[entry.deductorTan] = existing.add(entry);
      }
    }

    return map.map(
      (tan, s) => MapEntry(
        tan,
        DeductorTdsSummary(
          deductorName: s.deductorName,
          deductorTan: s.deductorTan,
          totalGrossAmount: s.totalGrossAmount,
          totalTdsDeducted: s.totalTdsDeducted,
          totalTdsCredited: s.totalTdsCredited,
        ),
      ),
    );
  }

  /// Identifies deductors who have not fully credited TDS for this PAN.
  ///
  /// Returns a list of [ShortCreditItem]s — one per deductor with a non-zero
  /// credit shortfall (deducted > credited).
  List<ShortCreditItem> detectShortCredits(PanTdsConsolidation consolidation) {
    return consolidation.deductorWiseSummary
        .where((d) => d.creditShortfall > 0)
        .map(
          (d) => ShortCreditItem(
            deductorName: d.deductorName,
            deductorTan: d.deductorTan,
            shortfallAmount: d.creditShortfall,
          ),
        )
        .toList();
  }

  /// Returns the total TDS credit available for this PAN.
  ///
  /// This is [PanTdsConsolidation.totalTdsCredited] — the amount the assessee
  /// can claim as tax credit when filing their return.
  int computeTotalTaxCredit(PanTdsConsolidation consolidation) =>
      consolidation.totalTdsCredited;
}

// ---------------------------------------------------------------------------
// Private mutable accumulator — only used inside groupByDeductor.
// Dart does not have built-in record mutation, so we use a small private class.
// ---------------------------------------------------------------------------

class _MutableSummary {
  _MutableSummary({
    required this.deductorName,
    required this.deductorTan,
    required this.totalGrossAmount,
    required this.totalTdsDeducted,
    required this.totalTdsCredited,
  });

  final String deductorName;
  final String deductorTan;
  final int totalGrossAmount;
  final int totalTdsDeducted;
  final int totalTdsCredited;

  /// Returns a new [_MutableSummary] with this [entry]'s amounts added.
  _MutableSummary add(Form26AsEntry entry) => _MutableSummary(
    deductorName: deductorName,
    deductorTan: deductorTan,
    totalGrossAmount: totalGrossAmount + entry.grossAmount,
    totalTdsDeducted: totalTdsDeducted + entry.tdsDeducted,
    totalTdsCredited: totalTdsCredited + entry.tdsCredited,
  );
}
