import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Batch Retry Service
// ---------------------------------------------------------------------------

/// Stateless utility service encapsulating retry policy decisions for
/// batch HTTP operations against government portals.
///
/// All methods are static — no instance state is needed or maintained.
///
/// ### Retry strategy
/// - Retries on transient server errors (5xx) and rate-limit responses (429).
/// - Never retries on permanent client errors (4xx except 429, 408).
/// - Uses exponential back-off with jitter to avoid thundering-herd
///   problems when multiple clients retry simultaneously.
///
/// ### Jitter
/// A random value in the range [0, baseDelay × 0.3] is added to each
/// computed delay to spread retries across time.
class BatchRetryService {
  const BatchRetryService._();

  /// Maximum jitter fraction applied to each retry delay.
  static const double _jitterFraction = 0.30;

  /// Base delay for the first retry, in seconds.
  static const int _baseDelaySeconds = 2;

  /// Multiplier applied to the delay after each attempt.
  static const double _backoffMultiplier = 2.0;

  /// Maximum delay cap, in seconds (prevents unbounded wait times).
  static const int _maxDelaySeconds = 60;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns true when a failed request should be retried.
  ///
  /// - [statusCode]  — HTTP status code of the failed response
  /// - [attempt]     — 0-based current attempt count (0 = first attempt)
  /// - [maxAttempts] — Maximum number of total attempts (default 3)
  ///
  /// Retries are allowed when:
  /// 1. [attempt] < [maxAttempts] - 1 (not yet exhausted)
  /// 2. [statusCode] is NOT a permanent failure (see [isPermanentFailure])
  static bool shouldRetry(int statusCode, int attempt, {int maxAttempts = 3}) {
    if (attempt >= maxAttempts - 1) return false;
    return !isPermanentFailure(statusCode);
  }

  /// Computes the delay before the next retry attempt.
  ///
  /// Formula: `baseDelay × backoffMultiplier^attempt`, capped at
  /// [_maxDelaySeconds], with a random jitter of up to 30% of the base delay.
  ///
  /// - [attempt] — 0-based attempt count (0 = delay before first retry)
  ///
  /// ### Example delays (no jitter, defaults):
  /// - attempt 0: 2 s
  /// - attempt 1: 4 s
  /// - attempt 2: 8 s
  /// - attempt 3: 16 s
  /// - attempt 4: 32 s
  /// - attempt 5+: 60 s (capped)
  static Duration delayFor(int attempt) {
    final rawSeconds =
        _baseDelaySeconds * math.pow(_backoffMultiplier, attempt);
    final cappedSeconds = math.min(rawSeconds, _maxDelaySeconds.toDouble());
    final jitterSeconds =
        cappedSeconds * _jitterFraction * math.Random().nextDouble();
    return Duration(
      milliseconds: ((cappedSeconds + jitterSeconds) * 1000).round(),
    );
  }

  /// Returns true when the [statusCode] represents a permanent failure that
  /// must not be retried regardless of attempt count.
  ///
  /// Permanent failures:
  /// - 400 Bad Request — request is malformed
  /// - 401 Unauthorized — authentication failed
  /// - 403 Forbidden — access denied
  /// - 404 Not Found — resource does not exist
  /// - 409 Conflict — duplicate or conflicting request
  /// - 410 Gone — resource permanently removed
  /// - 422 Unprocessable Entity — validation error
  ///
  /// Retryable status codes (NOT permanent failures):
  /// - 408 Request Timeout
  /// - 429 Too Many Requests (rate limit)
  /// - 500 Internal Server Error
  /// - 502 Bad Gateway
  /// - 503 Service Unavailable
  /// - 504 Gateway Timeout
  static bool isPermanentFailure(int statusCode) {
    const permanentCodes = <int>{400, 401, 403, 404, 409, 410, 422};
    return permanentCodes.contains(statusCode);
  }

  /// Returns true when [statusCode] indicates a server-side or transient error
  /// that is worth retrying.
  static bool isRetryableError(int statusCode) {
    if (statusCode == 408 || statusCode == 429) return true;
    if (statusCode >= 500 && statusCode < 600) return true;
    return false;
  }

  /// Returns a human-readable reason for why a given [statusCode] triggers
  /// (or prevents) a retry.
  ///
  /// Intended for logging and diagnostic messages.
  static String retryReasonFor(int statusCode) {
    switch (statusCode) {
      case 408:
        return 'Request timed out — retrying';
      case 429:
        return 'Rate limit exceeded — backing off and retrying';
      case 500:
        return 'Internal server error — retrying';
      case 502:
        return 'Bad gateway — retrying';
      case 503:
        return 'Service unavailable — retrying';
      case 504:
        return 'Gateway timeout — retrying';
      case 400:
        return 'Bad request — not retrying (permanent failure)';
      case 401:
        return 'Unauthorised — not retrying (authentication error)';
      case 403:
        return 'Forbidden — not retrying (access denied)';
      case 404:
        return 'Not found — not retrying (resource missing)';
      case 409:
        return 'Conflict — not retrying (duplicate or collision)';
      case 410:
        return 'Gone — not retrying (resource permanently removed)';
      case 422:
        return 'Unprocessable entity — not retrying (validation error)';
      default:
        if (statusCode >= 500) {
          return 'Server error ($statusCode) — retrying';
        }
        return 'Unexpected status ($statusCode) — not retrying';
    }
  }
}
