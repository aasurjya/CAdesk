import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';

/// Abstract contract for accounts data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class AccountsRepository {
  /// Retrieve all financial statements for a given [clientId] and [financialYear].
  Future<List<FinancialStatement>> getStatementsByClient(
    String clientId,
    String financialYear,
  );

  /// Retrieve a single financial statement by [id]. Returns null if not found.
  Future<FinancialStatement?> getStatementById(String id);

  /// Insert a new [FinancialStatement] and return its ID.
  Future<String> insertStatement(FinancialStatement statement);

  /// Update an existing [FinancialStatement]. Returns true on success.
  Future<bool> updateStatement(FinancialStatement statement);

  /// Delete the financial statement identified by [id]. Returns true on success.
  Future<bool> deleteStatement(String id);

  /// Retrieve all financial statements.
  Future<List<FinancialStatement>> getAllStatements();
}
