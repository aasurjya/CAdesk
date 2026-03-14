import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';

/// Local data source for user sessions and guest links.
///
/// Uses in-memory caches as a fallback when Supabase is unavailable.
class CollaborationLocalSource {
  CollaborationLocalSource();

  final List<UserSession> _sessionCache = [];
  final List<GuestLink> _linkCache = [];

  // ── UserSession ────────────────────────────────────────────────────────────

  Future<String> insertSession(UserSession session) async {
    final idx = _sessionCache.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      final updated = List<UserSession>.of(_sessionCache)..[idx] = session;
      _sessionCache
        ..clear()
        ..addAll(updated);
    } else {
      _sessionCache.add(session);
    }
    return session.id;
  }

  Future<List<UserSession>> getAllSessions() async {
    return List.unmodifiable(_sessionCache);
  }

  Future<UserSession?> getSessionById(String sessionId) async {
    try {
      return _sessionCache.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  Future<List<UserSession>> getActiveSessions() async {
    return List.unmodifiable(_sessionCache.where((s) => s.isOnline).toList());
  }

  Future<bool> updateSession(UserSession session) async {
    final idx = _sessionCache.indexWhere((s) => s.id == session.id);
    if (idx == -1) return false;
    final updated = List<UserSession>.of(_sessionCache)..[idx] = session;
    _sessionCache
      ..clear()
      ..addAll(updated);
    return true;
  }

  Future<bool> deleteSession(String sessionId) async {
    final before = _sessionCache.length;
    _sessionCache.removeWhere((s) => s.id == sessionId);
    return _sessionCache.length < before;
  }

  // ── GuestLink ──────────────────────────────────────────────────────────────

  Future<String> insertGuestLink(GuestLink link) async {
    final idx = _linkCache.indexWhere((l) => l.id == link.id);
    if (idx >= 0) {
      final updated = List<GuestLink>.of(_linkCache)..[idx] = link;
      _linkCache
        ..clear()
        ..addAll(updated);
    } else {
      _linkCache.add(link);
    }
    return link.id;
  }

  Future<List<GuestLink>> getAllGuestLinks() async {
    return List.unmodifiable(_linkCache);
  }

  Future<GuestLink?> getGuestLinkById(String linkId) async {
    try {
      return _linkCache.firstWhere((l) => l.id == linkId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateGuestLink(GuestLink link) async {
    final idx = _linkCache.indexWhere((l) => l.id == link.id);
    if (idx == -1) return false;
    final updated = List<GuestLink>.of(_linkCache)..[idx] = link;
    _linkCache
      ..clear()
      ..addAll(updated);
    return true;
  }

  Future<bool> deleteGuestLink(String linkId) async {
    final before = _linkCache.length;
    _linkCache.removeWhere((l) => l.id == linkId);
    return _linkCache.length < before;
  }
}
