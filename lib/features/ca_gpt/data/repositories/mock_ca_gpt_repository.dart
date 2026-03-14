import 'package:ca_app/features/ca_gpt/domain/models/tax_query.dart';
import 'package:ca_app/features/ca_gpt/domain/repositories/ca_gpt_repository.dart';

/// In-memory mock implementation of [CaGptRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations use immutable patterns.
class MockCaGptRepository implements CaGptRepository {
  static final List<TaxQuery> _seed = [
    TaxQuery(
      queryId: 'mock-query-001',
      question:
          'What is the applicability of Section 44AD for a proprietorship '
          'with turnover of ₹1.2 crore in FY 2024-25?',
      queryType: QueryType.sectionLookup,
      timestamp: DateTime(2026, 3, 1, 9, 30),
      context: 'Client is a sole proprietor with retail trading business.',
      financialYear: 2024,
      pan: 'ABCDE1234F',
    ),
    TaxQuery(
      queryId: 'mock-query-002',
      question:
          'How should we respond to a notice under Section 143(1) for '
          'mismatch in 26AS data?',
      queryType: QueryType.noticeResponse,
      timestamp: DateTime(2026, 3, 5, 14, 15),
      context: 'Notice received for AY 2023-24 with ₹45,000 discrepancy.',
      financialYear: 2022,
    ),
    TaxQuery(
      queryId: 'mock-query-003',
      question:
          'What is the GST rate applicable on restaurant services '
          'provided through Swiggy/Zomato?',
      queryType: QueryType.rateQuery,
      timestamp: DateTime(2026, 3, 8, 11, 0),
      context: 'Restaurant client registered as regular taxpayer.',
      financialYear: 2024,
    ),
  ];

  final List<TaxQuery> _state = List.of(_seed);

  @override
  Future<List<TaxQuery>> getAllQueries() async {
    return List.unmodifiable(_state);
  }

  @override
  Future<TaxQuery?> getQueryById(String queryId) async {
    try {
      return _state.firstWhere((q) => q.queryId == queryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TaxQuery>> getQueriesByType(QueryType queryType) async {
    return List.unmodifiable(
      _state.where((q) => q.queryType == queryType).toList(),
    );
  }

  @override
  Future<String> insertQuery(TaxQuery query) async {
    _state.add(query);
    return query.queryId;
  }

  @override
  Future<bool> updateQuery(TaxQuery query) async {
    final idx = _state.indexWhere((q) => q.queryId == query.queryId);
    if (idx == -1) return false;
    final updated = List<TaxQuery>.of(_state)..[idx] = query;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteQuery(String queryId) async {
    final before = _state.length;
    _state.removeWhere((q) => q.queryId == queryId);
    return _state.length < before;
  }
}
