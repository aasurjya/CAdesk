/// The output of a generated analytics report.
///
/// [rows] contains the filtered and sorted data; [totals] holds aggregated
/// metric sums. All monetary totals are in paise; count totals are integers.
class ReportResult {
  const ReportResult({
    required this.reportId,
    required this.generatedAt,
    required this.rows,
    required this.totals,
    required this.rowCount,
  });

  /// The report definition ID this result was generated from.
  final String reportId;

  /// Timestamp when this result was generated.
  final DateTime generatedAt;

  /// Filtered and sorted rows; each row maps column name → string value.
  final List<Map<String, String>> rows;

  /// Aggregated totals for each numeric metric column.
  ///
  /// Monetary values are in paise; count values are integers encoded as int.
  final Map<String, int> totals;

  /// Total number of rows in this result.
  final int rowCount;

  ReportResult copyWith({
    String? reportId,
    DateTime? generatedAt,
    List<Map<String, String>>? rows,
    Map<String, int>? totals,
    int? rowCount,
  }) {
    return ReportResult(
      reportId: reportId ?? this.reportId,
      generatedAt: generatedAt ?? this.generatedAt,
      rows: rows ?? this.rows,
      totals: totals ?? this.totals,
      rowCount: rowCount ?? this.rowCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportResult &&
        other.reportId == reportId &&
        other.generatedAt == generatedAt &&
        other.rowCount == rowCount;
  }

  @override
  int get hashCode => Object.hash(reportId, generatedAt, rowCount);
}
