import 'package:dio/dio.dart';

import 'package:ca_app/core/network/portal_interceptors.dart';
import 'package:ca_app/core/network/portal_types.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';

// ---------------------------------------------------------------------------
// Feature flag name for real portal API access.
// ---------------------------------------------------------------------------

/// Feature flag checked before making real portal API calls.
/// When disabled, callers should use mock/stub responses instead.
const String kPortalApiEnabledFlag = 'portal_api_enabled';

// ---------------------------------------------------------------------------
// PortalHttpClient
// ---------------------------------------------------------------------------

/// Dio wrapper configured for government portal HTTP communication.
///
/// Each instance is bound to a single [PortalEndpoint] and carries:
/// - Portal-specific base URL and timeout configuration
/// - An interceptor chain: auth, rate limit, retry, audit log
/// - Debug-mode request/response logging
///
/// Create via the factory [PortalHttpClient.forPortal]:
/// ```dart
/// final client = PortalHttpClient.forPortal(PortalEndpoint.gstn);
/// final response = await client.get('/taxpayerapi/v2.0/search/ABC123',
///   authToken: apiKey);
/// ```
///
/// This class is intentionally **not** a singleton — callers may create
/// multiple clients for different portals or test configurations.
class PortalHttpClient {
  PortalHttpClient._({required this.portal, required Dio dio}) : _dio = dio;

  /// The portal this client is configured for.
  final PortalEndpoint portal;

  /// The underlying Dio instance (fully configured with interceptors).
  final Dio _dio;

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Creates a [PortalHttpClient] pre-configured for [portal].
  ///
  /// Optional overrides:
  /// - [baseUrlOverride] — replaces the default portal base URL.
  /// - [timeoutOverride] — replaces the default timeout.
  /// - [onAuditEntry] — callback for persisting audit entries.
  /// - [maxRetries] — maximum retry attempts (default 3).
  factory PortalHttpClient.forPortal(
    PortalEndpoint portal, {
    String? baseUrlOverride,
    Duration? timeoutOverride,
    void Function(PortalAuditEntry)? onAuditEntry,
    int maxRetries = 3,
  }) {
    final timeout =
        timeoutOverride ?? Duration(seconds: portal.defaultTimeoutSeconds);

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrlOverride ?? portal.baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      const PortalAuthInterceptor(),
      PortalRateLimitInterceptor(),
      PortalRetryInterceptor(maxRetries: maxRetries),
      PortalAuditLogInterceptor(onAuditEntry: onAuditEntry),
    ]);

    return PortalHttpClient._(portal: portal, dio: dio);
  }

  /// Creates a [PortalHttpClient] with a custom [Dio] instance.
  ///
  /// Useful for testing — inject a mock Dio to avoid real HTTP calls.
  factory PortalHttpClient.withDio(PortalEndpoint portal, Dio dio) {
    return PortalHttpClient._(portal: portal, dio: dio);
  }

  // ---------------------------------------------------------------------------
  // HTTP methods
  // ---------------------------------------------------------------------------

  /// Sends a GET request to [path] on this portal.
  ///
  /// [authToken] is passed to the auth interceptor via `extra`.
  /// [queryParameters] are appended as URL query params.
  ///
  /// Throws [PortalAuthException] on 401/403.
  /// Throws [PortalRateLimitException] on 429.
  /// Throws [PortalUnavailableException] on 5xx / connectivity errors.
  Future<Response<dynamic>> get(
    String path, {
    String? authToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(authToken),
      );
    } on DioException catch (e) {
      _throwPortalException(e);
    }
  }

  /// Sends a POST request to [path] on this portal.
  ///
  /// [body] is the request payload (JSON-serializable Map or String).
  Future<Response<dynamic>> post(
    String path, {
    String? authToken,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: _buildOptions(authToken),
      );
    } on DioException catch (e) {
      _throwPortalException(e);
    }
  }

  /// Sends a PUT request to [path] on this portal.
  Future<Response<dynamic>> put(
    String path, {
    String? authToken,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: _buildOptions(authToken),
      );
    } on DioException catch (e) {
      _throwPortalException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Builds [Options] with portal metadata in `extra` for interceptors.
  Options _buildOptions(String? authToken) {
    return Options(
      extra: <String, Object?>{'portal': portal, 'authToken': authToken},
    );
  }

  /// Converts a [DioException] to the appropriate portal domain exception.
  ///
  /// If the error already wraps a portal exception (e.g. from the rate-limit
  /// interceptor), it is re-thrown directly.
  Never _throwPortalException(DioException e) {
    // Re-throw if the interceptor already wrapped a portal exception.
    if (e.error is PortalAuthException) throw e.error as PortalAuthException;
    if (e.error is PortalRateLimitException) {
      throw e.error as PortalRateLimitException;
    }
    if (e.error is PortalUnavailableException) {
      throw e.error as PortalUnavailableException;
    }

    final status = e.response?.statusCode;
    final portalName = portal.displayName;

    if (status == 401 || status == 403) {
      throw PortalAuthException(
        portal: portalName,
        message:
            _extractMessage(e.response?.data) ??
            'Authentication failed for $portalName.',
        statusCode: status,
      );
    }

    if (status == 429) {
      final retryAfter = _parseRetryAfter(e.response?.headers);
      throw PortalRateLimitException(
        portal: portalName,
        message:
            _extractMessage(e.response?.data) ??
            '$portalName rate limit exceeded.',
        retryAfterSeconds: retryAfter,
      );
    }

    throw PortalUnavailableException(
      portal: portalName,
      message:
          _extractMessage(e.response?.data) ??
          e.message ??
          '$portalName is currently unavailable.',
      statusCode: status,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  static int? _parseRetryAfter(Headers? headers) {
    final value = headers?.value('Retry-After');
    if (value == null) return null;
    return int.tryParse(value);
  }
}
