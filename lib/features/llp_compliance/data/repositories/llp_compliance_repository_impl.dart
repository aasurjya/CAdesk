import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_entity.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp_compliance/domain/repositories/llp_compliance_repository.dart';

/// Real implementation of [LlpComplianceRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class LlpComplianceRepositoryImpl implements LlpComplianceRepository {
  const LlpComplianceRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _entitiesTable = 'llp_entities';
  static const _filingsTable = 'llp_filings';

  // -------------------------------------------------------------------------
  // LLPEntity
  // -------------------------------------------------------------------------

  @override
  Future<List<LLPEntity>> getEntities() async {
    try {
      final rows = await _client.from(_entitiesTable).select();
      return List.unmodifiable((rows as List).map(_entityFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<LLPEntity?> getEntityById(String id) async {
    try {
      final row = await _client
          .from(_entitiesTable)
          .select()
          .eq('id', id)
          .single();
      return _entityFromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LLPEntity>> searchEntities(String query) async {
    try {
      final rows = await _client
          .from(_entitiesTable)
          .select()
          .ilike('llp_name', '%$query%');
      return List.unmodifiable((rows as List).map(_entityFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertEntity(LLPEntity entity) async {
    final row = await _client
        .from(_entitiesTable)
        .insert(_entityToRow(entity))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateEntity(LLPEntity entity) async {
    try {
      await _client
          .from(_entitiesTable)
          .update(_entityToRow(entity))
          .eq('id', entity.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteEntity(String id) async {
    try {
      await _client.from(_entitiesTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // LLPFiling
  // -------------------------------------------------------------------------

  @override
  Future<List<LLPFiling>> getFilings() async {
    try {
      final rows = await _client.from(_filingsTable).select();
      return List.unmodifiable((rows as List).map(_filingFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<LLPFiling>> getFilingsByEntity(String llpId) async {
    try {
      final rows = await _client
          .from(_filingsTable)
          .select()
          .eq('llp_id', llpId);
      return List.unmodifiable((rows as List).map(_filingFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<LLPFiling>> getFilingsByStatus(LLPFilingStatus status) async {
    try {
      final rows = await _client
          .from(_filingsTable)
          .select()
          .eq('status', status.name);
      return List.unmodifiable((rows as List).map(_filingFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertFiling(LLPFiling filing) async {
    final row = await _client
        .from(_filingsTable)
        .insert(_filingToRow(filing))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateFiling(LLPFiling filing) async {
    try {
      await _client
          .from(_filingsTable)
          .update(_filingToRow(filing))
          .eq('id', filing.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteFiling(String id) async {
    try {
      await _client.from(_filingsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mappers
  // -------------------------------------------------------------------------

  LLPEntity _entityFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    final partnersList = (m['designated_partners'] as List? ?? [])
        .map((p) => _partnerFromMap(p as Map<String, dynamic>))
        .toList();
    return LLPEntity(
      id: m['id'] as String,
      llpName: m['llp_name'] as String,
      llpin: m['llpin'] as String,
      incorporationDate: DateTime.parse(m['incorporation_date'] as String),
      turnover: (m['turnover'] as num).toDouble(),
      capitalContribution: (m['capital_contribution'] as num).toDouble(),
      isAuditRequired: m['is_audit_required'] as bool,
      designatedPartners: partnersList,
      registeredOffice: m['registered_office'] as String,
      rocJurisdiction: m['roc_jurisdiction'] as String,
    );
  }

  LLPPartner _partnerFromMap(Map<String, dynamic> m) {
    return LLPPartner(
      name: m['name'] as String,
      din: m['din'] as String,
      email: m['email'] as String,
      isDesignated: m['is_designated'] as bool,
    );
  }

  Map<String, dynamic> _entityToRow(LLPEntity e) => {
    'id': e.id,
    'llp_name': e.llpName,
    'llpin': e.llpin,
    'incorporation_date': e.incorporationDate.toIso8601String(),
    'turnover': e.turnover,
    'capital_contribution': e.capitalContribution,
    'is_audit_required': e.isAuditRequired,
    'designated_partners': e.designatedPartners
        .map(
          (p) => {
            'name': p.name,
            'din': p.din,
            'email': p.email,
            'is_designated': p.isDesignated,
          },
        )
        .toList(),
    'registered_office': e.registeredOffice,
    'roc_jurisdiction': e.rocJurisdiction,
  };

  LLPFiling _filingFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return LLPFiling(
      id: m['id'] as String,
      llpId: m['llp_id'] as String,
      llpName: m['llp_name'] as String,
      formType: LLPFormType.values.firstWhere((e) => e.name == m['form_type']),
      dueDate: DateTime.parse(m['due_date'] as String),
      filedDate: m['filed_date'] != null
          ? DateTime.parse(m['filed_date'] as String)
          : null,
      status: LLPFilingStatus.values.firstWhere((e) => e.name == m['status']),
      financialYear: m['financial_year'] as String,
      penaltyPerDay: m['penalty_per_day'] as int,
      maxPenalty: m['max_penalty'] as int,
      currentPenalty: m['current_penalty'] as int,
      certifyingProfessional: m['certifying_professional'] as String?,
    );
  }

  Map<String, dynamic> _filingToRow(LLPFiling f) => {
    'id': f.id,
    'llp_id': f.llpId,
    'llp_name': f.llpName,
    'form_type': f.formType.name,
    'due_date': f.dueDate.toIso8601String(),
    'filed_date': f.filedDate?.toIso8601String(),
    'status': f.status.name,
    'financial_year': f.financialYear,
    'penalty_per_day': f.penaltyPerDay,
    'max_penalty': f.maxPenalty,
    'current_penalty': f.currentPenalty,
    'certifying_professional': f.certifyingProfessional,
  };
}
