import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/cma_report.dart';
import '../../domain/models/loan_calculator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

YearProjection _projection({
  required int year,
  required double sales,
  required double cogsPct,
  required double opexPct,
  required double currentAssets,
  required double currentLiabilities,
  required double totalDebt,
  required double netWorth,
  required double annualDebtService,
}) {
  final cogs = sales * cogsPct;
  final grossProfit = sales - cogs;
  final opex = sales * opexPct;
  final ebitda = grossProfit - opex;
  final depreciation = sales * 0.03;
  final interest = totalDebt * 0.09;
  final netProfit = ebitda - depreciation - interest;
  final dscr = annualDebtService > 0
      ? (netProfit + depreciation + interest) / annualDebtService
      : 0.0;
  final mpbf = (currentAssets - currentLiabilities) * 0.75;

  return YearProjection(
    year: year,
    sales: sales,
    cogs: cogs,
    grossProfit: grossProfit,
    operatingExpenses: opex,
    ebitda: ebitda,
    netProfit: netProfit,
    currentAssets: currentAssets,
    currentLiabilities: currentLiabilities,
    totalDebt: totalDebt,
    netWorth: netWorth,
    dscr: dscr,
    mpbf: mpbf > 0 ? mpbf : 0,
  );
}

List<YearProjection> _growthProjections({
  required double baseSales,
  required double cogsPct,
  required double opexPct,
  required double baseCurrentAssets,
  required double baseCurrentLiabilities,
  required double totalDebt,
  required double netWorth,
  required double annualDebtService,
  required double growthRate,
  required int startYear,
  required int years,
}) {
  final list = <YearProjection>[];
  var sales = baseSales;
  var assets = baseCurrentAssets;
  var liabilities = baseCurrentLiabilities;
  var nw = netWorth;
  for (var i = 0; i < years; i++) {
    list.add(_projection(
      year: startYear + i,
      sales: sales,
      cogsPct: cogsPct,
      opexPct: opexPct,
      currentAssets: assets,
      currentLiabilities: liabilities,
      totalDebt: totalDebt,
      netWorth: nw,
      annualDebtService: annualDebtService,
    ));
    sales *= (1 + growthRate);
    assets *= (1 + growthRate * 0.8);
    liabilities *= (1 + growthRate * 0.5);
    nw *= (1 + growthRate * 1.1);
  }
  return List.unmodifiable(list);
}

// ---------------------------------------------------------------------------
// Mock CMA Reports
// ---------------------------------------------------------------------------

final List<CmaReport> _mockCmaReports = [
  CmaReport(
    id: 'cma-001',
    clientId: 'cl-001',
    clientName: 'Rajesh Industries Pvt Ltd',
    bankName: 'State Bank of India',
    loanPurpose: 'Working Capital Enhancement',
    projectionYears: 3,
    status: CmaReportStatus.submitted,
    preparedDate: DateTime(2026, 1, 15),
    submittedDate: DateTime(2026, 1, 20),
    requestedAmount: 75000000,
    projections: _growthProjections(
      baseSales: 120000000,
      cogsPct: 0.62,
      opexPct: 0.18,
      baseCurrentAssets: 35000000,
      baseCurrentLiabilities: 18000000,
      totalDebt: 40000000,
      netWorth: 55000000,
      annualDebtService: 8500000,
      growthRate: 0.15,
      startYear: 2024,
      years: 3,
    ),
  ),
  CmaReport(
    id: 'cma-002',
    clientId: 'cl-002',
    clientName: 'Patel Agro Foods Ltd',
    bankName: 'HDFC Bank',
    loanPurpose: 'Term Loan for Plant Expansion',
    projectionYears: 5,
    status: CmaReportStatus.approved,
    preparedDate: DateTime(2025, 10, 5),
    submittedDate: DateTime(2025, 10, 12),
    requestedAmount: 200000000,
    sanctionedAmount: 185000000,
    projections: _growthProjections(
      baseSales: 300000000,
      cogsPct: 0.58,
      opexPct: 0.16,
      baseCurrentAssets: 80000000,
      baseCurrentLiabilities: 30000000,
      totalDebt: 120000000,
      netWorth: 150000000,
      annualDebtService: 24000000,
      growthRate: 0.18,
      startYear: 2024,
      years: 5,
    ),
  ),
  CmaReport(
    id: 'cma-003',
    clientId: 'cl-003',
    clientName: 'Sharma Textiles Pvt Ltd',
    bankName: 'Punjab National Bank',
    loanPurpose: 'Machinery Purchase',
    projectionYears: 3,
    status: CmaReportStatus.draft,
    preparedDate: DateTime(2026, 2, 28),
    requestedAmount: 50000000,
    projections: _growthProjections(
      baseSales: 85000000,
      cogsPct: 0.65,
      opexPct: 0.20,
      baseCurrentAssets: 22000000,
      baseCurrentLiabilities: 12000000,
      totalDebt: 30000000,
      netWorth: 40000000,
      annualDebtService: 7000000,
      growthRate: 0.12,
      startYear: 2025,
      years: 3,
    ),
  ),
  CmaReport(
    id: 'cma-004',
    clientId: 'cl-004',
    clientName: 'Mehta Constructions Pvt Ltd',
    bankName: 'Axis Bank',
    loanPurpose: 'Project Finance – Residential Complex',
    projectionYears: 5,
    status: CmaReportStatus.rejected,
    preparedDate: DateTime(2025, 9, 10),
    submittedDate: DateTime(2025, 9, 18),
    requestedAmount: 500000000,
    projections: _growthProjections(
      baseSales: 400000000,
      cogsPct: 0.72,
      opexPct: 0.12,
      baseCurrentAssets: 150000000,
      baseCurrentLiabilities: 100000000,
      totalDebt: 200000000,
      netWorth: 180000000,
      annualDebtService: 45000000,
      growthRate: 0.20,
      startYear: 2024,
      years: 5,
    ),
  ),
  CmaReport(
    id: 'cma-005',
    clientId: 'cl-005',
    clientName: 'Gupta Pharma Distributors',
    bankName: 'State Bank of India',
    loanPurpose: 'Trade Finance & CC Limit',
    projectionYears: 3,
    status: CmaReportStatus.submitted,
    preparedDate: DateTime(2026, 2, 10),
    submittedDate: DateTime(2026, 2, 14),
    requestedAmount: 30000000,
    projections: _growthProjections(
      baseSales: 180000000,
      cogsPct: 0.82,
      opexPct: 0.08,
      baseCurrentAssets: 55000000,
      baseCurrentLiabilities: 25000000,
      totalDebt: 15000000,
      netWorth: 60000000,
      annualDebtService: 4500000,
      growthRate: 0.10,
      startYear: 2025,
      years: 3,
    ),
  ),
  CmaReport(
    id: 'cma-006',
    clientId: 'cl-006',
    clientName: 'Kapoor Engineering Works',
    bankName: 'HDFC Bank',
    loanPurpose: 'Equipment Finance',
    projectionYears: 3,
    status: CmaReportStatus.approved,
    preparedDate: DateTime(2025, 11, 20),
    submittedDate: DateTime(2025, 11, 28),
    requestedAmount: 80000000,
    sanctionedAmount: 80000000,
    projections: _growthProjections(
      baseSales: 150000000,
      cogsPct: 0.60,
      opexPct: 0.18,
      baseCurrentAssets: 45000000,
      baseCurrentLiabilities: 20000000,
      totalDebt: 55000000,
      netWorth: 70000000,
      annualDebtService: 12000000,
      growthRate: 0.14,
      startYear: 2025,
      years: 3,
    ),
  ),
];

// ---------------------------------------------------------------------------
// Mock Loan Calculators
// ---------------------------------------------------------------------------

LoanCalculator _buildLoan({
  required String id,
  required String clientId,
  required String clientName,
  required double loanAmount,
  required double annualRate,
  required int tenureMonths,
  required DateTime disbursementDate,
}) {
  final emi = computeEmi(loanAmount, annualRate, tenureMonths);
  final schedule =
      buildAmortizationSchedule(loanAmount, annualRate, tenureMonths, emi);
  final totalPayment = emi * tenureMonths;
  return LoanCalculator(
    id: id,
    clientId: clientId,
    clientName: clientName,
    loanAmount: loanAmount,
    interestRate: annualRate,
    tenureMonths: tenureMonths,
    emi: emi,
    totalInterest: totalPayment - loanAmount,
    totalPayment: totalPayment,
    disbursementDate: disbursementDate,
    amortizationSchedule: schedule,
  );
}

final List<LoanCalculator> _mockLoanCalculators = [
  _buildLoan(
    id: 'loan-001',
    clientId: 'cl-001',
    clientName: 'Rajesh Industries Pvt Ltd',
    loanAmount: 75000000,
    annualRate: 9.25,
    tenureMonths: 84,
    disbursementDate: DateTime(2025, 4, 1),
  ),
  _buildLoan(
    id: 'loan-002',
    clientId: 'cl-002',
    clientName: 'Patel Agro Foods Ltd',
    loanAmount: 185000000,
    annualRate: 8.75,
    tenureMonths: 120,
    disbursementDate: DateTime(2025, 1, 15),
  ),
  _buildLoan(
    id: 'loan-003',
    clientId: 'cl-006',
    clientName: 'Kapoor Engineering Works',
    loanAmount: 80000000,
    annualRate: 9.50,
    tenureMonths: 60,
    disbursementDate: DateTime(2025, 6, 1),
  ),
  _buildLoan(
    id: 'loan-004',
    clientId: 'cl-005',
    clientName: 'Gupta Pharma Distributors',
    loanAmount: 30000000,
    annualRate: 10.00,
    tenureMonths: 48,
    disbursementDate: DateTime(2025, 9, 1),
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All CMA reports.
final cmaReportsProvider = Provider<List<CmaReport>>(
  (_) => List.unmodifiable(_mockCmaReports),
);

/// All loan calculators.
final loanCalculatorsProvider = Provider<List<LoanCalculator>>(
  (_) => List.unmodifiable(_mockLoanCalculators),
);

/// Active status filter for CMA reports (null = all).
final cmaStatusFilterProvider =
    NotifierProvider<CmaStatusFilterNotifier, CmaReportStatus?>(
  CmaStatusFilterNotifier.new,
);

class CmaStatusFilterNotifier extends Notifier<CmaReportStatus?> {
  @override
  CmaReportStatus? build() => null;

  void update(CmaReportStatus? value) => state = value;
}

/// CMA reports filtered by [cmaStatusFilterProvider].
final cmaFilteredReportsProvider = Provider<List<CmaReport>>((ref) {
  final filter = ref.watch(cmaStatusFilterProvider);
  final all = ref.watch(cmaReportsProvider);
  if (filter == null) return all;
  return all.where((r) => r.status == filter).toList();
});

/// Summary statistics for CMA.
final cmaSummaryProvider = Provider<CmaSummary>((ref) {
  final reports = ref.watch(cmaReportsProvider);
  final loans = ref.watch(loanCalculatorsProvider);

  final totalRequested =
      reports.fold<double>(0, (sum, r) => sum + r.requestedAmount);
  final totalSanctioned = reports
      .where((r) => r.sanctionedAmount != null)
      .fold<double>(0, (sum, r) => sum + (r.sanctionedAmount ?? 0));
  final pending =
      reports.where((r) => r.status == CmaReportStatus.submitted).length;
  final totalEmi =
      loans.fold<double>(0, (sum, l) => sum + l.emi);

  return CmaSummary(
    totalReports: reports.length,
    pendingReports: pending,
    totalRequested: totalRequested,
    totalSanctioned: totalSanctioned,
    totalMonthlyEmi: totalEmi,
  );
});

/// Simple immutable summary.
class CmaSummary {
  const CmaSummary({
    required this.totalReports,
    required this.pendingReports,
    required this.totalRequested,
    required this.totalSanctioned,
    required this.totalMonthlyEmi,
  });

  final int totalReports;
  final int pendingReports;
  final double totalRequested;
  final double totalSanctioned;
  final double totalMonthlyEmi;
}
