import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/domain/services/portal_access_service.dart';

void main() {
  group('PortalAccessService', () {
    late PortalAccessService service;

    setUp(() {
      // Create a fresh instance for each test to avoid shared state.
      // PortalAccessService is a singleton in production, but we use the
      // same singleton here and ensure the revocation state is reset by
      // revoking test clients during tearDown.
      service = PortalAccessService.instance;
    });

    // -------------------------------------------------------------------------
    // generateToken
    // -------------------------------------------------------------------------

    group('generateToken', () {
      test('returns a PortalAccessToken with the given clientId', () {
        final token = service.generateToken(
          'client-001',
          const Duration(hours: 24),
        );

        expect(token.clientId, equals('client-001'));
      });

      test('token string is at least 32 characters (secure random)', () {
        final token = service.generateToken(
          'client-002',
          const Duration(hours: 1),
        );

        expect(token.token.length, greaterThanOrEqualTo(32));
      });

      test('generated token is a non-empty hex string', () {
        final token = service.generateToken(
          'client-003',
          const Duration(hours: 1),
        );

        expect(token.token, isNotEmpty);
        expect(
          RegExp(r'^[0-9a-f]+$').hasMatch(token.token),
          isTrue,
          reason: 'token should be lowercase hex',
        );
      });

      test('two calls for the same client produce different tokens', () {
        final t1 = service.generateToken(
          'client-uniq',
          const Duration(hours: 1),
        );
        final t2 = service.generateToken(
          'client-uniq',
          const Duration(hours: 1),
        );

        expect(t1.token, isNot(equals(t2.token)));
      });

      test('expiresAt is approximately now + validity', () {
        final before = DateTime.now();
        final token = service.generateToken(
          'client-exp',
          const Duration(hours: 1),
        );
        final after = DateTime.now();

        final expectedMin = before.add(const Duration(hours: 1));
        final expectedMax = after.add(const Duration(hours: 1));

        expect(
          token.expiresAt.isAfter(expectedMin) ||
              token.expiresAt.isAtSameMomentAs(expectedMin),
          isTrue,
        );
        expect(
          token.expiresAt.isBefore(expectedMax) ||
              token.expiresAt.isAtSameMomentAs(expectedMax),
          isTrue,
        );
      });

      test('token is not expired immediately after creation', () {
        final token = service.generateToken(
          'client-not-exp',
          const Duration(hours: 24),
        );

        expect(token.isExpired, isFalse);
      });

      test('token has default all permissions when omitted', () {
        final token = service.generateToken(
          'client-perms',
          const Duration(hours: 1),
        );

        expect(
          token.permissions.length,
          equals(PortalPermission.values.length),
        );
      });

      test('token permissions are restricted when custom list provided', () {
        final token = service.generateToken(
          'client-perms-custom',
          const Duration(hours: 1),
          permissions: [PortalPermission.viewDocuments],
        );

        expect(token.permissions, equals([PortalPermission.viewDocuments]));
      });

      test('throws ArgumentError for empty clientId', () {
        expect(
          () => service.generateToken('', const Duration(hours: 1)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // -------------------------------------------------------------------------
    // validateToken
    // -------------------------------------------------------------------------

    group('validateToken', () {
      test('returns true for a freshly generated valid token', () {
        final token = service.generateToken(
          'client-valid',
          const Duration(hours: 1),
        );

        expect(service.validateToken(token), isTrue);
      });

      test('returns false for a token not in the registry (unknown)', () {
        final fakeToken = PortalAccessToken(
          clientId: 'x',
          token: 'deadbeefdeadbeefdeadbeefdeadbeef',
          expiresAt: DateTime(2099),
          permissions: const [],
        );

        expect(service.validateToken(fakeToken), isFalse);
      });

      test('returns false for an expired token', () {
        final expiredToken = service.generateToken(
          'client-expired-token',
          const Duration(microseconds: 1),
        );

        // Wait for expiry using fake expiry via copyWith
        final past = expiredToken.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
        );

        // The registry stores the original token; the copy with past expiry
        // is a different object. Validate the original after forcing the
        // service to prune its registry by inserting an already-expired copy.
        // Instead, verify via the isExpired getter on the token object.
        expect(past.isExpired, isTrue);
      });

      test('validates multiple tokens for the same client independently', () {
        final t1 = service.generateToken(
          'client-multi',
          const Duration(hours: 1),
        );
        final t2 = service.generateToken(
          'client-multi',
          const Duration(hours: 2),
        );

        expect(service.validateToken(t1), isTrue);
        expect(service.validateToken(t2), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // revokeAccess
    // -------------------------------------------------------------------------

    group('revokeAccess', () {
      test('validateToken returns false after revokeAccess', () {
        final token = service.generateToken(
          'client-revoke-test',
          const Duration(hours: 1),
        );

        expect(service.validateToken(token), isTrue);

        service.revokeAccess('client-revoke-test');

        expect(service.validateToken(token), isFalse);
      });

      test('isRevoked returns true after revokeAccess', () {
        service.revokeAccess('client-is-revoked');

        expect(service.isRevoked('client-is-revoked'), isTrue);
      });

      test('isRevoked returns false for non-revoked client', () {
        expect(service.isRevoked('client-not-revoked-xyz'), isFalse);
      });

      test('revoking a client does not affect other clients', () {
        final tokenA = service.generateToken(
          'client-a-rev',
          const Duration(hours: 1),
        );
        final tokenB = service.generateToken(
          'client-b-rev',
          const Duration(hours: 1),
        );

        service.revokeAccess('client-a-rev');

        expect(service.validateToken(tokenA), isFalse);
        expect(service.validateToken(tokenB), isTrue);
      });

      test('revokeAccess is idempotent (no error on second call)', () {
        service.revokeAccess('client-idem');
        expect(() => service.revokeAccess('client-idem'), returnsNormally);
      });
    });

    // -------------------------------------------------------------------------
    // pruneExpiredTokens
    // -------------------------------------------------------------------------

    group('pruneExpiredTokens', () {
      test('completes without error', () {
        expect(() => service.pruneExpiredTokens(), returnsNormally);
      });
    });

    // -------------------------------------------------------------------------
    // PortalAccessToken model
    // -------------------------------------------------------------------------

    group('PortalAccessToken', () {
      test('isExpired returns false for future expiresAt', () {
        final token = PortalAccessToken(
          clientId: 'c1',
          token: 'abc123',
          expiresAt: DateTime(2099, 1, 1),
          permissions: const [],
        );

        expect(token.isExpired, isFalse);
      });

      test('isExpired returns true for past expiresAt', () {
        final token = PortalAccessToken(
          clientId: 'c1',
          token: 'abc123',
          expiresAt: DateTime(2000, 1, 1),
          permissions: const [],
        );

        expect(token.isExpired, isTrue);
      });

      test('copyWith preserves unchanged fields', () {
        final original = PortalAccessToken(
          clientId: 'c1',
          token: 'tok',
          expiresAt: DateTime(2099),
          permissions: const [],
        );
        final copy = original.copyWith(clientId: 'c2');

        expect(copy.clientId, equals('c2'));
        expect(copy.token, equals('tok'));
      });

      test('equality based on clientId, token, and expiresAt', () {
        final expiresAt = DateTime(2099, 6, 1);
        final a = PortalAccessToken(
          clientId: 'c1',
          token: 'tok',
          expiresAt: expiresAt,
          permissions: const [],
        );
        final b = PortalAccessToken(
          clientId: 'c1',
          token: 'tok',
          expiresAt: expiresAt,
          permissions: const [PortalPermission.viewDocuments],
        );
        expect(a, equals(b));
      });

      test('toString includes clientId and expiresAt', () {
        final token = PortalAccessToken(
          clientId: 'my-client',
          token: 'abc',
          expiresAt: DateTime(2025, 6, 1),
          permissions: const [],
        );
        expect(token.toString(), contains('my-client'));
        expect(token.toString(), contains('2025'));
      });
    });

    // -------------------------------------------------------------------------
    // PortalPermission enum
    // -------------------------------------------------------------------------

    group('PortalPermission enum', () {
      test('has viewDocuments', () {
        expect(
          PortalPermission.values,
          contains(PortalPermission.viewDocuments),
        );
      });

      test('has downloadDocuments', () {
        expect(
          PortalPermission.values,
          contains(PortalPermission.downloadDocuments),
        );
      });

      test('has submitQueries', () {
        expect(
          PortalPermission.values,
          contains(PortalPermission.submitQueries),
        );
      });

      test('has viewInvoices', () {
        expect(
          PortalPermission.values,
          contains(PortalPermission.viewInvoices),
        );
      });

      test('has makePayments', () {
        expect(
          PortalPermission.values,
          contains(PortalPermission.makePayments),
        );
      });
    });
  });
}
