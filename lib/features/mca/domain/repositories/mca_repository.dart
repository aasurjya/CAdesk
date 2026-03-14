import 'package:ca_app/features/mca/domain/models/mca_filing_data.dart';

/// Repository interface for MCA/ROC filing data access.
abstract class McaRepository {
  /// Insert a new MCA filing and return the generated row ID.
  Future<String> insertMCAFiling(McaFilingData filing);

  /// Get all MCA filings for a specific client.
  Future<List<McaFilingData>> getMCAFilingsByClient(String clientId);

  /// Get MCA filings for a client filtered by financial year (e.g. "2024-25").
  Future<List<McaFilingData>> getMCAFilingsByYear(String clientId, String year);

  /// Update an existing MCA filing and return true on success.
  Future<bool> updateMCAFiling(McaFilingData filing);

  /// Get MCA filings filtered by status string (e.g. 'pending', 'filed').
  Future<List<McaFilingData>> getMCAFilingsByStatus(String status);

  /// Get MCA filings whose due date falls within [daysAhead] days from today.
  Future<List<McaFilingData>> getDueMCAFilings(int daysAhead);

  /// Get a single MCA filing by its ID, or null if not found.
  Future<McaFilingData?> getMCAFilingById(String id);

  /// Watch MCA filings for a client (real-time stream via Drift).
  Stream<List<McaFilingData>> watchMCAFilingsByClient(String clientId);
}
