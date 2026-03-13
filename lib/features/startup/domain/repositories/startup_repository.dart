import 'package:ca_app/features/startup/domain/models/startup_record.dart';

/// Repository interface for Startup India registration data access.
abstract class StartupRepository {
  /// Insert a new startup record and return the generated row ID.
  Future<String> insert(StartupRecord record);

  /// Get all startup records for a specific client.
  Future<List<StartupRecord>> getByClient(String clientId);

  /// Update an existing startup record and return true on success.
  Future<bool> update(StartupRecord record);

  /// Get startup records filtered by recognition status.
  Future<List<StartupRecord>> getByStatus(String status);

  /// Get startup records eligible for Section 80-IAC or Section 56 exemptions.
  Future<List<StartupRecord>> getEligibleForExemptions();
}
