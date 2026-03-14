import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';
import 'package:ca_app/features/litigation/domain/models/response_template.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/repositories/litigation_repository.dart';

/// In-memory mock implementation of [LitigationRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockLitigationRepository implements LitigationRepository {
  static final List<TaxNotice> _seedNotices = [
    TaxNotice(
      noticeId: 'mock-notice-001',
      pan: 'ABCPS1234K',
      assessmentYear: 'AY 2023-24',
      noticeType: NoticeType.scrutiny143_2,
      issuedBy: 'NFAC, Delhi',
      issuedDate: DateTime(2025, 11, 10),
      responseDeadline: DateTime(2026, 3, 10),
      demandAmount: 28500000,
      section: '143(2)',
      status: NoticeStatus.responseDrafted,
    ),
    TaxNotice(
      noticeId: 'mock-notice-002',
      pan: 'BKNPN5678L',
      assessmentYear: 'AY 2022-23',
      noticeType: NoticeType.reopening148,
      issuedBy: 'ITO Ward 2(4), Delhi',
      issuedDate: DateTime(2025, 10, 5),
      responseDeadline: DateTime(2026, 1, 5),
      demandAmount: 52000000,
      section: '148',
      status: NoticeStatus.responseFiled,
    ),
    TaxNotice(
      noticeId: 'mock-notice-003',
      pan: 'AABFP9012M',
      assessmentYear: 'AY 2024-25',
      noticeType: NoticeType.intimation143_1,
      issuedBy: 'CPC, Bengaluru',
      issuedDate: DateTime(2026, 2, 1),
      responseDeadline: DateTime(2026, 5, 1),
      demandAmount: 15000000,
      section: '143(1)',
      status: NoticeStatus.received,
    ),
  ];

  static final List<AppealCase> _seedCases = [
    AppealCase(
      caseId: 'mock-case-001',
      pan: 'ABCPS1234K',
      assessmentYear: 'AY 2021-22',
      currentForum: AppealForum.cita,
      originalDemand: 85000000,
      amountInDispute: 85000000,
      filingDate: DateTime(2025, 8, 15),
      hearingDate: DateTime(2026, 4, 10),
      status: AppealStatus.pending,
      nextAction: 'Attend CIT(A) hearing and file additional submissions',
      nextActionDate: DateTime(2026, 4, 10),
      history: [
        AppealStage(
          forum: AppealForum.ao,
          outcome: StageOutcome.dismissed,
          orderDate: DateTime(2025, 6, 30),
          orderSummary:
              'AO upheld full demand of ₹8.5L citing unexplained investments',
          reliefGranted: 0,
        ),
      ],
    ),
    AppealCase(
      caseId: 'mock-case-002',
      pan: 'BKNPN5678L',
      assessmentYear: 'AY 2020-21',
      currentForum: AppealForum.itat,
      originalDemand: 120000000,
      amountInDispute: 60000000,
      filingDate: DateTime(2024, 3, 20),
      status: AppealStatus.partialRelief,
      nextAction: 'Prepare written submissions for ITAT',
      history: [
        AppealStage(
          forum: AppealForum.ao,
          outcome: StageOutcome.dismissed,
          orderDate: DateTime(2023, 12, 15),
          orderSummary: 'AO upheld demand in full',
          reliefGranted: 0,
        ),
        AppealStage(
          forum: AppealForum.cita,
          outcome: StageOutcome.partiallyAllowed,
          orderDate: DateTime(2024, 2, 28),
          orderSummary:
              'CIT(A) granted partial relief of ₹6L on house property',
          reliefGranted: 60000000,
        ),
      ],
    ),
    AppealCase(
      caseId: 'mock-case-003',
      pan: 'AABFP9012M',
      assessmentYear: 'AY 2022-23',
      currentForum: AppealForum.cita,
      originalDemand: 25000000,
      amountInDispute: 25000000,
      filingDate: DateTime(2026, 1, 10),
      status: AppealStatus.admitted,
      nextAction: 'Await hearing date from CIT(A)',
      history: [],
    ),
  ];

  static const List<ResponseTemplate> _seedTemplates = [
    ResponseTemplate(
      templateId: 'mock-tmpl-001',
      noticeType: NoticeType.scrutiny143_2,
      title: 'Response to Scrutiny Notice u/s 143(2)',
      templateText:
          'With reference to the notice dated {notice_date} bearing DIN '
          '{din} issued u/s 143(2) of the Income Tax Act, 1961 for the '
          'Assessment Year {assessment_year}, we submit as follows...',
      requiredDocuments: [
        'Audited financial statements',
        'Bank statements for the year',
        'TDS certificates (Form 16/16A)',
        'Investment proof documents',
      ],
      legalGrounds: [
        'Section 143(2) — Scrutiny assessment',
        'Section 142(1) — Information/document requisition',
      ],
      successRate: 0.68,
    ),
    ResponseTemplate(
      templateId: 'mock-tmpl-002',
      noticeType: NoticeType.intimation143_1,
      title: 'Response to CPC Intimation u/s 143(1)',
      templateText:
          'In response to the Intimation dated {notice_date} u/s 143(1) '
          'for AY {assessment_year} issued by CPC Bengaluru, we submit '
          'the following clarification regarding the adjustments made...',
      requiredDocuments: [
        'Original ITR acknowledgement',
        'Form 26AS / AIS printout',
        'TDS certificates',
      ],
      legalGrounds: [
        'Section 143(1)(a) — CPC adjustments limited to prima facie errors',
        'Rule 12 — ITR filing requirements',
      ],
      successRate: 0.82,
    ),
    ResponseTemplate(
      templateId: 'mock-tmpl-003',
      noticeType: NoticeType.penalty156,
      title: 'Response to Demand Notice u/s 156',
      templateText:
          'In response to the Demand Notice u/s 156 dated {notice_date} '
          'raising a demand of ₹{demand_amount} for AY {assessment_year}, '
          'we submit the following grounds of appeal and request for stay...',
      requiredDocuments: [
        'Assessment order',
        'Challan of taxes paid',
        'Appeal filing receipts (if any)',
      ],
      legalGrounds: [
        'Section 220(2A) — Waiver of interest on demand',
        'Section 237 — Refund provisions',
      ],
      successRate: 0.55,
    ),
  ];

  final List<TaxNotice> _notices = List.of(_seedNotices);
  final List<AppealCase> _cases = List.of(_seedCases);
  final List<ResponseTemplate> _templates = List.of(_seedTemplates);

  // -------------------------------------------------------------------------
  // TaxNotice
  // -------------------------------------------------------------------------

  @override
  Future<List<TaxNotice>> getNotices() async => List.unmodifiable(_notices);

  @override
  Future<List<TaxNotice>> getNoticesByPan(String pan) async =>
      List.unmodifiable(_notices.where((n) => n.pan == pan).toList());

  @override
  Future<List<TaxNotice>> getNoticesByStatus(NoticeStatus status) async =>
      List.unmodifiable(_notices.where((n) => n.status == status).toList());

  @override
  Future<TaxNotice?> getNoticeById(String noticeId) async {
    final matches = _notices.where((n) => n.noticeId == noticeId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<String> insertNotice(TaxNotice notice) async {
    _notices.add(notice);
    return notice.noticeId;
  }

  @override
  Future<bool> updateNotice(TaxNotice notice) async {
    final idx = _notices.indexWhere((n) => n.noticeId == notice.noticeId);
    if (idx == -1) return false;
    final updated = List<TaxNotice>.of(_notices)..[idx] = notice;
    _notices
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteNotice(String noticeId) async {
    final before = _notices.length;
    _notices.removeWhere((n) => n.noticeId == noticeId);
    return _notices.length < before;
  }

  // -------------------------------------------------------------------------
  // AppealCase
  // -------------------------------------------------------------------------

  @override
  Future<List<AppealCase>> getAppealCases() async => List.unmodifiable(_cases);

  @override
  Future<List<AppealCase>> getAppealCasesByPan(String pan) async =>
      List.unmodifiable(_cases.where((c) => c.pan == pan).toList());

  @override
  Future<String> insertAppealCase(AppealCase appealCase) async {
    _cases.add(appealCase);
    return appealCase.caseId;
  }

  @override
  Future<bool> updateAppealCase(AppealCase appealCase) async {
    final idx = _cases.indexWhere((c) => c.caseId == appealCase.caseId);
    if (idx == -1) return false;
    final updated = List<AppealCase>.of(_cases)..[idx] = appealCase;
    _cases
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteAppealCase(String caseId) async {
    final before = _cases.length;
    _cases.removeWhere((c) => c.caseId == caseId);
    return _cases.length < before;
  }

  // -------------------------------------------------------------------------
  // ResponseTemplate
  // -------------------------------------------------------------------------

  @override
  Future<List<ResponseTemplate>> getTemplates() async =>
      List.unmodifiable(_templates);

  @override
  Future<List<ResponseTemplate>> getTemplatesByNoticeType(
    NoticeType noticeType,
  ) async => List.unmodifiable(
    _templates.where((t) => t.noticeType == noticeType).toList(),
  );
}
