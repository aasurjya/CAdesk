import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/network/portal_http_client.dart';
import 'package:ca_app/core/network/portal_types.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';

// ---------------------------------------------------------------------------
// _StubAdapter — mock HttpClientAdapter that returns predetermined responses
// ---------------------------------------------------------------------------

/// Callback type for determining response per request.
typedef _StubResponder = ResponseBody Function(RequestOptions options);

/// A [HttpClientAdapter] stub that invokes [respond] for every request,
/// allowing tests to return arbitrary responses without real HTTP calls.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.respond);

  final _StubResponder respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a [ResponseBody] with [statusCode] and JSON [data].
ResponseBody _responseBody(
  int statusCode, {
  Map<String, dynamic> data = const {'ok': true},
  Map<String, List<String>> headers = const {},
}) {
  final bodyBytes = Uint8List.fromList(utf8.encode(jsonEncode(data)));
  return ResponseBody(
    Stream.value(bodyBytes),
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
      ...headers,
    },
  );
}

/// Creates a [Dio] instance with a stub adapter and no real interceptors.
///
/// The [PortalHttpClient.withDio] factory bypasses the portal interceptors
/// (auth, rate-limit, retry, audit), so the stub just needs to return
/// or throw the expected HTTP response.
Dio _stubDio(int statusCode, {Map<String, dynamic>? data}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
  dio.httpClientAdapter = _StubAdapter(
    (opts) => _responseBody(statusCode, data: data ?? {'ok': true}),
  );
  // Clear any interceptors so retries do not fire during unit tests.
  dio.interceptors.clear();
  return dio;
}

/// Creates a [Dio] that throws a [DioException] wrapping [error].
Dio _stubDioThrowing({
  required int statusCode,
  Map<String, dynamic>? responseData,
  Map<String, List<String>>? headers,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
  dio.httpClientAdapter = _StubAdapter((opts) {
    // Return an HTTP error status that Dio will turn into a DioException.
    return _responseBody(
      statusCode,
      data: responseData ?? {},
      headers: headers ?? {},
    );
  });
  dio.interceptors.clear();
  return dio;
}

/// Wraps [error] in a [DioException] and throws it from a custom interceptor.
Dio _stubDioWithWrappedError(Object error) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: error,
            type: DioExceptionType.unknown,
          ),
        );
      },
    ),
  );
  return dio;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PortalHttpClient', () {
    group('factory constructors', () {
      test('forPortal(gstn) creates client with gstn portal', () {
        final client = PortalHttpClient.forPortal(PortalEndpoint.gstn);
        expect(client.portal, equals(PortalEndpoint.gstn));
      });

      test('forPortal(itd) creates client with itd portal', () {
        final client = PortalHttpClient.forPortal(PortalEndpoint.itd);
        expect(client.portal, equals(PortalEndpoint.itd));
      });

      test('forPortal(traces) creates client with traces portal', () {
        final client = PortalHttpClient.forPortal(PortalEndpoint.traces);
        expect(client.portal, equals(PortalEndpoint.traces));
      });

      test('withDio sets portal correctly for gstn', () {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
        final client = PortalHttpClient.withDio(PortalEndpoint.gstn, dio);
        expect(client.portal, equals(PortalEndpoint.gstn));
      });

      test('withDio sets portal correctly for itd', () {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
        final client = PortalHttpClient.withDio(PortalEndpoint.itd, dio);
        expect(client.portal, equals(PortalEndpoint.itd));
      });

      test('withDio accepts custom Dio without throwing', () {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
        expect(
          () => PortalHttpClient.withDio(PortalEndpoint.itd, dio),
          returnsNormally,
        );
      });
    });

    group('get()', () {
      test('delegates to Dio and returns 200 response', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDio(200, data: {'result': 'data'}),
        );

        final response = await client.get('/taxpayerapi/v2.0/search/ABC');

        expect(response.statusCode, equals(200));
      });

      test('throws PortalAuthException on 401', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(statusCode: 401),
        );

        await expectLater(
          () => client.get('/secure'),
          throwsA(isA<PortalAuthException>()),
        );
      });

      test('throws PortalAuthException on 403', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(statusCode: 403),
        );

        await expectLater(
          () => client.get('/secure'),
          throwsA(isA<PortalAuthException>()),
        );
      });

      test('PortalAuthException on 401 carries portal name', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(statusCode: 401),
        );

        try {
          await client.get('/secure');
          fail('Expected PortalAuthException');
        } on PortalAuthException catch (e) {
          expect(e.portal, equals(PortalEndpoint.gstn.displayName));
        }
      });

      test('PortalAuthException on 401 carries statusCode', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(statusCode: 401),
        );

        try {
          await client.get('/secure');
          fail('Expected PortalAuthException');
        } on PortalAuthException catch (e) {
          expect(e.statusCode, equals(401));
        }
      });

      test('throws PortalRateLimitException on 429', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(statusCode: 429),
        );

        await expectLater(
          () => client.get('/rate-limited'),
          throwsA(isA<PortalRateLimitException>()),
        );
      });

      test('throws PortalUnavailableException on 500', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(statusCode: 500),
        );

        await expectLater(
          () => client.get('/api'),
          throwsA(isA<PortalUnavailableException>()),
        );
      });

      test('throws PortalUnavailableException on 503', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(statusCode: 503),
        );

        await expectLater(
          () => client.get('/api'),
          throwsA(isA<PortalUnavailableException>()),
        );
      });

      test('PortalUnavailableException on 500 carries statusCode', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.itd,
          _stubDioThrowing(statusCode: 500),
        );

        try {
          await client.get('/api');
          fail('Expected PortalUnavailableException');
        } on PortalUnavailableException catch (e) {
          expect(e.statusCode, equals(500));
        }
      });

      test('re-throws wrapped PortalAuthException from interceptor', () async {
        const wrappedEx = PortalAuthException(
          portal: 'GST Network',
          message: 'Token expired',
        );
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioWithWrappedError(wrappedEx),
        );

        await expectLater(
          () => client.get('/api'),
          throwsA(isA<PortalAuthException>()),
        );
      });

      test(
        're-throws wrapped PortalRateLimitException from interceptor',
        () async {
          const wrappedEx = PortalRateLimitException(
            portal: 'GST Network',
            message: 'Rate limit hit',
            retryAfterSeconds: 60,
          );
          final client = PortalHttpClient.withDio(
            PortalEndpoint.gstn,
            _stubDioWithWrappedError(wrappedEx),
          );

          await expectLater(
            () => client.get('/api'),
            throwsA(isA<PortalRateLimitException>()),
          );
        },
      );

      test(
        're-throws wrapped PortalUnavailableException from interceptor',
        () async {
          const wrappedEx = PortalUnavailableException(
            portal: 'GST Network',
            message: 'Service down',
          );
          final client = PortalHttpClient.withDio(
            PortalEndpoint.gstn,
            _stubDioWithWrappedError(wrappedEx),
          );

          await expectLater(
            () => client.get('/api'),
            throwsA(isA<PortalUnavailableException>()),
          );
        },
      );

      test('extracts message from response data map on auth error', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.gstn,
          _stubDioThrowing(
            statusCode: 401,
            responseData: {'message': 'Session expired'},
          ),
        );

        try {
          await client.get('/api');
          fail('Expected PortalAuthException');
        } on PortalAuthException catch (e) {
          expect(e.message, equals('Session expired'));
        }
      });

      test(
        'extracts error field from response data map when message absent',
        () async {
          final client = PortalHttpClient.withDio(
            PortalEndpoint.gstn,
            _stubDioThrowing(
              statusCode: 401,
              responseData: {'error': 'invalid_token'},
            ),
          );

          try {
            await client.get('/api');
            fail('Expected PortalAuthException');
          } on PortalAuthException catch (e) {
            expect(e.message, equals('invalid_token'));
          }
        },
      );
    });

    group('post()', () {
      test('delegates to Dio and returns 200 response', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.itd,
          _stubDio(200, data: {'status': 'created'}),
        );

        final response = await client.post('/submit', body: {'pan': 'ABC'});

        expect(response.statusCode, equals(200));
      });

      test('throws PortalAuthException on 401', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.itd,
          _stubDioThrowing(statusCode: 401),
        );

        await expectLater(
          () => client.post('/submit'),
          throwsA(isA<PortalAuthException>()),
        );
      });

      test('throws PortalRateLimitException on 429', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.itd,
          _stubDioThrowing(statusCode: 429),
        );

        await expectLater(
          () => client.post('/submit'),
          throwsA(isA<PortalRateLimitException>()),
        );
      });

      test('throws PortalUnavailableException on 500', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.itd,
          _stubDioThrowing(statusCode: 500),
        );

        await expectLater(
          () => client.post('/submit'),
          throwsA(isA<PortalUnavailableException>()),
        );
      });

      test('PortalUnavailableException carries portal name', () async {
        final client = PortalHttpClient.withDio(
          PortalEndpoint.itd,
          _stubDioThrowing(statusCode: 500),
        );

        try {
          await client.post('/submit');
          fail('Expected PortalUnavailableException');
        } on PortalUnavailableException catch (e) {
          expect(e.portal, equals(PortalEndpoint.itd.displayName));
        }
      });
    });

    group('PortalEndpoint enum', () {
      test('gstn has correct displayName', () {
        expect(PortalEndpoint.gstn.displayName, equals('GST Network'));
      });

      test('itd has correct displayName', () {
        expect(PortalEndpoint.itd.displayName, equals('Income Tax Department'));
      });

      test('traces has correct displayName', () {
        expect(PortalEndpoint.traces.displayName, equals('TRACES'));
      });

      test('mca has correct displayName', () {
        expect(
          PortalEndpoint.mca.displayName,
          equals('Ministry of Corporate Affairs'),
        );
      });

      test('epfo has correct displayName', () {
        expect(PortalEndpoint.epfo.displayName, equals('EPFO'));
      });

      test('gstn has defaultTimeoutSeconds = 30', () {
        expect(PortalEndpoint.gstn.defaultTimeoutSeconds, equals(30));
      });

      test('traces has defaultTimeoutSeconds = 45', () {
        expect(PortalEndpoint.traces.defaultTimeoutSeconds, equals(45));
      });

      test('itd has defaultTimeoutSeconds = 30', () {
        expect(PortalEndpoint.itd.defaultTimeoutSeconds, equals(30));
      });
    });
  });
}
