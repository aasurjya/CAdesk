import 'package:ca_app/features/msme/domain/models/msme_record.dart';

/// Repository interface for MSME registration data access.
abstract class MsmeRepository {
  /// Insert a new MSME record and return the generated row ID.
  Future<String> insert(MsmeRecord record);

  /// Get all MSME records for a specific client.
  Future<List<MsmeRecord>> getByClient(String clientId);

  /// Update an existing MSME record and return true on success.
  Future<bool> update(MsmeRecord record);

  /// Get MSME records filtered by enterprise category.
  Future<List<MsmeRecord>> getByCategory(MsmeCategory category);

  /// Get MSME records filtered by status string.
  Future<List<MsmeRecord>> getByStatus(String status);
}
