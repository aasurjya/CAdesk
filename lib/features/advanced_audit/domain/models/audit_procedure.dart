/// Assertion tested by an audit procedure (ISA 500).
enum AuditAssertion {
  existence('Existence'),
  completeness('Completeness'),
  accuracy('Accuracy'),
  cutoff('Cut-off'),
  classification('Classification');

  const AuditAssertion(this.label);
  final String label;
}

/// Lifecycle status of an audit procedure.
enum ProcedureStatus {
  planned('Planned'),
  inProgress('In Progress'),
  completed('Completed');

  const ProcedureStatus(this.label);
  final String label;
}

/// Immutable model representing a single audit procedure within a program.
class AuditProcedure {
  const AuditProcedure({
    required this.procedureId,
    required this.area,
    required this.assertion,
    required this.plannedSampleSize,
    required this.actualSampleSize,
    required this.exceptions,
    required this.status,
  });

  final String procedureId;
  final String area;
  final AuditAssertion assertion;
  final int plannedSampleSize;
  final int actualSampleSize;

  /// Immutable list of exceptions found during this procedure.
  final List<AuditException> exceptions;
  final ProcedureStatus status;

  /// Effective error rate: exceptions count divided by actual sample size.
  double get errorRate =>
      actualSampleSize == 0 ? 0 : exceptions.length / actualSampleSize;

  AuditProcedure copyWith({
    String? procedureId,
    String? area,
    AuditAssertion? assertion,
    int? plannedSampleSize,
    int? actualSampleSize,
    List<AuditException>? exceptions,
    ProcedureStatus? status,
  }) {
    return AuditProcedure(
      procedureId: procedureId ?? this.procedureId,
      area: area ?? this.area,
      assertion: assertion ?? this.assertion,
      plannedSampleSize: plannedSampleSize ?? this.plannedSampleSize,
      actualSampleSize: actualSampleSize ?? this.actualSampleSize,
      exceptions: exceptions ?? this.exceptions,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditProcedure && other.procedureId == procedureId;
  }

  @override
  int get hashCode => procedureId.hashCode;
}

/// Nature of an audit exception.
enum ExceptionNature {
  error('Error'),
  fraud('Fraud'),
  irregularity('Irregularity'),
  misstatement('Misstatement');

  const ExceptionNature(this.label);
  final String label;
}

/// Immutable model for an exception identified during an audit procedure.
class AuditException {
  const AuditException({
    required this.description,
    required this.amountPaise,
    required this.nature,
    required this.projectedErrorPaise,
    required this.auditResponse,
  });

  final String description;

  /// Actual exception amount in paise (1/100 of a rupee).
  final int amountPaise;
  final ExceptionNature nature;

  /// Projected error extrapolated to the population.
  final int projectedErrorPaise;
  final String auditResponse;

  AuditException copyWith({
    String? description,
    int? amountPaise,
    ExceptionNature? nature,
    int? projectedErrorPaise,
    String? auditResponse,
  }) {
    return AuditException(
      description: description ?? this.description,
      amountPaise: amountPaise ?? this.amountPaise,
      nature: nature ?? this.nature,
      projectedErrorPaise: projectedErrorPaise ?? this.projectedErrorPaise,
      auditResponse: auditResponse ?? this.auditResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditException &&
        other.description == description &&
        other.amountPaise == amountPaise &&
        other.nature == nature &&
        other.projectedErrorPaise == projectedErrorPaise &&
        other.auditResponse == auditResponse;
  }

  @override
  int get hashCode => Object.hash(
        description,
        amountPaise,
        nature,
        projectedErrorPaise,
        auditResponse,
      );
}
