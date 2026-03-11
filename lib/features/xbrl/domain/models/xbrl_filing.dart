import 'package:flutter/material.dart';

/// Report type: standalone or consolidated financial statements.
enum XbrlReportType {
  standalone(label: 'Standalone', shortLabel: 'STA'),
  consolidated(label: 'Consolidated', shortLabel: 'CON');

  const XbrlReportType({required this.label, required this.shortLabel});

  final String label;
  final String shortLabel;
}

/// XBRL filing workflow status.
enum XbrlFilingStatus {
  notStarted(
    label: 'Not Started',
    color: Color(0xFF718096),
    icon: Icons.radio_button_unchecked_rounded,
  ),
  dataEntry(
    label: 'Data Entry',
    color: Color(0xFF2A5B8C),
    icon: Icons.edit_rounded,
  ),
  validation(
    label: 'Validation',
    color: Color(0xFFD4890E),
    icon: Icons.rule_rounded,
  ),
  review(
    label: 'Review',
    color: Color(0xFF7B1FA2),
    icon: Icons.rate_review_rounded,
  ),
  filed(
    label: 'Filed',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  );

  const XbrlFilingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a single XBRL filing.
class XbrlFiling {
  const XbrlFiling({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.cin,
    required this.financialYear,
    required this.reportType,
    required this.taxonomyVersion,
    required this.status,
    required this.totalTags,
    required this.completedTags,
    required this.validationErrors,
    required this.validationWarnings,
    this.startedDate,
    this.filedDate,
    this.preparedBy,
    this.reviewedBy,
  });

  final String id;
  final String companyId;
  final String companyName;

  /// Corporate Identification Number
  final String cin;

  /// e.g. "2024-25"
  final String financialYear;
  final XbrlReportType reportType;

  /// MCA taxonomy version, e.g. "2023"
  final String taxonomyVersion;
  final XbrlFilingStatus status;
  final DateTime? startedDate;
  final DateTime? filedDate;

  final int totalTags;
  final int completedTags;
  final int validationErrors;
  final int validationWarnings;

  final String? preparedBy;
  final String? reviewedBy;

  double get completionPercentage =>
      totalTags > 0 ? (completedTags / totalTags).clamp(0.0, 1.0) : 0.0;

  bool get hasErrors => validationErrors > 0;

  XbrlFiling copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? cin,
    String? financialYear,
    XbrlReportType? reportType,
    String? taxonomyVersion,
    XbrlFilingStatus? status,
    DateTime? startedDate,
    DateTime? filedDate,
    int? totalTags,
    int? completedTags,
    int? validationErrors,
    int? validationWarnings,
    String? preparedBy,
    String? reviewedBy,
  }) {
    return XbrlFiling(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      cin: cin ?? this.cin,
      financialYear: financialYear ?? this.financialYear,
      reportType: reportType ?? this.reportType,
      taxonomyVersion: taxonomyVersion ?? this.taxonomyVersion,
      status: status ?? this.status,
      startedDate: startedDate ?? this.startedDate,
      filedDate: filedDate ?? this.filedDate,
      totalTags: totalTags ?? this.totalTags,
      completedTags: completedTags ?? this.completedTags,
      validationErrors: validationErrors ?? this.validationErrors,
      validationWarnings: validationWarnings ?? this.validationWarnings,
      preparedBy: preparedBy ?? this.preparedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XbrlFiling &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
