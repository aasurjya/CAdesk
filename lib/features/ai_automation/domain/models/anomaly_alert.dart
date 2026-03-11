import 'package:flutter/material.dart';

/// Type of anomaly detected in a transaction.
enum AlertType {
  unusualAmount(
    label: 'Unusual Amount',
    icon: Icons.trending_up_rounded,
  ),
  duplicate(
    label: 'Duplicate',
    icon: Icons.content_copy_rounded,
  ),
  patternBreak(
    label: 'Pattern Break',
    icon: Icons.show_chart_rounded,
  ),
  missingEntry(
    label: 'Missing Entry',
    icon: Icons.playlist_remove_rounded,
  );

  const AlertType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Severity level of an anomaly alert.
enum AlertSeverity {
  critical(
    label: 'Critical',
    color: Color(0xFFC62828),
    icon: Icons.error_rounded,
  ),
  high(
    label: 'High',
    color: Color(0xFFEF6C00),
    icon: Icons.warning_rounded,
  ),
  medium(
    label: 'Medium',
    color: Color(0xFFD4890E),
    icon: Icons.info_rounded,
  ),
  low(
    label: 'Low',
    color: Color(0xFF1565C0),
    icon: Icons.info_outline_rounded,
  );

  const AlertSeverity({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing an anomaly detection alert.
class AnomalyAlert {
  const AnomalyAlert({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.transactionId,
    required this.alertType,
    required this.severity,
    required this.description,
    required this.detectedAt,
    required this.isResolved,
    required this.amountInr,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String transactionId;
  final AlertType alertType;
  final AlertSeverity severity;
  final String description;
  final DateTime detectedAt;
  final bool isResolved;
  final double amountInr;

  /// Amount formatted as INR string.
  String get formattedAmount {
    final absolute = amountInr.abs();
    if (absolute >= 100000) {
      return 'INR ${(absolute / 100000).toStringAsFixed(2)}L';
    }
    if (absolute >= 1000) {
      return 'INR ${(absolute / 1000).toStringAsFixed(1)}K';
    }
    return 'INR ${absolute.toStringAsFixed(2)}';
  }

  /// How long ago the anomaly was detected, as a human-readable string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(detectedAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  AnomalyAlert copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? transactionId,
    AlertType? alertType,
    AlertSeverity? severity,
    String? description,
    DateTime? detectedAt,
    bool? isResolved,
    double? amountInr,
  }) {
    return AnomalyAlert(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      transactionId: transactionId ?? this.transactionId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      detectedAt: detectedAt ?? this.detectedAt,
      isResolved: isResolved ?? this.isResolved,
      amountInr: amountInr ?? this.amountInr,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnomalyAlert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
