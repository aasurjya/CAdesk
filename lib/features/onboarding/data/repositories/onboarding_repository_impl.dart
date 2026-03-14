import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';
import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';
import 'package:ca_app/features/onboarding/domain/models/onboarding_checklist.dart';
import 'package:ca_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Real implementation of [OnboardingRepository] backed by Supabase.
class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _kycTable = 'kyc_records';
  static const _checklistTable = 'onboarding_checklists';
  static const _expiryTable = 'document_expiries';

  // ---------------------------------------------------------------------------
  // KYC Records
  // ---------------------------------------------------------------------------

  @override
  Future<List<KycRecord>> getKycRecords() async {
    final response = await _client.from(_kycTable).select();
    return List<Map<String, dynamic>>.from(response)
        .map(_kycFromJson)
        .toList();
  }

  @override
  Future<KycRecord?> getKycRecordById(String id) async {
    final response = await _client
        .from(_kycTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _kycFromJson(response);
  }

  @override
  Future<List<KycRecord>> getKycRecordsByStatus(KycStatus status) async {
    final response = await _client
        .from(_kycTable)
        .select()
        .eq('kyc_status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_kycFromJson)
        .toList();
  }

  @override
  Future<String> insertKycRecord(KycRecord record) async {
    final response = await _client
        .from(_kycTable)
        .insert(_kycToJson(record))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateKycRecord(KycRecord record) async {
    await _client
        .from(_kycTable)
        .update(_kycToJson(record))
        .eq('id', record.id);
    return true;
  }

  @override
  Future<bool> deleteKycRecord(String id) async {
    await _client.from(_kycTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Onboarding Checklists
  // ---------------------------------------------------------------------------

  @override
  Future<List<OnboardingChecklist>> getChecklists() async {
    final response = await _client.from(_checklistTable).select();
    return List<Map<String, dynamic>>.from(response)
        .map(_checklistFromJson)
        .toList();
  }

  @override
  Future<List<OnboardingChecklist>> getChecklistsByClient(
    String clientId,
  ) async {
    final response = await _client
        .from(_checklistTable)
        .select()
        .eq('client_id', clientId);
    return List<Map<String, dynamic>>.from(response)
        .map(_checklistFromJson)
        .toList();
  }

  @override
  Future<String> insertChecklist(OnboardingChecklist checklist) async {
    final response = await _client
        .from(_checklistTable)
        .insert(_checklistToJson(checklist))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateChecklist(OnboardingChecklist checklist) async {
    await _client
        .from(_checklistTable)
        .update(_checklistToJson(checklist))
        .eq('id', checklist.id);
    return true;
  }

  @override
  Future<bool> deleteChecklist(String id) async {
    await _client.from(_checklistTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Document Expiry
  // ---------------------------------------------------------------------------

  @override
  Future<List<DocumentExpiry>> getDocumentExpiries() async {
    final response = await _client.from(_expiryTable).select();
    return List<Map<String, dynamic>>.from(response)
        .map(_expiryFromJson)
        .toList();
  }

  @override
  Future<List<DocumentExpiry>> getDocumentExpiriesByClient(
    String clientId,
  ) async {
    final response = await _client
        .from(_expiryTable)
        .select()
        .eq('client_id', clientId);
    return List<Map<String, dynamic>>.from(response)
        .map(_expiryFromJson)
        .toList();
  }

  @override
  Future<List<DocumentExpiry>> getDocumentExpiriesByStatus(
    ExpiryStatus status,
  ) async {
    final response = await _client
        .from(_expiryTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_expiryFromJson)
        .toList();
  }

  @override
  Future<String> insertDocumentExpiry(DocumentExpiry expiry) async {
    final response = await _client
        .from(_expiryTable)
        .insert(_expiryToJson(expiry))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateDocumentExpiry(DocumentExpiry expiry) async {
    await _client
        .from(_expiryTable)
        .update(_expiryToJson(expiry))
        .eq('id', expiry.id);
    return true;
  }

  @override
  Future<bool> deleteDocumentExpiry(String id) async {
    await _client.from(_expiryTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  KycRecord _kycFromJson(Map<String, dynamic> j) => KycRecord(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        clientName: j['client_name'] as String,
        kycStatus: KycStatus.values
            .firstWhere((s) => s.name == j['kyc_status'] as String),
        aadhaarVerified: j['aadhaar_verified'] as bool,
        panVerified: j['pan_verified'] as bool,
        ckycKin: j['ckyc_kin'] as String,
        submittedAt: DateTime.parse(j['submitted_at'] as String),
        verifiedAt: j['verified_at'] != null
            ? DateTime.parse(j['verified_at'] as String)
            : null,
        expiryDate: j['expiry_date'] != null
            ? DateTime.parse(j['expiry_date'] as String)
            : null,
        remarks: j['remarks'] as String? ?? '',
      );

  Map<String, dynamic> _kycToJson(KycRecord r) => {
        'id': r.id,
        'client_id': r.clientId,
        'client_name': r.clientName,
        'kyc_status': r.kycStatus.name,
        'aadhaar_verified': r.aadhaarVerified,
        'pan_verified': r.panVerified,
        'ckyc_kin': r.ckycKin,
        'submitted_at': r.submittedAt.toIso8601String(),
        'verified_at': r.verifiedAt?.toIso8601String(),
        'expiry_date': r.expiryDate?.toIso8601String(),
        'remarks': r.remarks,
      };

  OnboardingChecklist _checklistFromJson(Map<String, dynamic> j) =>
      OnboardingChecklist(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        clientName: j['client_name'] as String,
        serviceType: j['service_type'] as String,
        items: const [],
        overallProgress: (j['overall_progress'] as num).toDouble(),
        createdAt: DateTime.parse(j['created_at'] as String),
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> _checklistToJson(OnboardingChecklist c) => {
        'id': c.id,
        'client_id': c.clientId,
        'client_name': c.clientName,
        'service_type': c.serviceType,
        'overall_progress': c.overallProgress,
        'created_at': c.createdAt.toIso8601String(),
        'completed_at': c.completedAt?.toIso8601String(),
      };

  DocumentExpiry _expiryFromJson(Map<String, dynamic> j) => DocumentExpiry(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        clientName: j['client_name'] as String,
        documentType: DocumentType.values
            .firstWhere((t) => t.name == j['document_type'] as String),
        expiryDate: DateTime.parse(j['expiry_date'] as String),
        reminderSentAt: j['reminder_sent_at'] != null
            ? DateTime.parse(j['reminder_sent_at'] as String)
            : null,
        status: ExpiryStatus.values
            .firstWhere((s) => s.name == j['status'] as String),
      );

  Map<String, dynamic> _expiryToJson(DocumentExpiry d) => {
        'id': d.id,
        'client_id': d.clientId,
        'client_name': d.clientName,
        'document_type': d.documentType.name,
        'expiry_date': d.expiryDate.toIso8601String(),
        'reminder_sent_at': d.reminderSentAt?.toIso8601String(),
        'status': d.status.name,
      };
}
