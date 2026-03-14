import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';
import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';
import 'package:ca_app/features/collaboration/data/repositories/mock_collaboration_repository.dart';

void main() {
  group('MockCollaborationRepository', () {
    late MockCollaborationRepository repo;

    setUp(() {
      repo = MockCollaborationRepository();
    });

    // ── UserSession tests ────────────────────────────────────────────────────

    group('getAllSessions', () {
      test('returns seeded sessions', () async {
        final sessions = await repo.getAllSessions();
        expect(sessions.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final sessions = await repo.getAllSessions();
        expect(
          () => (sessions as dynamic).add(sessions.first),
          throwsA(isA<Error>()),
        );
      });
    });

    group('getSessionById', () {
      test('returns session for valid ID', () async {
        final session = await repo.getSessionById('mock-session-001');
        expect(session, isNotNull);
        expect(session!.id, 'mock-session-001');
      });

      test('returns null for unknown ID', () async {
        final session = await repo.getSessionById('no-such-session');
        expect(session, isNull);
      });
    });

    group('getActiveSessions', () {
      test('returns only online or idle sessions', () async {
        final active = await repo.getActiveSessions();
        expect(
          active.every(
            (s) =>
                s.presence == PresenceStatus.online ||
                s.presence == PresenceStatus.idle,
          ),
          isTrue,
        );
      });
    });

    group('insertSession', () {
      test('inserts and returns new session ID', () async {
        final session = UserSession(
          id: 'new-session-001',
          userName: 'New User',
          role: UserRole.staff,
          device: 'iPhone 15',
          presence: PresenceStatus.online,
          lastActivity: DateTime(2026, 3, 14),
          loginTime: DateTime(2026, 3, 14, 9, 0),
        );
        final id = await repo.insertSession(session);
        expect(id, 'new-session-001');

        final fetched = await repo.getSessionById('new-session-001');
        expect(fetched, isNotNull);
        expect(fetched!.userName, 'New User');
      });
    });

    group('updateSession', () {
      test('updates existing session and returns true', () async {
        final existing = await repo.getSessionById('mock-session-001');
        expect(existing, isNotNull);

        final updated = UserSession(
          id: existing!.id,
          userName: existing.userName,
          role: existing.role,
          device: existing.device,
          presence: PresenceStatus.offline,
          lastActivity: DateTime(2026, 3, 14),
          loginTime: existing.loginTime,
        );
        final success = await repo.updateSession(updated);
        expect(success, isTrue);

        final fetched = await repo.getSessionById('mock-session-001');
        expect(fetched!.presence, PresenceStatus.offline);
      });

      test('returns false for non-existent session', () async {
        final ghost = UserSession(
          id: 'ghost-session',
          userName: 'Ghost',
          role: UserRole.staff,
          device: 'Unknown',
          presence: PresenceStatus.offline,
          lastActivity: DateTime(2026, 1, 1),
          loginTime: DateTime(2026, 1, 1),
        );
        final success = await repo.updateSession(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteSession', () {
      test('deletes session and returns true', () async {
        final id = await repo.insertSession(
          UserSession(
            id: 'to-delete-session',
            userName: 'Del User',
            role: UserRole.outsourced,
            device: 'Web',
            presence: PresenceStatus.offline,
            lastActivity: DateTime(2026, 3, 1),
            loginTime: DateTime(2026, 3, 1, 8, 0),
          ),
        );

        final success = await repo.deleteSession(id);
        expect(success, isTrue);

        final fetched = await repo.getSessionById(id);
        expect(fetched, isNull);
      });

      test('returns false for non-existent session ID', () async {
        final success = await repo.deleteSession('no-such-session');
        expect(success, isFalse);
      });
    });

    // ── GuestLink tests ──────────────────────────────────────────────────────

    group('getAllGuestLinks', () {
      test('returns seeded guest links', () async {
        final links = await repo.getAllGuestLinks();
        expect(links.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final links = await repo.getAllGuestLinks();
        expect(
          () => (links as dynamic).add(links.first),
          throwsA(isA<Error>()),
        );
      });
    });

    group('getGuestLinkById', () {
      test('returns guest link for valid ID', () async {
        final link = await repo.getGuestLinkById('mock-link-001');
        expect(link, isNotNull);
        expect(link!.id, 'mock-link-001');
      });

      test('returns null for unknown ID', () async {
        final link = await repo.getGuestLinkById('no-such-link');
        expect(link, isNull);
      });
    });

    group('insertGuestLink', () {
      test('inserts and returns new guest link ID', () async {
        final link = GuestLink(
          id: 'new-link-001',
          title: 'Q4 Audit Documents',
          clientName: 'Ravi Kumar',
          accessLevel: GuestAccessLevel.viewOnly,
          status: GuestLinkStatus.active,
          createdAt: DateTime(2026, 3, 14),
          expiresAt: DateTime(2026, 4, 14),
          viewCount: 0,
        );
        final id = await repo.insertGuestLink(link);
        expect(id, 'new-link-001');

        final fetched = await repo.getGuestLinkById('new-link-001');
        expect(fetched, isNotNull);
        expect(fetched!.title, 'Q4 Audit Documents');
      });
    });

    group('updateGuestLink', () {
      test('updates existing guest link and returns true', () async {
        final existing = await repo.getGuestLinkById('mock-link-001');
        expect(existing, isNotNull);

        final updated = GuestLink(
          id: existing!.id,
          title: existing.title,
          clientName: existing.clientName,
          accessLevel: existing.accessLevel,
          status: GuestLinkStatus.revoked,
          createdAt: existing.createdAt,
          expiresAt: existing.expiresAt,
          viewCount: existing.viewCount,
        );
        final success = await repo.updateGuestLink(updated);
        expect(success, isTrue);

        final fetched = await repo.getGuestLinkById('mock-link-001');
        expect(fetched!.status, GuestLinkStatus.revoked);
      });

      test('returns false for non-existent guest link', () async {
        final ghost = GuestLink(
          id: 'ghost-link',
          title: 'Ghost',
          clientName: 'Ghost',
          accessLevel: GuestAccessLevel.viewOnly,
          status: GuestLinkStatus.expired,
          createdAt: DateTime(2026, 1, 1),
          expiresAt: DateTime(2026, 1, 2),
          viewCount: 0,
        );
        final success = await repo.updateGuestLink(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteGuestLink', () {
      test('deletes guest link and returns true', () async {
        final id = await repo.insertGuestLink(
          GuestLink(
            id: 'to-delete-link',
            title: 'Delete Link',
            clientName: 'Del Client',
            accessLevel: GuestAccessLevel.download,
            status: GuestLinkStatus.active,
            createdAt: DateTime(2026, 3, 1),
            expiresAt: DateTime(2026, 4, 1),
            viewCount: 0,
          ),
        );

        final success = await repo.deleteGuestLink(id);
        expect(success, isTrue);

        final fetched = await repo.getGuestLinkById(id);
        expect(fetched, isNull);
      });

      test('returns false for non-existent guest link ID', () async {
        final success = await repo.deleteGuestLink('no-such-link');
        expect(success, isFalse);
      });
    });
  });
}
