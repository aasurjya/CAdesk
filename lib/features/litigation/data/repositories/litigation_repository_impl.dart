import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';
import 'package:ca_app/features/litigation/domain/models/response_template.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/repositories/litigation_repository.dart';

/// Real implementation of [LitigationRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class LitigationRepositoryImpl implements LitigationRepository {
  const LitigationRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _noticesTable = 'tax_notices';
  static const _casesTable = 'appeal_cases';
  static const _templatesTable = 'response_templates';

  // -------------------------------------------------------------------------
  // TaxNotice
  // -------------------------------------------------------------------------

  @override
  Future<List<TaxNotice>> getNotices() async {
    try {
      final rows = await _client.from(_noticesTable).select();
      return List.unmodifiable((rows as List).map(_noticeFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<TaxNotice>> getNoticesByPan(String pan) async {
    try {
      final rows = await _client.from(_noticesTable).select().eq('pan', pan);
      return List.unmodifiable((rows as List).map(_noticeFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<TaxNotice>> getNoticesByStatus(NoticeStatus status) async {
    try {
      final rows = await _client
          .from(_noticesTable)
          .select()
          .eq('status', status.name);
      return List.unmodifiable((rows as List).map(_noticeFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<TaxNotice?> getNoticeById(String noticeId) async {
    try {
      final row = await _client
          .from(_noticesTable)
          .select()
          .eq('notice_id', noticeId)
          .single();
      return _noticeFromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertNotice(TaxNotice notice) async {
    final row = await _client
        .from(_noticesTable)
        .insert(_noticeToRow(notice))
        .select()
        .single();
    return row['notice_id'] as String;
  }

  @override
  Future<bool> updateNotice(TaxNotice notice) async {
    try {
      await _client
          .from(_noticesTable)
          .update(_noticeToRow(notice))
          .eq('notice_id', notice.noticeId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteNotice(String noticeId) async {
    try {
      await _client.from(_noticesTable).delete().eq('notice_id', noticeId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // AppealCase
  // -------------------------------------------------------------------------

  @override
  Future<List<AppealCase>> getAppealCases() async {
    try {
      final rows = await _client.from(_casesTable).select();
      return List.unmodifiable((rows as List).map(_caseFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<AppealCase>> getAppealCasesByPan(String pan) async {
    try {
      final rows = await _client.from(_casesTable).select().eq('pan', pan);
      return List.unmodifiable((rows as List).map(_caseFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertAppealCase(AppealCase appealCase) async {
    final row = await _client
        .from(_casesTable)
        .insert(_caseToRow(appealCase))
        .select()
        .single();
    return row['case_id'] as String;
  }

  @override
  Future<bool> updateAppealCase(AppealCase appealCase) async {
    try {
      await _client
          .from(_casesTable)
          .update(_caseToRow(appealCase))
          .eq('case_id', appealCase.caseId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteAppealCase(String caseId) async {
    try {
      await _client.from(_casesTable).delete().eq('case_id', caseId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // ResponseTemplate
  // -------------------------------------------------------------------------

  @override
  Future<List<ResponseTemplate>> getTemplates() async {
    try {
      final rows = await _client.from(_templatesTable).select();
      return List.unmodifiable((rows as List).map(_templateFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ResponseTemplate>> getTemplatesByNoticeType(
    NoticeType noticeType,
  ) async {
    try {
      final rows = await _client
          .from(_templatesTable)
          .select()
          .eq('notice_type', noticeType.name);
      return List.unmodifiable((rows as List).map(_templateFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  // -------------------------------------------------------------------------
  // Mappers
  // -------------------------------------------------------------------------

  TaxNotice _noticeFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return TaxNotice(
      noticeId: m['notice_id'] as String,
      pan: m['pan'] as String,
      assessmentYear: m['assessment_year'] as String,
      noticeType: NoticeType.values.firstWhere(
        (e) => e.name == m['notice_type'],
      ),
      issuedBy: m['issued_by'] as String,
      issuedDate: DateTime.parse(m['issued_date'] as String),
      responseDeadline: DateTime.parse(m['response_deadline'] as String),
      demandAmount: m['demand_amount'] as int?,
      section: m['section'] as String,
      status: NoticeStatus.values.firstWhere((e) => e.name == m['status']),
    );
  }

  Map<String, dynamic> _noticeToRow(TaxNotice n) => {
    'notice_id': n.noticeId,
    'pan': n.pan,
    'assessment_year': n.assessmentYear,
    'notice_type': n.noticeType.name,
    'issued_by': n.issuedBy,
    'issued_date': n.issuedDate.toIso8601String(),
    'response_deadline': n.responseDeadline.toIso8601String(),
    'demand_amount': n.demandAmount,
    'section': n.section,
    'status': n.status.name,
  };

  AppealCase _caseFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    final historyList = (m['history'] as List? ?? [])
        .map((h) => _stageFromMap(h as Map<String, dynamic>))
        .toList();
    return AppealCase(
      caseId: m['case_id'] as String,
      pan: m['pan'] as String,
      assessmentYear: m['assessment_year'] as String,
      currentForum: AppealForum.values.firstWhere(
        (e) => e.name == m['current_forum'],
      ),
      originalDemand: m['original_demand'] as int,
      amountInDispute: m['amount_in_dispute'] as int,
      filingDate: DateTime.parse(m['filing_date'] as String),
      hearingDate: m['hearing_date'] != null
          ? DateTime.parse(m['hearing_date'] as String)
          : null,
      status: AppealStatus.values.firstWhere((e) => e.name == m['status']),
      nextAction: m['next_action'] as String,
      nextActionDate: m['next_action_date'] != null
          ? DateTime.parse(m['next_action_date'] as String)
          : null,
      history: historyList,
    );
  }

  AppealStage _stageFromMap(Map<String, dynamic> m) {
    return AppealStage(
      forum: AppealForum.values.firstWhere((e) => e.name == m['forum']),
      outcome: StageOutcome.values.firstWhere((e) => e.name == m['outcome']),
      orderDate: m['order_date'] != null
          ? DateTime.parse(m['order_date'] as String)
          : null,
      orderSummary: m['order_summary'] as String?,
      reliefGranted: m['relief_granted'] as int,
    );
  }

  Map<String, dynamic> _caseToRow(AppealCase c) => {
    'case_id': c.caseId,
    'pan': c.pan,
    'assessment_year': c.assessmentYear,
    'current_forum': c.currentForum.name,
    'original_demand': c.originalDemand,
    'amount_in_dispute': c.amountInDispute,
    'filing_date': c.filingDate.toIso8601String(),
    'hearing_date': c.hearingDate?.toIso8601String(),
    'status': c.status.name,
    'next_action': c.nextAction,
    'next_action_date': c.nextActionDate?.toIso8601String(),
    'history': c.history
        .map(
          (s) => {
            'forum': s.forum.name,
            'outcome': s.outcome.name,
            'order_date': s.orderDate?.toIso8601String(),
            'order_summary': s.orderSummary,
            'relief_granted': s.reliefGranted,
          },
        )
        .toList(),
  };

  ResponseTemplate _templateFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return ResponseTemplate(
      templateId: m['template_id'] as String,
      noticeType: NoticeType.values.firstWhere(
        (e) => e.name == m['notice_type'],
      ),
      title: m['title'] as String,
      templateText: m['template_text'] as String,
      requiredDocuments: List<String>.from(m['required_documents'] as List),
      legalGrounds: List<String>.from(m['legal_grounds'] as List),
      successRate: (m['success_rate'] as num).toDouble(),
    );
  }
}
