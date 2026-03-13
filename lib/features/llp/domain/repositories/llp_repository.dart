import 'package:ca_app/features/llp/domain/models/llp_filing.dart';

/// Repository interface for LLP filing data access.
abstract class LlpRepository {
  /// Insert a new LLP filing and return the generated row ID.
  Future<String> insertLlpFiling(LlpFiling filing);

  /// Get all LLP filings for a specific client.
  Future<List<LlpFiling>> getByClient(String clientId);

  /// Get LLP filings for a client filtered by financial year (e.g. "2024-25").
  Future<List<LlpFiling>> getByYear(String clientId, String year);

  /// Update the status of a filing and return true on success.
  Future<bool> updateStatus(String id, String status);

  /// Get LLP filings that are overdue (past due date and not yet filed/approved).
  Future<List<LlpFiling>> getOverdue();

  /// Get LLP filings due within [daysAhead] days from today.
  Future<List<LlpFiling>> getDue(int daysAhead);
}
