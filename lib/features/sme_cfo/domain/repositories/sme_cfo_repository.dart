import 'package:ca_app/features/sme_cfo/domain/models/cfo_deliverable.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_retainer.dart';

/// Abstract contract for SME CFO data operations.
///
/// Covers CFO deliverables and CFO retainers.
abstract class SmeCfoRepository {
  // ---------------------------------------------------------------------------
  // CfoDeliverable
  // ---------------------------------------------------------------------------

  /// Returns all CFO deliverables.
  Future<List<CfoDeliverable>> getDeliverables();

  /// Returns the deliverable for [id], or null if not found.
  Future<CfoDeliverable?> getDeliverableById(String id);

  /// Returns all deliverables for [retainerId].
  Future<List<CfoDeliverable>> getDeliverablesByRetainer(String retainerId);

  /// Returns all deliverables matching [status].
  Future<List<CfoDeliverable>> getDeliverablesByStatus(
    DeliverableStatus status,
  );

  /// Inserts a new [CfoDeliverable] and returns its ID.
  Future<String> insertDeliverable(CfoDeliverable deliverable);

  /// Updates an existing [CfoDeliverable]. Returns true on success.
  Future<bool> updateDeliverable(CfoDeliverable deliverable);

  /// Deletes the deliverable identified by [id]. Returns true on success.
  Future<bool> deleteDeliverable(String id);

  // ---------------------------------------------------------------------------
  // CfoRetainer
  // ---------------------------------------------------------------------------

  /// Returns all CFO retainers.
  Future<List<CfoRetainer>> getRetainers();

  /// Returns the retainer for [id], or null if not found.
  Future<CfoRetainer?> getRetainerById(String id);

  /// Returns all retainers matching [status].
  Future<List<CfoRetainer>> getRetainersByStatus(CfoRetainerStatus status);

  /// Inserts a new [CfoRetainer] and returns its ID.
  Future<String> insertRetainer(CfoRetainer retainer);

  /// Updates an existing [CfoRetainer]. Returns true on success.
  Future<bool> updateRetainer(CfoRetainer retainer);

  /// Deletes the retainer identified by [id]. Returns true on success.
  Future<bool> deleteRetainer(String id);
}
