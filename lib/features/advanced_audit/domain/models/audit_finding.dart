import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Category of an audit finding.
enum FindingCategory {
  materialMisstatement('Material Misstatement'),
  controlWeakness('Control Weakness'),
  complianceGap('Compliance Gap'),
  fraudIndicator('Fraud Indicator'),
  processImprovement('Process Improvement');

  const FindingCategory(this.label);
  final String label;
}

/// Severity of an audit finding.
enum FindingSeverity {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const FindingSeverity(this.label);
  final String label;

  Color get color {
    switch (this) {
      case FindingSeverity.low:
        return AppColors.success;
      case FindingSeverity.medium:
        return AppColors.warning;
      case FindingSeverity.high:
        return AppColors.accent;
      case FindingSeverity.critical:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case FindingSeverity.low:
        return Icons.info_outline;
      case FindingSeverity.medium:
        return Icons.warning_amber;
      case FindingSeverity.high:
        return Icons.error_outline;
      case FindingSeverity.critical:
        return Icons.dangerous;
    }
  }
}

/// Status of an audit finding.
enum FindingStatus {
  open('Open'),
  acknowledged('Acknowledged'),
  remediated('Remediated'),
  closed('Closed');

  const FindingStatus(this.label);
  final String label;

  Color get color {
    switch (this) {
      case FindingStatus.open:
        return AppColors.error;
      case FindingStatus.acknowledged:
        return AppColors.warning;
      case FindingStatus.remediated:
        return AppColors.primaryVariant;
      case FindingStatus.closed:
        return AppColors.success;
    }
  }
}

/// Immutable model representing an audit finding.
class AuditFinding {
  const AuditFinding({
    required this.id,
    required this.engagementId,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.recommendation,
    this.managementResponse,
    required this.status,
    required this.reportedDate,
    this.resolvedDate,
  });

  final String id;
  final String engagementId;
  final String title;
  final String description;
  final FindingCategory category;
  final FindingSeverity severity;
  final String recommendation;
  final String? managementResponse;
  final FindingStatus status;
  final DateTime reportedDate;
  final DateTime? resolvedDate;

  AuditFinding copyWith({
    String? id,
    String? engagementId,
    String? title,
    String? description,
    FindingCategory? category,
    FindingSeverity? severity,
    String? recommendation,
    String? managementResponse,
    FindingStatus? status,
    DateTime? reportedDate,
    DateTime? resolvedDate,
  }) {
    return AuditFinding(
      id: id ?? this.id,
      engagementId: engagementId ?? this.engagementId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      recommendation: recommendation ?? this.recommendation,
      managementResponse: managementResponse ?? this.managementResponse,
      status: status ?? this.status,
      reportedDate: reportedDate ?? this.reportedDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditFinding && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
