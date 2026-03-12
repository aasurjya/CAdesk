import 'dart:convert';

import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_response.dart';

/// Categorised portal error types.
enum PortalErrorType {
  rateLimitExceeded,
  authFailed,
  serverError,
  clientError,
  unknown,
}

/// Immutable representation of a portal API error.
class PortalError {
  const PortalError({
    required this.portal,
    required this.type,
    required this.message,
    required this.statusCode,
  });

  final Portal portal;
  final PortalErrorType type;
  final String message;
  final int statusCode;

  PortalError copyWith({
    Portal? portal,
    PortalErrorType? type,
    String? message,
    int? statusCode,
  }) {
    return PortalError(
      portal: portal ?? this.portal,
      type: type ?? this.type,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortalError &&
          runtimeType == other.runtimeType &&
          portal == other.portal &&
          type == other.type &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(portal, type, message, statusCode);
}

// ---------------------------------------------------------------------------
// Portal-specific error code maps
// ---------------------------------------------------------------------------

const Map<String, PortalErrorType> _kItdCodes = {
  'ERR_429': PortalErrorType.rateLimitExceeded,
  'ERR_401': PortalErrorType.authFailed,
  'ERR_500': PortalErrorType.serverError,
};

const Map<String, PortalErrorType> _kGstnCodes = {
  'RET191429': PortalErrorType.rateLimitExceeded,
  'RET191401': PortalErrorType.authFailed,
  'RET191500': PortalErrorType.serverError,
};

const Map<String, PortalErrorType> _kTracesCodes = {
  'T_RATE_LIMIT': PortalErrorType.rateLimitExceeded,
  'T_AUTH_FAIL': PortalErrorType.authFailed,
  'T_SERVER_ERR': PortalErrorType.serverError,
};

const Map<String, PortalErrorType> _kMcaCodes = {
  'MCA_THROTTLE': PortalErrorType.rateLimitExceeded,
  'MCA_UNAUTH': PortalErrorType.authFailed,
  'MCA_INTERNAL': PortalErrorType.serverError,
};

Map<String, PortalErrorType> _codesFor(Portal portal) {
  switch (portal) {
    case Portal.itd:
      return _kItdCodes;
    case Portal.gstn:
      return _kGstnCodes;
    case Portal.traces:
      return _kTracesCodes;
    case Portal.mca:
      return _kMcaCodes;
    case Portal.epfo:
    case Portal.nic:
      return const {};
  }
}

/// Stateless utility for interpreting portal error responses.
class PortalErrorHandler {
  PortalErrorHandler._();

  /// Analyse [response] and return a typed [PortalError].
  static PortalError handleError(PortalResponse response) {
    final message = extractErrorMessage(response);
    final type = _classifyError(response);
    return PortalError(
      portal: response.portal,
      type: type,
      message: message,
      statusCode: response.statusCode,
    );
  }

  /// Returns `true` when it is safe to retry after [response].
  ///
  /// 5xx responses are retryable; 4xx and 2xx are not.
  static bool isRetryable(PortalResponse response) {
    return response.statusCode >= 500 && response.statusCode <= 599;
  }

  /// Extract the `message` field from the JSON [response] body, or return a
  /// fallback string when extraction fails.
  static String extractErrorMessage(PortalResponse response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final msg = decoded['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {
      // Body is not valid JSON — fall through to fallback.
    }
    return 'HTTP ${response.statusCode} error from ${response.portal.name.toUpperCase()}';
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static PortalErrorType _classifyError(PortalResponse response) {
    // Try portal-specific error code first.
    final errorCode = _extractErrorCode(response);
    if (errorCode != null) {
      final type = _codesFor(response.portal)[errorCode];
      if (type != null) return type;
    }

    // Fall back to HTTP status class.
    if (response.statusCode == 429) return PortalErrorType.rateLimitExceeded;
    if (response.statusCode == 401 || response.statusCode == 403) {
      return PortalErrorType.authFailed;
    }
    if (response.statusCode >= 500) return PortalErrorType.serverError;
    if (response.statusCode >= 400) return PortalErrorType.clientError;
    return PortalErrorType.unknown;
  }

  static String? _extractErrorCode(PortalResponse response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final code = decoded['errorCode'];
        if (code is String) return code;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
