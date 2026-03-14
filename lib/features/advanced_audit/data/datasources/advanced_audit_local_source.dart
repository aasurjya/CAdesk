import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';

/// Local data source for audit engagements.
///
/// Uses an in-memory cache as a fallback when Supabase is unavailable.
class AdvancedAuditLocalSource {
  AdvancedAuditLocalSource();

  final List<AuditEngagement> _cache = [];

  /// Insert or replace an [AuditEngagement] in the local cache.
  Future<String> insertEngagement(AuditEngagement engagement) async {
    final idx = _cache.indexWhere((e) => e.id == engagement.id);
    if (idx >= 0) {
      final updated = List<AuditEngagement>.of(_cache)..[idx] = engagement;
      _cache
        ..clear()
        ..addAll(updated);
    } else {
      _cache.add(engagement);
    }
    return engagement.id;
  }

  /// Retrieve all cached engagements for [clientId].
  Future<List<AuditEngagement>> getByClient(String clientId) async {
    return List.unmodifiable(
      _cache.where((e) => e.clientId == clientId).toList(),
    );
  }

  /// Retrieve a cached engagement by [id].
  Future<AuditEngagement?> getById(String id) async {
    try {
      return _cache.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retrieve all cached engagements.
  Future<List<AuditEngagement>> getAll() async {
    return List.unmodifiable(_cache);
  }

  /// Update a cached [AuditEngagement].
  Future<bool> updateEngagement(AuditEngagement engagement) async {
    final idx = _cache.indexWhere((e) => e.id == engagement.id);
    if (idx == -1) return false;
    final updated = List<AuditEngagement>.of(_cache)..[idx] = engagement;
    _cache
      ..clear()
      ..addAll(updated);
    return true;
  }

  /// Delete a cached engagement by [id].
  Future<bool> deleteEngagement(String id) async {
    final before = _cache.length;
    _cache.removeWhere((e) => e.id == id);
    return _cache.length < before;
  }
}
