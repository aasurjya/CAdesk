import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr4/business_income_44ad.dart';
import 'package:ca_app/features/filing/domain/models/itr4/goods_carriage_income_44ae.dart';
import 'package:ca_app/features/filing/domain/models/itr4/profession_income_44ada.dart';

/// Composite immutable model holding all ITR-4 (Sugam) form data.
///
/// ITR-4 is for resident individuals, HUFs, and firms (other than LLP) having
/// income from business/profession computed under presumptive taxation
/// (Sections 44AD, 44ADA, 44AE) along with income from other sources.
///
/// Computed income aggregates follow the Income Tax Act flow:
/// Gross Total Income -> less Chapter VI-A deductions -> Taxable Income.
class Itr4FormData {
  const Itr4FormData({
    required this.personalInfo,
    required this.businessIncome44AD,
    required this.professionIncome44ADA,
    required this.goodsCarriageIncome44AE,
    required this.otherSourceIncome,
    required this.deductions,
    required this.selectedRegime,
  });

  factory Itr4FormData.empty() => Itr4FormData(
    personalInfo: PersonalInfo.empty(),
    businessIncome44AD: BusinessIncome44AD.empty(),
    professionIncome44ADA: ProfessionIncome44ADA.empty(),
    goodsCarriageIncome44AE: GoodsCarriageIncome44AE.empty(),
    otherSourceIncome: OtherSourceIncome.empty(),
    deductions: ChapterViaDeductions.empty(),
    selectedRegime: TaxRegime.newRegime,
  );

  final PersonalInfo personalInfo;
  final BusinessIncome44AD businessIncome44AD;
  final ProfessionIncome44ADA professionIncome44ADA;
  final GoodsCarriageIncome44AE goodsCarriageIncome44AE;
  final OtherSourceIncome otherSourceIncome;
  final ChapterViaDeductions deductions;
  final TaxRegime selectedRegime;

  /// Total presumptive income from all business/profession heads.
  double get totalPresumptiveIncome =>
      businessIncome44AD.presumptiveIncome +
      professionIncome44ADA.presumptiveIncome +
      goodsCarriageIncome44AE.presumptiveIncome;

  /// Aggregate of all income heads before deductions.
  double get grossTotalIncome =>
      totalPresumptiveIncome + otherSourceIncome.total;

  /// Allowable Chapter VI-A deductions based on the chosen tax regime.
  ///
  /// New regime: most deductions disallowed (returns 0).
  /// Old regime: full [ChapterViaDeductions.totalDeductions] with caps.
  double get allowableDeductions =>
      selectedRegime == TaxRegime.oldRegime ? deductions.totalDeductions : 0;

  /// Final taxable income after deductions, floored at zero.
  double get taxableIncome {
    final raw = grossTotalIncome - allowableDeductions;
    return raw < 0 ? 0 : raw;
  }

  Itr4FormData copyWith({
    PersonalInfo? personalInfo,
    BusinessIncome44AD? businessIncome44AD,
    ProfessionIncome44ADA? professionIncome44ADA,
    GoodsCarriageIncome44AE? goodsCarriageIncome44AE,
    OtherSourceIncome? otherSourceIncome,
    ChapterViaDeductions? deductions,
    TaxRegime? selectedRegime,
  }) {
    return Itr4FormData(
      personalInfo: personalInfo ?? this.personalInfo,
      businessIncome44AD: businessIncome44AD ?? this.businessIncome44AD,
      professionIncome44ADA:
          professionIncome44ADA ?? this.professionIncome44ADA,
      goodsCarriageIncome44AE:
          goodsCarriageIncome44AE ?? this.goodsCarriageIncome44AE,
      otherSourceIncome: otherSourceIncome ?? this.otherSourceIncome,
      deductions: deductions ?? this.deductions,
      selectedRegime: selectedRegime ?? this.selectedRegime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Itr4FormData &&
        other.personalInfo == personalInfo &&
        other.businessIncome44AD == businessIncome44AD &&
        other.professionIncome44ADA == professionIncome44ADA &&
        other.goodsCarriageIncome44AE == goodsCarriageIncome44AE &&
        other.otherSourceIncome == otherSourceIncome &&
        other.deductions == deductions &&
        other.selectedRegime == selectedRegime;
  }

  @override
  int get hashCode => Object.hash(
    personalInfo,
    businessIncome44AD,
    professionIncome44ADA,
    goodsCarriageIncome44AE,
    otherSourceIncome,
    deductions,
    selectedRegime,
  );
}
