/// The nature of a tax question submitted to CA GPT.
enum QueryType {
  sectionLookup,
  caseSearch,
  noticeResponse,
  complianceCheck,
  rateQuery,
  deadlineQuery,
}

/// An immutable tax query submitted by the CA to the knowledge engine.
///
/// Use [copyWith] to derive a modified copy without mutating the original.
class TaxQuery {
  const TaxQuery({
    required this.queryId,
    required this.question,
    required this.queryType,
    required this.timestamp,
    this.context,
    this.financialYear,
    this.pan,
  });

  final String queryId;
  final String question;

  /// Optional client-specific context, e.g. "Client is a sole proprietor with
  /// turnover of ₹1.2 crore in FY 2024-25."
  final String? context;

  final QueryType queryType;

  /// Financial year as the starting calendar year, e.g. 2024 for FY 2024-25.
  final int? financialYear;

  final String? pan;
  final DateTime timestamp;

  TaxQuery copyWith({
    String? queryId,
    String? question,
    String? context,
    QueryType? queryType,
    int? financialYear,
    String? pan,
    DateTime? timestamp,
  }) {
    return TaxQuery(
      queryId: queryId ?? this.queryId,
      question: question ?? this.question,
      context: context ?? this.context,
      queryType: queryType ?? this.queryType,
      financialYear: financialYear ?? this.financialYear,
      pan: pan ?? this.pan,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxQuery &&
        other.queryId == queryId &&
        other.question == question &&
        other.context == context &&
        other.queryType == queryType &&
        other.financialYear == financialYear &&
        other.pan == pan &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(
    queryId,
    question,
    context,
    queryType,
    financialYear,
    pan,
    timestamp,
  );
}
