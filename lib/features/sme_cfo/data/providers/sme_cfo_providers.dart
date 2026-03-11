import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/cfo_retainer.dart';
import '../../domain/models/cfo_deliverable.dart';

// ---------------------------------------------------------------------------
// Mock data — CFO Retainers (8 Indian SMEs across sectors)
// ---------------------------------------------------------------------------

final List<CfoRetainer> _mockRetainers = [
  CfoRetainer(
    id: 'ret-001',
    clientId: 'cli-001',
    clientName: 'Bharat Forge Components',
    industry: 'Manufacturing',
    monthlyFee: 35000,
    startDate: DateTime(2024, 4, 1),
    nextReviewDate: DateTime(2026, 4, 1),
    deliverables: const [
      'Monthly MIS Report',
      'Cash Flow Forecast',
      'Board Pack',
      'Advance Tax Calculation',
    ],
    status: CfoRetainerStatus.active,
    assignedPartner: 'Rajesh Sharma',
    healthScore: 88,
  ),
  CfoRetainer(
    id: 'ret-002',
    clientId: 'cli-002',
    clientName: 'SwiftCart India Pvt Ltd',
    industry: 'E-Commerce',
    monthlyFee: 18000,
    startDate: DateTime(2025, 1, 1),
    nextReviewDate: DateTime(2026, 3, 25),
    deliverables: const [
      'Monthly MIS Report',
      'GST Outflow Analysis',
      'Budget Variance Report',
    ],
    status: CfoRetainerStatus.active,
    assignedPartner: 'Priya Mehta',
    healthScore: 76,
  ),
  CfoRetainer(
    id: 'ret-003',
    clientId: 'cli-003',
    clientName: 'Horizon Realty Developers',
    industry: 'Real Estate',
    monthlyFee: 35000,
    startDate: DateTime(2023, 7, 1),
    nextReviewDate: DateTime(2026, 3, 15),
    deliverables: const [
      'Monthly MIS Report',
      'Cash Flow Forecast',
      'Tax Review',
      'Board Pack',
      'Advance Tax Calculation',
    ],
    status: CfoRetainerStatus.review,
    assignedPartner: 'Rajesh Sharma',
    healthScore: 62,
  ),
  CfoRetainer(
    id: 'ret-004',
    clientId: 'cli-004',
    clientName: 'The Spice Route Hospitality',
    industry: 'Hospitality',
    monthlyFee: 8000,
    startDate: DateTime(2025, 6, 1),
    nextReviewDate: DateTime(2026, 6, 1),
    deliverables: const [
      'Monthly MIS Report',
      'GST Outflow Analysis',
    ],
    status: CfoRetainerStatus.active,
    assignedPartner: 'Anil Kumar',
    healthScore: 82,
  ),
  CfoRetainer(
    id: 'ret-005',
    clientId: 'cli-005',
    clientName: 'Global Spices Export House',
    industry: 'Exports',
    monthlyFee: 18000,
    startDate: DateTime(2024, 10, 1),
    nextReviewDate: DateTime(2026, 4, 15),
    deliverables: const [
      'Monthly MIS Report',
      'Cash Flow Forecast',
      'Tax Review',
      'Budget Variance Report',
    ],
    status: CfoRetainerStatus.active,
    assignedPartner: 'Sunita Rao',
    healthScore: 91,
  ),
  CfoRetainer(
    id: 'ret-006',
    clientId: 'cli-006',
    clientName: 'MedPlus Generics Ltd',
    industry: 'Pharmaceuticals',
    monthlyFee: 35000,
    startDate: DateTime(2023, 1, 1),
    nextReviewDate: DateTime(2026, 1, 1),
    deliverables: const [
      'Monthly MIS Report',
      'Cash Flow Forecast',
      'Board Pack',
      'Tax Review',
      'Advance Tax Calculation',
      'GST Outflow Analysis',
    ],
    status: CfoRetainerStatus.onHold,
    assignedPartner: 'Vikram Joshi',
    healthScore: 45,
  ),
  CfoRetainer(
    id: 'ret-007',
    clientId: 'cli-007',
    clientName: 'CodeCraft Solutions',
    industry: 'IT Services',
    monthlyFee: 18000,
    startDate: DateTime(2025, 3, 1),
    nextReviewDate: DateTime(2026, 9, 1),
    deliverables: const [
      'Monthly MIS Report',
      'Tax Review',
      'Budget Variance Report',
      'Advance Tax Calculation',
    ],
    status: CfoRetainerStatus.active,
    assignedPartner: 'Priya Mehta',
    healthScore: 79,
  ),
  CfoRetainer(
    id: 'ret-008',
    clientId: 'cli-008',
    clientName: 'FastTrack Logistics Pvt Ltd',
    industry: 'Logistics',
    monthlyFee: 8000,
    startDate: DateTime(2024, 8, 1),
    nextReviewDate: DateTime(2026, 2, 1),
    deliverables: const [
      'Monthly MIS Report',
      'Cash Flow Forecast',
    ],
    status: CfoRetainerStatus.churned,
    assignedPartner: 'Anil Kumar',
    healthScore: 28,
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Deliverables (10 items across retainers)
// ---------------------------------------------------------------------------

final List<CfoDeliverable> _mockDeliverables = [
  CfoDeliverable(
    id: 'del-001',
    retainerId: 'ret-001',
    clientName: 'Bharat Forge Components',
    title: 'February 2026 MIS Report',
    deliverableType: DeliverableType.misReport,
    dueDate: DateTime(2026, 3, 10),
    status: DeliverableStatus.approved,
    completedAt: DateTime(2026, 3, 9),
  ),
  CfoDeliverable(
    id: 'del-002',
    retainerId: 'ret-001',
    clientName: 'Bharat Forge Components',
    title: 'Q4 FY2026 Cash Flow Forecast',
    deliverableType: DeliverableType.cashFlowForecast,
    dueDate: DateTime(2026, 3, 20),
    status: DeliverableStatus.inProgress,
  ),
  CfoDeliverable(
    id: 'del-003',
    retainerId: 'ret-002',
    clientName: 'SwiftCart India Pvt Ltd',
    title: 'February 2026 GST Outflow Analysis',
    deliverableType: DeliverableType.gstOutflow,
    dueDate: DateTime(2026, 3, 8),
    status: DeliverableStatus.delivered,
    completedAt: DateTime(2026, 3, 7),
  ),
  CfoDeliverable(
    id: 'del-004',
    retainerId: 'ret-002',
    clientName: 'SwiftCart India Pvt Ltd',
    title: 'FY2026 Budget vs Actuals — Feb',
    deliverableType: DeliverableType.budgetVariance,
    dueDate: DateTime(2026, 3, 5),
    status: DeliverableStatus.pending,
  ),
  CfoDeliverable(
    id: 'del-005',
    retainerId: 'ret-003',
    clientName: 'Horizon Realty Developers',
    title: 'Q4 FY2026 Board Pack',
    deliverableType: DeliverableType.boardPack,
    dueDate: DateTime(2026, 3, 12),
    status: DeliverableStatus.inProgress,
  ),
  CfoDeliverable(
    id: 'del-006',
    retainerId: 'ret-005',
    clientName: 'Global Spices Export House',
    title: 'Advance Tax — March 2026 Instalment',
    deliverableType: DeliverableType.advanceTaxCalc,
    dueDate: DateTime(2026, 3, 15),
    status: DeliverableStatus.pending,
  ),
  CfoDeliverable(
    id: 'del-007',
    retainerId: 'ret-005',
    clientName: 'Global Spices Export House',
    title: 'February 2026 MIS Report',
    deliverableType: DeliverableType.misReport,
    dueDate: DateTime(2026, 3, 10),
    status: DeliverableStatus.approved,
    completedAt: DateTime(2026, 3, 8),
  ),
  CfoDeliverable(
    id: 'del-008',
    retainerId: 'ret-007',
    clientName: 'CodeCraft Solutions',
    title: 'FY2026 Tax Review — Q4',
    deliverableType: DeliverableType.taxReview,
    dueDate: DateTime(2026, 3, 25),
    status: DeliverableStatus.pending,
  ),
  CfoDeliverable(
    id: 'del-009',
    retainerId: 'ret-004',
    clientName: 'The Spice Route Hospitality',
    title: 'February 2026 MIS Report',
    deliverableType: DeliverableType.misReport,
    dueDate: DateTime(2026, 3, 1),
    status: DeliverableStatus.delivered,
    completedAt: DateTime(2026, 3, 2),
  ),
  CfoDeliverable(
    id: 'del-010',
    retainerId: 'ret-006',
    clientName: 'MedPlus Generics Ltd',
    title: 'January 2026 MIS Report',
    deliverableType: DeliverableType.misReport,
    dueDate: DateTime(2026, 2, 10),
    status: DeliverableStatus.pending,
  ),
];

// ---------------------------------------------------------------------------
// Notifiers
// ---------------------------------------------------------------------------

class _CfoRetainersNotifier extends Notifier<List<CfoRetainer>> {
  @override
  List<CfoRetainer> build() => List.unmodifiable(_mockRetainers);
}

class _CfoDeliverablesNotifier extends Notifier<List<CfoDeliverable>> {
  @override
  List<CfoDeliverable> build() => List.unmodifiable(_mockDeliverables);
}

class RetainerStatusFilterNotifier extends Notifier<CfoRetainerStatus?> {
  @override
  CfoRetainerStatus? build() => null;

  void update(CfoRetainerStatus? value) => state = value;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All CFO retainers.
final allCfoRetainersProvider =
    NotifierProvider<_CfoRetainersNotifier, List<CfoRetainer>>(
  _CfoRetainersNotifier.new,
);

/// All deliverables across retainers.
final allDeliverablesProvider =
    NotifierProvider<_CfoDeliverablesNotifier, List<CfoDeliverable>>(
  _CfoDeliverablesNotifier.new,
);

/// Currently selected retainer status filter (null = show all).
final retainerStatusFilterProvider =
    NotifierProvider<RetainerStatusFilterNotifier, CfoRetainerStatus?>(
  RetainerStatusFilterNotifier.new,
);

/// Retainers filtered by the active status selection.
final filteredRetainersProvider = Provider<List<CfoRetainer>>((ref) {
  final filter = ref.watch(retainerStatusFilterProvider);
  final retainers = ref.watch(allCfoRetainersProvider);
  if (filter == null) return retainers;
  return retainers.where((r) => r.status == filter).toList();
});

/// Aggregated dashboard summary statistics.
final cfoDashboardSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final retainers = ref.watch(allCfoRetainersProvider);

  final totalRetainers = retainers.length;
  final activeRetainers =
      retainers.where((r) => r.status == CfoRetainerStatus.active).length;

  final monthlyRevenue = retainers
      .where((r) => r.status == CfoRetainerStatus.active)
      .fold<double>(0, (sum, r) => sum + r.monthlyFee);

  final avgHealthScore = retainers.isEmpty
      ? 0
      : (retainers.fold<int>(0, (sum, r) => sum + r.healthScore) ~/
          retainers.length);

  // Format monthly revenue in lakh notation
  final revenueInLakhs = monthlyRevenue / 100000;
  final formattedRevenue = revenueInLakhs >= 1
      ? '₹${revenueInLakhs.toStringAsFixed(1)}L'
      : '₹${(monthlyRevenue / 1000).toStringAsFixed(1)}K';

  return {
    'totalRetainers': totalRetainers,
    'activeRetainers': activeRetainers,
    'monthlyRevenue': formattedRevenue,
    'avgHealthScore': avgHealthScore,
  };
});
