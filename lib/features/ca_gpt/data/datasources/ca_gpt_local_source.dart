import 'package:ca_app/features/ca_gpt/domain/models/tax_query.dart';

/// Local data source for tax queries.
///
/// Uses an in-memory cache as a fallback when Supabase is unavailable.
class CaGptLocalSource {
  CaGptLocalSource();

  final List<TaxQuery> _cache = [];

  /// Insert or replace a [TaxQuery] in the local cache.
  Future<String> insertQuery(TaxQuery query) async {
    final idx = _cache.indexWhere((q) => q.queryId == query.queryId);
    if (idx >= 0) {
      final updated = List<TaxQuery>.of(_cache)..[idx] = query;
      _cache
        ..clear()
        ..addAll(updated);
    } else {
      _cache.add(query);
    }
    return query.queryId;
  }

  /// Retrieve all cached tax queries.
  Future<List<TaxQuery>> getAll() async {
    return List.unmodifiable(_cache);
  }

  /// Retrieve a cached tax query by [queryId].
  Future<TaxQuery?> getById(String queryId) async {
    try {
      return _cache.firstWhere((q) => q.queryId == queryId);
    } catch (_) {
      return null;
    }
  }

  /// Retrieve cached queries by [queryType].
  Future<List<TaxQuery>> getByType(QueryType queryType) async {
    return List.unmodifiable(
      _cache.where((q) => q.queryType == queryType).toList(),
    );
  }

  /// Update a cached [TaxQuery].
  Future<bool> updateQuery(TaxQuery query) async {
    final idx = _cache.indexWhere((q) => q.queryId == query.queryId);
    if (idx == -1) return false;
    final updated = List<TaxQuery>.of(_cache)..[idx] = query;
    _cache
      ..clear()
      ..addAll(updated);
    return true;
  }

  /// Delete a cached tax query by [queryId].
  Future<bool> deleteQuery(String queryId) async {
    final before = _cache.length;
    _cache.removeWhere((q) => q.queryId == queryId);
    return _cache.length < before;
  }
}
