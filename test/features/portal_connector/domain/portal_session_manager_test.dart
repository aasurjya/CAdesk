import 'package:ca_app/features/portal_connector/domain/models/portal_credentials.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_session.dart';
import 'package:ca_app/features/portal_connector/domain/services/portal_session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 1, 1, 10, 0, 0);

  PortalCredentials creds(Portal portal) => PortalCredentials(
        portal: portal,
        userId: 'user123',
        passwordHash: 'hash_abc',
      );

  group('PortalSessionManager.createSession', () {
    test('creates active session with correct portal', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(session.portal, Portal.itd);
      expect(session.isActive, isTrue);
      expect(session.userId, 'user123');
    });

    test('ITD session expires in 8 hours', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(session.expiresAt, now.add(const Duration(hours: 8)));
    });

    test('GSTN session expires in 4 hours', () {
      final session = PortalSessionManager.createSession(creds(Portal.gstn), now);
      expect(session.expiresAt, now.add(const Duration(hours: 4)));
    });

    test('TRACES session expires in 2 hours', () {
      final session = PortalSessionManager.createSession(creds(Portal.traces), now);
      expect(session.expiresAt, now.add(const Duration(hours: 2)));
    });

    test('MCA session expires in 8 hours', () {
      final session = PortalSessionManager.createSession(creds(Portal.mca), now);
      expect(session.expiresAt, now.add(const Duration(hours: 8)));
    });

    test('createdAt and lastActivityAt are both set to now', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(session.createdAt, now);
      expect(session.lastActivityAt, now);
    });

    test('sessionId is non-empty', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(session.sessionId, isNotEmpty);
    });

    test('each call produces a different sessionId', () {
      final s1 = PortalSessionManager.createSession(creds(Portal.itd), now);
      final s2 = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(s1.sessionId, isNot(equals(s2.sessionId)));
    });
  });

  group('PortalSessionManager.refreshSession', () {
    test('returns new session with updated lastActivityAt', () {
      final original = PortalSessionManager.createSession(creds(Portal.itd), now);
      final refreshed = PortalSessionManager.refreshSession(
        original,
        now.add(const Duration(hours: 1)),
      );
      expect(refreshed.lastActivityAt, now.add(const Duration(hours: 1)));
    });

    test('refreshed session retains same sessionId', () {
      final original = PortalSessionManager.createSession(creds(Portal.itd), now);
      final refreshed = PortalSessionManager.refreshSession(original, now.add(const Duration(hours: 1)));
      expect(refreshed.sessionId, original.sessionId);
    });

    test('refreshed session extends expiresAt', () {
      final original = PortalSessionManager.createSession(creds(Portal.itd), now);
      final refreshAt = now.add(const Duration(hours: 1));
      final refreshed = PortalSessionManager.refreshSession(original, refreshAt);
      // ITD lifetime is 8h so refreshed expiry should be refreshAt + 8h
      expect(refreshed.expiresAt, refreshAt.add(const Duration(hours: 8)));
    });

    test('returns a new immutable instance', () {
      final original = PortalSessionManager.createSession(creds(Portal.itd), now);
      final refreshed = PortalSessionManager.refreshSession(original, now);
      expect(identical(original, refreshed), isFalse);
    });
  });

  group('PortalSessionManager.invalidateSession', () {
    test('returns session with isActive = false', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      final invalidated = PortalSessionManager.invalidateSession(session);
      expect(invalidated.isActive, isFalse);
    });

    test('retains original fields except isActive', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      final invalidated = PortalSessionManager.invalidateSession(session);
      expect(invalidated.sessionId, session.sessionId);
      expect(invalidated.userId, session.userId);
      expect(invalidated.portal, session.portal);
    });

    test('returns a new immutable instance', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      final invalidated = PortalSessionManager.invalidateSession(session);
      expect(identical(session, invalidated), isFalse);
    });
  });

  group('PortalSessionManager.isExpired', () {
    test('returns false when now is before expiresAt', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(PortalSessionManager.isExpired(session, now.add(const Duration(hours: 7))), isFalse);
    });

    test('returns true when now is after expiresAt', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(PortalSessionManager.isExpired(session, now.add(const Duration(hours: 9))), isTrue);
    });

    test('returns true exactly at expiresAt', () {
      final session = PortalSessionManager.createSession(creds(Portal.itd), now);
      expect(PortalSessionManager.isExpired(session, session.expiresAt), isTrue);
    });
  });

  group('PortalSession model', () {
    PortalSession makeSession() => PortalSession(
          sessionId: 's1',
          portal: Portal.gstn,
          userId: 'u1',
          createdAt: now,
          lastActivityAt: now,
          isActive: true,
          expiresAt: now.add(const Duration(hours: 4)),
        );

    test('isExpired returns true after expiresAt', () {
      final session = makeSession();
      expect(session.isExpired(now.add(const Duration(hours: 5))), isTrue);
    });

    test('isExpired returns false before expiresAt', () {
      final session = makeSession();
      expect(session.isExpired(now.add(const Duration(hours: 3))), isFalse);
    });

    test('copyWith creates new instance with updated field', () {
      final session = makeSession();
      final updated = session.copyWith(isActive: false);
      expect(updated.isActive, isFalse);
      expect(updated.sessionId, session.sessionId);
    });

    test('equality holds for identical values', () {
      final a = makeSession();
      final b = makeSession();
      expect(a, equals(b));
    });

    test('hashCode is consistent', () {
      final a = makeSession();
      final b = makeSession();
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
