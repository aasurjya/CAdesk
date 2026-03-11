import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/virtual_cfo/domain/models/mis_report.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/cfo_scenario.dart';

// ---------------------------------------------------------------------------
// Mock data — MIS Reports (8 Indian SME clients)
// ---------------------------------------------------------------------------

const List<MisReport> _mockMisReports = [
  MisReport(
    id: 'mis-001',
    clientName: 'TechForge Solutions',
    reportType: 'Monthly P&L',
    period: 'Feb 2025',
    revenue: 85,
    expenses: 62,
    netProfit: 23,
    ebitdaMarginPercent: 32,
    cashBalance: 41,
    status: 'Delivered',
    keyHighlights: [
      'Revenue grew 12% MoM driven by new SaaS contracts',
      'Operating expenses stable; headcount addition deferred to Q1 FY26',
      'Cash runway extended to 8 months at current burn',
    ],
  ),
  MisReport(
    id: 'mis-002',
    clientName: 'GreenBuild Infra',
    reportType: 'Cash Flow',
    period: 'Feb 2025',
    revenue: 210,
    expenses: 178,
    netProfit: 32,
    ebitdaMarginPercent: 18,
    cashBalance: 56,
    status: 'Approved',
    keyHighlights: [
      'Collections improved 8% after debtor follow-up drive',
      'Advance payment to suppliers reduced working capital pressure',
    ],
  ),
  MisReport(
    id: 'mis-003',
    clientName: 'Mehta Exports',
    reportType: 'Board Pack',
    period: 'Q3 FY25',
    revenue: 450,
    expenses: 398,
    netProfit: 52,
    ebitdaMarginPercent: 14,
    cashBalance: 88,
    status: 'Delivered',
    keyHighlights: [
      'Export volume up 6% QoQ; USD/INR hedging saved ₹4.2L',
      'Receivables DSO reduced from 62 to 54 days',
      'Capex plan approved for new warehouse in Nhava Sheva',
    ],
  ),
  MisReport(
    id: 'mis-004',
    clientName: 'Sharma Clinics',
    reportType: 'KPI Dashboard',
    period: 'Feb 2025',
    revenue: 38,
    expenses: 27,
    netProfit: 11,
    ebitdaMarginPercent: 34,
    cashBalance: 19,
    status: 'Review',
    keyHighlights: [
      'OPD footfall increased 18% post digital marketing push',
      'Average revenue per patient up ₹320 vs last month',
    ],
  ),
  MisReport(
    id: 'mis-005',
    clientName: 'FoodBridge Logistics',
    reportType: 'Monthly P&L',
    period: 'Feb 2025',
    revenue: 125,
    expenses: 108,
    netProfit: 17,
    ebitdaMarginPercent: 15,
    cashBalance: 22,
    status: 'Draft',
    keyHighlights: [
      'Fuel cost spike (12%) dented margins; rate revision under review',
      'Two new enterprise clients onboarded; revenue recognition from Mar',
    ],
  ),
  MisReport(
    id: 'mis-006',
    clientName: 'CloudNine SaaS',
    reportType: 'Balance Sheet',
    period: 'Q3 FY25',
    revenue: 95,
    expenses: 71,
    netProfit: 24,
    ebitdaMarginPercent: 29,
    cashBalance: 63,
    status: 'Delivered',
    keyHighlights: [
      'ARR crossed ₹11Cr milestone; net revenue retention at 118%',
      'Deferred revenue liability up 34% — strong advance billing quarter',
    ],
  ),
  MisReport(
    id: 'mis-007',
    clientName: 'Raj Steel Works',
    reportType: 'Cash Flow',
    period: 'Jan 2025',
    revenue: 340,
    expenses: 310,
    netProfit: 30,
    ebitdaMarginPercent: 10,
    cashBalance: 47,
    status: 'Approved',
    keyHighlights: [
      'Inventory buildup due to anticipatory procurement before price rise',
      'CC limit utilisation at 78%; OD margin comfortable',
    ],
  ),
  MisReport(
    id: 'mis-008',
    clientName: 'Bharat Pharma',
    reportType: 'Board Pack',
    period: 'Feb 2025',
    revenue: 180,
    expenses: 148,
    netProfit: 32,
    ebitdaMarginPercent: 20,
    cashBalance: 54,
    status: 'Draft',
    keyHighlights: [
      'Regulatory approval for two new SKUs expected in Q1 FY26',
      'R&D spend at 8.4% of revenue; on track with product roadmap',
      'Distribution network expansion to Tier-2 cities progressing well',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock data — CFO Scenarios (10 across clients and types)
// ---------------------------------------------------------------------------

const List<CfoScenario> _mockScenarios = [
  CfoScenario(
    id: 'scn-001',
    clientName: 'TechForge Solutions',
    scenarioName: 'Best Case',
    category: 'Revenue',
    baselineValue: 85,
    projectedValue: 110,
    impactPercent: 29.4,
    timeHorizon: 'Q1 FY26',
    assumption:
        'Two enterprise deals close by April; upsell adds ₹15L MRR uplift',
  ),
  CfoScenario(
    id: 'scn-002',
    clientName: 'TechForge Solutions',
    scenarioName: 'Cost Optimization',
    category: 'Cost',
    baselineValue: 62,
    projectedValue: 52,
    impactPercent: -16.1,
    timeHorizon: 'FY26',
    assumption:
        'Cloud infra renegotiation and vendor consolidation saves ₹10L/yr',
  ),
  CfoScenario(
    id: 'scn-003',
    clientName: 'GreenBuild Infra',
    scenarioName: 'Expansion Plan',
    category: 'Revenue',
    baselineValue: 210,
    projectedValue: 290,
    impactPercent: 38.1,
    timeHorizon: 'FY26',
    assumption: 'Pune project wins tender; adds ₹80L revenue over 9 months',
  ),
  CfoScenario(
    id: 'scn-004',
    clientName: 'GreenBuild Infra',
    scenarioName: 'Worst Case',
    category: 'Working Capital',
    baselineValue: 56,
    projectedValue: 28,
    impactPercent: -50.0,
    timeHorizon: 'Q1 FY26',
    assumption:
        'Client payment delay of 60 days on two projects; cash stress scenario',
  ),
  CfoScenario(
    id: 'scn-005',
    clientName: 'Mehta Exports',
    scenarioName: 'Base Case',
    category: 'Revenue',
    baselineValue: 450,
    projectedValue: 480,
    impactPercent: 6.7,
    timeHorizon: 'FY26',
    assumption: 'Steady volume growth of 6% with stable USD/INR at 84',
  ),
  CfoScenario(
    id: 'scn-006',
    clientName: 'Mehta Exports',
    scenarioName: 'Cost Optimization',
    category: 'Tax',
    baselineValue: 24,
    projectedValue: 18,
    impactPercent: -25.0,
    timeHorizon: 'FY26',
    assumption:
        'SEZ registration reduces effective tax rate; IGST refunds expedited',
  ),
  CfoScenario(
    id: 'scn-007',
    clientName: 'CloudNine SaaS',
    scenarioName: 'Expansion Plan',
    category: 'Funding',
    baselineValue: 63,
    projectedValue: 163,
    impactPercent: 158.7,
    timeHorizon: '3-year',
    assumption:
        'Series A of ₹10Cr closes Q2 FY26; deployed into sales and product',
  ),
  CfoScenario(
    id: 'scn-008',
    clientName: 'Raj Steel Works',
    scenarioName: 'Worst Case',
    category: 'Cost',
    baselineValue: 310,
    projectedValue: 355,
    impactPercent: 14.5,
    timeHorizon: 'Q1 FY26',
    assumption:
        'Steel coil prices rise 15%; input cost pressure cannot be passed on',
  ),
  CfoScenario(
    id: 'scn-009',
    clientName: 'Bharat Pharma',
    scenarioName: 'Best Case',
    category: 'Revenue',
    baselineValue: 180,
    projectedValue: 230,
    impactPercent: 27.8,
    timeHorizon: 'FY26',
    assumption:
        'Two new SKUs approved Q1; distribution push adds ₹50L top line',
  ),
  CfoScenario(
    id: 'scn-010',
    clientName: 'Sharma Clinics',
    scenarioName: 'Expansion Plan',
    category: 'Working Capital',
    baselineValue: 19,
    projectedValue: 35,
    impactPercent: 84.2,
    timeHorizon: '3-year',
    assumption:
        'Second clinic launch funded by term loan; DSCR remains above 1.4x',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All MIS reports — static mock data.
final allMisReportsProvider = Provider<List<MisReport>>((ref) {
  return List.unmodifiable(_mockMisReports);
});

/// All CFO scenarios — static mock data.
final allCfoScenariosProvider = Provider<List<CfoScenario>>((ref) {
  return List.unmodifiable(_mockScenarios);
});

// ---------------------------------------------------------------------------
// Filter notifiers
// ---------------------------------------------------------------------------

class _MisStatusNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

class _ScenarioCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Currently selected MIS report status filter (null = show all).
final selectedMisStatusProvider = NotifierProvider<_MisStatusNotifier, String?>(
  _MisStatusNotifier.new,
);

/// Currently selected scenario category filter (null = show all).
final selectedScenarioCategoryProvider =
    NotifierProvider<_ScenarioCategoryNotifier, String?>(
      _ScenarioCategoryNotifier.new,
    );

/// MIS reports filtered by the active status selection.
final filteredMisReportsProvider = Provider<List<MisReport>>((ref) {
  final all = ref.watch(allMisReportsProvider);
  final status = ref.watch(selectedMisStatusProvider);
  if (status == null) {
    return all;
  }
  return all.where((r) => r.status == status).toList();
});

/// CFO scenarios filtered by the active category selection.
final filteredCfoScenariosProvider = Provider<List<CfoScenario>>((ref) {
  final all = ref.watch(allCfoScenariosProvider);
  final category = ref.watch(selectedScenarioCategoryProvider);
  if (category == null) {
    return all;
  }
  return all.where((s) => s.category == category).toList();
});

/// Aggregated KPI summary across all MIS reports.
final virtualCfoKpiProvider = Provider<Map<String, String>>((ref) {
  final reports = ref.watch(allMisReportsProvider);

  final clientCount = reports.map((r) => r.clientName).toSet().length;

  final totalRevenue = reports.fold<double>(0, (sum, r) => sum + r.revenue);
  final totalRevenueCrore = totalRevenue / 100;

  final avgEbitda = reports.isEmpty
      ? 0.0
      : reports.fold<double>(0, (sum, r) => sum + r.ebitdaMarginPercent) /
            reports.length;

  final reportsThisMonth = reports
      .where((r) => r.period.contains('Feb 2025'))
      .length;

  return {
    'clients': '$clientCount',
    'aum': '₹${totalRevenueCrore.toStringAsFixed(1)}Cr',
    'avgEbitda': '${avgEbitda.toStringAsFixed(1)}%',
    'reportsThisMonth': '$reportsThisMonth',
  };
});
