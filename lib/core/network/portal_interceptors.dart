import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:ca_app/core/network/portal_types.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/services/portal_rate_limiter.dart';

// ---------------------------------------------------------------------------
// AuthInterceptor — portal-specific auth headers
// ---------------------------------------------------------------------------

/// Adds portal-specific authentication headers to every outbound request.
///
/// The auth strategy depends on the portal:
/// - **GSTN**: `gstin-apikey` header with API key.
/// - **ITD / TRACES / MCA / EPFO**: `Authorization: Bearer <token>` header.
///
/// The token or API key is resolved at call-time from the request's
/// `extra['authToken']` field — no credentials are stored in this interceptor.
class PortalAuthInterceptor extends Interceptor {
  const PortalAuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authToken = options.extra['authToken'] as String?;
    final portal = options.extra['portal'] as PortalEndpoint?;

    if (authToken == null || authToken.isEmpty) {
      handler.next(options);
      return;
    }

    final updatedHeaders = Map<String, dynamic>.from(options.headers);

    if (portal == PortalEndpoint.gstn) {
      updatedHeaders['gstin-apikey'] = authToken;
    } else {
      updatedHeaders['Authorization'] = 'Bearer $authToken';
    }

    handler.next(options.copyWith(headers: updatedHeaders));
  }
}

// ---------------------------------------------------------------------------
// RateLimitInterceptor — token-bucket enforcement
// ---------------------------------------------------------------------------

/// Enforces per-portal request-rate limits using [PortalRateLimiter].
///
/// When a request would exceed the rate limit, the interceptor rejects it
/// immediately with a [PortalRateLimitException] instead of queuing.
///
/// Rate limits per portal (requests per 60-second rolling window):
/// - ITD: 10, GSTN: 20, TRACES: 5, MCA: 10, EPFO: 10.
///
/// This interceptor holds mutable state (the rate-limiter instance) because
/// Dio interceptors are inherently stateful singletons. The [PortalRateLimiter]
/// itself is immutable — each update produces a new instance.
class PortalRateLimitInterceptor extends Interceptor {
  PortalRateLimitInterceptor();

  PortalRateLimiter _limiter = const PortalRateLimiter();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final portalEndpoint = options.extra['portal'] as PortalEndpoint?;
    if (portalEndpoint == null) {
      handler.next(options);
      return;
    }

    final portal = _toPortal(portalEndpoint);
    final now = DateTime.now();

    if (!_limiter.isAllowed(portal, now: now)) {
      final wait = _limiter.computeWaitTime(portal, now: now);
      handler.reject(
        DioException(
          requestOptions: options,
          error: PortalRateLimitException(
            portal: portalEndpoint.displayName,
            message:
                'Rate limit exceeded for ${portalEndpoint.displayName}. '
                'Retry after ${wait.inSeconds}s.',
            retryAfterSeconds: wait.inSeconds,
          ),
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }

    _limiter = _limiter.recordRequest(portal, now);
    handler.next(options);
  }

  /// Maps [PortalEndpoint] to the domain [Portal] enum used by the rate limiter.
  static Portal _toPortal(PortalEndpoint endpoint) {
    switch (endpoint) {
      case PortalEndpoint.itd:
        return Portal.itd;
      case PortalEndpoint.gstn:
        return Portal.gstn;
      case PortalEndpoint.traces:
        return Portal.traces;
      case PortalEndpoint.mca:
        return Portal.mca;
      case PortalEndpoint.epfo:
        return Portal.epfo;
    }
  }
}

// ---------------------------------------------------------------------------
// RetryInterceptor — exponential backoff on 429 / 5xx
// ---------------------------------------------------------------------------

/// Retries failed requests with exponential backoff on transient errors.
///
/// Retries on:
/// - HTTP 429 (Too Many Requests)
/// - HTTP 5xx (Server Error)
/// - Network connectivity errors
///
/// Maximum [maxRetries] attempts (default 3). Backoff starts at 1s and
/// doubles per attempt with ±25% jitter.
class PortalRetryInterceptor extends Interceptor {
  PortalRetryInterceptor({this.maxRetries = 3});

  /// Maximum number of retry attempts.
  final int maxRetries;

  static final Random _random = Random();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final currentRetry = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;

    if (currentRetry >= maxRetries || !_isRetryable(err)) {
      handler.next(err);
      return;
    }

    final delay = _computeBackoff(currentRetry);
    await Future<void>.delayed(delay);

    final retryOptions = err.requestOptions.copyWith(
      extra: {...err.requestOptions.extra, '_retryCount': currentRetry + 1},
    );

    try {
      final dio = Dio();
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  /// Whether the error is retryable (429, 5xx, or connectivity issues).
  static bool _isRetryable(DioException err) {
    final status = err.response?.statusCode;
    if (status == 429) return true;
    if (status != null && status >= 500 && status < 600) return true;
    if (err.type == DioExceptionType.connectionTimeout) return true;
    if (err.type == DioExceptionType.receiveTimeout) return true;
    if (err.type == DioExceptionType.connectionError) return true;
    return false;
  }

  /// Computes exponential backoff with ±25% jitter.
  ///
  /// Base delay = 1 second, doubling each retry:
  /// Retry 0 → ~1s, Retry 1 → ~2s, Retry 2 → ~4s.
  static Duration _computeBackoff(int attempt) {
    final baseMs = 1000 * (1 << attempt); // 1s, 2s, 4s, ...
    final jitter = (baseMs * 0.25 * (2 * _random.nextDouble() - 1)).round();
    return Duration(milliseconds: baseMs + jitter);
  }
}

// ---------------------------------------------------------------------------
// AuditLogInterceptor — request/response audit trail
// ---------------------------------------------------------------------------

/// Logs portal API requests and responses for audit and debugging.
///
/// In debug mode, logs to [debugPrint]. In release mode, the interceptor
/// collects structured audit entries that can be persisted by a listener.
///
/// Sensitive data (PAN, Aadhaar, authorization tokens) is redacted.
class PortalAuditLogInterceptor extends Interceptor {
  PortalAuditLogInterceptor({this.onAuditEntry});

  /// Optional callback for persisting audit entries in release builds.
  final void Function(PortalAuditEntry entry)? onAuditEntry;

  // PAN: 5 uppercase letters, 4 digits, 1 uppercase letter.
  static final _panPattern = RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]');

  // 12 consecutive digits (Aadhaar-like).
  static final _aadhaarPattern = RegExp(r'\b\d{12}\b');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final portal = options.extra['portal'] as PortalEndpoint?;
    final entry = PortalAuditEntry(
      timestamp: DateTime.now(),
      portal: portal?.displayName ?? 'unknown',
      method: options.method,
      url: options.uri.toString(),
      direction: AuditDirection.request,
      statusCode: null,
      body: _redact(options.data?.toString() ?? ''),
    );

    _emit(entry);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final portal = response.requestOptions.extra['portal'] as PortalEndpoint?;
    final entry = PortalAuditEntry(
      timestamp: DateTime.now(),
      portal: portal?.displayName ?? 'unknown',
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      direction: AuditDirection.response,
      statusCode: response.statusCode,
      body: _redact(response.data?.toString() ?? ''),
    );

    _emit(entry);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final portal = err.requestOptions.extra['portal'] as PortalEndpoint?;
    final entry = PortalAuditEntry(
      timestamp: DateTime.now(),
      portal: portal?.displayName ?? 'unknown',
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      direction: AuditDirection.error,
      statusCode: err.response?.statusCode,
      body: err.message ?? 'Unknown error',
    );

    _emit(entry);
    handler.next(err);
  }

  void _emit(PortalAuditEntry entry) {
    if (kDebugMode) {
      debugPrint(
        '[Portal ${entry.direction.name.toUpperCase()}] '
        '${entry.method} ${entry.url} '
        '${entry.statusCode != null ? "(${entry.statusCode}) " : ""}'
        '${entry.portal}',
      );
    }
    onAuditEntry?.call(entry);
  }

  static String _redact(String input) {
    var result = input.replaceAll(_panPattern, '[PAN-REDACTED]');
    result = result.replaceAll(_aadhaarPattern, '[AADHAAR-REDACTED]');
    return result;
  }
}

// ---------------------------------------------------------------------------
// Audit entry model
// ---------------------------------------------------------------------------

/// Direction of an audit log entry.
enum AuditDirection { request, response, error }

/// Immutable audit log entry for a portal API interaction.
class PortalAuditEntry {
  const PortalAuditEntry({
    required this.timestamp,
    required this.portal,
    required this.method,
    required this.url,
    required this.direction,
    required this.statusCode,
    required this.body,
  });

  final DateTime timestamp;
  final String portal;
  final String method;
  final String url;
  final AuditDirection direction;
  final int? statusCode;
  final String body;

  @override
  String toString() =>
      'PortalAuditEntry(${direction.name}, $method $url, '
      'portal: $portal, status: $statusCode)';
}
