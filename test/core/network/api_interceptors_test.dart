import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/network/api_interceptors.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a minimal [RequestOptions] with only required fields set.
RequestOptions _makeRequest({
  String method = 'GET',
  String path = 'https://example.com/test',
  Map<String, dynamic>? headers,
  Object? data,
}) {
  return RequestOptions(
    path: path,
    method: method,
    headers: headers ?? {},
    data: data,
  );
}

// ---------------------------------------------------------------------------
// IdempotencyInterceptor
// ---------------------------------------------------------------------------

/// Captures the [RequestOptions] passed to [handler.next] during onRequest.
class _CapturingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? captured;

  @override
  void next(RequestOptions options) {
    captured = options;
  }
}

void main() {
  group('IdempotencyInterceptor', () {
    late IdempotencyInterceptor interceptor;
    late _CapturingRequestHandler handler;

    setUp(() {
      interceptor = IdempotencyInterceptor();
      handler = _CapturingRequestHandler();
    });

    test('POST request gets Idempotency-Key header', () {
      final request = _makeRequest(method: 'POST');
      interceptor.onRequest(request, handler);

      expect(handler.captured, isNotNull);
      expect(handler.captured!.headers.containsKey('Idempotency-Key'), isTrue);
    });

    test('PUT request gets Idempotency-Key header', () {
      final request = _makeRequest(method: 'PUT');
      interceptor.onRequest(request, handler);

      expect(handler.captured!.headers.containsKey('Idempotency-Key'), isTrue);
    });

    test('PATCH request gets Idempotency-Key header', () {
      final request = _makeRequest(method: 'PATCH');
      interceptor.onRequest(request, handler);

      expect(handler.captured!.headers.containsKey('Idempotency-Key'), isTrue);
    });

    test('GET request does NOT get Idempotency-Key header', () {
      final request = _makeRequest(method: 'GET');
      interceptor.onRequest(request, handler);

      expect(handler.captured!.headers.containsKey('Idempotency-Key'), isFalse);
    });

    test('DELETE request does NOT get Idempotency-Key header', () {
      final request = _makeRequest(method: 'DELETE');
      interceptor.onRequest(request, handler);

      expect(handler.captured!.headers.containsKey('Idempotency-Key'), isFalse);
    });

    test('Idempotency-Key is a valid UUID v4 format', () {
      final request = _makeRequest(method: 'POST');
      interceptor.onRequest(request, handler);

      final key = handler.captured!.headers['Idempotency-Key'] as String;
      // UUID v4 pattern: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidPattern.hasMatch(key), isTrue, reason: 'Key was: $key');
    });

    test('two POST requests get different Idempotency-Keys', () {
      final request1 = _makeRequest(method: 'POST');
      final request2 = _makeRequest(method: 'POST');
      final handler2 = _CapturingRequestHandler();

      interceptor.onRequest(request1, handler);
      interceptor.onRequest(request2, handler2);

      final key1 = handler.captured!.headers['Idempotency-Key'] as String;
      final key2 = handler2.captured!.headers['Idempotency-Key'] as String;

      expect(key1, isNot(equals(key2)));
    });

    test('existing headers are preserved alongside Idempotency-Key', () {
      final request = _makeRequest(
        method: 'POST',
        headers: {'X-Custom': 'value'},
      );
      interceptor.onRequest(request, handler);

      expect(handler.captured!.headers['X-Custom'], 'value');
      expect(handler.captured!.headers.containsKey('Idempotency-Key'), isTrue);
    });

    test('lowercase method is treated as uppercase (POST)', () {
      final request = RequestOptions(
        path: 'https://example.com/test',
        method: 'post', // lowercase
        headers: {},
      );
      interceptor.onRequest(request, handler);

      expect(handler.captured!.headers.containsKey('Idempotency-Key'), isTrue);
    });
  });

  group('LoggingInterceptor', () {
    late LoggingInterceptor interceptor;
    late _CapturingRequestHandler handler;

    setUp(() {
      interceptor = LoggingInterceptor();
      handler = _CapturingRequestHandler();
    });

    test('passes request through to handler.next', () {
      final request = _makeRequest(method: 'GET');
      interceptor.onRequest(request, handler);
      // handler.next should be called (captured is set)
      expect(handler.captured, isNotNull);
    });
  });
}
