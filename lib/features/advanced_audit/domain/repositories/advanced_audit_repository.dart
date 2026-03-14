import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';

/// Abstract contract for advanced audit data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class AdvancedAuditRepository {
  /// Retrieve all audit engagements for a given [clientId].
  Future<List<AuditEngagement>> getEngagementsByClient(String clientId);

  /// Retrieve a single audit engagement by [id]. Returns null if not found.
  Future<AuditEngagement?> getEngagementById(String id);

  /// Insert a new [AuditEngagement] and return its ID.
  Future<String> insertEngagement(AuditEngagement engagement);

  /// Update an existing [AuditEngagement]. Returns true on success.
  Future<bool> updateEngagement(AuditEngagement engagement);

  /// Delete the audit engagement identified by [id]. Returns true on success.
  Future<bool> deleteEngagement(String id);

  /// Retrieve all audit engagements.
  Future<List<AuditEngagement>> getAllEngagements();
}
