/// Thrown when portal authentication fails (bad credentials, expired token).
class PortalAuthException implements Exception {
  const PortalAuthException({
    required this.portal,
    required this.message,
    this.statusCode,
  });

  final String portal;
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'PortalAuthException[$portal]: $message'
      '${statusCode != null ? " (HTTP $statusCode)" : ""}';
}

/// Thrown when a portal API rate-limit is exceeded.
class PortalRateLimitException implements Exception {
  const PortalRateLimitException({
    required this.portal,
    required this.message,
    this.retryAfterSeconds,
  });

  final String portal;
  final String message;

  /// Seconds until the next request is allowed, if the portal provides it.
  final int? retryAfterSeconds;

  @override
  String toString() =>
      'PortalRateLimitException[$portal]: $message'
      '${retryAfterSeconds != null ? " (retry after ${retryAfterSeconds}s)" : ""}';
}

/// Thrown when a portal is temporarily unavailable (5xx, timeout, no network).
class PortalUnavailableException implements Exception {
  const PortalUnavailableException({
    required this.portal,
    required this.message,
    this.statusCode,
  });

  final String portal;
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'PortalUnavailableException[$portal]: $message'
      '${statusCode != null ? " (HTTP $statusCode)" : ""}';
}
