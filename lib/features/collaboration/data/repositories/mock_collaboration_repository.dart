import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';
import 'package:ca_app/features/collaboration/domain/repositories/collaboration_repository.dart';

/// In-memory mock implementation of [CollaborationRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations use immutable patterns.
class MockCollaborationRepository implements CollaborationRepository {
  static final List<UserSession> _sessionSeed = [
    UserSession(
      id: 'mock-session-001',
      userName: 'CA Anil Sharma',
      role: UserRole.partner,
      device: 'MacBook Pro',
      presence: PresenceStatus.online,
      lastActivity: DateTime(2026, 3, 14, 10, 30),
      loginTime: DateTime(2026, 3, 14, 9, 0),
      currentModule: 'Audit',
      location: 'Mumbai',
    ),
    UserSession(
      id: 'mock-session-002',
      userName: 'Rohit Verma',
      role: UserRole.senior,
      device: 'iPad Pro',
      presence: PresenceStatus.idle,
      lastActivity: DateTime(2026, 3, 14, 9, 45),
      loginTime: DateTime(2026, 3, 14, 8, 30),
      currentModule: 'GST',
      location: 'Delhi',
    ),
    UserSession(
      id: 'mock-session-003',
      userName: 'Anita Rao',
      role: UserRole.staff,
      device: 'iPhone 15',
      presence: PresenceStatus.offline,
      lastActivity: DateTime(2026, 3, 13, 18, 0),
      loginTime: DateTime(2026, 3, 13, 9, 0),
      location: 'Bangalore',
    ),
  ];

  static final List<GuestLink> _linkSeed = [
    GuestLink(
      id: 'mock-link-001',
      title: 'Annual Report FY 2024-25',
      clientName: 'Ravi Kumar Enterprises',
      accessLevel: GuestAccessLevel.viewOnly,
      status: GuestLinkStatus.active,
      createdAt: DateTime(2026, 3, 1),
      expiresAt: DateTime(2026, 4, 1),
      viewCount: 3,
      purpose: 'Board presentation review',
      createdBy: 'CA Anil Sharma',
    ),
    GuestLink(
      id: 'mock-link-002',
      title: 'Audit Working Papers',
      clientName: 'Priya Textiles Pvt Ltd',
      accessLevel: GuestAccessLevel.comment,
      status: GuestLinkStatus.active,
      createdAt: DateTime(2026, 2, 15),
      expiresAt: DateTime(2026, 3, 15),
      viewCount: 12,
      purpose: 'Concurrent audit review',
      createdBy: 'CA Meena Iyer',
    ),
    GuestLink(
      id: 'mock-link-003',
      title: 'Tax Documents FY 2023-24',
      clientName: 'Raj & Sons',
      accessLevel: GuestAccessLevel.download,
      status: GuestLinkStatus.expired,
      createdAt: DateTime(2025, 12, 1),
      expiresAt: DateTime(2026, 1, 1),
      viewCount: 7,
      createdBy: 'CA Anil Sharma',
    ),
  ];

  final List<UserSession> _sessions = List.of(_sessionSeed);
  final List<GuestLink> _links = List.of(_linkSeed);

  // ── UserSession ────────────────────────────────────────────────────────────

  @override
  Future<List<UserSession>> getAllSessions() async {
    return List.unmodifiable(_sessions);
  }

  @override
  Future<UserSession?> getSessionById(String sessionId) async {
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<UserSession>> getActiveSessions() async {
    return List.unmodifiable(_sessions.where((s) => s.isOnline).toList());
  }

  @override
  Future<String> insertSession(UserSession session) async {
    _sessions.add(session);
    return session.id;
  }

  @override
  Future<bool> updateSession(UserSession session) async {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx == -1) return false;
    final updated = List<UserSession>.of(_sessions)..[idx] = session;
    _sessions
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteSession(String sessionId) async {
    final before = _sessions.length;
    _sessions.removeWhere((s) => s.id == sessionId);
    return _sessions.length < before;
  }

  // ── GuestLink ──────────────────────────────────────────────────────────────

  @override
  Future<List<GuestLink>> getAllGuestLinks() async {
    return List.unmodifiable(_links);
  }

  @override
  Future<GuestLink?> getGuestLinkById(String linkId) async {
    try {
      return _links.firstWhere((l) => l.id == linkId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertGuestLink(GuestLink link) async {
    _links.add(link);
    return link.id;
  }

  @override
  Future<bool> updateGuestLink(GuestLink link) async {
    final idx = _links.indexWhere((l) => l.id == link.id);
    if (idx == -1) return false;
    final updated = List<GuestLink>.of(_links)..[idx] = link;
    _links
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteGuestLink(String linkId) async {
    final before = _links.length;
    _links.removeWhere((l) => l.id == linkId);
    return _links.length < before;
  }
}
