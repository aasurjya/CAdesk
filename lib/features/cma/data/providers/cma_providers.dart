import 'dart:math' show pow;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/cma_report.dart';
import '../../domain/models/loan_calculator.dart';

// ---------------------------------------------------------------------------
// CmaCalculator — financial calculation service
// ---------------------------------------------------------------------------

/// Immutable row in a CmaCalculator amortization schedule.
class AmortizationRow {
  const AmortizationRow({
    required this.month,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  final int month;
  final double emi;
  final double principal;
  final double interest;
  final double balance;
}

/// Immutable result of a full loan analysis.
class LoanAnalysisResult {
  const LoanAnalysisResult({
    required this.principal,
    required this.annualRatePercent,
    required this.tenureMonths,
    required this.monthlyEmi,
    required this.totalInterest,
    required this.totalPayment,
    required this.mpbf,
    required this.dscr,
    required this.dscrStatus,
  });

  final double principal;
  final double annualRatePercent;
  final int tenureMonths;
  final double monthlyEmi;
  final double totalInterest;
  final double totalPayment;

  /// Maximum Permissible Bank Finance.
  final double mpbf;

  /// Debt Service Coverage Ratio.
  final double dscr;

  /// 'Excellent' >=1.5, 'Acceptable' >=1.25, 'Marginal' >=1.0, 'Poor' <1.0
  final String dscrStatus;
}

/// Pure financial calculation service — all methods are static and side-effect free.
class CmaCalculator {
  CmaCalculator._();

  /// EMI = P × r × (1+r)^n / ((1+r)^n - 1)
  static double emi({
    required double principal,
    required double annualRatePercent,
    required int tenureMonths,
  }) {
    if (tenureMonths == 0) return 0;
    if (annualRatePercent == 0) return principal / tenureMonths;
    final r = annualRatePercent / 100 / 12;
    final n = tenureMonths;
    final factor = pow(1 + r, n);
    return principal * r * factor / (factor - 1);
  }

  /// Total interest paid over loan tenure.
  static double totalInterest({
    required double principal,
    required double annualRatePercent,
    required int tenureMonths,
  }) {
    final monthlyEmi = emi(
      principal: principal,
      annualRatePercent: annualRatePercent,
      tenureMonths: tenureMonths,
    );
    return monthlyEmi * tenureMonths - principal;
  }

  /// MPBF (Maximum Permissible Bank Finance) — Tandon Committee Method II.
  /// MPBF = 75% of (Current Assets - Current Liabilities excl. bank borrowings)
  static double mpbf({
    required double currentAssets,
    required double currentLiabilities,
    required double existingBankBorrowings,
  }) {
    final workingCapitalGap =
        currentAssets - (currentLiabilities - existingBankBorrowings);
    final result = workingCapitalGap * 0.75;
    return result < 0 ? 0 : result;
  }

  /// DSCR (Debt Service Coverage Ratio) = EBITDA / Total Debt Service.
  /// Banks require >= 1.25 for project loans.
  static double dscr({
    required double ebitda,
    required double annualEmi,
    required double annualInterest,
  }) {
    final debtService = annualEmi + annualInterest;
    if (debtService == 0) return 0;
    return ebitda / debtService;
  }

  /// DSCR status label.
  static String dscrStatus(double dscrValue) {
    if (dscrValue >= 1.5) return 'Excellent';
    if (dscrValue >= 1.25) return 'Acceptable';
    if (dscrValue >= 1.0) return 'Marginal';
    return 'Poor';
  }

  /// NPV = sum of (cashFlow[t] / (1+r)^t) - initialInvestment.
  static double npv({
    required double initialInvestment,
    required List<double> annualCashFlows,
    required double discountRatePercent,
  }) {
    final r = discountRatePercent / 100;
    double sum = -initialInvestment;
    for (int t = 1; t <= annualCashFlows.length; t++) {
      sum += annualCashFlows[t - 1] / pow(1 + r, t);
    }
    return sum;
  }

  /// IRR approximation using the bisection method.
  /// Returns the IRR as a percentage (e.g. 15.5 for 15.5%).
  static double irr({
    required double initialInvestment,
    required List<double> annualCashFlows,
  }) {
    double low = -0.99;
    double high = 10.0;
    for (int i = 0; i < 100; i++) {
      final mid = (low + high) / 2;
      final n = npv(
        initialInvestment: initialInvestment,
        annualCashFlows: annualCashFlows,
        discountRatePercent: mid * 100,
      );
      if (n > 0) {
        low = mid;
      } else {
        high = mid;
      }
      if ((high - low).abs() < 0.0001) break;
    }
    return (low + high) / 2 * 100;
  }

  /// Approximate payback period in years.
  static double paybackPeriod({
    required double initialInvestment,
    required List<double> annualCashFlows,
  }) {
    double cumulative = 0;
    for (int i = 0; i < annualCashFlows.length; i++) {
      cumulative += annualCashFlows[i];
      if (cumulative >= initialInvestment) {
        final prev = cumulative - annualCashFlows[i];
        final fraction = (initialInvestment - prev) / annualCashFlows[i];
        return i + fraction;
      }
    }
    return double.infinity;
  }

  /// Full amortization schedule — one [AmortizationRow] per month.
  static List<AmortizationRow> amortizationSchedule({
    required double principal,
    required double annualRatePercent,
    required int tenureMonths,
  }) {
    final r = annualRatePercent / 100 / 12;
    final monthlyEmi = emi(
      principal: principal,
      annualRatePercent: annualRatePercent,
      tenureMonths: tenureMonths,
    );
    final rows = <AmortizationRow>[];
    double balance = principal;
    for (int month = 1; month <= tenureMonths; month++) {
      final interest = balance * r;
      final principalPart = monthlyEmi - interest;
      balance = (balance - principalPart).clamp(0, double.infinity);
      rows.add(
        AmortizationRow(
          month: month,
          emi: monthlyEmi,
          principal: principalPart,
          interest: interest,
          balance: balance,
        ),
      );
    }
    return List.unmodifiable(rows);
  }
}

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
    list.add(
      _projection(
        year: startYear + i,
        sales: sales,
        cogsPct: cogsPct,
        opexPct: opexPct,
        currentAssets: assets,
        currentLiabilities: liabilities,
        totalDebt: totalDebt,
        netWorth: nw,
        annualDebtService: annualDebtService,
      ),
    );
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
  final schedule = buildAmortizationSchedule(
    loanAmount,
    annualRate,
    tenureMonths,
    emi,
  );
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

  final totalRequested = reports.fold<double>(
    0,
    (sum, r) => sum + r.requestedAmount,
  );
  final totalSanctioned = reports
      .where((r) => r.sanctionedAmount != null)
      .fold<double>(0, (sum, r) => sum + (r.sanctionedAmount ?? 0));
  final pending = reports
      .where((r) => r.status == CmaReportStatus.submitted)
      .length;
  final totalEmi = loans.fold<double>(0, (sum, l) => sum + l.emi);

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
