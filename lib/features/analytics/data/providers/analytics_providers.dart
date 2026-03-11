import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/analytics/domain/models/aging_receivable.dart';
import 'package:ca_app/features/analytics/domain/models/growth_opportunity.dart';
import 'package:ca_app/features/analytics/domain/models/kpi_metric.dart';
import 'package:ca_app/features/analytics/domain/models/revenue_data.dart';
import 'package:ca_app/features/billing/data/providers/billing_providers.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/income_tax/data/providers/income_tax_providers.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';

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
      AnalyticsPeriodNotifier.new,
    );

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
      KpiMetricsNotifier.new,
    );

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
      RevenueDataNotifier.new,
    );

class RevenueDataNotifier extends Notifier<List<RevenueData>> {
  @override
  List<RevenueData> build() => List.unmodifiable(_mockRevenue);

  void update(List<RevenueData> value) => state = value;
}

final _mockRevenue = <RevenueData>[
  const RevenueData(
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    serviceType: 'ITR Filing',
    amount: 15000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    serviceType: 'GST Filing',
    amount: 8000,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    serviceType: 'Audit',
    amount: 150000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    serviceType: 'GST Filing',
    amount: 12000,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    serviceType: 'TDS Return',
    amount: 10000,
    month: 3,
    year: 2026,
  ),
  const RevenueData(
    clientId: '4',
    clientName: 'Mehta & Sons',
    serviceType: 'Bookkeeping',
    amount: 18000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '4',
    clientName: 'Mehta & Sons',
    serviceType: 'GST Filing',
    amount: 7500,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    serviceType: 'Payroll',
    amount: 25000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    serviceType: 'TDS Return',
    amount: 12000,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    serviceType: 'GST Filing',
    amount: 10000,
    month: 3,
    year: 2026,
  ),
  const RevenueData(
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    serviceType: 'Audit',
    amount: 250000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    serviceType: 'Payroll',
    amount: 45000,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    serviceType: 'GST Filing',
    amount: 15000,
    month: 3,
    year: 2026,
  ),
  const RevenueData(
    clientId: '9',
    clientName: 'Deepak Patel',
    serviceType: 'ITR Filing',
    amount: 8000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '9',
    clientName: 'Deepak Patel',
    serviceType: 'GST Filing',
    amount: 5000,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    serviceType: 'GST Filing',
    amount: 9000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    serviceType: 'TDS Return',
    amount: 8000,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '14',
    clientName: 'Vikram Singh Rathore',
    serviceType: 'ITR Filing',
    amount: 12000,
    month: 1,
    year: 2026,
  ),
  const RevenueData(
    clientId: '14',
    clientName: 'Vikram Singh Rathore',
    serviceType: 'Bookkeeping',
    amount: 20000,
    month: 2,
    year: 2026,
  ),
  const RevenueData(
    clientId: '2',
    clientName: 'Priya Mehta',
    serviceType: 'ITR Filing',
    amount: 10000,
    month: 3,
    year: 2026,
  ),
];

// ---------------------------------------------------------------------------
// Aging receivables — 15 records
// ---------------------------------------------------------------------------

final agingReceivablesProvider =
    NotifierProvider<AgingReceivablesNotifier, List<AgingReceivable>>(
      AgingReceivablesNotifier.new,
    );

class AgingReceivablesNotifier extends Notifier<List<AgingReceivable>> {
  @override
  List<AgingReceivable> build() => List.unmodifiable(_mockReceivables);

  void update(List<AgingReceivable> value) => state = value;
}

final _now = DateTime.now();

final _mockReceivables = <AgingReceivable>[
  AgingReceivable(
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    invoiceId: 'INV-2026-001',
    amount: 15000,
    dueDate: _now,
    daysPastDue: 0,
    bucket: AgingBucket.current,
  ),
  AgingReceivable(
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    invoiceId: 'INV-2026-002',
    amount: 75000,
    dueDate: _now.subtract(const Duration(days: 10)),
    daysPastDue: 10,
    bucket: AgingBucket.days30,
  ),
  AgingReceivable(
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    invoiceId: 'INV-2026-003',
    amount: 45000,
    dueDate: _now.subtract(const Duration(days: 25)),
    daysPastDue: 25,
    bucket: AgingBucket.days30,
  ),
  AgingReceivable(
    clientId: '4',
    clientName: 'Mehta & Sons',
    invoiceId: 'INV-2026-004',
    amount: 18000,
    dueDate: _now.subtract(const Duration(days: 5)),
    daysPastDue: 5,
    bucket: AgingBucket.days30,
  ),
  AgingReceivable(
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    invoiceId: 'INV-2026-005',
    amount: 25000,
    dueDate: _now.subtract(const Duration(days: 35)),
    daysPastDue: 35,
    bucket: AgingBucket.days60,
  ),
  AgingReceivable(
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    invoiceId: 'INV-2026-006',
    amount: 12000,
    dueDate: _now.subtract(const Duration(days: 42)),
    daysPastDue: 42,
    bucket: AgingBucket.days60,
  ),
  AgingReceivable(
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    invoiceId: 'INV-2026-007',
    amount: 95000,
    dueDate: _now.subtract(const Duration(days: 65)),
    daysPastDue: 65,
    bucket: AgingBucket.days90,
  ),
  AgingReceivable(
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    invoiceId: 'INV-2026-008',
    amount: 45000,
    dueDate: _now.subtract(const Duration(days: 72)),
    daysPastDue: 72,
    bucket: AgingBucket.days90,
  ),
  AgingReceivable(
    clientId: '9',
    clientName: 'Deepak Patel',
    invoiceId: 'INV-2026-009',
    amount: 8000,
    dueDate: _now.subtract(const Duration(days: 15)),
    daysPastDue: 15,
    bucket: AgingBucket.days30,
  ),
  AgingReceivable(
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    invoiceId: 'INV-2026-010',
    amount: 17000,
    dueDate: _now.subtract(const Duration(days: 50)),
    daysPastDue: 50,
    bucket: AgingBucket.days60,
  ),
  AgingReceivable(
    clientId: '14',
    clientName: 'Vikram Singh Rathore',
    invoiceId: 'INV-2026-011',
    amount: 12000,
    dueDate: _now.subtract(const Duration(days: 95)),
    daysPastDue: 95,
    bucket: AgingBucket.over90,
  ),
  AgingReceivable(
    clientId: '2',
    clientName: 'Priya Mehta',
    invoiceId: 'INV-2026-012',
    amount: 10000,
    dueDate: _now.subtract(const Duration(days: 8)),
    daysPastDue: 8,
    bucket: AgingBucket.days30,
  ),
  AgingReceivable(
    clientId: '7',
    clientName: 'Anil Gupta HUF',
    invoiceId: 'INV-2026-013',
    amount: 6000,
    dueDate: _now.subtract(const Duration(days: 100)),
    daysPastDue: 100,
    bucket: AgingBucket.over90,
  ),
  AgingReceivable(
    clientId: '10',
    clientName: 'Sharma Charitable Trust',
    invoiceId: 'INV-2026-014',
    amount: 22000,
    dueDate: _now.subtract(const Duration(days: 55)),
    daysPastDue: 55,
    bucket: AgingBucket.days60,
  ),
  AgingReceivable(
    clientId: '12',
    clientName: 'Hindustan Traders AOP',
    invoiceId: 'INV-2026-015',
    amount: 20000,
    dueDate: _now.subtract(const Duration(days: 88)),
    daysPastDue: 88,
    bucket: AgingBucket.days90,
  ),
];

final growthOpportunitiesProvider = Provider<List<GrowthOpportunity>>((ref) {
  return List.unmodifiable(_mockGrowthOpportunities);
});

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// KPIs filtered by a specific category.
final kpisByCategoryProvider = Provider.family<List<KpiMetric>, KpiCategory>((
  ref,
  category,
) {
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
final receivablesByBucketProvider = Provider<Map<AgingBucket, double>>((ref) {
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

// ---------------------------------------------------------------------------
// PracticeKpi — cross-module KPI computed from real mock data
// ---------------------------------------------------------------------------

class PracticeKpi {
  const PracticeKpi({
    required this.totalRevenue,
    required this.revenueGrowthPercent,
    required this.totalClients,
    required this.activeClients,
    required this.newClientsThisMonth,
    required this.churnedClients,
    required this.avgRevenuePerClient,
    required this.collectionEfficiency,
    required this.outstandingReceivables,
    required this.itrFilingCompletion,
    required this.gstComplianceRate,
    required this.utilization,
  });

  final double totalRevenue;
  final double revenueGrowthPercent;
  final int totalClients;
  final int activeClients;
  final int newClientsThisMonth;
  final int churnedClients;
  final double avgRevenuePerClient;
  final double collectionEfficiency;
  final double outstandingReceivables;
  final double itrFilingCompletion;
  final double gstComplianceRate;
  final double utilization;

  String get revenueGrowthLabel {
    if (revenueGrowthPercent >= 0) {
      return '+${revenueGrowthPercent.toStringAsFixed(1)}%';
    }
    return '${revenueGrowthPercent.toStringAsFixed(1)}%';
  }

  PracticeKpi copyWith({
    double? totalRevenue,
    double? revenueGrowthPercent,
    int? totalClients,
    int? activeClients,
    int? newClientsThisMonth,
    int? churnedClients,
    double? avgRevenuePerClient,
    double? collectionEfficiency,
    double? outstandingReceivables,
    double? itrFilingCompletion,
    double? gstComplianceRate,
    double? utilization,
  }) {
    return PracticeKpi(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      revenueGrowthPercent: revenueGrowthPercent ?? this.revenueGrowthPercent,
      totalClients: totalClients ?? this.totalClients,
      activeClients: activeClients ?? this.activeClients,
      newClientsThisMonth: newClientsThisMonth ?? this.newClientsThisMonth,
      churnedClients: churnedClients ?? this.churnedClients,
      avgRevenuePerClient: avgRevenuePerClient ?? this.avgRevenuePerClient,
      collectionEfficiency: collectionEfficiency ?? this.collectionEfficiency,
      outstandingReceivables:
          outstandingReceivables ?? this.outstandingReceivables,
      itrFilingCompletion: itrFilingCompletion ?? this.itrFilingCompletion,
      gstComplianceRate: gstComplianceRate ?? this.gstComplianceRate,
      utilization: utilization ?? this.utilization,
    );
  }
}

// ---------------------------------------------------------------------------
// RevenueBreakdown — 6-month revenue split by service type
// ---------------------------------------------------------------------------

class RevenueBreakdown {
  const RevenueBreakdown({
    required this.period,
    required this.itrRevenue,
    required this.gstRevenue,
    required this.auditRevenue,
    required this.advisoryRevenue,
    required this.otherRevenue,
    required this.totalRevenue,
  });

  final String period;
  final double itrRevenue;
  final double gstRevenue;
  final double auditRevenue;
  final double advisoryRevenue;
  final double otherRevenue;
  final double totalRevenue;

  RevenueBreakdown copyWith({
    String? period,
    double? itrRevenue,
    double? gstRevenue,
    double? auditRevenue,
    double? advisoryRevenue,
    double? otherRevenue,
    double? totalRevenue,
  }) {
    return RevenueBreakdown(
      period: period ?? this.period,
      itrRevenue: itrRevenue ?? this.itrRevenue,
      gstRevenue: gstRevenue ?? this.gstRevenue,
      auditRevenue: auditRevenue ?? this.auditRevenue,
      advisoryRevenue: advisoryRevenue ?? this.advisoryRevenue,
      otherRevenue: otherRevenue ?? this.otherRevenue,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
}

// ---------------------------------------------------------------------------
// ClientHealthDistribution — healthy / attention / critical counts
// ---------------------------------------------------------------------------

class ClientHealthDistribution {
  const ClientHealthDistribution({
    required this.healthy,
    required this.attention,
    required this.critical,
    required this.total,
  });

  final int healthy;
  final int attention;
  final int critical;
  final int total;

  double get healthyPercent => total > 0 ? healthy / total * 100 : 0;
  double get attentionPercent => total > 0 ? attention / total * 100 : 0;
  double get criticalPercent => total > 0 ? critical / total * 100 : 0;

  ClientHealthDistribution copyWith({
    int? healthy,
    int? attention,
    int? critical,
    int? total,
  }) {
    return ClientHealthDistribution(
      healthy: healthy ?? this.healthy,
      attention: attention ?? this.attention,
      critical: critical ?? this.critical,
      total: total ?? this.total,
    );
  }
}

// ---------------------------------------------------------------------------
// practiceKpiProvider — derived from billing + clients + ITR mock data
// ---------------------------------------------------------------------------

final practiceKpiProvider = Provider<PracticeKpi>((ref) {
  final invoices = ref.watch(allInvoicesProvider);
  final clients = ref.watch(allClientsProvider);
  final itrClients = ref.watch(itrClientsProvider);

  // Revenue = sum of paid amounts across all non-cancelled invoices
  final totalRevenue = invoices
      .where((inv) => inv.status != InvoiceStatus.cancelled)
      .fold<double>(0, (sum, inv) => sum + inv.paidAmount);

  // Outstanding receivables = sum of balance due
  final outstandingReceivables = invoices.fold<double>(
    0,
    (sum, inv) => sum + inv.balanceDue,
  );

  // Total billed (excl cancelled) — for collection efficiency
  final totalBilled = invoices
      .where((inv) => inv.status != InvoiceStatus.cancelled)
      .fold<double>(0, (sum, inv) => sum + inv.grandTotal);

  final collectionEfficiency = totalBilled > 0
      ? (totalRevenue / totalBilled * 100)
      : 0.0;

  // Client counts
  final activeClients = clients
      .where((c) => c.status == ClientStatus.active)
      .length;
  final inactiveCount = clients
      .where((c) => c.status == ClientStatus.inactive)
      .length;

  // New clients this month — created in Mar 2026 (current month)
  final newClientsThisMonth = clients
      .where((c) => c.createdAt.month == 3 && c.createdAt.year == 2026)
      .length;

  // ITR filing completion: % of clients with filed/verified/processed status
  final itrFiled = itrClients
      .where(
        (c) =>
            c.filingStatus == FilingStatus.filed ||
            c.filingStatus == FilingStatus.verified ||
            c.filingStatus == FilingStatus.processed,
      )
      .length;
  final itrTotal = itrClients.length;
  final itrFilingCompletion = itrTotal > 0 ? (itrFiled / itrTotal * 100) : 0.0;

  // GST compliance: from mock — 10 out of 13 GST-registered clients compliant
  const gstComplianceRate = 76.9;

  // Avg revenue per client (active)
  final avgRevenuePerClient = activeClients > 0
      ? totalRevenue / activeClients
      : 0.0;

  // Revenue growth vs last year — hardcoded 14.2% YoY based on CA firm norms
  const revenueGrowthPercent = 14.2;

  // Staff utilization — hardcoded from KPI mock (kpi-10)
  const utilization = 78.0;

  return PracticeKpi(
    totalRevenue: totalRevenue,
    revenueGrowthPercent: revenueGrowthPercent,
    totalClients: clients.length,
    activeClients: activeClients,
    newClientsThisMonth: newClientsThisMonth,
    churnedClients: inactiveCount,
    avgRevenuePerClient: avgRevenuePerClient,
    collectionEfficiency: collectionEfficiency,
    outstandingReceivables: outstandingReceivables,
    itrFilingCompletion: itrFilingCompletion,
    gstComplianceRate: gstComplianceRate,
    utilization: utilization,
  );
});

// ---------------------------------------------------------------------------
// revenueBreakdownProvider — 6 months (Oct 2025 – Mar 2026) with service splits
// ---------------------------------------------------------------------------

final revenueBreakdownProvider = Provider<List<RevenueBreakdown>>((ref) {
  return List.unmodifiable(_mockRevenueBreakdown);
});

const _mockRevenueBreakdown = <RevenueBreakdown>[
  RevenueBreakdown(
    period: 'Oct 2025',
    itrRevenue: 120000,
    gstRevenue: 210000,
    auditRevenue: 350000,
    advisoryRevenue: 85000,
    otherRevenue: 45000,
    totalRevenue: 810000,
  ),
  RevenueBreakdown(
    period: 'Nov 2025',
    itrRevenue: 95000,
    gstRevenue: 230000,
    auditRevenue: 280000,
    advisoryRevenue: 110000,
    otherRevenue: 55000,
    totalRevenue: 770000,
  ),
  RevenueBreakdown(
    period: 'Dec 2025',
    itrRevenue: 180000,
    gstRevenue: 195000,
    auditRevenue: 420000,
    advisoryRevenue: 130000,
    otherRevenue: 60000,
    totalRevenue: 985000,
  ),
  RevenueBreakdown(
    period: 'Jan 2026',
    itrRevenue: 310000,
    gstRevenue: 215000,
    auditRevenue: 310000,
    advisoryRevenue: 145000,
    otherRevenue: 70000,
    totalRevenue: 1050000,
  ),
  RevenueBreakdown(
    period: 'Feb 2026',
    itrRevenue: 420000,
    gstRevenue: 240000,
    auditRevenue: 300000,
    advisoryRevenue: 160000,
    otherRevenue: 80000,
    totalRevenue: 1200000,
  ),
  RevenueBreakdown(
    period: 'Mar 2026',
    itrRevenue: 580000,
    gstRevenue: 260000,
    auditRevenue: 450000,
    advisoryRevenue: 185000,
    otherRevenue: 95000,
    totalRevenue: 1570000,
  ),
];

// ---------------------------------------------------------------------------
// clientHealthDistributionProvider — from _mockHealthScores data
// ---------------------------------------------------------------------------

final clientHealthDistributionProvider = Provider<ClientHealthDistribution>((
  ref,
) {
  // Scores from client_providers.dart _mockHealthScores:
  // >= 80 = Healthy: 1(92), 4(85), 6(88), 7(80), 9(83), 10(90), 13(81) = 7
  // >= 60 = Attention: 2(78), 3(61), 8(72), 12(76), 14(79) = 5
  // < 60 = Critical: 5(55), 11(58), 15(42) = 3
  const healthy = 7;
  const attention = 5;
  const critical = 3;
  const total = healthy + attention + critical;

  return const ClientHealthDistribution(
    healthy: healthy,
    attention: attention,
    critical: critical,
    total: total,
  );
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
