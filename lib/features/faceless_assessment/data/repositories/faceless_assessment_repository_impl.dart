import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/itr_u_filing.dart';
import 'package:ca_app/features/faceless_assessment/domain/repositories/faceless_assessment_repository.dart';

/// Real implementation of [FacelessAssessmentRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class FacelessAssessmentRepositoryImpl implements FacelessAssessmentRepository {
  const FacelessAssessmentRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _proceedingsTable = 'e_proceedings';
  static const _hearingsTable = 'hearing_schedules';
  static const _itrUTable = 'itr_u_filings';

  // -------------------------------------------------------------------------
  // EProceeding
  // -------------------------------------------------------------------------

  @override
  Future<List<EProceeding>> getProceedings() async {
    try {
      final rows = await _client.from(_proceedingsTable).select();
      return List.unmodifiable((rows as List).map(_proceedingFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<EProceeding>> getProceedingsByClient(String clientId) async {
    try {
      final rows = await _client
          .from(_proceedingsTable)
          .select()
          .eq('client_id', clientId);
      return List.unmodifiable((rows as List).map(_proceedingFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertProceeding(EProceeding proceeding) async {
    final row = await _client
        .from(_proceedingsTable)
        .insert(_proceedingToRow(proceeding))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateProceeding(EProceeding proceeding) async {
    try {
      await _client
          .from(_proceedingsTable)
          .update(_proceedingToRow(proceeding))
          .eq('id', proceeding.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteProceeding(String id) async {
    try {
      await _client.from(_proceedingsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // HearingSchedule
  // -------------------------------------------------------------------------

  @override
  Future<List<HearingSchedule>> getHearings() async {
    try {
      final rows = await _client.from(_hearingsTable).select();
      return List.unmodifiable((rows as List).map(_hearingFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<HearingSchedule>> getHearingsByProceeding(
    String proceedingId,
  ) async {
    try {
      final rows = await _client
          .from(_hearingsTable)
          .select()
          .eq('proceeding_id', proceedingId);
      return List.unmodifiable((rows as List).map(_hearingFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertHearing(HearingSchedule hearing) async {
    final row = await _client
        .from(_hearingsTable)
        .insert(_hearingToRow(hearing))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateHearing(HearingSchedule hearing) async {
    try {
      await _client
          .from(_hearingsTable)
          .update(_hearingToRow(hearing))
          .eq('id', hearing.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteHearing(String id) async {
    try {
      await _client.from(_hearingsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // ItrUFiling
  // -------------------------------------------------------------------------

  @override
  Future<List<ItrUFiling>> getItrUFilings() async {
    try {
      final rows = await _client.from(_itrUTable).select();
      return List.unmodifiable((rows as List).map(_itrUFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ItrUFiling>> getItrUFilingsByClient(String clientId) async {
    try {
      final rows = await _client
          .from(_itrUTable)
          .select()
          .eq('client_id', clientId);
      return List.unmodifiable((rows as List).map(_itrUFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertItrUFiling(ItrUFiling filing) async {
    final row = await _client
        .from(_itrUTable)
        .insert(_itrUToRow(filing))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateItrUFiling(ItrUFiling filing) async {
    try {
      await _client
          .from(_itrUTable)
          .update(_itrUToRow(filing))
          .eq('id', filing.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteItrUFiling(String id) async {
    try {
      await _client.from(_itrUTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mappers (row <-> domain)
  // -------------------------------------------------------------------------

  EProceeding _proceedingFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return EProceeding(
      id: m['id'] as String,
      clientId: m['client_id'] as String,
      clientName: m['client_name'] as String,
      pan: m['pan'] as String,
      assessmentYear: m['assessment_year'] as String,
      proceedingType: ProceedingType.values.firstWhere(
        (e) => e.name == m['proceeding_type'],
      ),
      noticeDate: DateTime.parse(m['notice_date'] as String),
      responseDeadline: DateTime.parse(m['response_deadline'] as String),
      status: ProceedingStatus.values.firstWhere((e) => e.name == m['status']),
      nfacReferenceNumber: m['nfac_reference_number'] as String,
      assignedOfficer: m['assigned_officer'] as String?,
      demandAmount: (m['demand_amount'] as num?)?.toDouble(),
      remarks: m['remarks'] as String?,
    );
  }

  Map<String, dynamic> _proceedingToRow(EProceeding p) => {
    'id': p.id,
    'client_id': p.clientId,
    'client_name': p.clientName,
    'pan': p.pan,
    'assessment_year': p.assessmentYear,
    'proceeding_type': p.proceedingType.name,
    'notice_date': p.noticeDate.toIso8601String(),
    'response_deadline': p.responseDeadline.toIso8601String(),
    'status': p.status.name,
    'nfac_reference_number': p.nfacReferenceNumber,
    'assigned_officer': p.assignedOfficer,
    'demand_amount': p.demandAmount,
    'remarks': p.remarks,
  };

  HearingSchedule _hearingFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return HearingSchedule(
      id: m['id'] as String,
      proceedingId: m['proceeding_id'] as String,
      clientName: m['client_name'] as String,
      hearingDate: DateTime.parse(m['hearing_date'] as String),
      hearingTime: m['hearing_time'] as String,
      platform: HearingPlatform.values.firstWhere(
        (e) => e.name == m['platform'],
      ),
      agenda: m['agenda'] as String,
      documentsToSubmit: List<String>.from(m['documents_to_submit'] as List),
      representativeName: m['representative_name'] as String,
      status: HearingStatus.values.firstWhere((e) => e.name == m['status']),
      notes: m['notes'] as String?,
    );
  }

  Map<String, dynamic> _hearingToRow(HearingSchedule h) => {
    'id': h.id,
    'proceeding_id': h.proceedingId,
    'client_name': h.clientName,
    'hearing_date': h.hearingDate.toIso8601String(),
    'hearing_time': h.hearingTime,
    'platform': h.platform.name,
    'agenda': h.agenda,
    'documents_to_submit': h.documentsToSubmit,
    'representative_name': h.representativeName,
    'status': h.status.name,
    'notes': h.notes,
  };

  ItrUFiling _itrUFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return ItrUFiling(
      id: m['id'] as String,
      clientId: m['client_id'] as String,
      clientName: m['client_name'] as String,
      pan: m['pan'] as String,
      originalAssessmentYear: m['original_assessment_year'] as String,
      originalFilingDate: DateTime.parse(m['original_filing_date'] as String),
      updateReason: UpdateReason.values.firstWhere(
        (e) => e.name == m['update_reason'],
      ),
      additionalTax: (m['additional_tax'] as num).toDouble(),
      penaltyPercentage: m['penalty_percentage'] as int,
      penaltyAmount: (m['penalty_amount'] as num).toDouble(),
      totalPayable: (m['total_payable'] as num).toDouble(),
      status: ItrUStatus.values.firstWhere((e) => e.name == m['status']),
      filingDeadline: DateTime.parse(m['filing_deadline'] as String),
    );
  }

  Map<String, dynamic> _itrUToRow(ItrUFiling f) => {
    'id': f.id,
    'client_id': f.clientId,
    'client_name': f.clientName,
    'pan': f.pan,
    'original_assessment_year': f.originalAssessmentYear,
    'original_filing_date': f.originalFilingDate.toIso8601String(),
    'update_reason': f.updateReason.name,
    'additional_tax': f.additionalTax,
    'penalty_percentage': f.penaltyPercentage,
    'penalty_amount': f.penaltyAmount,
    'total_payable': f.totalPayable,
    'status': f.status.name,
    'filing_deadline': f.filingDeadline.toIso8601String(),
  };
}
