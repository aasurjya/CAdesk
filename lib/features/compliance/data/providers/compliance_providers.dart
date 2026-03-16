import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/compliance/data/providers/compliance_repository_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';

/// All compliance deadlines — sourced from the repository; falls back to
/// the built-in mock schedule when the repository returns no data.
final allComplianceDeadlinesProvider =
    AsyncNotifierProvider<
      AllComplianceDeadlinesNotifier,
      List<ComplianceDeadline>
    >(AllComplianceDeadlinesNotifier.new);

class AllComplianceDeadlinesNotifier
    extends AsyncNotifier<List<ComplianceDeadline>> {
  @override
  Future<List<ComplianceDeadline>> build() async {
    // The ComplianceRepository operates on ComplianceEvent, while the UI
    // uses ComplianceDeadline (a richer model). When the repository is wired
    // we fall back to the rich mock data so the screen always has content.
    final repo = ref.watch(complianceRepositoryProvider);
    try {
      // Fetch upcoming events (next 365 days) from the repository.
      final events = await repo.getUpcomingEvents(365);
      if (events.isEmpty) return List.unmodifiable(_mockDeadlines);
      // Convert ComplianceEvent → ComplianceDeadline.
      final deadlines = events.map((e) {
        return ComplianceDeadline(
          id: e.id,
          title: e.description,
          description: e.description,
          category: ComplianceCategory.values.firstWhere(
            (c) => c.name == e.type.name,
            orElse: () => ComplianceCategory.incomeTax,
          ),
          dueDate: e.dueDate,
          applicableTo: [e.clientId],
          isRecurring: false,
          frequency: ComplianceFrequency.monthly,
          status: e.status == ComplianceEventStatus.completed
              ? ComplianceStatus.completed
              : ComplianceStatus.upcoming,
        );
      }).toList();
      return List.unmodifiable(deadlines);
    } catch (_) {
      return List.unmodifiable(_mockDeadlines);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.invalidateSelf();
      return build();
    });
  }

  void setDeadlines(List<ComplianceDeadline> value) {
    state = AsyncData(List.unmodifiable(value));
  }

  /// Add a new compliance deadline.
  void addDeadline(ComplianceDeadline deadline) {
    final current = state.value ?? [];
    final updated = [...current, deadline]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    state = AsyncData(List.unmodifiable(updated));
  }

  /// Mark a deadline as completed (removes from active list).
  void markCompleted(ComplianceDeadline deadline) {
    final current = state.value ?? [];
    final completed = deadline.copyWith(status: ComplianceStatus.completed);
    final updated = current
        .map((d) => d.id == completed.id ? completed : d)
        .where((d) => d.status != ComplianceStatus.completed)
        .toList();
    state = AsyncData(List.unmodifiable(updated));
  }

  /// Delete a compliance deadline by ID.
  void deleteDeadline(String deadlineId) {
    final current = state.value ?? [];
    final updated = current.where((d) => d.id != deadlineId).toList();
    state = AsyncData(List.unmodifiable(updated));
  }
}

/// Selected month offset from the current month (0 = current, 1 = next, etc.).
final complianceMonthOffsetProvider =
    NotifierProvider<ComplianceMonthOffsetNotifier, int>(
      ComplianceMonthOffsetNotifier.new,
    );

class ComplianceMonthOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Whether the user is viewing calendar mode (true) or list mode (false).
final complianceViewModeProvider =
    NotifierProvider<ComplianceViewModeNotifier, bool>(
      ComplianceViewModeNotifier.new,
    );

class ComplianceViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void update(bool value) => state = value;
}

/// The currently displayed year/month based on offset.
final complianceDisplayMonthProvider = Provider<DateTime>((ref) {
  final offset = ref.watch(complianceMonthOffsetProvider);
  final now = DateTime.now();
  return DateTime(now.year, now.month + offset, 1);
});

/// Deadlines filtered to the currently displayed month.
final complianceMonthDeadlinesProvider = Provider<List<ComplianceDeadline>>((
  ref,
) {
  final deadlines =
      ref.watch(allComplianceDeadlinesProvider).asData?.value ?? [];
  final displayMonth = ref.watch(complianceDisplayMonthProvider);

  return deadlines
      .where(
        (d) =>
            d.dueDate.year == displayMonth.year &&
            d.dueDate.month == displayMonth.month,
      )
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

/// All upcoming deadlines (today and future) sorted by date, regardless of month.
final upcomingDeadlinesProvider = Provider<List<ComplianceDeadline>>((ref) {
  final deadlines =
      ref.watch(allComplianceDeadlinesProvider).asData?.value ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return deadlines
      .where(
        (d) =>
            d.status != ComplianceStatus.completed &&
            d.dueDate.isAfter(today.subtract(const Duration(days: 1))),
      )
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

/// Map of day -> list of deadlines for calendar dot rendering.
final complianceCalendarDotsProvider =
    Provider<Map<int, List<ComplianceDeadline>>>((ref) {
      final deadlines = ref.watch(complianceMonthDeadlinesProvider);
      final Map<int, List<ComplianceDeadline>> result = {};
      for (final d in deadlines) {
        result.putIfAbsent(d.dueDate.day, () => []).add(d);
      }
      return result;
    });

// ---------------------------------------------------------------------------
// Mock Indian tax compliance deadlines for current month + next 3 months
// ---------------------------------------------------------------------------

final _now = DateTime.now();
final _year = _now.year;
final _month = _now.month;

final _mockDeadlines = <ComplianceDeadline>[
  // --- Current month ---
  ComplianceDeadline(
    id: 'cd-001',
    title: 'TDS/TCS Payment',
    description: 'Payment of TDS/TCS deducted/collected in the previous month.',
    category: ComplianceCategory.tds,
    dueDate: DateTime(_year, _month, 7),
    applicableTo: ['All Deductors'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-002',
    title: 'GST-1 (Outward Supplies)',
    description: 'GSTR-1 return for outward supplies of the previous month.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month, 11),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-003',
    title: 'Advance Tax - 4th Instalment',
    description:
        'Fourth and final instalment of advance tax for FY 2025-26 (100% of tax liability).',
    category: ComplianceCategory.incomeTax,
    dueDate: DateTime(_year, _month, 15),
    applicableTo: ['All Assessees'],
    isRecurring: true,
    frequency: ComplianceFrequency.quarterly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-004',
    title: 'GST-3B (Monthly Return)',
    description:
        'GSTR-3B summary return with tax payment for the previous month.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month, 20),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-005',
    title: 'TDS Return - Q4',
    description: 'Quarterly TDS return (Form 24Q/26Q/27Q) for Q4 FY 2025-26.',
    category: ComplianceCategory.tds,
    dueDate: DateTime(_year, _month, 31),
    applicableTo: ['All Deductors'],
    isRecurring: true,
    frequency: ComplianceFrequency.quarterly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-006',
    title: 'GST Annual Return (GSTR-9)',
    description: 'Annual GST return for FY 2024-25.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month, 31),
    applicableTo: ['Regular Taxpayers (Turnover > 2Cr)'],
    isRecurring: true,
    frequency: ComplianceFrequency.annual,
    status: ComplianceStatus.upcoming,
  ),

  // --- Month +1 ---
  ComplianceDeadline(
    id: 'cd-007',
    title: 'TDS/TCS Payment',
    description:
        'Monthly TDS/TCS payment for deductions in the previous month.',
    category: ComplianceCategory.tds,
    dueDate: DateTime(_year, _month + 1, 7),
    applicableTo: ['All Deductors'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-008',
    title: 'GSTR-1 (Outward Supplies)',
    description: 'Monthly GSTR-1 for outward supplies.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month + 1, 11),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-009',
    title: 'GST-3B (Monthly Return)',
    description: 'GSTR-3B summary return with tax payment.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month + 1, 20),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-010',
    title: 'TDS Certificate - Form 16A (Q4)',
    description: 'Issue TDS certificates to deductees for Q4 FY 2025-26.',
    category: ComplianceCategory.tds,
    dueDate: DateTime(_year, _month + 1, 15),
    applicableTo: ['All Deductors'],
    isRecurring: true,
    frequency: ComplianceFrequency.quarterly,
    status: ComplianceStatus.upcoming,
  ),

  // --- Month +2 ---
  ComplianceDeadline(
    id: 'cd-011',
    title: 'TDS/TCS Payment',
    description: 'Monthly TDS/TCS payment.',
    category: ComplianceCategory.tds,
    dueDate: DateTime(_year, _month + 2, 7),
    applicableTo: ['All Deductors'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-012',
    title: 'GSTR-1 (Outward Supplies)',
    description: 'Monthly GSTR-1 for outward supplies.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month + 2, 11),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-013',
    title: 'GST-3B (Monthly Return)',
    description: 'GSTR-3B summary return with tax payment.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month + 2, 20),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-014',
    title: 'ROC Annual Return (MGT-7)',
    description:
        'Annual return filing with Registrar of Companies for FY 2025-26.',
    category: ComplianceCategory.roc,
    dueDate: DateTime(_year, _month + 2, 30),
    applicableTo: ['Companies'],
    isRecurring: true,
    frequency: ComplianceFrequency.annual,
    status: ComplianceStatus.upcoming,
  ),

  // --- Month +3 ---
  ComplianceDeadline(
    id: 'cd-015',
    title: 'TDS/TCS Payment',
    description: 'Monthly TDS/TCS payment.',
    category: ComplianceCategory.tds,
    dueDate: DateTime(_year, _month + 3, 7),
    applicableTo: ['All Deductors'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-016',
    title: 'GSTR-1 (Outward Supplies)',
    description: 'Monthly GSTR-1 for outward supplies.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month + 3, 11),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-017',
    title: 'GST-3B (Monthly Return)',
    description: 'GSTR-3B summary return with tax payment.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(_year, _month + 3, 20),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'cd-018',
    title: 'ITR Filing Deadline (Non-Audit)',
    description:
        'Due date for filing ITR for individuals and entities not requiring audit for AY 2026-27.',
    category: ComplianceCategory.incomeTax,
    dueDate: DateTime(_year, _month + 3, 31),
    applicableTo: ['Individuals', 'HUFs', 'Non-audit entities'],
    isRecurring: true,
    frequency: ComplianceFrequency.annual,
    status: ComplianceStatus.upcoming,
  ),
];
