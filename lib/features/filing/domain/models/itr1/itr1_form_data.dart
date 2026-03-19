import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/tds_payment_summary.dart';

/// Tax regime election for the assessment year.
enum TaxRegime {
  /// Old regime — allows Chapter VI-A deductions and exemptions.
  oldRegime(label: 'Old Regime'),

  /// New regime (Section 115BAC) — lower slab rates, most deductions not
  /// allowed (except 80CCD(1B) NPS and standard deduction).
  newRegime(label: 'New Regime');

  const TaxRegime({required this.label});

  final String label;
}

/// Composite immutable model holding all ITR-1 (Sahaj) form data.
///
/// Computed income aggregates follow the Income Tax Act flow:
/// Gross Total Income → less Chapter VI-A deductions → Taxable Income.
class Itr1FormData {
  const Itr1FormData({
    required this.personalInfo,
    required this.salaryIncome,
    required this.housePropertyIncome,
    required this.otherSourceIncome,
    required this.deductions,
    required this.selectedRegime,
    required this.tdsPaymentSummary,
  });

  factory Itr1FormData.empty() => Itr1FormData(
    personalInfo: PersonalInfo.empty(),
    salaryIncome: SalaryIncome.empty(),
    housePropertyIncome: HousePropertyIncome.empty(),
    otherSourceIncome: OtherSourceIncome.empty(),
    deductions: ChapterViaDeductions.empty(),
    selectedRegime: TaxRegime.newRegime,
    tdsPaymentSummary: TdsPaymentSummary.empty(),
  );

  final PersonalInfo personalInfo;
  final SalaryIncome salaryIncome;
  final HousePropertyIncome housePropertyIncome;
  final OtherSourceIncome otherSourceIncome;
  final ChapterViaDeductions deductions;
  final TaxRegime selectedRegime;
  final TdsPaymentSummary tdsPaymentSummary;

  /// Aggregate of all income heads before deductions.
  double get grossTotalIncome =>
      salaryIncome.netSalary +
      housePropertyIncome.incomeFromHouseProperty +
      otherSourceIncome.total;

  /// Allowable Chapter VI-A deductions based on the chosen tax regime.
  ///
  /// New regime: ₹0 (most deductions disallowed; 80CCD(1B) is handled
  /// separately by the tax slab computation layer and is not included here
  /// to keep this model regime-agnostic for that edge case).
  /// Old regime: full [ChapterViaDeductions.totalDeductions] with caps.
  double get allowableDeductions =>
      selectedRegime == TaxRegime.oldRegime ? deductions.totalDeductions : 0;

  /// Final taxable income after deductions, floored at zero.
  double get taxableIncome {
    final raw = grossTotalIncome - allowableDeductions;
    return raw < 0 ? 0 : raw;
  }

  Itr1FormData copyWith({
    PersonalInfo? personalInfo,
    SalaryIncome? salaryIncome,
    HousePropertyIncome? housePropertyIncome,
    OtherSourceIncome? otherSourceIncome,
    ChapterViaDeductions? deductions,
    TaxRegime? selectedRegime,
    TdsPaymentSummary? tdsPaymentSummary,
  }) {
    return Itr1FormData(
      personalInfo: personalInfo ?? this.personalInfo,
      salaryIncome: salaryIncome ?? this.salaryIncome,
      housePropertyIncome: housePropertyIncome ?? this.housePropertyIncome,
      otherSourceIncome: otherSourceIncome ?? this.otherSourceIncome,
      deductions: deductions ?? this.deductions,
      selectedRegime: selectedRegime ?? this.selectedRegime,
      tdsPaymentSummary: tdsPaymentSummary ?? this.tdsPaymentSummary,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Itr1FormData &&
        other.personalInfo == personalInfo &&
        other.salaryIncome == salaryIncome &&
        other.housePropertyIncome == housePropertyIncome &&
        other.otherSourceIncome == otherSourceIncome &&
        other.deductions == deductions &&
        other.selectedRegime == selectedRegime &&
        other.tdsPaymentSummary == tdsPaymentSummary;
  }

  @override
  int get hashCode => Object.hash(
    personalInfo,
    salaryIncome,
    housePropertyIncome,
    otherSourceIncome,
    deductions,
    selectedRegime,
    tdsPaymentSummary,
  );

  Map<String, dynamic> toJson() => {
    'personalInfo': personalInfo.toJson(),
    'salaryIncome': salaryIncome.toJson(),
    'housePropertyIncome': housePropertyIncome.toJson(),
    'otherSourceIncome': otherSourceIncome.toJson(),
    'deductions': deductions.toJson(),
    'selectedRegime': selectedRegime.name,
    'tdsPaymentSummary': tdsPaymentSummary.toJson(),
  };

  factory Itr1FormData.fromJson(Map<String, dynamic> json) => Itr1FormData(
    personalInfo: PersonalInfo.fromJson(
      json['personalInfo'] as Map<String, dynamic>? ?? {},
    ),
    salaryIncome: SalaryIncome.fromJson(
      json['salaryIncome'] as Map<String, dynamic>? ?? {},
    ),
    housePropertyIncome: HousePropertyIncome.fromJson(
      json['housePropertyIncome'] as Map<String, dynamic>? ?? {},
    ),
    otherSourceIncome: OtherSourceIncome.fromJson(
      json['otherSourceIncome'] as Map<String, dynamic>? ?? {},
    ),
    deductions: ChapterViaDeductions.fromJson(
      json['deductions'] as Map<String, dynamic>? ?? {},
    ),
    selectedRegime: TaxRegime.values.firstWhere(
      (e) => e.name == json['selectedRegime'],
      orElse: () => TaxRegime.newRegime,
    ),
    tdsPaymentSummary: TdsPaymentSummary.fromJson(
      json['tdsPaymentSummary'] as Map<String, dynamic>? ?? {},
    ),
  );
}
