import 'package:ca_app/features/industry_playbooks/domain/models/vertical_playbook.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/service_bundle.dart';

/// Abstract contract for industry playbooks data operations.
///
/// Covers industry-vertical playbooks and their associated service bundles.
abstract class IndustryPlaybooksRepository {
  // -------------------------------------------------------------------------
  // VerticalPlaybook operations
  // -------------------------------------------------------------------------

  /// Retrieve all vertical playbooks.
  Future<List<VerticalPlaybook>> getPlaybooks();

  /// Retrieve a single playbook by [id]. Returns null if not found.
  Future<VerticalPlaybook?> getPlaybookById(String id);

  /// Search playbooks by [query] (matched against vertical name and description).
  Future<List<VerticalPlaybook>> searchPlaybooks(String query);

  /// Insert a new [VerticalPlaybook] and return its ID.
  Future<String> insertPlaybook(VerticalPlaybook playbook);

  /// Update an existing [VerticalPlaybook]. Returns true on success.
  Future<bool> updatePlaybook(VerticalPlaybook playbook);

  /// Delete the playbook identified by [id]. Returns true on success.
  Future<bool> deletePlaybook(String id);

  // -------------------------------------------------------------------------
  // ServiceBundle operations
  // -------------------------------------------------------------------------

  /// Retrieve service bundles for a specific [verticalId].
  Future<List<ServiceBundle>> getBundlesByVertical(String verticalId);

  /// Insert a new [ServiceBundle] and return its ID.
  Future<String> insertBundle(ServiceBundle bundle);

  /// Update an existing [ServiceBundle]. Returns true on success.
  Future<bool> updateBundle(ServiceBundle bundle);

  /// Delete the service bundle identified by [id]. Returns true on success.
  Future<bool> deleteBundle(String id);
}
