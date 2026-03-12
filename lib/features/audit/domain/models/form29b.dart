/// A single adjustment to book profit for MAT computation under Sec 115JB.
///
/// Positive [adjustmentPaise] = addition to book profit.
/// Negative [adjustmentPaise] = deduction from book profit.
class BookProfitAdjustment {
  const BookProfitAdjustment({
    required this.description,
    required this.adjustmentPaise,
  });

  final String description;

  /// Adjustment amount in paise. Positive = add back; negative = deduct.
  final int adjustmentPaise;

  BookProfitAdjustment copyWith({String? description, int? adjustmentPaise}) {
    return BookProfitAdjustment(
      description: description ?? this.description,
      adjustmentPaise: adjustmentPaise ?? this.adjustmentPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookProfitAdjustment &&
        other.description == description &&
        other.adjustmentPaise == adjustmentPaise;
  }

  @override
  int get hashCode => Object.hash(description, adjustmentPaise);
}

/// Immutable Form 29B — Report under Section 115JB (MAT computation).
///
/// MAT = Minimum Alternate Tax = 15% of book profit per Sec 115JB.
/// MAT credit can be carried forward for 15 years per Sec 115JAA.
///
/// All amounts are in paise (int).
class Form29B {
  const Form29B({
    required this.financialYear,
    required this.bookProfitPaise,
    required this.matLiabilityPaise,
    required this.matCreditAvailablePaise,
    required this.matCreditCarryForwardYears,
    required this.bookProfitAdjustments,
  });

  /// Financial year integer (e.g. 2025 = FY 2024-25).
  final int financialYear;

  /// Computed book profit per Sec 115JB (paise).
  final int bookProfitPaise;

  /// MAT liability = 15% of book profit (paise).
  final int matLiabilityPaise;

  /// MAT credit available for carry-forward (paise).
  final int matCreditAvailablePaise;

  /// Number of years MAT credit can be carried forward (15 as per Sec 115JAA).
  final int matCreditCarryForwardYears;

  /// Detailed list of adjustments made to arrive at book profit.
  final List<BookProfitAdjustment> bookProfitAdjustments;

  Form29B copyWith({
    int? financialYear,
    int? bookProfitPaise,
    int? matLiabilityPaise,
    int? matCreditAvailablePaise,
    int? matCreditCarryForwardYears,
    List<BookProfitAdjustment>? bookProfitAdjustments,
  }) {
    return Form29B(
      financialYear: financialYear ?? this.financialYear,
      bookProfitPaise: bookProfitPaise ?? this.bookProfitPaise,
      matLiabilityPaise: matLiabilityPaise ?? this.matLiabilityPaise,
      matCreditAvailablePaise:
          matCreditAvailablePaise ?? this.matCreditAvailablePaise,
      matCreditCarryForwardYears:
          matCreditCarryForwardYears ?? this.matCreditCarryForwardYears,
      bookProfitAdjustments:
          bookProfitAdjustments ?? this.bookProfitAdjustments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Form29B) return false;
    if (other.financialYear != financialYear) return false;
    if (other.bookProfitPaise != bookProfitPaise) return false;
    if (other.matLiabilityPaise != matLiabilityPaise) return false;
    if (other.matCreditAvailablePaise != matCreditAvailablePaise) return false;
    if (other.matCreditCarryForwardYears != matCreditCarryForwardYears) {
      return false;
    }
    if (other.bookProfitAdjustments.length != bookProfitAdjustments.length) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    financialYear,
    bookProfitPaise,
    matLiabilityPaise,
    matCreditAvailablePaise,
    matCreditCarryForwardYears,
  );
}
