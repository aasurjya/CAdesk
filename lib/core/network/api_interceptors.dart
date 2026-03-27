import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// AuthInterceptor
// ---------------------------------------------------------------------------

/// Attaches the Supabase JWT access token and API key to every request.
/// On a 401 response the session is refreshed once and the request is retried.
class AuthInterceptor extends Interceptor {
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    final updatedHeaders = Map<String, dynamic>.from(options.headers);
    if (token != null) {
      updatedHeaders['Authorization'] = 'Bearer $token';
    }
    updatedHeaders['apikey'] = _anonKey;

    handler.next(options.copyWith(headers: updatedHeaders));
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Attempt session refresh once.
    try {
      final refreshed = await Supabase.instance.client.auth.refreshSession();
      final newToken = refreshed.session?.accessToken;
      if (newToken == null) {
        handler.next(err);
        return;
      }

      // Retry the original request with the new token.
      final retryOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $newToken',
          'apikey': _anonKey,
        },
      );

      final dio = Dio();
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on AuthException catch (e) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          message: 'Session refresh failed: ${e.message}',
          type: DioExceptionType.unknown,
        ),
      );
    } catch (e) {
      handler.next(err);
    }
  }
}

// ---------------------------------------------------------------------------
// IdempotencyInterceptor
// ---------------------------------------------------------------------------

/// Generates a unique `Idempotency-Key` UUID header for POST, PUT, and PATCH
/// requests to prevent duplicate operations on retry.
class IdempotencyInterceptor extends Interceptor {
  static const _mutatingMethods = {'POST', 'PUT', 'PATCH'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_mutatingMethods.contains(options.method.toUpperCase())) {
      final updatedHeaders = Map<String, dynamic>.from(options.headers)
        ..['Idempotency-Key'] = _generateUuidV4();
      handler.next(options.copyWith(headers: updatedHeaders));
    } else {
      handler.next(options);
    }
  }

  /// Generates a random UUID v4 string without external dependencies.
  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Set version bits (version 4).
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant bits.
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hex.sublist(0, 4).join()}'
        '-${hex.sublist(4, 6).join()}'
        '-${hex.sublist(6, 8).join()}'
        '-${hex.sublist(8, 10).join()}'
        '-${hex.sublist(10, 16).join()}';
  }
}

// ---------------------------------------------------------------------------
// LoggingInterceptor
// ---------------------------------------------------------------------------

/// Logs HTTP requests and responses in debug builds only.
///
/// Sensitive data is redacted before logging:
/// - PAN numbers matching `[A-Z]{5}[0-9]{4}[A-Z]`
/// - Aadhaar-like 12-digit numbers
class LoggingInterceptor extends Interceptor {
  // PAN: 5 uppercase letters, 4 digits, 1 uppercase letter.
  static final _panPattern = RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]');

  // 12 consecutive digits (Aadhaar-like).
  static final _aadhaarPattern = RegExp(r'\b\d{12}\b');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitizedData = _redact(options.data?.toString() ?? '');
      debugPrint(
        '[HTTP] --> ${options.method} ${options.uri}\n'
        '  Headers: ${_sanitizeHeaders(options.headers)}\n'
        '  Data: $sanitizedData',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final sanitizedData = _redact(response.data?.toString() ?? '');
      debugPrint(
        '[HTTP] <-- ${response.statusCode} '
        '${response.requestOptions.method} '
        '${response.requestOptions.uri}\n'
        '  Data: $sanitizedData',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[HTTP] ERROR ${err.response?.statusCode} '
        '${err.requestOptions.method} ${err.requestOptions.uri}\n'
        '  Message: ${err.message}',
      );
    }
    handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _redact(String input) {
    var result = input.replaceAll(_panPattern, '[PAN-REDACTED]');
    result = result.replaceAll(_aadhaarPattern, '[AADHAAR-REDACTED]');
    return result;
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }
}
