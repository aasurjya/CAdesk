import 'package:ca_app/features/renewal_expiry/domain/models/renewal_item.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/retainer_contract.dart';

/// Abstract contract for renewal and expiry tracking data operations.
///
/// Covers renewal items and retainer contracts.
abstract class RenewalExpiryRepository {
  // ---------------------------------------------------------------------------
  // RenewalItem
  // ---------------------------------------------------------------------------

  /// Returns all renewal items.
  Future<List<RenewalItem>> getRenewalItems();

  /// Returns the renewal item for [id], or null if not found.
  Future<RenewalItem?> getRenewalItemById(String id);

  /// Returns all renewal items for [clientId].
  Future<List<RenewalItem>> getRenewalItemsByClient(String clientId);

  /// Returns all renewal items matching [status].
  Future<List<RenewalItem>> getRenewalItemsByStatus(RenewalStatus status);

  /// Inserts a new [RenewalItem] and returns its ID.
  Future<String> insertRenewalItem(RenewalItem item);

  /// Updates an existing [RenewalItem]. Returns true on success.
  Future<bool> updateRenewalItem(RenewalItem item);

  /// Deletes the renewal item identified by [id]. Returns true on success.
  Future<bool> deleteRenewalItem(String id);

  // ---------------------------------------------------------------------------
  // RetainerContract
  // ---------------------------------------------------------------------------

  /// Returns all retainer contracts.
  Future<List<RetainerContract>> getRetainerContracts();

  /// Returns the retainer contract for [id], or null if not found.
  Future<RetainerContract?> getRetainerContractById(String id);

  /// Returns all retainer contracts for [clientId].
  Future<List<RetainerContract>> getRetainerContractsByClient(String clientId);

  /// Inserts a new [RetainerContract] and returns its ID.
  Future<String> insertRetainerContract(RetainerContract contract);

  /// Updates an existing [RetainerContract]. Returns true on success.
  Future<bool> updateRetainerContract(RetainerContract contract);

  /// Deletes the retainer contract identified by [id]. Returns true on success.
  Future<bool> deleteRetainerContract(String id);
}
