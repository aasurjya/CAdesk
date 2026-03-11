import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Type of audit engagement.
enum AuditType {
  statutory('Statutory', Icons.gavel),
  internal('Internal', Icons.shield_outlined),
  stock('Stock', Icons.inventory_2_outlined),
  cost('Cost', Icons.calculate_outlined),
  forensic('Forensic', Icons.search),
  bank('Bank', Icons.account_balance),
  concurrent('Concurrent', Icons.sync);

  const AuditType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Status of an audit engagement.
enum AuditStatus {
  planning('Planning'),
  fieldwork('Fieldwork'),
  review('Review'),
  reporting('Reporting'),
  completed('Completed');

  const AuditStatus(this.label);
  final String label;

  Color get color {
    switch (this) {
      case AuditStatus.planning:
        return AppColors.neutral400;
      case AuditStatus.fieldwork:
        return AppColors.primaryVariant;
      case AuditStatus.review:
        return AppColors.warning;
      case AuditStatus.reporting:
        return AppColors.accent;
      case AuditStatus.completed:
        return AppColors.success;
    }
  }
}

/// Risk level for an engagement.
enum AuditRiskLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const AuditRiskLevel(this.label);
  final String label;

  Color get color {
    switch (this) {
      case AuditRiskLevel.low:
        return AppColors.success;
      case AuditRiskLevel.medium:
        return AppColors.warning;
      case AuditRiskLevel.high:
        return AppColors.accent;
      case AuditRiskLevel.critical:
        return AppColors.error;
    }
  }
}

/// Immutable model representing an audit engagement.
class AuditEngagement {
  const AuditEngagement({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.auditType,
    required this.financialYear,
    required this.assignedPartner,
    required this.teamMembers,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.reportDueDate,
    required this.workpaperCount,
    required this.findingsCount,
    required this.riskLevel,
  });

  final String id;
  final String clientId;
  final String clientName;
  final AuditType auditType;
  final String financialYear;
  final String assignedPartner;
  final List<String> teamMembers;
  final AuditStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime reportDueDate;
  final int workpaperCount;
  final int findingsCount;
  final AuditRiskLevel riskLevel;

  /// Progress percentage based on status.
  double get progressPercent {
    switch (status) {
      case AuditStatus.planning:
        return 0.15;
      case AuditStatus.fieldwork:
        return 0.40;
      case AuditStatus.review:
        return 0.65;
      case AuditStatus.reporting:
        return 0.85;
      case AuditStatus.completed:
        return 1.0;
    }
  }

  AuditEngagement copyWith({
    String? id,
    String? clientId,
    String? clientName,
    AuditType? auditType,
    String? financialYear,
    String? assignedPartner,
    List<String>? teamMembers,
    AuditStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? reportDueDate,
    int? workpaperCount,
    int? findingsCount,
    AuditRiskLevel? riskLevel,
  }) {
    return AuditEngagement(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      auditType: auditType ?? this.auditType,
      financialYear: financialYear ?? this.financialYear,
      assignedPartner: assignedPartner ?? this.assignedPartner,
      teamMembers: teamMembers ?? this.teamMembers,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reportDueDate: reportDueDate ?? this.reportDueDate,
      workpaperCount: workpaperCount ?? this.workpaperCount,
      findingsCount: findingsCount ?? this.findingsCount,
      riskLevel: riskLevel ?? this.riskLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditEngagement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
