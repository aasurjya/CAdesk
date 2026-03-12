import 'package:ca_app/features/audit/domain/models/form3cd_clause.dart';

/// Immutable model representing a complete Form 3CD tax audit report.
///
/// Form 3CD is prescribed under Rule 6G of the Income Tax Rules 1962
/// and must accompany the audit report under Section 44AB.
/// It contains 44 clauses covering various aspects of the business.
class Form3CD {
  const Form3CD({
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.financialYear,
    required this.businessNature,
    required this.clauses,
  });

  final String clientName;
  final String pan;

  /// Assessment year, e.g. '2025-26'.
  final String assessmentYear;

  /// Financial year integer, e.g. 2025 = FY 2024-25.
  final int financialYear;

  final String businessNature;

  /// All 44 clauses in order.
  final List<Form3CDClause> clauses;

  /// Returns the clause with the given [number], or null if not found.
  Form3CDClause? clauseByNumber(int number) {
    for (final clause in clauses) {
      if (clause.clauseNumber == number) return clause;
    }
    return null;
  }

  Form3CD copyWith({
    String? clientName,
    String? pan,
    String? assessmentYear,
    int? financialYear,
    String? businessNature,
    List<Form3CDClause>? clauses,
  }) {
    return Form3CD(
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      financialYear: financialYear ?? this.financialYear,
      businessNature: businessNature ?? this.businessNature,
      clauses: clauses ?? this.clauses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Form3CD) return false;
    if (other.clientName != clientName) return false;
    if (other.pan != pan) return false;
    if (other.assessmentYear != assessmentYear) return false;
    if (other.financialYear != financialYear) return false;
    if (other.businessNature != businessNature) return false;
    if (other.clauses.length != clauses.length) return false;
    for (int i = 0; i < clauses.length; i++) {
      if (other.clauses[i] != clauses[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    clientName,
    pan,
    assessmentYear,
    financialYear,
    businessNature,
    clauses.length,
  );
}
