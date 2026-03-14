import 'package:ca_app/features/regulatory_intelligence/domain/models/client_impact_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/compliance_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_circular.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_update.dart';

/// Abstract contract for regulatory intelligence data operations.
///
/// Covers regulatory updates, compliance alerts, regulatory circulars, and
/// client impact alerts.
abstract class RegulatoryIntelligenceRepository {
  // ---------------------------------------------------------------------------
  // RegulatoryUpdate
  // ---------------------------------------------------------------------------

  /// Returns all regulatory updates.
  Future<List<RegulatoryUpdate>> getUpdates();

  /// Returns the update for [id], or null if not found.
  Future<RegulatoryUpdate?> getUpdateById(String id);

  /// Returns all updates from [source].
  Future<List<RegulatoryUpdate>> getUpdatesBySource(RegSource source);

  /// Returns all updates matching [impactLevel].
  Future<List<RegulatoryUpdate>> getUpdatesByImpactLevel(
    ImpactLevel impactLevel,
  );

  /// Inserts a new [RegulatoryUpdate] and returns its ID.
  Future<String> insertUpdate(RegulatoryUpdate update);

  /// Marks the update identified by [id] as read. Returns true on success.
  Future<bool> markUpdateAsRead(String id);

  /// Deletes the update identified by [id]. Returns true on success.
  Future<bool> deleteUpdate(String id);

  // ---------------------------------------------------------------------------
  // ComplianceAlert
  // ---------------------------------------------------------------------------

  /// Returns all compliance alerts.
  Future<List<ComplianceAlert>> getAlerts();

  /// Returns the compliance alert for [id], or null if not found.
  Future<ComplianceAlert?> getAlertById(String id);

  /// Returns all alerts matching [priority].
  Future<List<ComplianceAlert>> getAlertsByPriority(AlertPriority priority);

  /// Inserts a new [ComplianceAlert] and returns its ID.
  Future<String> insertAlert(ComplianceAlert alert);

  /// Deletes the alert identified by [id]. Returns true on success.
  Future<bool> deleteAlert(String id);

  // ---------------------------------------------------------------------------
  // RegulatoryCircular
  // ---------------------------------------------------------------------------

  /// Returns all regulatory circulars.
  Future<List<RegulatoryCircular>> getCirculars();

  /// Returns the circular for [id], or null if not found.
  Future<RegulatoryCircular?> getCircularById(String id);

  /// Inserts a new [RegulatoryCircular] and returns its ID.
  Future<String> insertCircular(RegulatoryCircular circular);

  /// Deletes the circular identified by [id]. Returns true on success.
  Future<bool> deleteCircular(String id);

  // ---------------------------------------------------------------------------
  // ClientImpactAlert
  // ---------------------------------------------------------------------------

  /// Returns all client impact alerts.
  Future<List<ClientImpactAlert>> getClientImpactAlerts();

  /// Returns all client impact alerts for [circularId].
  Future<List<ClientImpactAlert>> getClientImpactAlertsByCircular(
    String circularId,
  );

  /// Inserts a new [ClientImpactAlert] and returns its ID.
  Future<String> insertClientImpactAlert(ClientImpactAlert alert);

  /// Updates the [status] of the impact alert identified by [id].
  /// Returns true on success.
  Future<bool> updateClientImpactAlertStatus(String id, String status);
}
