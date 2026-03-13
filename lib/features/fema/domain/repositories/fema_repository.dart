import 'package:ca_app/features/fema/domain/models/fema_filing_data.dart';

/// Repository interface for FEMA filing data access.
abstract class FemaRepository {
  /// Insert a new FEMA filing and return the generated row ID.
  Future<String> insert(FemaFilingData filing);

  /// Get all FEMA filings for a specific client.
  Future<List<FemaFilingData>> getByClient(String clientId);

  /// Get FEMA filings filtered by filing type.
  Future<List<FemaFilingData>> getByType(FemaType filingType);

  /// Update the status of a filing and return true on success.
  Future<bool> updateStatus(String id, String status);

  /// Get FEMA filings whose transaction date falls within the given year.
  Future<List<FemaFilingData>> getByYear(String clientId, int year);
}
