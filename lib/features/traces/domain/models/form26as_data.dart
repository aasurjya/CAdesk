/// A single TDS entry in a Form 26AS statement.
class TdsEntry26as {
  const TdsEntry26as({
    required this.deductorName,
    required this.deductorTan,
    required this.section,
    required this.amountPaid,
    required this.taxDeducted,
    required this.depositDate,
  });

  final String deductorName;

  /// 10-character TAN of the deductor.
  final String deductorTan;

  /// TDS section under which deduction was made (e.g. "192", "194C").
  final String section;

  /// Amount paid / credited to the deductee in paise.
  final int amountPaid;

  /// Tax deducted at source in paise.
  final int taxDeducted;

  /// Date on which tax was deposited with the government.
  final DateTime depositDate;

  TdsEntry26as copyWith({
    String? deductorName,
    String? deductorTan,
    String? section,
    int? amountPaid,
    int? taxDeducted,
    DateTime? depositDate,
  }) {
    return TdsEntry26as(
      deductorName: deductorName ?? this.deductorName,
      deductorTan: deductorTan ?? this.deductorTan,
      section: section ?? this.section,
      amountPaid: amountPaid ?? this.amountPaid,
      taxDeducted: taxDeducted ?? this.taxDeducted,
      depositDate: depositDate ?? this.depositDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsEntry26as &&
          runtimeType == other.runtimeType &&
          deductorName == other.deductorName &&
          deductorTan == other.deductorTan &&
          section == other.section &&
          amountPaid == other.amountPaid &&
          taxDeducted == other.taxDeducted &&
          depositDate == other.depositDate;

  @override
  int get hashCode => Object.hash(
        deductorName,
        deductorTan,
        section,
        amountPaid,
        taxDeducted,
        depositDate,
      );
}

/// Immutable Form 26AS statement for a PAN and assessment year.
class Form26asData {
  const Form26asData({
    required this.pan,
    required this.assessmentYear,
    required this.tdsEntries,
    required this.advanceTax,
    required this.selfAssessment,
  });

  /// 10-character PAN for which the statement was downloaded.
  final String pan;

  /// Assessment year in YYYY-YY format, e.g. "2024-25".
  final String assessmentYear;

  final List<TdsEntry26as> tdsEntries;

  /// Total advance tax paid in paise.
  final int advanceTax;

  /// Total self-assessment tax paid in paise.
  final int selfAssessment;

  /// Derived: total TDS from all entries in paise.
  int get totalTds =>
      tdsEntries.fold(0, (sum, e) => sum + e.taxDeducted);

  Form26asData copyWith({
    String? pan,
    String? assessmentYear,
    List<TdsEntry26as>? tdsEntries,
    int? advanceTax,
    int? selfAssessment,
  }) {
    return Form26asData(
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      tdsEntries: tdsEntries ?? this.tdsEntries,
      advanceTax: advanceTax ?? this.advanceTax,
      selfAssessment: selfAssessment ?? this.selfAssessment,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26asData &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          assessmentYear == other.assessmentYear &&
          advanceTax == other.advanceTax &&
          selfAssessment == other.selfAssessment;

  @override
  int get hashCode =>
      Object.hash(pan, assessmentYear, advanceTax, selfAssessment);
}
