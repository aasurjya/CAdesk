/// Output format for a generated report.
enum ReportFormat {
  /// Tabular row-and-column layout.
  table('Table'),

  /// Visual chart (bar, line, pie).
  chart('Chart'),

  /// Aggregated summary with totals only.
  summary('Summary');

  const ReportFormat(this.label);

  final String label;
}

/// Describes the structure and parameters of a custom analytics report.
///
/// Immutable value object — create new instances via [copyWith].
class ReportDefinition {
  const ReportDefinition({
    required this.reportId,
    required this.name,
    required this.dimensions,
    required this.metrics,
    required this.filters,
    required this.sortBy,
    required this.sortAscending,
    required this.format,
  });

  /// Unique identifier for this report definition.
  final String reportId;

  /// Human-readable report name.
  final String name;

  /// Column names that group data (e.g. ["client", "service_type", "month"]).
  final List<String> dimensions;

  /// Numeric columns to aggregate (e.g. ["revenue", "hours", "filing_count"]).
  final List<String> metrics;

  /// Key-value pairs used to filter rows before aggregation.
  ///
  /// Example: `{"year": "2024", "service": "ITR"}`.
  final Map<String, String> filters;

  /// Column name to sort results by.
  final String sortBy;

  /// Whether to sort in ascending order.
  final bool sortAscending;

  /// Presentation format for this report.
  final ReportFormat format;

  ReportDefinition copyWith({
    String? reportId,
    String? name,
    List<String>? dimensions,
    List<String>? metrics,
    Map<String, String>? filters,
    String? sortBy,
    bool? sortAscending,
    ReportFormat? format,
  }) {
    return ReportDefinition(
      reportId: reportId ?? this.reportId,
      name: name ?? this.name,
      dimensions: dimensions ?? this.dimensions,
      metrics: metrics ?? this.metrics,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      format: format ?? this.format,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportDefinition &&
        other.reportId == reportId &&
        other.name == name &&
        other.sortBy == sortBy &&
        other.sortAscending == sortAscending &&
        other.format == format;
  }

  @override
  int get hashCode =>
      Object.hash(reportId, name, sortBy, sortAscending, format);
}
