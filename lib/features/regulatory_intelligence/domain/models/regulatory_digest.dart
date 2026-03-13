import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'compliance_alert.dart';
import 'rate_change.dart';
import 'regulatory_update.dart';

/// Immutable aggregated digest of regulatory updates, compliance alerts, and
/// rate changes for a given day or week.
@immutable
class RegulatoryDigest {
  const RegulatoryDigest({
    required this.digestDate,
    required this.updates,
    required this.alerts,
    required this.rateChanges,
  });

  /// The date (or week start) this digest covers.
  final DateTime digestDate;

  /// Regulatory updates included in the digest.
  final List<RegulatoryUpdate> updates;

  /// Compliance alerts included in the digest.
  final List<ComplianceAlert> alerts;

  /// Rate-change entries included in the digest.
  final List<RateChange> rateChanges;

  /// Total number of items across all three lists.
  int get totalItems => updates.length + alerts.length + rateChanges.length;

  /// Count of high-priority items: critical/high [ComplianceAlert]s plus
  /// [ImpactLevel.high] [RegulatoryUpdate]s.
  int get highPriorityCount {
    final highAlerts = alerts
        .where(
          (a) =>
              a.priority == AlertPriority.critical ||
              a.priority == AlertPriority.high,
        )
        .length;
    final highUpdates = updates
        .where((u) => u.impactLevel == ImpactLevel.high)
        .length;
    return highAlerts + highUpdates;
  }

  /// Returns a new [RegulatoryDigest] with the specified fields replaced.
  RegulatoryDigest copyWith({
    DateTime? digestDate,
    List<RegulatoryUpdate>? updates,
    List<ComplianceAlert>? alerts,
    List<RateChange>? rateChanges,
  }) {
    return RegulatoryDigest(
      digestDate: digestDate ?? this.digestDate,
      updates: updates ?? this.updates,
      alerts: alerts ?? this.alerts,
      rateChanges: rateChanges ?? this.rateChanges,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegulatoryDigest &&
          runtimeType == other.runtimeType &&
          digestDate == other.digestDate &&
          listEquals(updates, other.updates) &&
          listEquals(alerts, other.alerts) &&
          listEquals(rateChanges, other.rateChanges);

  @override
  int get hashCode => Object.hash(digestDate, updates, alerts, rateChanges);

  @override
  String toString() =>
      'RegulatoryDigest(digestDate: $digestDate, '
      'totalItems: $totalItems, highPriority: $highPriorityCount)';
}
