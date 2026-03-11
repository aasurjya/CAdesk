import 'package:flutter/foundation.dart';

/// Immutable model representing a CA's alert about how a regulatory circular
/// affects a specific client.
@immutable
class ClientImpactAlert {
  const ClientImpactAlert({
    required this.id,
    required this.circularId,
    required this.clientName,
    required this.clientPan,
    required this.impactDescription,
    required this.actionRequired,
    required this.dueDate,
    required this.status,
    required this.urgency,
  });

  /// Unique identifier.
  final String id;

  /// Foreign key referencing the [RegulatoryCircular] that triggered this alert.
  final String circularId;

  /// Display name of the affected client.
  final String clientName;

  /// PAN of the affected client, e.g. "ABCDE1234F".
  final String clientPan;

  /// One-sentence description of how the circular impacts this client.
  final String impactDescription;

  /// Specific action the CA needs to take for this client.
  final String actionRequired;

  /// Human-readable deadline, e.g. "31 Mar 2026".
  final String dueDate;

  /// Current workflow status: New, Reviewed, Action Taken, or Not Applicable.
  final String status;

  /// Priority level: Urgent, Normal, or Low.
  final String urgency;

  /// Returns a new [ClientImpactAlert] with the specified fields replaced.
  ClientImpactAlert copyWith({
    String? id,
    String? circularId,
    String? clientName,
    String? clientPan,
    String? impactDescription,
    String? actionRequired,
    String? dueDate,
    String? status,
    String? urgency,
  }) {
    return ClientImpactAlert(
      id: id ?? this.id,
      circularId: circularId ?? this.circularId,
      clientName: clientName ?? this.clientName,
      clientPan: clientPan ?? this.clientPan,
      impactDescription: impactDescription ?? this.impactDescription,
      actionRequired: actionRequired ?? this.actionRequired,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientImpactAlert &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          circularId == other.circularId &&
          clientName == other.clientName &&
          clientPan == other.clientPan &&
          impactDescription == other.impactDescription &&
          actionRequired == other.actionRequired &&
          dueDate == other.dueDate &&
          status == other.status &&
          urgency == other.urgency;

  @override
  int get hashCode => Object.hash(
        id,
        circularId,
        clientName,
        clientPan,
        impactDescription,
        actionRequired,
        dueDate,
        status,
        urgency,
      );

  @override
  String toString() =>
      'ClientImpactAlert(id: $id, client: $clientName, '
      'circular: $circularId, status: $status, urgency: $urgency)';
}
