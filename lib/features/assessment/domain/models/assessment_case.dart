/// Type of income tax assessment.
enum AssessmentType {
  intimation143_1('143(1) Intimation'),
  scrutiny143_3('143(3) Scrutiny'),
  bestJudgment144('144 Best Judgment'),
  revision263('263 Revision'),
  appealCit('CIT Appeal'),
  itat('ITAT');

  const AssessmentType(this.label);

  final String label;
}

/// Status of an assessment case.
enum AssessmentCaseStatus {
  open('Open'),
  pending('Pending'),
  closed('Closed'),
  appealed('Appealed');

  const AssessmentCaseStatus(this.label);

  final String label;
}

/// Immutable model representing an income tax assessment case for a client.
class AssessmentCase {
  const AssessmentCase({
    required this.id,
    required this.clientId,
    required this.assessmentYear,
    required this.caseType,
    required this.status,
    required this.demandAmount,
    required this.paidAmount,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.notes,
  });

  final String id;
  final String clientId;

  /// e.g. "AY 2023-24"
  final String assessmentYear;
  final AssessmentType caseType;
  final AssessmentCaseStatus status;

  /// Demand amount raised (INR as string for decimal precision).
  final String demandAmount;

  /// Amount already paid against the demand.
  final String paidAmount;
  final DateTime? dueDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssessmentCase copyWith({
    String? id,
    String? clientId,
    String? assessmentYear,
    AssessmentType? caseType,
    AssessmentCaseStatus? status,
    String? demandAmount,
    String? paidAmount,
    DateTime? dueDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssessmentCase(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      caseType: caseType ?? this.caseType,
      status: status ?? this.status,
      demandAmount: demandAmount ?? this.demandAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssessmentCase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
