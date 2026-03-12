import 'package:flutter/foundation.dart';

/// Type of compliance alert.
enum AlertType {
  deadlineApproaching,
  rateChange,
  newCompliance,
  penaltyRisk,
  formChange,
}

/// Priority level of the alert.
enum AlertPriority { critical, high, medium, low }

/// Immutable model representing a compliance deadline or rule-change alert
/// relevant to the CA practice.
@immutable
class ComplianceAlert {
  const ComplianceAlert({
    required this.alertId,
    required this.title,
    required this.description,
    required this.alertType,
    required this.dueDate,
    required this.daysRemaining,
    required this.applicableTo,
    required this.penaltyIfMissed,
    required this.priority,
  });

  /// Unique identifier.
  final String alertId;

  /// Short descriptive title, e.g. "ITR Filing Deadline – FY 2024-25".
  final String title;

  /// Full description of the compliance requirement.
  final String description;

  /// Classification of the alert.
  final AlertType alertType;

  /// Statutory deadline (nullable for open-ended alerts).
  final DateTime? dueDate;

  /// Pre-computed days until the deadline (nullable when [dueDate] is null).
  /// Use [ComplianceAlertService.computeDaysRemaining] for a live calculation.
  final int? daysRemaining;

  /// Entity types to which the alert applies, e.g. ["Individual", "Company"].
  final List<String> applicableTo;

  /// Description of the penalty or consequence if the deadline is missed
  /// (nullable when not applicable).
  final String? penaltyIfMissed;

  /// Urgency / priority of this alert.
  final AlertPriority priority;

  /// Returns a new [ComplianceAlert] with the specified fields replaced.
  ComplianceAlert copyWith({
    String? alertId,
    String? title,
    String? description,
    AlertType? alertType,
    DateTime? dueDate,
    int? daysRemaining,
    List<String>? applicableTo,
    String? penaltyIfMissed,
    AlertPriority? priority,
  }) {
    return ComplianceAlert(
      alertId: alertId ?? this.alertId,
      title: title ?? this.title,
      description: description ?? this.description,
      alertType: alertType ?? this.alertType,
      dueDate: dueDate ?? this.dueDate,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      applicableTo: applicableTo ?? this.applicableTo,
      penaltyIfMissed: penaltyIfMissed ?? this.penaltyIfMissed,
      priority: priority ?? this.priority,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplianceAlert &&
          runtimeType == other.runtimeType &&
          alertId == other.alertId &&
          title == other.title &&
          description == other.description &&
          alertType == other.alertType &&
          dueDate == other.dueDate &&
          daysRemaining == other.daysRemaining &&
          penaltyIfMissed == other.penaltyIfMissed &&
          priority == other.priority;

  @override
  int get hashCode => Object.hash(
    alertId,
    title,
    description,
    alertType,
    dueDate,
    daysRemaining,
    penaltyIfMissed,
    priority,
  );

  @override
  String toString() =>
      'ComplianceAlert(alertId: $alertId, type: ${alertType.name}, '
      'priority: ${priority.name}, dueDate: $dueDate)';
}
