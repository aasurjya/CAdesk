import 'package:ca_app/features/advanced_audit/data/datasources/advanced_audit_local_source.dart';
import 'package:ca_app/features/advanced_audit/data/datasources/advanced_audit_remote_source.dart';
import 'package:ca_app/features/advanced_audit/data/mappers/advanced_audit_mapper.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/domain/repositories/advanced_audit_repository.dart';

/// Real implementation of [AdvancedAuditRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// on any network error.
class AdvancedAuditRepositoryImpl implements AdvancedAuditRepository {
  const AdvancedAuditRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final AdvancedAuditRemoteSource remote;
  final AdvancedAuditLocalSource local;

  @override
  Future<List<AuditEngagement>> getEngagementsByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final engagements = jsonList.map(AdvancedAuditMapper.fromJson).toList();
      for (final e in engagements) {
        await local.insertEngagement(e);
      }
      return List.unmodifiable(engagements);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<AuditEngagement?> getEngagementById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final engagement = AdvancedAuditMapper.fromJson(json);
      await local.insertEngagement(engagement);
      return engagement;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<String> insertEngagement(AuditEngagement engagement) async {
    try {
      final json = await remote.insert(AdvancedAuditMapper.toJson(engagement));
      final inserted = AdvancedAuditMapper.fromJson(json);
      await local.insertEngagement(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertEngagement(engagement);
    }
  }

  @override
  Future<bool> updateEngagement(AuditEngagement engagement) async {
    try {
      final json = await remote.update(
        engagement.id,
        AdvancedAuditMapper.toJson(engagement),
      );
      final updated = AdvancedAuditMapper.fromJson(json);
      await local.updateEngagement(updated);
      return true;
    } catch (_) {
      return local.updateEngagement(engagement);
    }
  }

  @override
  Future<bool> deleteEngagement(String id) async {
    try {
      await remote.delete(id);
      await local.deleteEngagement(id);
      return true;
    } catch (_) {
      return local.deleteEngagement(id);
    }
  }

  @override
  Future<List<AuditEngagement>> getAllEngagements() async {
    try {
      final jsonList = await remote.fetchAll();
      final engagements = jsonList.map(AdvancedAuditMapper.fromJson).toList();
      for (final e in engagements) {
        await local.insertEngagement(e);
      }
      return List.unmodifiable(engagements);
    } catch (_) {
      return local.getAll();
    }
  }
}
