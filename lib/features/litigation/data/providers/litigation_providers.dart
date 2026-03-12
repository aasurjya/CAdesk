import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';
import 'package:ca_app/features/litigation/domain/models/notice_triage_result.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/services/notice_triage_service.dart';
import 'package:ca_app/features/litigation/domain/services/response_template_service.dart';

// ---------------------------------------------------------------------------
// Mock data — fixed reference date: 12 Mar 2026
// ---------------------------------------------------------------------------

final _ref = DateTime(2026, 3, 12);

final _mockNotices = <TaxNotice>[
  TaxNotice(
    noticeId: 'NTC-001',
    pan: 'ABCDE1234F',
    assessmentYear: 'AY 2023-24',
    noticeType: NoticeType.intimation143_1,
    issuedBy: 'CPC, Bengaluru',
    issuedDate: DateTime(2026, 3, 6),
    responseDeadline: DateTime(2026, 3, 17),
    section: '143(1)',
    status: NoticeStatus.received,
    demandAmount: 4_800_00, // ₹4,800 — paise
  ),
  TaxNotice(
    noticeId: 'NTC-002',
    pan: 'FGHIJ5678K',
    assessmentYear: 'AY 2021-22',
    noticeType: NoticeType.reopening148,
    issuedBy: 'ITO Ward 4(2), Mumbai',
    issuedDate: DateTime(2026, 2, 14),
    responseDeadline: DateTime(2026, 3, 22),
    section: '148',
    status: NoticeStatus.underReview,
    demandAmount: 2_80_00_000, // ₹2,80,000 — paise
  ),
  TaxNotice(
    noticeId: 'NTC-003',
    pan: 'KLMNO9012P',
    assessmentYear: 'AY 2024-25',
    noticeType: NoticeType.scrutiny143_2,
    issuedBy: 'NFAC, Delhi',
    issuedDate: DateTime(2026, 2, 28),
    responseDeadline: DateTime(2026, 4, 10),
    section: '143(2)',
    status: NoticeStatus.responseDrafted,
    demandAmount: null,
  ),
  TaxNotice(
    noticeId: 'NTC-004',
    pan: 'PQRST3456U',
    assessmentYear: 'AY 2023-24',
    noticeType: NoticeType.penalty156,
    issuedBy: 'ITO TDS Ward 1, Chennai',
    issuedDate: DateTime(2026, 3, 1),
    responseDeadline: DateTime(2026, 3, 13),
    section: '156 r/w 271C',
    status: NoticeStatus.received,
    demandAmount: 58_50_000, // ₹58,500 — paise
  ),
  TaxNotice(
    noticeId: 'NTC-005',
    pan: 'UVWXY7890Z',
    assessmentYear: 'AY 2022-23',
    noticeType: NoticeType.showCause,
    issuedBy: 'DCIT Circle 5, Hyderabad',
    issuedDate: DateTime(2026, 2, 20),
    responseDeadline: DateTime(2026, 3, 28),
    section: 'Show Cause',
    status: NoticeStatus.underReview,
    demandAmount: null,
  ),
];

// ---------------------------------------------------------------------------
// Notice list provider
// ---------------------------------------------------------------------------

final noticeListProvider =
    NotifierProvider<NoticeListNotifier, List<TaxNotice>>(
      NoticeListNotifier.new,
    );

class NoticeListNotifier extends Notifier<List<TaxNotice>> {
  @override
  List<TaxNotice> build() => List.unmodifiable(_mockNotices);

  void add(TaxNotice notice) {
    state = List.unmodifiable([...state, notice]);
  }

  void updateStatus(String noticeId, NoticeStatus status) {
    state = List.unmodifiable(
      state
          .map((n) => n.noticeId == noticeId ? n.copyWith(status: status) : n)
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Selected notice
// ---------------------------------------------------------------------------

final selectedNoticeProvider =
    NotifierProvider<SelectedNoticeNotifier, TaxNotice?>(
      SelectedNoticeNotifier.new,
    );

class SelectedNoticeNotifier extends Notifier<TaxNotice?> {
  @override
  TaxNotice? build() => null;

  void select(TaxNotice? notice) => state = notice;
}

// ---------------------------------------------------------------------------
// Service singletons
// ---------------------------------------------------------------------------

final noticeTriageProvider = Provider<NoticeTriageService>(
  (_) => NoticeTriageService.instance,
);

final responseTemplateProvider = Provider<ResponseTemplateService>(
  (_) => ResponseTemplateService.instance,
);

// ---------------------------------------------------------------------------
// Mock appeal cases (3 records)
// ---------------------------------------------------------------------------

final _mockAppeals = <AppealCase>[
  AppealCase(
    caseId: 'APC-2024-001',
    pan: 'FGHIJ5678K',
    assessmentYear: 'AY 2020-21',
    currentForum: AppealForum.cita,
    originalDemand: 8_50_00_000, // ₹8,50,000
    amountInDispute: 8_50_00_000,
    filingDate: DateTime(2025, 11, 10),
    hearingDate: DateTime(2026, 4, 5),
    status: AppealStatus.admitted,
    nextAction:
        'Prepare written submissions for CIT(A) hearing on 05/04/2026.',
    nextActionDate: DateTime(2026, 3, 29),
    history: const [
      AppealStage(
        forum: AppealForum.ao,
        outcome: StageOutcome.dismissed,
        orderDate: null,
        orderSummary: 'Objections dismissed by AO — demand confirmed.',
        reliefGranted: 0,
      ),
    ],
  ),
  AppealCase(
    caseId: 'APC-2023-007',
    pan: 'ABCDE1234F',
    assessmentYear: 'AY 2019-20',
    currentForum: AppealForum.itat,
    originalDemand: 45_00_00_000, // ₹45,00,000
    amountInDispute: 30_00_00_000, // ₹30,00,000 after partial CIT(A) relief
    filingDate: DateTime(2024, 8, 22),
    hearingDate: DateTime(2026, 5, 14),
    status: AppealStatus.partialRelief,
    nextAction:
        'File memorandum of appeal before ITAT. Pre-deposit 20% = ₹6,00,000.',
    nextActionDate: DateTime(2026, 3, 25),
    history: [
      const AppealStage(
        forum: AppealForum.ao,
        outcome: StageOutcome.dismissed,
        orderDate: null,
        orderSummary: 'AO confirmed additions on capital gains.',
        reliefGranted: 0,
      ),
      AppealStage(
        forum: AppealForum.cita,
        outcome: StageOutcome.partiallyAllowed,
        orderDate: DateTime(2025, 6, 18),
        orderSummary: 'CIT(A) granted partial relief on long-term capital gains.',
        reliefGranted: 15_00_00_000,
      ),
    ],
  ),
  AppealCase(
    caseId: 'APC-2025-012',
    pan: 'PQRST3456U',
    assessmentYear: 'AY 2022-23',
    currentForum: AppealForum.cita,
    originalDemand: 12_20_00_000, // ₹12,20,000
    amountInDispute: 12_20_00_000,
    filingDate: DateTime(2026, 1, 30),
    hearingDate: null,
    status: AppealStatus.pending,
    nextAction: 'Await admission notice from CIT(A).',
    nextActionDate: null,
    history: const [],
  ),
];

// ---------------------------------------------------------------------------
// Appeal list provider
// ---------------------------------------------------------------------------

final appealListProvider =
    NotifierProvider<AppealListNotifier, List<AppealCase>>(
      AppealListNotifier.new,
    );

class AppealListNotifier extends Notifier<List<AppealCase>> {
  @override
  List<AppealCase> build() => List.unmodifiable(_mockAppeals);

  void add(AppealCase appeal) {
    state = List.unmodifiable([...state, appeal]);
  }

  void update(AppealCase updated) {
    state = List.unmodifiable(
      state
          .map((a) => a.caseId == updated.caseId ? updated : a)
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Pre-computed triage results for each mock notice
// ---------------------------------------------------------------------------

final triageResultsProvider = Provider<Map<String, NoticeTriageResult>>((ref) {
  final notices = ref.watch(noticeListProvider);
  final results = <String, NoticeTriageResult>{};
  for (final notice in notices) {
    results[notice.noticeId] = NoticeTriageService.triage(notice);
  }
  return Map.unmodifiable(results);
});

// ---------------------------------------------------------------------------
// Derived summary stats
// ---------------------------------------------------------------------------

/// Urgency level for a notice based on deadline vs [_ref].
UrgencyLevel urgencyOf(TaxNotice notice) {
  return NoticeTriageService.computeUrgency(notice, _ref);
}
