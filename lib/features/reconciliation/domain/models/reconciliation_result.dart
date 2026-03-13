/// Reconciliation type — which 3-way or 2-way matching engine produced this result.
enum ReconciliationType {
  tds26as('26AS/TDS Reconciliation'),
  gstr2b('GSTR-2B Matching'),
  bankRecon('Bank Reconciliation'),
  pan3way('PAN 3-Way Match');

  const ReconciliationType(this.label);

  final String label;
}

/// Status of a reconciliation result.
enum ReconciliationStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  reviewed('Reviewed');

  const ReconciliationStatus(this.label);

  final String label;
}

/// Immutable model representing a single discrepancy found during reconciliation.
class Discrepancy {
  const Discrepancy({
    required this.id,
    required this.resultId,
    required this.field,
    required this.expectedValue,
    required this.actualValue,
    required this.source,
    this.resolved = false,
  });

  final String id;
  final String resultId;
  final String field;
  final String expectedValue;
  final String actualValue;
  final String source;
  final bool resolved;

  Discrepancy copyWith({
    String? id,
    String? resultId,
    String? field,
    String? expectedValue,
    String? actualValue,
    String? source,
    bool? resolved,
  }) {
    return Discrepancy(
      id: id ?? this.id,
      resultId: resultId ?? this.resultId,
      field: field ?? this.field,
      expectedValue: expectedValue ?? this.expectedValue,
      actualValue: actualValue ?? this.actualValue,
      source: source ?? this.source,
      resolved: resolved ?? this.resolved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Discrepancy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Discrepancy(id: $id, field: $field, source: $source, resolved: $resolved)';
}

/// Immutable model representing the persisted result of a reconciliation run.
class ReconciliationResult {
  const ReconciliationResult({
    required this.id,
    required this.clientId,
    required this.reconciliationType,
    required this.period,
    required this.totalMatched,
    required this.totalUnmatched,
    required this.discrepancies,
    required this.status,
    this.reviewedBy,
    this.reviewedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientId;
  final ReconciliationType reconciliationType;
  final String period;
  final int totalMatched;
  final int totalUnmatched;
  final List<Discrepancy> discrepancies;
  final ReconciliationStatus status;
  final String? reviewedBy;
  final DateTime? reviewedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether the reconciliation has unresolved discrepancies.
  bool get hasUnresolvedDiscrepancies =>
      discrepancies.any((d) => !d.resolved);

  /// Count of unresolved discrepancies.
  int get unresolvedCount => discrepancies.where((d) => !d.resolved).length;

  ReconciliationResult copyWith({
    String? id,
    String? clientId,
    ReconciliationType? reconciliationType,
    String? period,
    int? totalMatched,
    int? totalUnmatched,
    List<Discrepancy>? discrepancies,
    ReconciliationStatus? status,
    String? reviewedBy,
    DateTime? reviewedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReconciliationResult(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      reconciliationType: reconciliationType ?? this.reconciliationType,
      period: period ?? this.period,
      totalMatched: totalMatched ?? this.totalMatched,
      totalUnmatched: totalUnmatched ?? this.totalUnmatched,
      discrepancies: discrepancies ?? this.discrepancies,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReconciliationResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReconciliationResult(id: $id, clientId: $clientId, '
      'type: ${reconciliationType.label}, period: $period, status: ${status.label})';
}
