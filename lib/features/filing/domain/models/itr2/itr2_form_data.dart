import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr2/foreign_asset_schedule.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_al.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';

/// Total income threshold above which Schedule AL is mandatory (₹50 lakhs).
const double _kScheduleAlThreshold = 5000000.0;

/// Composite immutable model holding all ITR-2 form data.
///
/// ITR-2 is for resident and non-resident individuals/HUFs who have:
/// - Capital gains income (shares, MF, property, etc.)
/// - Foreign income or foreign assets
/// - Total income exceeding ₹50 lakhs (triggers Schedule AL)
///
/// Income flow: Gross Total Income → Chapter VI-A Deductions → Taxable Income.
/// Capital gains are subject to special tax rates and are NOT reduced by
/// Chapter VI-A deductions.
class Itr2FormData {
  const Itr2FormData({
    required this.personalInfo,
    required this.salaryIncome,
    required this.housePropertyIncome,
    required this.otherSourceIncome,
    required this.scheduleCg,
    required this.deductions,
    required this.selectedRegime,
    required this.foreignAssetSchedule,
    this.scheduleAl,
  });

  factory Itr2FormData.empty() => Itr2FormData(
    personalInfo: PersonalInfo.empty(),
    salaryIncome: SalaryIncome.empty(),
    housePropertyIncome: HousePropertyIncome.empty(),
    otherSourceIncome: OtherSourceIncome.empty(),
    scheduleCg: ScheduleCg.empty(),
    deductions: ChapterViaDeductions.empty(),
    selectedRegime: TaxRegime.newRegime,
    foreignAssetSchedule: const ForeignAssetSchedule(assets: []),
    scheduleAl: null,
  );

  final PersonalInfo personalInfo;
  final SalaryIncome salaryIncome;
  final HousePropertyIncome housePropertyIncome;
  final OtherSourceIncome otherSourceIncome;

  /// Schedule CG: Complete capital gains computation for the year.
  final ScheduleCg scheduleCg;

  final ChapterViaDeductions deductions;
  final TaxRegime selectedRegime;

  /// Schedule FA: Foreign assets held outside India.
  final ForeignAssetSchedule foreignAssetSchedule;

  /// Schedule AL: Assets and liabilities (mandatory when income > ₹50L).
  ///
  /// Null when income is ≤ ₹50 lakhs and Schedule AL is not required.
  final ScheduleAl? scheduleAl;

  // ---------------------------------------------------------------------------
  // Income aggregation
  // ---------------------------------------------------------------------------

  /// Net income from ordinary income heads (salary, HP, other sources).
  ///
  /// Capital gains are excluded here because they carry separate tax rates
  /// and must not be reduced by Chapter VI-A deductions.
  ///
  /// Each head is floored at zero at the aggregate level — individual head
  /// losses (e.g., house property loss) still reduce the total but the
  /// aggregate cannot go below zero.
  double get ordinaryIncome {
    final raw =
        salaryIncome.netSalary +
        housePropertyIncome.incomeFromHouseProperty +
        otherSourceIncome.total;
    return raw < 0 ? 0 : raw;
  }

  /// Total capital gains (STCG + LTCG) after set-off.
  double get capitalGainsTotal =>
      scheduleCg.netStcgAfterSetOff + scheduleCg.netLtcgAfterSetOff;

  /// Gross total income = ordinary income + capital gains + foreign income.
  double get grossTotalIncome =>
      ordinaryIncome +
      capitalGainsTotal +
      foreignAssetSchedule.totalIncomeOffered;

  /// Allowable Chapter VI-A deductions (only on ordinary income, not CG).
  ///
  /// New regime: ₹0 (deductions not allowed).
  /// Old regime: full deductions with caps, but capped at ordinary income.
  double get allowableDeductions {
    if (selectedRegime == TaxRegime.newRegime) return 0;
    final maxDeductible = ordinaryIncome > 0 ? ordinaryIncome : 0.0;
    final claimed = deductions.totalDeductions;
    return claimed > maxDeductible ? maxDeductible : claimed;
  }

  /// Taxable ordinary income after Chapter VI-A deductions, floored at zero.
  double get taxableOrdinaryIncome {
    final raw = ordinaryIncome - allowableDeductions;
    return raw < 0 ? 0 : raw;
  }

  /// Total taxable income (ordinary + capital gains), floored at zero.
  ///
  /// Capital gains are added back at their net-after-set-off values.
  double get taxableIncome => taxableOrdinaryIncome + capitalGainsTotal;

  // ---------------------------------------------------------------------------
  // Schedule AL eligibility
  // ---------------------------------------------------------------------------

  /// Whether Schedule AL must be filed (total income > ₹50 lakhs).
  bool get requiresScheduleAL => grossTotalIncome > _kScheduleAlThreshold;

  // ---------------------------------------------------------------------------
  // Immutable update
  // ---------------------------------------------------------------------------

  Itr2FormData copyWith({
    PersonalInfo? personalInfo,
    SalaryIncome? salaryIncome,
    HousePropertyIncome? housePropertyIncome,
    OtherSourceIncome? otherSourceIncome,
    ScheduleCg? scheduleCg,
    ChapterViaDeductions? deductions,
    TaxRegime? selectedRegime,
    ForeignAssetSchedule? foreignAssetSchedule,
    ScheduleAl? scheduleAl,
  }) {
    return Itr2FormData(
      personalInfo: personalInfo ?? this.personalInfo,
      salaryIncome: salaryIncome ?? this.salaryIncome,
      housePropertyIncome: housePropertyIncome ?? this.housePropertyIncome,
      otherSourceIncome: otherSourceIncome ?? this.otherSourceIncome,
      scheduleCg: scheduleCg ?? this.scheduleCg,
      deductions: deductions ?? this.deductions,
      selectedRegime: selectedRegime ?? this.selectedRegime,
      foreignAssetSchedule: foreignAssetSchedule ?? this.foreignAssetSchedule,
      scheduleAl: scheduleAl ?? this.scheduleAl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Itr2FormData &&
        other.personalInfo == personalInfo &&
        other.salaryIncome == salaryIncome &&
        other.housePropertyIncome == housePropertyIncome &&
        other.otherSourceIncome == otherSourceIncome &&
        other.scheduleCg == scheduleCg &&
        other.deductions == deductions &&
        other.selectedRegime == selectedRegime &&
        other.foreignAssetSchedule == foreignAssetSchedule &&
        other.scheduleAl == scheduleAl;
  }

  @override
  int get hashCode => Object.hash(
    personalInfo,
    salaryIncome,
    housePropertyIncome,
    otherSourceIncome,
    scheduleCg,
    deductions,
    selectedRegime,
    foreignAssetSchedule,
    scheduleAl,
  );
}
