/// Immutable model representing the penalty computation for late filing of LLP forms.
///
/// Under the LLP Act, a penalty of ₹100 per day is levied for each day of default
/// beyond the due date, subject to a maximum limit per form.
class LlpPenaltyComputation {
  const LlpPenaltyComputation({
    required this.formType,
    required this.dueDate,
    required this.filedDate,
    required this.daysBeyondDue,
    required this.penaltyPaise,
  });

  /// Form type, e.g. 'Form-11' or 'Form-8'.
  final String formType;

  /// Statutory due date for filing.
  final DateTime dueDate;

  /// Actual date on which the form was filed.
  final DateTime filedDate;

  /// Number of days the filing was late (0 if on time).
  final int daysBeyondDue;

  /// Penalty amount in paise (₹100/day = 10000 paise/day).
  final int penaltyPaise;

  LlpPenaltyComputation copyWith({
    String? formType,
    DateTime? dueDate,
    DateTime? filedDate,
    int? daysBeyondDue,
    int? penaltyPaise,
  }) {
    return LlpPenaltyComputation(
      formType: formType ?? this.formType,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      daysBeyondDue: daysBeyondDue ?? this.daysBeyondDue,
      penaltyPaise: penaltyPaise ?? this.penaltyPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LlpPenaltyComputation &&
        other.formType == formType &&
        other.dueDate == dueDate &&
        other.filedDate == filedDate &&
        other.daysBeyondDue == daysBeyondDue &&
        other.penaltyPaise == penaltyPaise;
  }

  @override
  int get hashCode =>
      Object.hash(formType, dueDate, filedDate, daysBeyondDue, penaltyPaise);
}
