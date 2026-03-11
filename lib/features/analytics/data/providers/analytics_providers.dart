import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/analytics/domain/models/aging_receivable.dart';
import 'package:ca_app/features/analytics/domain/models/growth_opportunity.dart';
import 'package:ca_app/features/analytics/domain/models/kpi_metric.dart';
import 'package:ca_app/features/analytics/domain/models/revenue_data.dart';

// ---------------------------------------------------------------------------
// Period filter
// ---------------------------------------------------------------------------

enum AnalyticsPeriod {
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisQuarter('This Quarter'),
  thisYear('This Year');

  const AnalyticsPeriod(this.label);

  final String label;
}

final analyticsPeriodProvider =
    NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>(
        AnalyticsPeriodNotifier.new);

class AnalyticsPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() => AnalyticsPeriod.thisMonth;

  void update(AnalyticsPeriod value) => state = value;
}

// ---------------------------------------------------------------------------
// KPI metrics — 12 firm-level KPIs
// ---------------------------------------------------------------------------

final kpiMetricsProvider =
    NotifierProvider<KpiMetricsNotifier, List<KpiMetric>>(
        KpiMetricsNotifier.new);

class KpiMetricsNotifier extends Notifier<List<KpiMetric>> {
  @override
  List<KpiMetric> build() => List.unmodifiable(_mockKpis);

  void update(List<KpiMetric> value) => state = value;
}

final _mockKpis = <KpiMetric>[
  const KpiMetric(
    id: 'kpi-01',
    name: 'Total Revenue',
    category: KpiCategory.firm,
    currentValue: 1850000,
    previousValue: 1620000,
    target: 2000000,
    unit: '₹',
    trend: KpiTrend.up,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-02',
    name: 'Active Clients',
    category: KpiCategory.firm,
    currentValue: 142,
    previousValue: 135,
    target: 160,
    unit: '',
    trend: KpiTrend.up,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-03',
    name: 'New Clients',
    category: KpiCategory.firm,
    currentValue: 8,
    previousValue: 12,
    target: 15,
    unit: '',
    trend: KpiTrend.down,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-04',
    name: 'ITR Filings Done',
    category: KpiCategory.compliance,
    currentValue: 78,
    previousValue: 65,
    target: 100,
    unit: '',
    trend: KpiTrend.up,
    periodLabel: 'AY 2026-27',
  ),
  const KpiMetric(
    id: 'kpi-05',
    name: 'GST Returns Filed',
    category: KpiCategory.compliance,
    currentValue: 210,
    previousValue: 205,
    target: 220,
    unit: '',
    trend: KpiTrend.up,
    periodLabel: 'Feb 2026',
  ),
  const KpiMetric(
    id: 'kpi-06',
    name: 'Overdue Tasks',
    category: KpiCategory.compliance,
    currentValue: 7,
    previousValue: 4,
    target: 0,
    unit: '',
    trend: KpiTrend.up,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-07',
    name: 'Avg Revenue / Client',
    category: KpiCategory.engagement,
    currentValue: 13028,
    previousValue: 12000,
    target: 15000,
    unit: '₹',
    trend: KpiTrend.up,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-08',
    name: 'Collection Rate',
    category: KpiCategory.engagement,
    currentValue: 87,
    previousValue: 82,
    target: 95,
    unit: '%',
    trend: KpiTrend.up,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-09',
    name: 'Outstanding Receivables',
    category: KpiCategory.engagement,
    currentValue: 425000,
    previousValue: 380000,
    target: 200000,
    unit: '₹',
    trend: KpiTrend.up,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-10',
    name: 'Staff Utilisation',
    category: KpiCategory.staff,
    currentValue: 78,
    previousValue: 75,
    target: 85,
    unit: '%',
    trend: KpiTrend.up,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-11',
    name: 'Billable Hours Ratio',
    category: KpiCategory.staff,
    currentValue: 72,
    previousValue: 72,
    target: 80,
    unit: '%',
    trend: KpiTrend.flat,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-12',
    name: 'Avg Task Completion Days',
    category: KpiCategory.staff,
    currentValue: 4.2,
    previousValue: 5.1,
    target: 3.0,
    unit: 'days',
    trend: KpiTrend.down,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-13',
    name: 'Unprofitable Clients',
    category: KpiCategory.firm,
    currentValue: 9,
    previousValue: 12,
    target: 5,
    unit: '',
    trend: KpiTrend.down,
    periodLabel: 'Mar 2026',
  ),
  const KpiMetric(
    id: 'kpi-14',
    name: 'Churn Risk Clients',
    category: KpiCategory.engagement,
    currentValue: 6,
    previousValue: 8,
    target: 3,
    unit: '',
    trend: KpiTrend.down,
    periodLabel: 'Mar 2026',
  ),
];

// ---------------------------------------------------------------------------
// Revenue data — 20 records across clients
// ---------------------------------------------------------------------------

final revenueDataProvider =
    NotifierProvider<RevenueDataNotifier, List<RevenueData>>(
        RevenueDataNotifier.new);

class RevenueDataNotifier extends Notifier<List<RevenueData>> {
  @override
  List<RevenueData> build() => List.unmodifiable(_mockRevenue);

  void update(List<RevenueData> value) => state = value;
}

final _mockRevenue = <RevenueData>[
  const RevenueData(clientId: '1', clientName: 'Rajesh Kumar Sharma', serviceType: 'ITR Filing', amount: 15000, month: 1, year: 2026),
  const RevenueData(clientId: '1', clientName: 'Rajesh Kumar Sharma', serviceType: 'GST Filing', amount: 8000, month: 2, year: 2026),
  const RevenueData(clientId: '3', clientName: 'ABC Infra Pvt Ltd', serviceType: 'Audit', amount: 150000, month: 1, year: 2026),
  const RevenueData(clientId: '3', clientName: 'ABC Infra Pvt Ltd', serviceType: 'GST Filing', amount: 12000, month: 2, year: 2026),
  const RevenueData(clientId: '3', clientName: 'ABC Infra Pvt Ltd', serviceType: 'TDS Return', amount: 10000, month: 3, year: 2026),
  const RevenueData(clientId: '4', clientName: 'Mehta & Sons', serviceType: 'Bookkeeping', amount: 18000, month: 1, year: 2026),
  const RevenueData(clientId: '4', clientName: 'Mehta & Sons', serviceType: 'GST Filing', amount: 7500, month: 2, year: 2026),
  const RevenueData(clientId: '6', clientName: 'TechVista Solutions LLP', serviceType: 'Payroll', amount: 25000, month: 1, year: 2026),
  const RevenueData(clientId: '6', clientName: 'TechVista Solutions LLP', serviceType: 'TDS Return', amount: 12000, month: 2, year: 2026),
  const RevenueData(clientId: '6', clientName: 'TechVista Solutions LLP', serviceType: 'GST Filing', amount: 10000, month: 3, year: 2026),
  const RevenueData(clientId: '8', clientName: 'Bharat Electronics Ltd', serviceType: 'Audit', amount: 250000, month: 1, year: 2026),
  const RevenueData(clientId: '8', clientName: 'Bharat Electronics Ltd', serviceType: 'Payroll', amount: 45000, month: 2, year: 2026),
  const RevenueData(clientId: '8', clientName: 'Bharat Electronics Ltd', serviceType: 'GST Filing', amount: 15000, month: 3, year: 2026),
  const RevenueData(clientId: '9', clientName: 'Deepak Patel', serviceType: 'ITR Filing', amount: 8000, month: 1, year: 2026),
  const RevenueData(clientId: '9', clientName: 'Deepak Patel', serviceType: 'GST Filing', amount: 5000, month: 2, year: 2026),
  const RevenueData(clientId: '13', clientName: 'GreenLeaf Organics LLP', serviceType: 'GST Filing', amount: 9000, month: 1, year: 2026),
  const RevenueData(clientId: '13', clientName: 'GreenLeaf Organics LLP', serviceType: 'TDS Return', amount: 8000, month: 2, year: 2026),
  const RevenueData(clientId: '14', clientName: 'Vikram Singh Rathore', serviceType: 'ITR Filing', amount: 12000, month: 1, year: 2026),
  const RevenueData(clientId: '14', clientName: 'Vikram Singh Rathore', serviceType: 'Bookkeeping', amount: 20000, month: 2, year: 2026),
  const RevenueData(clientId: '2', clientName: 'Priya Mehta', serviceType: 'ITR Filing', amount: 10000, month: 3, year: 2026),
];

// ---------------------------------------------------------------------------
// Aging receivables — 15 records
// ---------------------------------------------------------------------------

final agingReceivablesProvider =
    NotifierProvider<AgingReceivablesNotifier, List<AgingReceivable>>(
        AgingReceivablesNotifier.new);

class AgingReceivablesNotifier extends Notifier<List<AgingReceivable>> {
  @override
  List<AgingReceivable> build() => List.unmodifiable(_mockReceivables);

  void update(List<AgingReceivable> value) => state = value;
}

final _now = DateTime.now();

final _mockReceivables = <AgingReceivable>[
  AgingReceivable(clientId: '1', clientName: 'Rajesh Kumar Sharma', invoiceId: 'INV-2026-001', amount: 15000, dueDate: _now, daysPastDue: 0, bucket: AgingBucket.current),
  AgingReceivable(clientId: '3', clientName: 'ABC Infra Pvt Ltd', invoiceId: 'INV-2026-002', amount: 75000, dueDate: _now.subtract(const Duration(days: 10)), daysPastDue: 10, bucket: AgingBucket.days30),
  AgingReceivable(clientId: '3', clientName: 'ABC Infra Pvt Ltd', invoiceId: 'INV-2026-003', amount: 45000, dueDate: _now.subtract(const Duration(days: 25)), daysPastDue: 25, bucket: AgingBucket.days30),
  AgingReceivable(clientId: '4', clientName: 'Mehta & Sons', invoiceId: 'INV-2026-004', amount: 18000, dueDate: _now.subtract(const Duration(days: 5)), daysPastDue: 5, bucket: AgingBucket.days30),
  AgingReceivable(clientId: '6', clientName: 'TechVista Solutions LLP', invoiceId: 'INV-2026-005', amount: 25000, dueDate: _now.subtract(const Duration(days: 35)), daysPastDue: 35, bucket: AgingBucket.days60),
  AgingReceivable(clientId: '6', clientName: 'TechVista Solutions LLP', invoiceId: 'INV-2026-006', amount: 12000, dueDate: _now.subtract(const Duration(days: 42)), daysPastDue: 42, bucket: AgingBucket.days60),
  AgingReceivable(clientId: '8', clientName: 'Bharat Electronics Ltd', invoiceId: 'INV-2026-007', amount: 95000, dueDate: _now.subtract(const Duration(days: 65)), daysPastDue: 65, bucket: AgingBucket.days90),
  AgingReceivable(clientId: '8', clientName: 'Bharat Electronics Ltd', invoiceId: 'INV-2026-008', amount: 45000, dueDate: _now.subtract(const Duration(days: 72)), daysPastDue: 72, bucket: AgingBucket.days90),
  AgingReceivable(clientId: '9', clientName: 'Deepak Patel', invoiceId: 'INV-2026-009', amount: 8000, dueDate: _now.subtract(const Duration(days: 15)), daysPastDue: 15, bucket: AgingBucket.days30),
  AgingReceivable(clientId: '13', clientName: 'GreenLeaf Organics LLP', invoiceId: 'INV-2026-010', amount: 17000, dueDate: _now.subtract(const Duration(days: 50)), daysPastDue: 50, bucket: AgingBucket.days60),
  AgingReceivable(clientId: '14', clientName: 'Vikram Singh Rathore', invoiceId: 'INV-2026-011', amount: 12000, dueDate: _now.subtract(const Duration(days: 95)), daysPastDue: 95, bucket: AgingBucket.over90),
  AgingReceivable(clientId: '2', clientName: 'Priya Mehta', invoiceId: 'INV-2026-012', amount: 10000, dueDate: _now.subtract(const Duration(days: 8)), daysPastDue: 8, bucket: AgingBucket.days30),
  AgingReceivable(clientId: '7', clientName: 'Anil Gupta HUF', invoiceId: 'INV-2026-013', amount: 6000, dueDate: _now.subtract(const Duration(days: 100)), daysPastDue: 100, bucket: AgingBucket.over90),
  AgingReceivable(clientId: '10', clientName: 'Sharma Charitable Trust', invoiceId: 'INV-2026-014', amount: 22000, dueDate: _now.subtract(const Duration(days: 55)), daysPastDue: 55, bucket: AgingBucket.days60),
  AgingReceivable(clientId: '12', clientName: 'Hindustan Traders AOP', invoiceId: 'INV-2026-015', amount: 20000, dueDate: _now.subtract(const Duration(days: 88)), daysPastDue: 88, bucket: AgingBucket.days90),
];

final growthOpportunitiesProvider =
    Provider<List<GrowthOpportunity>>((ref) {
  return List.unmodifiable(_mockGrowthOpportunities);
});

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// KPIs filtered by a specific category.
final kpisByCategoryProvider =
    Provider.family<List<KpiMetric>, KpiCategory>((ref, category) {
  final all = ref.watch(kpiMetricsProvider);
  return all.where((k) => k.category == category).toList();
});

/// Total revenue across all records.
final totalRevenueProvider = Provider<double>((ref) {
  final records = ref.watch(revenueDataProvider);
  return records.fold<double>(0, (sum, r) => sum + r.amount);
});

/// Revenue grouped by service type.
final revenueByServiceProvider = Provider<Map<String, double>>((ref) {
  final records = ref.watch(revenueDataProvider);
  final map = <String, double>{};
  for (final r in records) {
    map[r.serviceType] = (map[r.serviceType] ?? 0) + r.amount;
  }
  return Map.unmodifiable(map);
});

/// Total outstanding receivables by aging bucket.
final receivablesByBucketProvider =
    Provider<Map<AgingBucket, double>>((ref) {
  final records = ref.watch(agingReceivablesProvider);
  final map = <AgingBucket, double>{};
  for (final r in records) {
    map[r.bucket] = (map[r.bucket] ?? 0) + r.amount;
  }
  return Map.unmodifiable(map);
});

/// Grand total of all outstanding receivables.
final totalReceivablesProvider = Provider<double>((ref) {
  final records = ref.watch(agingReceivablesProvider);
  return records.fold<double>(0, (sum, r) => sum + r.amount);
});

final growthOpportunitiesByStageProvider =
    Provider<Map<GrowthOpportunityStage, int>>((ref) {
  final records = ref.watch(growthOpportunitiesProvider);
  final counts = <GrowthOpportunityStage, int>{};
  for (final item in GrowthOpportunityStage.values) {
    counts[item] = records.where((r) => r.stage == item).length;
  }
  return Map.unmodifiable(counts);
});

final totalGrowthPipelineValueProvider = Provider<double>((ref) {
  final records = ref.watch(growthOpportunitiesProvider);
  return records.fold<double>(0, (sum, item) => sum + item.estimatedFee);
});

final weightedGrowthPipelineValueProvider = Provider<double>((ref) {
  final records = ref.watch(growthOpportunitiesProvider);
  return records.fold<double>(
    0,
    (sum, item) => sum + (item.estimatedFee * item.conversionProbability),
  );
});

final topGrowthOpportunitiesProvider = Provider<List<GrowthOpportunity>>((ref) {
  final records = ref.watch(growthOpportunitiesProvider).toList()
    ..sort((a, b) => b.estimatedFee.compareTo(a.estimatedFee));
  return List.unmodifiable(records.take(4));
});

final _mockGrowthOpportunities = <GrowthOpportunity>[
  GrowthOpportunity(
    id: 'growth-001',
    clientName: 'Rajesh Kumar Sharma',
    title: 'Capital Gains Optimization Review',
    description:
        'ITR review flagged a missed loss set-off and advance-tax planning '
        'opportunity for AY 2026-27.',
    type: GrowthOpportunityType.advisory,
    stage: GrowthOpportunityStage.inDiscussion,
    estimatedFee: 18000,
    owner: 'Amit Verma',
    nextAction: 'Share advisory note + revised quote',
    nextActionDue: _now.add(const Duration(days: 2)),
    conversionProbability: 0.72,
  ),
  GrowthOpportunity(
    id: 'growth-002',
    clientName: 'Vikram Singh Rathore',
    title: 'GST Registration + CFO Retainer',
    description:
        'Onboarding activity and repeated bookkeeping requests indicate a '
        'strong fit for a monthly SME tax planning retainer.',
    type: GrowthOpportunityType.cfoRetainer,
    stage: GrowthOpportunityStage.proposalSent,
    estimatedFee: 96000,
    owner: 'Neha Kapoor',
    nextAction: 'Follow up on proposal and onboarding scope',
    nextActionDue: _now.add(const Duration(days: 1)),
    conversionProbability: 0.64,
  ),
  GrowthOpportunity(
    id: 'growth-003',
    clientName: 'GreenLeaf Organics LLP',
    title: 'Exporter Vertical Tax Pack',
    description:
        'Recurring GST/TDS work fits the exporter playbook with LUT, refund, '
        'and working-capital tax review bundle.',
    type: GrowthOpportunityType.verticalService,
    stage: GrowthOpportunityStage.identified,
    estimatedFee: 75000,
    owner: 'Ramesh Iyer',
    nextAction: 'Prepare vertical proposal deck',
    nextActionDue: _now.add(const Duration(days: 3)),
    conversionProbability: 0.46,
  ),
  GrowthOpportunity(
    id: 'growth-004',
    clientName: 'Priya Mehta',
    title: 'NRI Return + Foreign Asset Support',
    description:
        'Travel history and overseas holdings indicate a cross-border tax '
        'engagement opportunity for FY 2025-26.',
    type: GrowthOpportunityType.nri,
    stage: GrowthOpportunityStage.inDiscussion,
    estimatedFee: 42000,
    owner: 'Priya Nair',
    nextAction: 'Collect travel history and FTC documents',
    nextActionDue: _now.add(const Duration(days: 4)),
    conversionProbability: 0.58,
  ),
  GrowthOpportunity(
    id: 'growth-005',
    clientName: 'Dormant ITR Campaign',
    title: 'ITR-U Reactivation Campaign',
    description:
        'Seasonal campaign targeting 28 past clients with potential updated '
        'return and missed filing opportunities.',
    type: GrowthOpportunityType.campaign,
    stage: GrowthOpportunityStage.won,
    estimatedFee: 135000,
    owner: 'Campaign Desk',
    nextAction: 'Launch reminder batch 2',
    nextActionDue: _now.add(const Duration(days: 1)),
    conversionProbability: 0.91,
  ),
];
