import 'dart:math' as math;

/// Immutable configuration controlling how failed [BatchJobItem]s are retried.
///
/// Uses exponential backoff: delay = initialDelay × backoffMultiplier^(attempt-1),
/// capped at [maxDelaySeconds].
///
/// ### Example delays (defaults):
/// - Attempt 1: 30 s
/// - Attempt 2: 60 s
/// - Attempt 3: 120 s
/// - Attempt 4: 240 s
/// - Max cap: 3600 s (1 hour)
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelaySeconds = 30,
    this.backoffMultiplier = 2.0,
    this.maxDelaySeconds = 3600,
    this.retryableErrorCodes = const [
      'PORTAL_TIMEOUT',
      'RATE_LIMIT',
      'SERVER_ERROR_5XX',
    ],
  });

  /// Maximum number of processing attempts before marking an item as permanently
  /// failed. Includes the initial attempt.
  final int maxAttempts;

  /// Delay before the first retry in seconds.
  final int initialDelaySeconds;

  /// Multiplier applied to the delay after each failed attempt.
  final double backoffMultiplier;

  /// Upper bound on retry delay in seconds (prevents runaway wait times).
  final int maxDelaySeconds;

  /// Error codes that warrant a retry. Errors not in this list are treated as
  /// permanent failures (e.g., VALIDATION_ERROR, AUTH_FAILED).
  final List<String> retryableErrorCodes;

  // ── Behaviour ─────────────────────────────────────────────────────────────

  /// Computes the delay before the next retry attempt.
  ///
  /// [attemptNumber] is 1-based (first retry is attempt 1 → uses initialDelay,
  /// second retry is attempt 2 → doubles, etc.).
  ///
  /// Formula: `initialDelay × backoffMultiplier^(attemptNumber - 1)`, capped
  /// at [maxDelaySeconds].
  Duration computeNextRetryDelay(int attemptNumber) {
    final rawSeconds =
        initialDelaySeconds * math.pow(backoffMultiplier, attemptNumber - 1);
    final cappedSeconds = math.min(rawSeconds, maxDelaySeconds.toDouble());
    return Duration(seconds: cappedSeconds.round());
  }

  // ── Immutable update ───────────────────────────────────────────────────────

  RetryPolicy copyWith({
    int? maxAttempts,
    int? initialDelaySeconds,
    double? backoffMultiplier,
    int? maxDelaySeconds,
    List<String>? retryableErrorCodes,
  }) {
    return RetryPolicy(
      maxAttempts: maxAttempts ?? this.maxAttempts,
      initialDelaySeconds: initialDelaySeconds ?? this.initialDelaySeconds,
      backoffMultiplier: backoffMultiplier ?? this.backoffMultiplier,
      maxDelaySeconds: maxDelaySeconds ?? this.maxDelaySeconds,
      retryableErrorCodes: retryableErrorCodes ?? this.retryableErrorCodes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RetryPolicy) return false;
    return maxAttempts == other.maxAttempts &&
        initialDelaySeconds == other.initialDelaySeconds &&
        backoffMultiplier == other.backoffMultiplier &&
        maxDelaySeconds == other.maxDelaySeconds;
  }

  @override
  int get hashCode => Object.hash(
        maxAttempts,
        initialDelaySeconds,
        backoffMultiplier,
        maxDelaySeconds,
      );

  @override
  String toString() =>
      'RetryPolicy(maxAttempts: $maxAttempts, initialDelay: ${initialDelaySeconds}s, '
      'multiplier: $backoffMultiplier, maxDelay: ${maxDelaySeconds}s)';
}
