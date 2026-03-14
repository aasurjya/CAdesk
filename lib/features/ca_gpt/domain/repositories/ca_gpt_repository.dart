import 'package:ca_app/features/ca_gpt/domain/models/tax_query.dart';

/// Abstract contract for CA GPT data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class CaGptRepository {
  /// Retrieve all tax queries.
  Future<List<TaxQuery>> getAllQueries();

  /// Retrieve a single [TaxQuery] by [queryId]. Returns null if not found.
  Future<TaxQuery?> getQueryById(String queryId);

  /// Retrieve all tax queries of a specific [queryType].
  Future<List<TaxQuery>> getQueriesByType(QueryType queryType);

  /// Insert a new [TaxQuery] and return its ID.
  Future<String> insertQuery(TaxQuery query);

  /// Update an existing [TaxQuery]. Returns true on success.
  Future<bool> updateQuery(TaxQuery query);

  /// Delete the tax query identified by [queryId]. Returns true on success.
  Future<bool> deleteQuery(String queryId);
}
