import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_response.dart';
import 'package:ca_app/features/portal_connector/domain/services/portal_error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ts = DateTime(2026, 1, 1, 12, 0, 0);

  PortalResponse makeResponse({
    required Portal portal,
    required int statusCode,
    String body = '{}',
  }) =>
      PortalResponse(
        requestId: 'req-1',
        portal: portal,
        statusCode: statusCode,
        body: body,
        headers: const {},
        latencyMs: 100,
        timestamp: ts,
      );

  group('PortalErrorHandler.handleError', () {
    test('maps ITD 429 body to PortalError with rateLimitExceeded type', () {
      final response = makeResponse(
        portal: Portal.itd,
        statusCode: 429,
        body: '{"errorCode":"ERR_429","message":"Too many requests"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.rateLimitExceeded);
      expect(error.portal, Portal.itd);
    });

    test('maps ITD 401 body to authFailed type', () {
      final response = makeResponse(
        portal: Portal.itd,
        statusCode: 401,
        body: '{"errorCode":"ERR_401","message":"Unauthorized"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.authFailed);
    });

    test('maps ITD 500 to serverError type', () {
      final response = makeResponse(
        portal: Portal.itd,
        statusCode: 500,
        body: '{"errorCode":"ERR_500","message":"Internal error"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.serverError);
    });

    test('maps GSTN 429 body (RET191429) to rateLimitExceeded', () {
      final response = makeResponse(
        portal: Portal.gstn,
        statusCode: 429,
        body: '{"errorCode":"RET191429","message":"Rate limited"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.rateLimitExceeded);
    });

    test('maps GSTN 401 body (RET191401) to authFailed', () {
      final response = makeResponse(
        portal: Portal.gstn,
        statusCode: 401,
        body: '{"errorCode":"RET191401","message":"Auth failed"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.authFailed);
    });

    test('maps GSTN 500 body (RET191500) to serverError', () {
      final response = makeResponse(
        portal: Portal.gstn,
        statusCode: 500,
        body: '{"errorCode":"RET191500","message":"Server error"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.serverError);
    });

    test('maps TRACES T_RATE_LIMIT body to rateLimitExceeded', () {
      final response = makeResponse(
        portal: Portal.traces,
        statusCode: 429,
        body: '{"errorCode":"T_RATE_LIMIT","message":"Throttled"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.rateLimitExceeded);
    });

    test('maps TRACES T_AUTH_FAIL to authFailed', () {
      final response = makeResponse(
        portal: Portal.traces,
        statusCode: 401,
        body: '{"errorCode":"T_AUTH_FAIL","message":"Auth fail"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.authFailed);
    });

    test('maps TRACES T_SERVER_ERR to serverError', () {
      final response = makeResponse(
        portal: Portal.traces,
        statusCode: 500,
        body: '{"errorCode":"T_SERVER_ERR","message":"Server error"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.serverError);
    });

    test('maps MCA MCA_THROTTLE to rateLimitExceeded', () {
      final response = makeResponse(
        portal: Portal.mca,
        statusCode: 429,
        body: '{"errorCode":"MCA_THROTTLE","message":"Throttled"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.rateLimitExceeded);
    });

    test('maps MCA MCA_UNAUTH to authFailed', () {
      final response = makeResponse(
        portal: Portal.mca,
        statusCode: 401,
        body: '{"errorCode":"MCA_UNAUTH","message":"Unauthorized"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.authFailed);
    });

    test('maps MCA MCA_INTERNAL to serverError', () {
      final response = makeResponse(
        portal: Portal.mca,
        statusCode: 500,
        body: '{"errorCode":"MCA_INTERNAL","message":"Internal"}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.serverError);
    });

    test('maps unknown 4xx to clientError', () {
      final response = makeResponse(
        portal: Portal.itd,
        statusCode: 404,
        body: '{}',
      );
      final error = PortalErrorHandler.handleError(response);
      expect(error.type, PortalErrorType.clientError);
    });
  });

  group('PortalErrorHandler.isRetryable', () {
    test('5xx responses are retryable', () {
      for (final code in [500, 502, 503, 504]) {
        final response = makeResponse(portal: Portal.itd, statusCode: code);
        expect(PortalErrorHandler.isRetryable(response), isTrue,
            reason: '$code should be retryable');
      }
    });

    test('4xx responses are not retryable', () {
      for (final code in [400, 401, 403, 404, 429]) {
        final response = makeResponse(portal: Portal.itd, statusCode: code);
        expect(PortalErrorHandler.isRetryable(response), isFalse,
            reason: '$code should not be retryable');
      }
    });

    test('2xx responses are not retryable', () {
      final response = makeResponse(portal: Portal.itd, statusCode: 200);
      expect(PortalErrorHandler.isRetryable(response), isFalse);
    });
  });

  group('PortalErrorHandler.extractErrorMessage', () {
    test('extracts message field from JSON body', () {
      final response = makeResponse(
        portal: Portal.itd,
        statusCode: 500,
        body: '{"errorCode":"ERR_500","message":"Internal server error"}',
      );
      expect(
        PortalErrorHandler.extractErrorMessage(response),
        'Internal server error',
      );
    });

    test('returns fallback when message missing', () {
      final response = makeResponse(
        portal: Portal.itd,
        statusCode: 500,
        body: '{"errorCode":"ERR_500"}',
      );
      final msg = PortalErrorHandler.extractErrorMessage(response);
      expect(msg, isNotEmpty);
    });

    test('returns fallback for non-JSON body', () {
      final response = makeResponse(
        portal: Portal.gstn,
        statusCode: 500,
        body: 'Internal Server Error',
      );
      final msg = PortalErrorHandler.extractErrorMessage(response);
      expect(msg, isNotEmpty);
    });
  });

  group('PortalError model', () {
    test('equality and hashCode consistent', () {
      const a = PortalError(
        portal: Portal.itd,
        type: PortalErrorType.serverError,
        message: 'err',
        statusCode: 500,
      );
      const b = PortalError(
        portal: Portal.itd,
        type: PortalErrorType.serverError,
        message: 'err',
        statusCode: 500,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith updates fields', () {
      const a = PortalError(
        portal: Portal.itd,
        type: PortalErrorType.serverError,
        message: 'err',
        statusCode: 500,
      );
      final b = a.copyWith(message: 'updated');
      expect(b.message, 'updated');
      expect(b.portal, Portal.itd);
    });
  });
}
