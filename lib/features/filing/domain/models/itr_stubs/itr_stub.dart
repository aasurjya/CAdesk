/// Type of ITR form that is not yet fully implemented.
enum ItrStubType {
  /// ITR-5: Partnership firms, LLPs, AOPs, BOIs.
  itr5('ITR-5', 'Partnership Firm'),

  /// ITR-6: Companies other than those claiming exemption under Section 11.
  itr6('ITR-6', 'Company'),

  /// ITR-7: Trusts, political parties, institutions, AOPs claiming
  /// exemption under Section 11.
  itr7('ITR-7', 'Trust/AOP');

  const ItrStubType(this.formName, this.entityDescription);

  /// Official form name (e.g. 'ITR-5').
  final String formName;

  /// Type of entity this form is applicable to.
  final String entityDescription;
}

/// Immutable placeholder model for ITR types not yet fully implemented.
///
/// Provides a "Coming Soon" stub so the UI can display these ITR types
/// in the filing hub without functional form data.
class ItrStub {
  const ItrStub({
    required this.stubType,
    required this.entityName,
    required this.pan,
    required this.assessmentYear,
    this.status = 'Coming Soon',
  });

  /// The ITR form type this stub represents.
  final ItrStubType stubType;

  /// Name of the entity (firm, company, or trust).
  final String entityName;

  /// PAN of the entity.
  final String pan;

  /// Assessment year (e.g. '2026-27').
  final String assessmentYear;

  /// Current status — defaults to 'Coming Soon'.
  final String status;

  ItrStub copyWith({
    ItrStubType? stubType,
    String? entityName,
    String? pan,
    String? assessmentYear,
    String? status,
  }) {
    return ItrStub(
      stubType: stubType ?? this.stubType,
      entityName: entityName ?? this.entityName,
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItrStub &&
        other.stubType == stubType &&
        other.entityName == entityName &&
        other.pan == pan &&
        other.assessmentYear == assessmentYear &&
        other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(stubType, entityName, pan, assessmentYear, status);
}
