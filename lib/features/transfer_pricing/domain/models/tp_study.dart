import 'package:flutter/material.dart';

/// Transfer Pricing study types.
enum TpStudyType {
  masterFile(
    label: 'Master File',
    description: 'Country-by-Country Master File',
  ),
  localFile(label: 'Local File', description: 'Local TP Documentation'),
  cbcr(label: 'CbCR', description: 'Country-by-Country Report');

  const TpStudyType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Status of a TP study.
enum TpStudyStatus {
  notStarted(
    label: 'Not Started',
    color: Color(0xFF718096),
    icon: Icons.circle_outlined,
    stepIndex: 0,
  ),
  dataCollection(
    label: 'Data Collection',
    color: Color(0xFFD4890E),
    icon: Icons.folder_open_rounded,
    stepIndex: 1,
  ),
  analysis(
    label: 'Analysis',
    color: Color(0xFF1565C0),
    icon: Icons.analytics_rounded,
    stepIndex: 2,
  ),
  draft(
    label: 'Draft',
    color: Color(0xFF6A1B9A),
    icon: Icons.edit_document,
    stepIndex: 3,
  ),
  review(
    label: 'Review',
    color: Color(0xFFE8890C),
    icon: Icons.rate_review_rounded,
    stepIndex: 4,
  ),
  final_(
    label: 'Final',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
    stepIndex: 5,
  );

  const TpStudyStatus({
    required this.label,
    required this.color,
    required this.icon,
    required this.stepIndex,
  });

  final String label;
  final Color color;
  final IconData icon;
  final int stepIndex;
}

/// Transfer Pricing methods.
enum TpMethod {
  cup(label: 'CUP', description: 'Comparable Uncontrolled Price'),
  rpm(label: 'RPM', description: 'Resale Price Method'),
  cpm(label: 'CPM', description: 'Cost Plus Method'),
  psm(label: 'PSM', description: 'Profit Split Method'),
  tnmm(label: 'TNMM', description: 'Transactional Net Margin Method');

  const TpMethod({required this.label, required this.description});

  final String label;
  final String description;
}

/// Immutable model representing a Transfer Pricing study.
@immutable
class TpStudy {
  const TpStudy({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.financialYear,
    required this.studyType,
    required this.status,
    required this.analystName,
    required this.dueDate,
    required this.transactionValue,
    required this.method,
    this.completedDate,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String financialYear;
  final TpStudyType studyType;
  final TpStudyStatus status;
  final String analystName;
  final DateTime dueDate;
  final DateTime? completedDate;
  final double transactionValue;
  final TpMethod method;

  /// Progress percentage based on study status step.
  double get progressPercent => status.stepIndex / 5.0;

  TpStudy copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? financialYear,
    TpStudyType? studyType,
    TpStudyStatus? status,
    String? analystName,
    DateTime? dueDate,
    DateTime? completedDate,
    double? transactionValue,
    TpMethod? method,
  }) {
    return TpStudy(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      financialYear: financialYear ?? this.financialYear,
      studyType: studyType ?? this.studyType,
      status: status ?? this.status,
      analystName: analystName ?? this.analystName,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      transactionValue: transactionValue ?? this.transactionValue,
      method: method ?? this.method,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TpStudy && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TpStudy(id: $id, client: $clientName, '
      'type: ${studyType.label}, status: ${status.label})';
}
