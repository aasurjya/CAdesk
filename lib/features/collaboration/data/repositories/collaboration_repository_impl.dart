import 'package:ca_app/features/collaboration/data/datasources/collaboration_local_source.dart';
import 'package:ca_app/features/collaboration/data/datasources/collaboration_remote_source.dart';
import 'package:ca_app/features/collaboration/data/mappers/collaboration_mapper.dart';
import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';
import 'package:ca_app/features/collaboration/domain/repositories/collaboration_repository.dart';

/// Real implementation of [CollaborationRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// on any network error.
class CollaborationRepositoryImpl implements CollaborationRepository {
  const CollaborationRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final CollaborationRemoteSource remote;
  final CollaborationLocalSource local;

  // ── UserSession ────────────────────────────────────────────────────────────

  @override
  Future<List<UserSession>> getAllSessions() async {
    try {
      final jsonList = await remote.fetchAllSessions();
      final sessions = jsonList
          .map(CollaborationMapper.sessionFromJson)
          .toList();
      for (final s in sessions) {
        await local.insertSession(s);
      }
      return List.unmodifiable(sessions);
    } catch (_) {
      return local.getAllSessions();
    }
  }

  @override
  Future<UserSession?> getSessionById(String sessionId) async {
    try {
      final json = await remote.fetchSessionById(sessionId);
      if (json == null) return null;
      final session = CollaborationMapper.sessionFromJson(json);
      await local.insertSession(session);
      return session;
    } catch (_) {
      return local.getSessionById(sessionId);
    }
  }

  @override
  Future<List<UserSession>> getActiveSessions() async {
    try {
      final jsonList = await remote.fetchActiveSessions();
      final sessions = jsonList
          .map(CollaborationMapper.sessionFromJson)
          .toList();
      for (final s in sessions) {
        await local.insertSession(s);
      }
      return List.unmodifiable(sessions);
    } catch (_) {
      return local.getActiveSessions();
    }
  }

  @override
  Future<String> insertSession(UserSession session) async {
    try {
      final json = await remote.insertSession(
        CollaborationMapper.sessionToJson(session),
      );
      final inserted = CollaborationMapper.sessionFromJson(json);
      await local.insertSession(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertSession(session);
    }
  }

  @override
  Future<bool> updateSession(UserSession session) async {
    try {
      final json = await remote.updateSession(
        session.id,
        CollaborationMapper.sessionToJson(session),
      );
      final updated = CollaborationMapper.sessionFromJson(json);
      await local.updateSession(updated);
      return true;
    } catch (_) {
      return local.updateSession(session);
    }
  }

  @override
  Future<bool> deleteSession(String sessionId) async {
    try {
      await remote.deleteSession(sessionId);
      await local.deleteSession(sessionId);
      return true;
    } catch (_) {
      return local.deleteSession(sessionId);
    }
  }

  // ── GuestLink ──────────────────────────────────────────────────────────────

  @override
  Future<List<GuestLink>> getAllGuestLinks() async {
    try {
      final jsonList = await remote.fetchAllGuestLinks();
      final links = jsonList.map(CollaborationMapper.linkFromJson).toList();
      for (final l in links) {
        await local.insertGuestLink(l);
      }
      return List.unmodifiable(links);
    } catch (_) {
      return local.getAllGuestLinks();
    }
  }

  @override
  Future<GuestLink?> getGuestLinkById(String linkId) async {
    try {
      final json = await remote.fetchGuestLinkById(linkId);
      if (json == null) return null;
      final link = CollaborationMapper.linkFromJson(json);
      await local.insertGuestLink(link);
      return link;
    } catch (_) {
      return local.getGuestLinkById(linkId);
    }
  }

  @override
  Future<String> insertGuestLink(GuestLink link) async {
    try {
      final json = await remote.insertGuestLink(
        CollaborationMapper.linkToJson(link),
      );
      final inserted = CollaborationMapper.linkFromJson(json);
      await local.insertGuestLink(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertGuestLink(link);
    }
  }

  @override
  Future<bool> updateGuestLink(GuestLink link) async {
    try {
      final json = await remote.updateGuestLink(
        link.id,
        CollaborationMapper.linkToJson(link),
      );
      final updated = CollaborationMapper.linkFromJson(json);
      await local.updateGuestLink(updated);
      return true;
    } catch (_) {
      return local.updateGuestLink(link);
    }
  }

  @override
  Future<bool> deleteGuestLink(String linkId) async {
    try {
      await remote.deleteGuestLink(linkId);
      await local.deleteGuestLink(linkId);
      return true;
    } catch (_) {
      return local.deleteGuestLink(linkId);
    }
  }
}
