import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/advance_tax/advance_tax_schedule.dart';

// ---------------------------------------------------------------------------
// Income estimate model
// ---------------------------------------------------------------------------

/// Immutable income estimate inputs for advance tax computation.
class IncomeEstimate {
  const IncomeEstimate({
    this.salary = 0,
    this.businessIncome = 0,
    this.capitalGains = 0,
    this.otherSources = 0,
    this.tdsAlreadyDeducted = 0,
  });

  final double salary;
  final double businessIncome;
  final double capitalGains;
  final double otherSources;
  final double tdsAlreadyDeducted;

  double get totalIncome =>
      salary + businessIncome + capitalGains + otherSources;

  IncomeEstimate copyWith({
    double? salary,
    double? businessIncome,
    double? capitalGains,
    double? otherSources,
    double? tdsAlreadyDeducted,
  }) {
    return IncomeEstimate(
      salary: salary ?? this.salary,
      businessIncome: businessIncome ?? this.businessIncome,
      capitalGains: capitalGains ?? this.capitalGains,
      otherSources: otherSources ?? this.otherSources,
      tdsAlreadyDeducted: tdsAlreadyDeducted ?? this.tdsAlreadyDeducted,
    );
  }
}

// ---------------------------------------------------------------------------
// Interest computation model
// ---------------------------------------------------------------------------

/// Immutable interest computation result under Sections 234B and 234C.
class AdvanceTaxInterest {
  const AdvanceTaxInterest({
    required this.section234B,
    required this.section234C,
    required this.quarterlyDetails,
  });

  /// Section 234B: 1% per month if advance tax paid < 90% of assessed tax.
  final double section234B;

  /// Section 234C: total deferment interest across quarters.
  final double section234C;

  /// Per-quarter Section 234C interest breakdown.
  final List<double> quarterlyDetails;

  double get totalInterest => section234B + section234C;
}

// ---------------------------------------------------------------------------
// Summary model
// ---------------------------------------------------------------------------

/// Immutable advance tax summary for display.
class AdvanceTaxSummary {
  const AdvanceTaxSummary({
    required this.totalLiability,
    required this.totalPaid,
    required this.balance,
    required this.interestAccrued,
  });

  final double totalLiability;
  final double totalPaid;
  final double balance;
  final double interestAccrued;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Income estimate inputs — mutable via notifier.
final advanceTaxIncomeEstimateProvider =
    NotifierProvider<IncomeEstimateNotifier, IncomeEstimate>(
      IncomeEstimateNotifier.new,
    );

class IncomeEstimateNotifier extends Notifier<IncomeEstimate> {
  @override
  IncomeEstimate build() => const IncomeEstimate();

  void update(IncomeEstimate estimate) => state = estimate;
}

/// Computed tax from income estimate using new regime slabs.
double _computeTax(double totalIncome) {
  final taxable = (totalIncome - 75000).clamp(0.0, double.infinity);
  double tax = 0;
  if (taxable > 2400000) tax += (taxable - 2400000) * 0.30;
  if (taxable > 2000000) {
    tax += (taxable.clamp(0.0, 2400000) - 2000000) * 0.25;
  }
  if (taxable > 1600000) {
    tax += (taxable.clamp(0.0, 2000000) - 1600000) * 0.20;
  }
  if (taxable > 1200000) {
    tax += (taxable.clamp(0.0, 1600000) - 1200000) * 0.15;
  }
  if (taxable > 800000) {
    tax += (taxable.clamp(0.0, 1200000) - 800000) * 0.10;
  }
  if (taxable > 400000) {
    tax += (taxable.clamp(0.0, 800000) - 400000) * 0.05;
  }
  return tax * 1.04; // 4% cess
}

/// Schedule derived from income estimate (FY 2025-26).
final advanceTaxScheduleProvider = Provider<AdvanceTaxSchedule>((ref) {
  final estimate = ref.watch(advanceTaxIncomeEstimateProvider);
  final grossTax = _computeTax(estimate.totalIncome);
  final netTax = (grossTax - estimate.tdsAlreadyDeducted).clamp(0.0, grossTax);
  return AdvanceTaxSchedule.forFY(netTax, 2025);
});

/// Payment amounts and challan numbers per quarter.
final advanceTaxPaymentsProvider =
    NotifierProvider<
      AdvanceTaxPaymentsNotifier,
      List<({double paid, String? challan})>
    >(AdvanceTaxPaymentsNotifier.new);

class AdvanceTaxPaymentsNotifier
    extends Notifier<List<({double paid, String? challan})>> {
  @override
  List<({double paid, String? challan})> build() {
    return List.generate(4, (_) => (paid: 0.0, challan: null));
  }

  void updatePayment(int quarter, {double? paid, String? challan}) {
    final updated = List<({double paid, String? challan})>.from(state);
    updated[quarter] = (
      paid: paid ?? state[quarter].paid,
      challan: challan ?? state[quarter].challan,
    );
    state = List.unmodifiable(updated);
  }
}

/// Interest computation — Section 234B and 234C.
final advanceTaxInterestProvider = Provider<AdvanceTaxInterest>((ref) {
  final schedule = ref.watch(advanceTaxScheduleProvider);
  final payments = ref.watch(advanceTaxPaymentsProvider);

  final estimatedTax = schedule.estimatedTax;
  final totalPaid = payments.fold<double>(0, (s, p) => s + p.paid);

  // Section 234B: if total advance tax paid < 90% of assessed tax
  double s234B = 0;
  if (totalPaid < estimatedTax * 0.90 && estimatedTax > 0) {
    final shortfall = estimatedTax - totalPaid;
    // Simple interest: 1% per month for 3 months (Apr–Jun assessment)
    s234B = shortfall * 0.01 * 3;
  }

  // Section 234C: per quarter deferment
  final quarterlyInterest = <double>[];
  final cumulativePercents = [0.15, 0.45, 0.75, 1.00];
  double cumulativePaid = 0;

  for (int i = 0; i < 4; i++) {
    cumulativePaid += payments[i].paid;
    final expectedCumulative = estimatedTax * cumulativePercents[i];
    final shortfall = expectedCumulative - cumulativePaid;
    if (shortfall > 0) {
      // 1% per month for 3 months
      quarterlyInterest.add(shortfall * 0.01 * 3);
    } else {
      quarterlyInterest.add(0);
    }
  }

  final s234C = quarterlyInterest.fold<double>(0, (s, v) => s + v);

  return AdvanceTaxInterest(
    section234B: s234B,
    section234C: s234C,
    quarterlyDetails: List.unmodifiable(quarterlyInterest),
  );
});

/// Overall summary combining schedule, payments, and interest.
final advanceTaxSummaryProvider = Provider<AdvanceTaxSummary>((ref) {
  final schedule = ref.watch(advanceTaxScheduleProvider);
  final payments = ref.watch(advanceTaxPaymentsProvider);
  final interest = ref.watch(advanceTaxInterestProvider);

  final totalPaid = payments.fold<double>(0, (s, p) => s + p.paid);

  return AdvanceTaxSummary(
    totalLiability: schedule.estimatedTax,
    totalPaid: totalPaid,
    balance: schedule.estimatedTax - totalPaid,
    interestAccrued: interest.totalInterest,
  );
});
