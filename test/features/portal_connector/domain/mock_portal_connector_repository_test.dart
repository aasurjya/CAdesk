import 'package:ca_app/features/portal_connector/data/mock_portal_connector_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credentials.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = MockPortalConnectorRepository.instance;

  group('MockPortalConnectorRepository.send', () {
    test('ITD /itr/v1/status returns processed status', () async {
      final request = PortalRequest(
        requestId: 'r1',
        portal: Portal.itd,
        endpoint: '/itr/v1/status',
        method: HttpMethod.get,
        headers: const {},
        body: '',
      );
      final response = await repo.send(request);
      expect(response.statusCode, 200);
      expect(response.isSuccess, isTrue);
      expect(response.body, contains('processed'));
      expect(response.body, contains('5000'));
    });

    test('GSTN /gst/returns/gstr1 returns ack', () async {
      final request = PortalRequest(
        requestId: 'r2',
        portal: Portal.gstn,
        endpoint: '/gst/returns/gstr1',
        method: HttpMethod.post,
        headers: const {},
        body: '{}',
      );
      final response = await repo.send(request);
      expect(response.statusCode, 200);
      expect(response.body, contains('AA123'));
      expect(response.body, contains('filed'));
    });

    test('TRACES /api/v1/form16 returns download URL', () async {
      final request = PortalRequest(
        requestId: 'r3',
        portal: Portal.traces,
        endpoint: '/api/v1/form16',
        method: HttpMethod.get,
        headers: const {},
        body: '',
      );
      final response = await repo.send(request);
      expect(response.statusCode, 200);
      expect(response.body, contains('available'));
      expect(response.body, contains('mock://form16'));
    });

    test('unknown endpoint returns 200 with generic response', () async {
      final request = PortalRequest(
        requestId: 'r4',
        portal: Portal.mca,
        endpoint: '/unknown/path',
        method: HttpMethod.get,
        headers: const {},
        body: '',
      );
      final response = await repo.send(request);
      expect(response.statusCode, 200);
    });

    test('response requestId matches request requestId', () async {
      final request = PortalRequest(
        requestId: 'my-request-id',
        portal: Portal.itd,
        endpoint: '/itr/v1/status',
        method: HttpMethod.get,
        headers: const {},
        body: '',
      );
      final response = await repo.send(request);
      expect(response.requestId, 'my-request-id');
    });

    test('response has positive latencyMs', () async {
      final request = PortalRequest(
        requestId: 'r5',
        portal: Portal.gstn,
        endpoint: '/gst/returns/gstr1',
        method: HttpMethod.get,
        headers: const {},
        body: '',
      );
      final response = await repo.send(request);
      expect(response.latencyMs, greaterThanOrEqualTo(0));
    });
  });

  group('MockPortalConnectorRepository.authenticate', () {
    test('returns active session for valid credentials', () async {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'testuser',
        passwordHash: 'hash123',
      );
      final session = await repo.authenticate(creds);
      expect(session.isActive, isTrue);
      expect(session.userId, 'testuser');
      expect(session.portal, Portal.itd);
    });

    test('session expires 8 hours from now for ITD', () async {
      final before = DateTime.now();
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
      );
      final session = await repo.authenticate(creds);
      final after = DateTime.now();
      final minExpiry = before.add(const Duration(hours: 8));
      final maxExpiry = after.add(const Duration(hours: 8));
      expect(session.expiresAt.isAfter(minExpiry) || session.expiresAt.isAtSameMomentAs(minExpiry), isTrue);
      expect(session.expiresAt.isBefore(maxExpiry) || session.expiresAt.isAtSameMomentAs(maxExpiry), isTrue);
    });

    test('sessionId is non-empty', () async {
      final creds = PortalCredentials(
        portal: Portal.gstn,
        userId: 'u2',
        passwordHash: 'hash',
      );
      final session = await repo.authenticate(creds);
      expect(session.sessionId, isNotEmpty);
    });
  });

  group('MockPortalConnectorRepository.logout', () {
    test('completes without error', () async {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
      );
      final session = await repo.authenticate(creds);
      await expectLater(repo.logout(session), completes);
    });
  });

  group('MockPortalConnectorRepository.isSessionValid', () {
    test('returns true for freshly created session', () async {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
      );
      final session = await repo.authenticate(creds);
      expect(await repo.isSessionValid(session), isTrue);
    });

    test('returns false for inactive session', () async {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
      );
      final session = (await repo.authenticate(creds)).copyWith(isActive: false);
      expect(await repo.isSessionValid(session), isFalse);
    });
  });

  group('PortalRequest model', () {
    test('default timeoutSeconds is 30', () {
      const req = PortalRequest(
        requestId: 'r1',
        portal: Portal.itd,
        endpoint: '/test',
        method: HttpMethod.get,
        headers: {},
        body: '',
      );
      expect(req.timeoutSeconds, 30);
    });

    test('default retryCount is 0', () {
      const req = PortalRequest(
        requestId: 'r1',
        portal: Portal.itd,
        endpoint: '/test',
        method: HttpMethod.get,
        headers: {},
        body: '',
      );
      expect(req.retryCount, 0);
    });

    test('copyWith creates new instance with updated fields', () {
      const req = PortalRequest(
        requestId: 'r1',
        portal: Portal.itd,
        endpoint: '/test',
        method: HttpMethod.get,
        headers: {},
        body: '',
      );
      final updated = req.copyWith(retryCount: 2);
      expect(updated.retryCount, 2);
      expect(updated.requestId, 'r1');
    });

    test('equality holds for same values', () {
      const a = PortalRequest(
        requestId: 'r1',
        portal: Portal.itd,
        endpoint: '/test',
        method: HttpMethod.get,
        headers: {},
        body: '',
      );
      const b = PortalRequest(
        requestId: 'r1',
        portal: Portal.itd,
        endpoint: '/test',
        method: HttpMethod.get,
        headers: {},
        body: '',
      );
      expect(a, equals(b));
    });
  });

  group('PortalResponse model', () {
    final ts = DateTime(2026, 1, 1);

    test('isSuccess true for 200', () {
      final r = PortalResponse(
        requestId: 'r',
        portal: Portal.itd,
        statusCode: 200,
        body: '{}',
        headers: const {},
        latencyMs: 50,
        timestamp: ts,
      );
      expect(r.isSuccess, isTrue);
    });

    test('isSuccess true for 201', () {
      final r = PortalResponse(
        requestId: 'r',
        portal: Portal.itd,
        statusCode: 201,
        body: '{}',
        headers: const {},
        latencyMs: 50,
        timestamp: ts,
      );
      expect(r.isSuccess, isTrue);
    });

    test('isSuccess false for 400', () {
      final r = PortalResponse(
        requestId: 'r',
        portal: Portal.itd,
        statusCode: 400,
        body: '{}',
        headers: const {},
        latencyMs: 50,
        timestamp: ts,
      );
      expect(r.isSuccess, isFalse);
    });

    test('isSuccess false for 500', () {
      final r = PortalResponse(
        requestId: 'r',
        portal: Portal.itd,
        statusCode: 500,
        body: '{}',
        headers: const {},
        latencyMs: 50,
        timestamp: ts,
      );
      expect(r.isSuccess, isFalse);
    });

    test('copyWith updates errorMessage', () {
      final r = PortalResponse(
        requestId: 'r',
        portal: Portal.itd,
        statusCode: 200,
        body: '{}',
        headers: const {},
        latencyMs: 50,
        timestamp: ts,
      );
      final updated = r.copyWith(errorMessage: 'oops');
      expect(updated.errorMessage, 'oops');
      expect(updated.statusCode, 200);
    });

    test('equality and hashCode consistent', () {
      final a = PortalResponse(
        requestId: 'r',
        portal: Portal.itd,
        statusCode: 200,
        body: '{}',
        headers: const {},
        latencyMs: 50,
        timestamp: ts,
      );
      final b = PortalResponse(
        requestId: 'r',
        portal: Portal.itd,
        statusCode: 200,
        body: '{}',
        headers: const {},
        latencyMs: 50,
        timestamp: ts,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('PortalCredentials model', () {
    test('isTokenValid false when no sessionToken', () {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
      );
      expect(creds.isTokenValid, isFalse);
    });

    test('isTokenValid false when token expired', () {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
        sessionToken: 'tok',
        tokenExpiry: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(creds.isTokenValid, isFalse);
    });

    test('isTokenValid true when token present and not expired', () {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
        sessionToken: 'tok',
        tokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(creds.isTokenValid, isTrue);
    });

    test('copyWith updates sessionToken', () {
      final creds = PortalCredentials(
        portal: Portal.itd,
        userId: 'u1',
        passwordHash: 'hash',
      );
      final updated = creds.copyWith(sessionToken: 'new-token');
      expect(updated.sessionToken, 'new-token');
      expect(updated.userId, 'u1');
    });
  });
}
