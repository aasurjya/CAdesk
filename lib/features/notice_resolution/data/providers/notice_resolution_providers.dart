import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/notice_case.dart';

// ---------------------------------------------------------------------------
// Mock data - 8 realistic Indian CA notices
// ---------------------------------------------------------------------------

final List<NoticeCase> _mockNotices = [
  NoticeCase(
    id: 'nc-001',
    clientId: 'cl-101',
    clientName: 'Reliance Industries Ltd',
    noticeType: NoticeType.scrutiny143_3,
    section: '143(3)',
    receivedDate: DateTime(2026, 1, 15),
    dueDate: DateTime(2026, 3, 20),
    status: NoticeStatus.pendingReview,
    severity: NoticeSeverity.critical,
    amountInDispute: 45000000,
    description:
        'Scrutiny assessment for AY 2023-24. AO raised queries on capital gains '
        'and deductions claimed under 80IC.',
  ),
  NoticeCase(
    id: 'nc-002',
    clientId: 'cl-102',
    clientName: 'Tata Consultancy Services',
    noticeType: NoticeType.tdsDefault,
    section: '201(1A)',
    receivedDate: DateTime(2026, 2, 3),
    dueDate: DateTime(2026, 3, 15),
    status: NoticeStatus.draftReady,
    severity: NoticeSeverity.high,
    amountInDispute: 8500000,
    description:
        'TDS short deduction demand for Q3 FY2024-25. Mismatch between 26AS '
        'and Form 16 data.',
  ),
  NoticeCase(
    id: 'nc-003',
    clientId: 'cl-103',
    clientName: 'Infosys BPM Ltd',
    noticeType: NoticeType.gstDemand,
    section: 'Section 73',
    receivedDate: DateTime(2026, 2, 18),
    dueDate: DateTime(2026, 4, 5),
    status: NoticeStatus.pendingReview,
    severity: NoticeSeverity.high,
    amountInDispute: 12000000,
    description:
        'GST demand for FY2022-23. Department alleges ITC reversal required on '
        'exempt supplies not separately accounted.',
  ),
  NoticeCase(
    id: 'nc-004',
    clientId: 'cl-104',
    clientName: 'Bajaj Auto Ltd',
    noticeType: NoticeType.reopening148,
    section: '148',
    receivedDate: DateTime(2026, 1, 8),
    dueDate: DateTime(2026, 3, 12),
    status: NoticeStatus.escalated,
    severity: NoticeSeverity.critical,
    amountInDispute: 32000000,
    description:
        'Reopening notice for AY 2021-22. AO has reason to believe income '
        'escaped assessment relating to foreign remittances.',
  ),
  NoticeCase(
    id: 'nc-005',
    clientId: 'cl-105',
    clientName: 'Godrej Properties Ltd',
    noticeType: NoticeType.intimation143_1,
    section: '143(1)',
    receivedDate: DateTime(2026, 2, 25),
    dueDate: DateTime(2026, 4, 15),
    status: NoticeStatus.draftReady,
    severity: NoticeSeverity.medium,
    amountInDispute: 1800000,
    description:
        'Intimation with demand arising from disallowance of deduction under '
        '80-IAB not supported by required certificate.',
  ),
  NoticeCase(
    id: 'nc-006',
    clientId: 'cl-106',
    clientName: 'Wipro Technologies Ltd',
    noticeType: NoticeType.penaltyNotice,
    section: '271AAB',
    receivedDate: DateTime(2025, 12, 10),
    dueDate: DateTime(2026, 3, 8),
    status: NoticeStatus.submitted,
    severity: NoticeSeverity.high,
    amountInDispute: 5600000,
    description:
        'Penalty notice under 271AAB consequent to search and seizure '
        'operation. Undisclosed income admitted during statement.',
  ),
  NoticeCase(
    id: 'nc-007',
    clientId: 'cl-107',
    clientName: 'Mahindra & Mahindra Ltd',
    noticeType: NoticeType.mcaNotice,
    section: 'Section 206',
    receivedDate: DateTime(2026, 1, 22),
    dueDate: DateTime(2026, 3, 30),
    status: NoticeStatus.pendingReview,
    severity: NoticeSeverity.medium,
    amountInDispute: 500000,
    description:
        'MCA show-cause notice regarding delayed filing of annual return. '
        'Compounding fees and penalty waiver sought.',
  ),
  NoticeCase(
    id: 'nc-008',
    clientId: 'cl-108',
    clientName: 'HDFC Bank Ltd',
    noticeType: NoticeType.scrutiny143_3,
    section: '143(3) r/w 144C',
    receivedDate: DateTime(2025, 11, 5),
    dueDate: DateTime(2026, 2, 28),
    status: NoticeStatus.closed,
    severity: NoticeSeverity.critical,
    amountInDispute: 78000000,
    description:
        'Transfer pricing scrutiny for AY 2022-23. DRP directions received; '
        'final order passed and appeal filed before ITAT.',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All notice cases (unmodifiable list).
final allNoticeCasesProvider =
    NotifierProvider<AllNoticeCasesNotifier, List<NoticeCase>>(
  AllNoticeCasesNotifier.new,
);

class AllNoticeCasesNotifier extends Notifier<List<NoticeCase>> {
  @override
  List<NoticeCase> build() => List.unmodifiable(_mockNotices);
}

/// Selected severity filter (null = show all).
final noticeSeverityFilterProvider =
    NotifierProvider<NoticeSeverityFilterNotifier, NoticeSeverity?>(
  NoticeSeverityFilterNotifier.new,
);

class NoticeSeverityFilterNotifier extends Notifier<NoticeSeverity?> {
  @override
  NoticeSeverity? build() => null;

  void update(NoticeSeverity? value) => state = value;
}

/// Notice cases filtered by severity.
final filteredNoticeCasesProvider = Provider<List<NoticeCase>>((ref) {
  final severity = ref.watch(noticeSeverityFilterProvider);
  final allCases = ref.watch(allNoticeCasesProvider);
  if (severity == null) return allCases;
  return allCases.where((c) => c.severity == severity).toList();
});

/// Summary statistics for notices.
final noticeSummaryProvider = Provider<Map<String, int>>((ref) {
  final allCases = ref.watch(allNoticeCasesProvider);
  final now = DateTime(2026, 3, 11);

  final total = allCases.length;
  final critical =
      allCases.where((c) => c.severity == NoticeSeverity.critical).length;
  final dueThisWeek = allCases
      .where((c) =>
          c.status != NoticeStatus.closed &&
          c.dueDate.isAfter(now) &&
          c.dueDate.difference(now).inDays <= 7)
      .length;
  final closed =
      allCases.where((c) => c.status == NoticeStatus.closed).length;

  return {
    'total': total,
    'critical': critical,
    'dueThisWeek': dueThisWeek,
    'closed': closed,
  };
});
