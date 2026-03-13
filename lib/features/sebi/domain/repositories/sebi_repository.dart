import 'package:ca_app/features/sebi/domain/models/sebi_compliance_data.dart';

/// Repository interface for SEBI compliance data access.
abstract class SebiRepository {
  /// Insert a new SEBI compliance record and return the generated row ID.
  Future<String> insert(SebiComplianceData compliance);

  /// Get all SEBI compliance records for a specific client.
  Future<List<SebiComplianceData>> getByClient(String clientId);

  /// Get SEBI records filtered by compliance type.
  Future<List<SebiComplianceData>> getByType(SebiType complianceType);

  /// Get SEBI records that are overdue (past due date and not yet filed).
  Future<List<SebiComplianceData>> getOverdue();

  /// Update the status of a compliance record and return true on success.
  Future<bool> updateStatus(String id, String status);
}
