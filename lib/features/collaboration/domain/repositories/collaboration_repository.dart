import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';

/// Abstract contract for collaboration data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class CollaborationRepository {
  // ── UserSession ────────────────────────────────────────────────────────────

  /// Retrieve all user sessions.
  Future<List<UserSession>> getAllSessions();

  /// Retrieve a single [UserSession] by [sessionId]. Returns null if not found.
  Future<UserSession?> getSessionById(String sessionId);

  /// Retrieve only active (online/idle) user sessions.
  Future<List<UserSession>> getActiveSessions();

  /// Insert a new [UserSession] and return its ID.
  Future<String> insertSession(UserSession session);

  /// Update an existing [UserSession]. Returns true on success.
  Future<bool> updateSession(UserSession session);

  /// Delete the user session identified by [sessionId]. Returns true on success.
  Future<bool> deleteSession(String sessionId);

  // ── GuestLink ──────────────────────────────────────────────────────────────

  /// Retrieve all guest links.
  Future<List<GuestLink>> getAllGuestLinks();

  /// Retrieve a single [GuestLink] by [linkId]. Returns null if not found.
  Future<GuestLink?> getGuestLinkById(String linkId);

  /// Insert a new [GuestLink] and return its ID.
  Future<String> insertGuestLink(GuestLink link);

  /// Update an existing [GuestLink]. Returns true on success.
  Future<bool> updateGuestLink(GuestLink link);

  /// Delete the guest link identified by [linkId]. Returns true on success.
  Future<bool> deleteGuestLink(String linkId);
}
