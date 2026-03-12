/// Type of entry in Form 26AS.
enum TdsEntryType {
  /// TDS on salary (Part A).
  tdsSalary('TDS — Salary'),

  /// TDS on non-salary payments (Part A).
  tdsNonSalary('TDS — Non-Salary'),

  /// Tax Collected at Source (Part B).
  tcs('TCS'),

  /// Specified Financial Transaction (Part E / SFT).
  sft('SFT'),

  /// Refund issued by the department (Part C).
  refund('Refund');

  const TdsEntryType(this.label);
  final String label;
}

/// Immutable model for a single entry from Form 26AS (Tax Credit Statement).
///
/// Form 26AS is issued by TRACES and contains TDS/TCS credits,
/// specified financial transactions, and refund details.
class Form26ASEntry {
  const Form26ASEntry({
    required this.deductorName,
    required this.deductorTan,
    required this.entryType,
    required this.grossAmount,
    required this.tdsAmount,
    required this.transactionDate,
  });

  /// Name of the deductor / collector.
  final String deductorName;

  /// TAN (Tax Deduction Account Number) of the deductor.
  final String deductorTan;

  /// Type of this 26AS entry.
  final TdsEntryType entryType;

  /// Gross amount on which TDS/TCS was deducted.
  final double grossAmount;

  /// TDS/TCS amount deducted or tax collected.
  final double tdsAmount;

  /// Date of the transaction or deduction.
  final DateTime transactionDate;

  Form26ASEntry copyWith({
    String? deductorName,
    String? deductorTan,
    TdsEntryType? entryType,
    double? grossAmount,
    double? tdsAmount,
    DateTime? transactionDate,
  }) {
    return Form26ASEntry(
      deductorName: deductorName ?? this.deductorName,
      deductorTan: deductorTan ?? this.deductorTan,
      entryType: entryType ?? this.entryType,
      grossAmount: grossAmount ?? this.grossAmount,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      transactionDate: transactionDate ?? this.transactionDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Form26ASEntry &&
        other.deductorName == deductorName &&
        other.deductorTan == deductorTan &&
        other.entryType == entryType &&
        other.grossAmount == grossAmount &&
        other.tdsAmount == tdsAmount &&
        other.transactionDate == transactionDate;
  }

  @override
  int get hashCode => Object.hash(
    deductorName,
    deductorTan,
    entryType,
    grossAmount,
    tdsAmount,
    transactionDate,
  );
}
