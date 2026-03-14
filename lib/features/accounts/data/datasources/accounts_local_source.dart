import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';

/// Local data source for financial statements.
///
/// Uses an in-memory cache as a fallback when Supabase is unavailable.
/// Replace with a Drift DAO once the accounts table is added to AppDatabase.
class AccountsLocalSource {
  AccountsLocalSource();

  final List<FinancialStatement> _cache = [];

  /// Insert or replace a [FinancialStatement] in the local cache.
  Future<String> insertStatement(FinancialStatement statement) async {
    final idx = _cache.indexWhere((s) => s.id == statement.id);
    if (idx >= 0) {
      final updated = List<FinancialStatement>.of(_cache)..[idx] = statement;
      _cache
        ..clear()
        ..addAll(updated);
    } else {
      _cache.add(statement);
    }
    return statement.id;
  }

  /// Retrieve all cached statements for [clientId] and [financialYear].
  Future<List<FinancialStatement>> getByClient(
    String clientId,
    String financialYear,
  ) async {
    return List.unmodifiable(
      _cache
          .where(
            (s) => s.clientId == clientId && s.financialYear == financialYear,
          )
          .toList(),
    );
  }

  /// Retrieve a cached statement by [id].
  Future<FinancialStatement?> getById(String id) async {
    try {
      return _cache.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retrieve all cached statements.
  Future<List<FinancialStatement>> getAll() async {
    return List.unmodifiable(_cache);
  }

  /// Update a cached [FinancialStatement].
  Future<bool> updateStatement(FinancialStatement statement) async {
    final idx = _cache.indexWhere((s) => s.id == statement.id);
    if (idx == -1) return false;
    final updated = List<FinancialStatement>.of(_cache)..[idx] = statement;
    _cache
      ..clear()
      ..addAll(updated);
    return true;
  }

  /// Delete a cached statement by [id].
  Future<bool> deleteStatement(String id) async {
    final before = _cache.length;
    _cache.removeWhere((s) => s.id == id);
    return _cache.length < before;
  }
}
