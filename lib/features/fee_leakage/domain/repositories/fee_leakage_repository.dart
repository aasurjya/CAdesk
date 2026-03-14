import 'package:ca_app/features/fee_leakage/domain/models/engagement.dart';
import 'package:ca_app/features/fee_leakage/domain/models/scope_item.dart';

/// Abstract contract for fee leakage data operations.
///
/// Covers client engagements (fee tracking) and scope items (scope creep).
abstract class FeeLeakageRepository {
  // -------------------------------------------------------------------------
  // Engagement operations
  // -------------------------------------------------------------------------

  /// Retrieve all engagements.
  Future<List<Engagement>> getEngagements();

  /// Retrieve engagements for a specific [clientId].
  Future<List<Engagement>> getEngagementsByClient(String clientId);

  /// Retrieve engagements filtered by [status].
  Future<List<Engagement>> getEngagementsByStatus(EngagementStatus status);

  /// Insert a new [Engagement] and return its ID.
  Future<String> insertEngagement(Engagement engagement);

  /// Update an existing [Engagement]. Returns true on success.
  Future<bool> updateEngagement(Engagement engagement);

  /// Delete the engagement identified by [id]. Returns true on success.
  Future<bool> deleteEngagement(String id);

  // -------------------------------------------------------------------------
  // ScopeItem operations
  // -------------------------------------------------------------------------

  /// Retrieve all scope items.
  Future<List<ScopeItem>> getScopeItems();

  /// Retrieve scope items for a specific [engagementId].
  Future<List<ScopeItem>> getScopeItemsByEngagement(String engagementId);

  /// Insert a new [ScopeItem] and return its ID.
  Future<String> insertScopeItem(ScopeItem item);

  /// Update an existing [ScopeItem]. Returns true on success.
  Future<bool> updateScopeItem(ScopeItem item);

  /// Delete the scope item identified by [id]. Returns true on success.
  Future<bool> deleteScopeItem(String id);
}
