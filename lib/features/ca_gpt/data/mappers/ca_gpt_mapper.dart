import 'package:ca_app/features/ca_gpt/domain/models/tax_query.dart';

/// Bi-directional converter between [TaxQuery] domain model
/// and Supabase JSON maps.
class CaGptMapper {
  const CaGptMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → TaxQuery domain model
  // ---------------------------------------------------------------------------
  static TaxQuery fromJson(Map<String, dynamic> json) {
    return TaxQuery(
      queryId: json['query_id'] as String,
      question: json['question'] as String? ?? '',
      context: json['context'] as String?,
      queryType: _parseQueryType(json['query_type'] as String?),
      financialYear: json['financial_year'] as int?,
      pan: json['pan'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // TaxQuery domain model → JSON (Supabase insert/update)
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> toJson(TaxQuery q) {
    return {
      'query_id': q.queryId,
      'question': q.question,
      'context': q.context,
      'query_type': q.queryType.name,
      'financial_year': q.financialYear,
      'pan': q.pan,
      'timestamp': q.timestamp.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static QueryType _parseQueryType(String? raw) {
    switch (raw) {
      case 'caseSearch':
        return QueryType.caseSearch;
      case 'noticeResponse':
        return QueryType.noticeResponse;
      case 'complianceCheck':
        return QueryType.complianceCheck;
      case 'rateQuery':
        return QueryType.rateQuery;
      case 'deadlineQuery':
        return QueryType.deadlineQuery;
      case 'sectionLookup':
      default:
        return QueryType.sectionLookup;
    }
  }
}
