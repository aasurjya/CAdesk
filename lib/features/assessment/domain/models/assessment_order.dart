/// Income Tax sections under which assessment orders are issued.
enum AssessmentSection {
  section143_1(label: '143(1)', fullLabel: 'Section 143(1) — Intimation'),
  section143_3(label: '143(3)', fullLabel: 'Section 143(3) — Scrutiny'),
  section147(label: '147', fullLabel: 'Section 147 — Reassessment'),
  section153A(label: '153A', fullLabel: 'Section 153A — Search Assessment'),
  section154(label: '154', fullLabel: 'Section 154 — Rectification'),
  appealEffect(label: 'Appeal', fullLabel: 'Appeal Effect Order');

  const AssessmentSection({required this.label, required this.fullLabel});

  final String label;
  final String fullLabel;
}

/// Verification outcome for an assessment order.
enum VerificationStatus {
  pending(label: 'Pending'),
  verified(label: 'Verified'),
  disputed(label: 'Disputed'),
  rectified(label: 'Rectified');

  const VerificationStatus({required this.label});

  final String label;
}

/// Immutable model representing an income tax assessment order.
class AssessmentOrder {
  const AssessmentOrder({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.section,
    required this.orderDate,
    required this.demandAmount,
    required this.taxAssessed,
    required this.incomeAssessed,
    required this.disallowances,
    required this.verificationStatus,
    required this.assignedTo,
    this.hasErrors = false,
    this.remarks,
  });

  final String id;
  final String clientId;
  final String clientName;

  /// 10-character PAN.
  final String pan;

  /// e.g. "AY 2023-24"
  final String assessmentYear;
  final AssessmentSection section;
  final DateTime orderDate;

  /// Total demand raised (INR).
  final double demandAmount;

  /// Total tax assessed by the department (INR).
  final double taxAssessed;

  /// Total income assessed (INR).
  final double incomeAssessed;

  /// Total disallowances made (INR).
  final double disallowances;

  /// Whether computation errors were found during verification.
  final bool hasErrors;
  final VerificationStatus verificationStatus;
  final String assignedTo;
  final String? remarks;

  AssessmentOrder copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? pan,
    String? assessmentYear,
    AssessmentSection? section,
    DateTime? orderDate,
    double? demandAmount,
    double? taxAssessed,
    double? incomeAssessed,
    double? disallowances,
    bool? hasErrors,
    VerificationStatus? verificationStatus,
    String? assignedTo,
    String? remarks,
  }) {
    return AssessmentOrder(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      section: section ?? this.section,
      orderDate: orderDate ?? this.orderDate,
      demandAmount: demandAmount ?? this.demandAmount,
      taxAssessed: taxAssessed ?? this.taxAssessed,
      incomeAssessed: incomeAssessed ?? this.incomeAssessed,
      disallowances: disallowances ?? this.disallowances,
      hasErrors: hasErrors ?? this.hasErrors,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      assignedTo: assignedTo ?? this.assignedTo,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentOrder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
