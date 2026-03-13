import 'package:ca_app/features/analytics/domain/models/report_definition.dart';
import 'package:ca_app/features/analytics/domain/models/report_result.dart';

/// Generates custom analytics reports from structured data.
///
/// Stateless singleton — all methods are pure functions of their inputs.
class ReportEngineService {
  ReportEngineService._();

  static final ReportEngineService instance = ReportEngineService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a [ReportResult] from [definition] and raw [data].
  ///
  /// The [data] parameter is a list of string-keyed maps representing rows.
  /// Each map should contain dimension and metric columns as string values.
  ///
  /// Processing order:
  /// 1. Filter rows using [definition.filters].
  /// 2. Sort rows using [definition.sortBy] and [definition.sortAscending].
  /// 3. Compute metric totals.
  ReportResult generateReport(ReportDefinition definition, List<Object> data) {
    // Convert data to typed rows; skip entries that are not Map<String, String>.
    final allRows = data.whereType<Map<String, String>>().toList();

    final filtered = filterData(allRows, definition.filters);

    final sorted = definition.sortBy.isEmpty
        ? filtered
        : sortData(filtered, definition.sortBy, definition.sortAscending);

    final totals = computeTotals(sorted, definition.metrics);

    return ReportResult(
      reportId: definition.reportId,
      generatedAt: DateTime.now(),
      rows: List.unmodifiable(sorted),
      totals: Map.unmodifiable(totals),
      rowCount: sorted.length,
    );
  }

  /// Returns rows that match every key-value pair in [filters].
  ///
  /// Filtering is case-sensitive and applies an AND across all filter entries.
  /// Returns a new list; does not mutate [rows].
  List<Map<String, String>> filterData(
    List<Map<String, String>> rows,
    Map<String, String> filters,
  ) {
    if (filters.isEmpty) return List.of(rows);

    return rows.where((row) {
      for (final entry in filters.entries) {
        if (row[entry.key] != entry.value) return false;
      }
      return true;
    }).toList();
  }

  /// Returns a new list sorted by [sortBy], in [ascending] or descending order.
  ///
  /// Uses lexicographic (string) comparison. Rows missing [sortBy] are treated
  /// as empty string and sort to the beginning.
  /// Does not mutate [rows].
  List<Map<String, String>> sortData(
    List<Map<String, String>> rows,
    String sortBy,
    bool ascending,
  ) {
    final copy = List<Map<String, String>>.of(rows);
    copy.sort((a, b) {
      final aVal = a[sortBy] ?? '';
      final bVal = b[sortBy] ?? '';
      return ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });
    return copy;
  }

  /// Sums each metric column across [rows] and returns a map of metric → total.
  ///
  /// Values are parsed as integers; unparseable values are treated as 0.
  /// Returns a new map with an entry for every metric in [metrics], even if
  /// that column is absent from every row.
  Map<String, int> computeTotals(
    List<Map<String, String>> rows,
    List<String> metrics,
  ) {
    final result = <String, int>{};
    for (final metric in metrics) {
      var total = 0;
      for (final row in rows) {
        total += int.tryParse(row[metric] ?? '') ?? 0;
      }
      result[metric] = total;
    }
    return result;
  }
}
