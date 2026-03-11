import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/engagement.dart';
import '../../domain/models/scope_item.dart';

// ---------------------------------------------------------------------------
// Mock data - Engagements
// ---------------------------------------------------------------------------

final List<Engagement> _mockEngagements = [
  const Engagement(
    id: 'eng-001',
    clientId: 'cli-001',
    clientName: 'Reliance Industries Ltd',
    serviceType: 'Income Tax Return Filing',
    agreedFee: 150000,
    billedAmount: 120000,
    actualHours: 42,
    budgetHours: 35,
    status: EngagementStatus.underBilled,
  ),
  const Engagement(
    id: 'eng-002',
    clientId: 'cli-002',
    clientName: 'Tata Consultancy Services',
    serviceType: 'GST Returns',
    agreedFee: 80000,
    billedAmount: 80000,
    actualHours: 20,
    budgetHours: 22,
    status: EngagementStatus.onTrack,
  ),
  const Engagement(
    id: 'eng-003',
    clientId: 'cli-003',
    clientName: 'Infosys BPM Limited',
    serviceType: 'Statutory Audit',
    agreedFee: 500000,
    billedAmount: 500000,
    actualHours: 180,
    budgetHours: 160,
    status: EngagementStatus.overScope,
  ),
  const Engagement(
    id: 'eng-004',
    clientId: 'cli-004',
    clientName: 'Bajaj Finance Ltd',
    serviceType: 'TDS Compliance',
    agreedFee: 60000,
    billedAmount: 45000,
    actualHours: 28,
    budgetHours: 25,
    status: EngagementStatus.underBilled,
  ),
  const Engagement(
    id: 'eng-005',
    clientId: 'cli-005',
    clientName: 'Godrej Properties Ltd',
    serviceType: 'MCA Filing',
    agreedFee: 35000,
    billedAmount: 35000,
    actualHours: 10,
    budgetHours: 12,
    status: EngagementStatus.onTrack,
  ),
  const Engagement(
    id: 'eng-006',
    clientId: 'cli-006',
    clientName: 'Wipro Technologies Ltd',
    serviceType: 'Payroll Compliance',
    agreedFee: 120000,
    billedAmount: 90000,
    actualHours: 55,
    budgetHours: 40,
    status: EngagementStatus.disputed,
  ),
  const Engagement(
    id: 'eng-007',
    clientId: 'cli-007',
    clientName: 'Mahindra & Mahindra Ltd',
    serviceType: 'Transfer Pricing',
    agreedFee: 750000,
    billedAmount: 750000,
    actualHours: 210,
    budgetHours: 200,
    status: EngagementStatus.onTrack,
  ),
  const Engagement(
    id: 'eng-008',
    clientId: 'cli-008',
    clientName: 'ZestMoney Pvt Ltd',
    serviceType: 'Startup Compliance',
    agreedFee: 90000,
    billedAmount: 55000,
    actualHours: 38,
    budgetHours: 30,
    status: EngagementStatus.overScope,
  ),
];

// ---------------------------------------------------------------------------
// Mock data - Scope Items
// ---------------------------------------------------------------------------

final List<ScopeItem> _mockScopeItems = [
  ScopeItem(
    id: 'si-001',
    engagementId: 'eng-001',
    description: 'Preparation and filing of ITR-6 for FY2024-25',
    isInScope: true,
    addedAt: DateTime(2026, 1, 15),
    billedExtra: false,
  ),
  ScopeItem(
    id: 'si-002',
    engagementId: 'eng-001',
    description: 'Capital gains computation for listed securities',
    isInScope: false,
    addedAt: DateTime(2026, 2, 10),
    billedExtra: false,
  ),
  ScopeItem(
    id: 'si-003',
    engagementId: 'eng-003',
    description: 'Statutory audit of standalone financials',
    isInScope: true,
    addedAt: DateTime(2026, 1, 1),
    billedExtra: false,
  ),
  ScopeItem(
    id: 'si-004',
    engagementId: 'eng-003',
    description: 'Review of internal controls over financial reporting',
    isInScope: false,
    addedAt: DateTime(2026, 2, 20),
    billedExtra: true,
  ),
  ScopeItem(
    id: 'si-005',
    engagementId: 'eng-006',
    description: 'Monthly payroll processing for 500 employees',
    isInScope: true,
    addedAt: DateTime(2025, 10, 1),
    billedExtra: false,
  ),
  ScopeItem(
    id: 'si-006',
    engagementId: 'eng-006',
    description: 'Expatriate payroll and shadow payroll calculation',
    isInScope: false,
    addedAt: DateTime(2026, 1, 5),
    billedExtra: false,
  ),
  ScopeItem(
    id: 'si-007',
    engagementId: 'eng-008',
    description: 'DPIIT startup recognition filing',
    isInScope: true,
    addedAt: DateTime(2025, 11, 15),
    billedExtra: false,
  ),
  ScopeItem(
    id: 'si-008',
    engagementId: 'eng-008',
    description: 'ESOP scheme documentation and compliance',
    isInScope: false,
    addedAt: DateTime(2026, 2, 1),
    billedExtra: true,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All engagements.
final allEngagementsProvider = Provider<List<Engagement>>(
  (_) => List.unmodifiable(_mockEngagements),
);

/// All scope items.
final allScopeItemsProvider = Provider<List<ScopeItem>>(
  (_) => List.unmodifiable(_mockScopeItems),
);

/// Selected engagement status filter.
final engagementStatusFilterProvider =
    NotifierProvider<EngagementStatusFilterNotifier, EngagementStatus?>(
      EngagementStatusFilterNotifier.new,
    );

class EngagementStatusFilterNotifier extends Notifier<EngagementStatus?> {
  @override
  EngagementStatus? build() => null;

  void update(EngagementStatus? value) => state = value;
}

/// Engagements filtered by status.
final filteredEngagementsProvider = Provider<List<Engagement>>((ref) {
  final status = ref.watch(engagementStatusFilterProvider);
  final all = ref.watch(allEngagementsProvider);
  if (status == null) return all;
  return all.where((e) => e.status == status).toList();
});

/// Aggregate fee leakage summary statistics.
final feeLeakageSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final engagements = ref.watch(allEngagementsProvider);

  final totalLeakage = engagements.fold<double>(
    0,
    (sum, e) => sum + e.leakageAmount,
  );

  final onTrackCount = engagements
      .where((e) => e.status == EngagementStatus.onTrack)
      .length;
  final overScopeCount = engagements
      .where((e) => e.status == EngagementStatus.overScope)
      .length;
  final underBilledCount = engagements
      .where((e) => e.status == EngagementStatus.underBilled)
      .length;

  return <String, dynamic>{
    'totalLeakage': totalLeakage,
    'onTrack': onTrackCount,
    'overScope': overScopeCount,
    'underBilled': underBilledCount,
  };
});
