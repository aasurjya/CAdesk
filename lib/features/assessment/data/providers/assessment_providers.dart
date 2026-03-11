import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/assessment_order.dart';
import '../../domain/models/interest_calculation.dart';

// ---------------------------------------------------------------------------
// Interest Calculator 234 — Sections 234A / 234B / 234C / 244A
// ---------------------------------------------------------------------------

/// Immutable result of a full 234A/234B/234C interest computation.
class AssessmentInterestSummary {
  const AssessmentInterestSummary({
    required this.interest234A,
    required this.interest234B,
    required this.interest234C,
    required this.netDemand,
    required this.refund,
  });

  final double interest234A;
  final double interest234B;
  final double interest234C;
  final double netDemand;
  final double refund;

  double get totalInterest => interest234A + interest234B + interest234C;
}

/// Interest calculation service for income tax assessment orders.
///
/// All methods are pure functions — no side effects.
class InterestCalculator234 {
  const InterestCalculator234._();

  /// Section 234A: Interest for late filing of ITR.
  ///
  /// Rate: 1% per month (or part thereof) on tax due after
  /// deducting advance tax and TDS credited.
  /// Period: from due date of filing to actual date of filing.
  static double section234A({
    required double taxPayable,
    required double advanceTaxPaid,
    required double tdsCredited,
    required int monthsLate,
  }) {
    final netTaxDue =
        (taxPayable - advanceTaxPaid - tdsCredited).clamp(0.0, double.infinity);
    return netTaxDue * 0.01 * monthsLate;
  }

  /// Section 234B: Interest for short payment of advance tax.
  ///
  /// Applicable if advance tax paid < 90% of assessed tax.
  /// Rate: 1% per month from April 1 to date of filing / assessment.
  static double section234B({
    required double assessedTax,
    required double advanceTaxPaid,
    required double tdsCredited,
    required int months,
  }) {
    final netAssessedTax =
        (assessedTax - tdsCredited).clamp(0.0, double.infinity);
    final threshold = netAssessedTax * 0.90;
    if (advanceTaxPaid >= threshold) {
      return 0;
    }
    final shortfall = netAssessedTax - advanceTaxPaid;
    return shortfall * 0.01 * months;
  }

  /// Section 234C: Interest for deferment of advance tax instalments.
  ///
  /// 1% per month for 3 months on the shortfall at each instalment date.
  static double section234C({
    required double assessedTax,
    required double advanceTaxByJun15,
    required double advanceTaxBySep15,
    required double advanceTaxByDec15,
    required double advanceTaxByMar15,
  }) {
    final required15 = assessedTax * 0.15;
    final required45 = assessedTax * 0.45;
    final required75 = assessedTax * 0.75;

    final junShortfall =
        (required15 - advanceTaxByJun15).clamp(0.0, double.infinity);
    final sepShortfall =
        (required45 - advanceTaxBySep15).clamp(0.0, double.infinity);
    final decShortfall =
        (required75 - advanceTaxByDec15).clamp(0.0, double.infinity);

    return (junShortfall + sepShortfall + decShortfall) * 0.01 * 3;
  }

  /// Section 244A: Interest on excess TDS / advance tax (refund interest).
  ///
  /// Rate: 0.5% per month from April 1 (or date of payment) to refund date.
  static double section244A({
    required double refundAmount,
    required int months,
  }) {
    return refundAmount * 0.005 * months;
  }

  /// Computes a full [AssessmentInterestSummary] for an assessment order.
  static AssessmentInterestSummary computeAll({
    required double taxPayable,
    required double advanceTaxPaid,
    required double tdsCredited,
    required double advanceTaxByJun15,
    required double advanceTaxBySep15,
    required double advanceTaxByDec15,
    required int monthsLateFor234A,
    required int monthsFor234B,
  }) {
    final a = section234A(
      taxPayable: taxPayable,
      advanceTaxPaid: advanceTaxPaid,
      tdsCredited: tdsCredited,
      monthsLate: monthsLateFor234A,
    );
    final b = section234B(
      assessedTax: taxPayable,
      advanceTaxPaid: advanceTaxPaid,
      tdsCredited: tdsCredited,
      months: monthsFor234B,
    );
    final c = section234C(
      assessedTax: taxPayable,
      advanceTaxByJun15: advanceTaxByJun15,
      advanceTaxBySep15: advanceTaxBySep15,
      advanceTaxByDec15: advanceTaxByDec15,
      advanceTaxByMar15: advanceTaxPaid,
    );
    final netDemand =
        taxPayable - advanceTaxPaid - tdsCredited + a + b + c;
    return AssessmentInterestSummary(
      interest234A: a,
      interest234B: b,
      interest234C: c,
      netDemand: netDemand > 0 ? netDemand : 0,
      refund: netDemand < 0 ? netDemand.abs() : 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data — Assessment Orders
// ---------------------------------------------------------------------------

final List<AssessmentOrder> _mockOrders = [
  AssessmentOrder(
    id: 'ao-001',
    clientId: 'acc-001',
    clientName: 'Mehta Textiles Pvt Ltd',
    pan: 'AABCM4521F',
    assessmentYear: 'AY 2022-23',
    section: AssessmentSection.section143_3,
    orderDate: DateTime(2024, 11, 15),
    demandAmount: 1850000,
    taxAssessed: 4250000,
    incomeAssessed: 14500000,
    disallowances: 2800000,
    hasErrors: true,
    verificationStatus: VerificationStatus.disputed,
    assignedTo: 'CA Suresh Agarwal',
    remarks: 'Depreciation disallowance appears incorrect — submitting rectification',
  ),
  AssessmentOrder(
    id: 'ao-002',
    clientId: 'acc-006',
    clientName: 'Joshi Electronics Pvt Ltd',
    pan: 'AABCJ2109E',
    assessmentYear: 'AY 2023-24',
    section: AssessmentSection.section143_1,
    orderDate: DateTime(2025, 3, 10),
    demandAmount: 0,
    taxAssessed: 1820000,
    incomeAssessed: 6100000,
    disallowances: 0,
    hasErrors: false,
    verificationStatus: VerificationStatus.verified,
    assignedTo: 'CA Vikram Desai',
    remarks: null,
  ),
  AssessmentOrder(
    id: 'ao-003',
    clientId: 'acc-009',
    clientName: 'Gupta Steel Industries Pvt Ltd',
    pan: 'AACPG8901G',
    assessmentYear: 'AY 2021-22',
    section: AssessmentSection.section147,
    orderDate: DateTime(2024, 8, 20),
    demandAmount: 3400000,
    taxAssessed: 8700000,
    incomeAssessed: 29000000,
    disallowances: 5500000,
    hasErrors: true,
    verificationStatus: VerificationStatus.pending,
    assignedTo: 'CA Rajesh Khanna',
    remarks: 'Section 80IC deduction re-opened, working on response',
  ),
  AssessmentOrder(
    id: 'ao-004',
    clientId: 'acc-002',
    clientName: 'Ramesh Kumar & Brothers',
    pan: 'AABPR7834K',
    assessmentYear: 'AY 2023-24',
    section: AssessmentSection.section154,
    orderDate: DateTime(2025, 1, 5),
    demandAmount: 28500,
    taxAssessed: 285000,
    incomeAssessed: 950000,
    disallowances: 0,
    hasErrors: false,
    verificationStatus: VerificationStatus.rectified,
    assignedTo: 'CA Anand Verma',
    remarks: 'TDS credit mismatch rectified successfully',
  ),
  AssessmentOrder(
    id: 'ao-005',
    clientId: 'acc-005',
    clientName: 'Patel & Sons HUF',
    pan: 'AAFPH6543H',
    assessmentYear: 'AY 2022-23',
    section: AssessmentSection.section143_3,
    orderDate: DateTime(2024, 12, 18),
    demandAmount: 620000,
    taxAssessed: 1950000,
    incomeAssessed: 6500000,
    disallowances: 1200000,
    hasErrors: true,
    verificationStatus: VerificationStatus.disputed,
    assignedTo: 'CA Anand Verma',
    remarks: 'Capital gains treatment disputed',
  ),
  AssessmentOrder(
    id: 'ao-006',
    clientId: 'acc-004',
    clientName: 'Krishnamurthy Family Trust',
    pan: 'AABCK9012T',
    assessmentYear: 'AY 2023-24',
    section: AssessmentSection.appealEffect,
    orderDate: DateTime(2025, 2, 14),
    demandAmount: 0,
    taxAssessed: 380000,
    incomeAssessed: 1260000,
    disallowances: 0,
    hasErrors: false,
    verificationStatus: VerificationStatus.verified,
    assignedTo: 'CA Priya Nair',
    remarks: 'CIT(A) appeal allowed in full',
  ),
  AssessmentOrder(
    id: 'ao-007',
    clientId: 'acc-007',
    clientName: 'Banerjee Exports LLP',
    pan: 'AABCB3456L',
    assessmentYear: 'AY 2022-23',
    section: AssessmentSection.section153A,
    orderDate: DateTime(2024, 10, 30),
    demandAmount: 4800000,
    taxAssessed: 10500000,
    incomeAssessed: 35000000,
    disallowances: 7200000,
    hasErrors: true,
    verificationStatus: VerificationStatus.pending,
    assignedTo: 'CA Rakesh Sinha',
    remarks: 'Post-search assessment — verification in progress',
  ),
  AssessmentOrder(
    id: 'ao-008',
    clientId: 'acc-010',
    clientName: 'Narayanan Charitable Trust',
    pan: 'AAACN5678T',
    assessmentYear: 'AY 2023-24',
    section: AssessmentSection.section143_1,
    orderDate: DateTime(2025, 2, 28),
    demandAmount: 0,
    taxAssessed: 0,
    incomeAssessed: 420000,
    disallowances: 0,
    hasErrors: false,
    verificationStatus: VerificationStatus.verified,
    assignedTo: 'CA Meena Iyer',
    remarks: 'No demand — exempt income correctly processed',
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Interest Calculations
// ---------------------------------------------------------------------------

final List<InterestCalculation> _mockInterest = [
  InterestCalculation(
    id: 'int-001',
    orderId: 'ao-001',
    clientId: 'acc-001',
    clientName: 'Mehta Textiles Pvt Ltd',
    section: InterestSection.section234B,
    principal: 1850000,
    rate: 1.0,
    period: 8,
    calculatedInterest: 148000,
    actualInterest: 162000,
    variance: -14000,
    isCorrect: false,
  ),
  InterestCalculation(
    id: 'int-002',
    orderId: 'ao-001',
    clientId: 'acc-001',
    clientName: 'Mehta Textiles Pvt Ltd',
    section: InterestSection.section220_2,
    principal: 1850000,
    rate: 1.0,
    period: 3,
    calculatedInterest: 55500,
    actualInterest: 55500,
    variance: 0,
    isCorrect: true,
  ),
  InterestCalculation(
    id: 'int-003',
    orderId: 'ao-003',
    clientId: 'acc-009',
    clientName: 'Gupta Steel Industries Pvt Ltd',
    section: InterestSection.section234B,
    principal: 3400000,
    rate: 1.0,
    period: 12,
    calculatedInterest: 408000,
    actualInterest: 440000,
    variance: -32000,
    isCorrect: false,
  ),
  InterestCalculation(
    id: 'int-004',
    orderId: 'ao-003',
    clientId: 'acc-009',
    clientName: 'Gupta Steel Industries Pvt Ltd',
    section: InterestSection.section234C,
    principal: 3400000,
    rate: 1.0,
    period: 3,
    calculatedInterest: 102000,
    actualInterest: 102000,
    variance: 0,
    isCorrect: true,
  ),
  InterestCalculation(
    id: 'int-005',
    orderId: 'ao-005',
    clientId: 'acc-005',
    clientName: 'Patel & Sons HUF',
    section: InterestSection.section234B,
    principal: 620000,
    rate: 1.0,
    period: 10,
    calculatedInterest: 62000,
    actualInterest: 68200,
    variance: -6200,
    isCorrect: false,
  ),
  InterestCalculation(
    id: 'int-006',
    orderId: 'ao-005',
    clientId: 'acc-005',
    clientName: 'Patel & Sons HUF',
    section: InterestSection.section234C,
    principal: 620000,
    rate: 1.0,
    period: 3,
    calculatedInterest: 18600,
    actualInterest: 18600,
    variance: 0,
    isCorrect: true,
  ),
  InterestCalculation(
    id: 'int-007',
    orderId: 'ao-006',
    clientId: 'acc-004',
    clientName: 'Krishnamurthy Family Trust',
    section: InterestSection.section244A,
    principal: 380000,
    rate: 0.5,
    period: 14,
    calculatedInterest: 26600,
    actualInterest: 26600,
    variance: 0,
    isCorrect: true,
  ),
  InterestCalculation(
    id: 'int-008',
    orderId: 'ao-007',
    clientId: 'acc-007',
    clientName: 'Banerjee Exports LLP',
    section: InterestSection.section234B,
    principal: 4800000,
    rate: 1.0,
    period: 15,
    calculatedInterest: 720000,
    actualInterest: 792000,
    variance: -72000,
    isCorrect: false,
  ),
  InterestCalculation(
    id: 'int-009',
    orderId: 'ao-007',
    clientId: 'acc-007',
    clientName: 'Banerjee Exports LLP',
    section: InterestSection.section220_2,
    principal: 4800000,
    rate: 1.0,
    period: 2,
    calculatedInterest: 96000,
    actualInterest: 96000,
    variance: 0,
    isCorrect: true,
  ),
  InterestCalculation(
    id: 'int-010',
    orderId: 'ao-002',
    clientId: 'acc-006',
    clientName: 'Joshi Electronics Pvt Ltd',
    section: InterestSection.section234B,
    principal: 1820000,
    rate: 1.0,
    period: 4,
    calculatedInterest: 72800,
    actualInterest: 72800,
    variance: 0,
    isCorrect: true,
  ),
  InterestCalculation(
    id: 'int-011',
    orderId: 'ao-004',
    clientId: 'acc-002',
    clientName: 'Ramesh Kumar & Brothers',
    section: InterestSection.section234B,
    principal: 28500,
    rate: 1.0,
    period: 6,
    calculatedInterest: 1710,
    actualInterest: 1710,
    variance: 0,
    isCorrect: true,
  ),
  InterestCalculation(
    id: 'int-012',
    orderId: 'ao-003',
    clientId: 'acc-009',
    clientName: 'Gupta Steel Industries Pvt Ltd',
    section: InterestSection.section234D,
    principal: 520000,
    rate: 0.5,
    period: 6,
    calculatedInterest: 15600,
    actualInterest: 18000,
    variance: -2400,
    isCorrect: false,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All assessment orders.
final assessmentOrdersProvider = Provider<List<AssessmentOrder>>(
  (_) => List.unmodifiable(_mockOrders),
);

/// All interest calculations.
final interestCalculationsProvider = Provider<List<InterestCalculation>>(
  (_) => List.unmodifiable(_mockInterest),
);

// ---------------------------------------------------------------------------
// Filter notifiers
// ---------------------------------------------------------------------------

/// Filter by assessment section.
final assessmentSectionFilterProvider =
    NotifierProvider<_SectionFilterNotifier, AssessmentSection?>(
  _SectionFilterNotifier.new,
);

class _SectionFilterNotifier extends Notifier<AssessmentSection?> {
  @override
  AssessmentSection? build() => null;

  void update(AssessmentSection? value) => state = value;
}

/// Filter by verification status.
final assessmentStatusFilterProvider =
    NotifierProvider<_StatusFilterNotifier, VerificationStatus?>(
  _StatusFilterNotifier.new,
);

class _StatusFilterNotifier extends Notifier<VerificationStatus?> {
  @override
  VerificationStatus? build() => null;

  void update(VerificationStatus? value) => state = value;
}

/// Filter by assessment year.
final assessmentYearFilterProvider =
    NotifierProvider<_YearFilterNotifier, String?>(
  _YearFilterNotifier.new,
);

class _YearFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// Orders after applying section, status, and year filters.
final filteredOrdersProvider = Provider<List<AssessmentOrder>>((ref) {
  final orders = ref.watch(assessmentOrdersProvider);
  final sectionFilter = ref.watch(assessmentSectionFilterProvider);
  final statusFilter = ref.watch(assessmentStatusFilterProvider);
  final yearFilter = ref.watch(assessmentYearFilterProvider);

  return orders.where((o) {
    final sectionMatch = sectionFilter == null || o.section == sectionFilter;
    final statusMatch =
        statusFilter == null || o.verificationStatus == statusFilter;
    final yearMatch =
        yearFilter == null || o.assessmentYear == yearFilter;
    return sectionMatch && statusMatch && yearMatch;
  }).toList();
});

/// Summary: counts for the error banner at the top.
final assessmentSummaryProvider = Provider<AssessmentSummary>((ref) {
  final orders = ref.watch(assessmentOrdersProvider);
  final interest = ref.watch(interestCalculationsProvider);

  final ordersWithErrors = orders.where((o) => o.hasErrors).length;
  final pendingVerification =
      orders.where((o) => o.verificationStatus == VerificationStatus.pending).length;
  final interestErrors =
      interest.where((i) => !i.isCorrect).length;
  final totalDemand = orders.fold<double>(0, (sum, o) => sum + o.demandAmount);

  return AssessmentSummary(
    ordersWithErrors: ordersWithErrors,
    pendingVerification: pendingVerification,
    interestErrors: interestErrors,
    totalDemand: totalDemand,
  );
});

/// Simple immutable summary data class.
class AssessmentSummary {
  const AssessmentSummary({
    required this.ordersWithErrors,
    required this.pendingVerification,
    required this.interestErrors,
    required this.totalDemand,
  });

  final int ordersWithErrors;
  final int pendingVerification;
  final int interestErrors;
  final double totalDemand;
}
