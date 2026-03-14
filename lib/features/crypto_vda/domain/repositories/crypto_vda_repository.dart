import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

/// Abstract contract for crypto/VDA data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class CryptoVdaRepository {
  /// Insert a new [VdaTransaction] and return its generated ID.
  Future<String> insertTransaction(VdaTransaction transaction);

  /// Retrieve all VDA transactions.
  Future<List<VdaTransaction>> getAllTransactions();

  /// Retrieve transactions for a specific [clientId].
  Future<List<VdaTransaction>> getTransactionsByClient(String clientId);

  /// Update an existing [VdaTransaction]. Returns true on success.
  Future<bool> updateTransaction(VdaTransaction transaction);

  /// Delete the transaction identified by [id]. Returns true on success.
  Future<bool> deleteTransaction(String id);

  /// Retrieve the VDA tax summary for [clientId] and [assessmentYear].
  ///
  /// Returns null if no summary is found.
  Future<VdaSummary?> getSummaryByClient(
    String clientId,
    String assessmentYear,
  );

  /// Insert or replace the [VdaSummary] for a client and assessment year.
  Future<void> upsertSummary(VdaSummary summary);
}
