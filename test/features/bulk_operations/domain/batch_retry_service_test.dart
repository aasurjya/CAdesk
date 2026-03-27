import 'package:ca_app/features/bulk_operations/domain/services/batch_retry_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BatchRetryService', () {
    // ── isPermanentFailure ────────────────────────────────────────────────────

    group('isPermanentFailure', () {
      test('400 is a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(400), isTrue);
      });

      test('401 is a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(401), isTrue);
      });

      test('403 is a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(403), isTrue);
      });

      test('404 is a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(404), isTrue);
      });

      test('409 is a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(409), isTrue);
      });

      test('410 is a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(410), isTrue);
      });

      test('422 is a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(422), isTrue);
      });

      test('500 is NOT a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(500), isFalse);
      });

      test('503 is NOT a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(503), isFalse);
      });

      test('429 is NOT a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(429), isFalse);
      });

      test('408 is NOT a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(408), isFalse);
      });

      test('200 is NOT a permanent failure', () {
        expect(BatchRetryService.isPermanentFailure(200), isFalse);
      });
    });

    // ── isRetryableError ──────────────────────────────────────────────────────

    group('isRetryableError', () {
      test('408 is retryable', () {
        expect(BatchRetryService.isRetryableError(408), isTrue);
      });

      test('429 is retryable', () {
        expect(BatchRetryService.isRetryableError(429), isTrue);
      });

      test('500 is retryable', () {
        expect(BatchRetryService.isRetryableError(500), isTrue);
      });

      test('502 is retryable', () {
        expect(BatchRetryService.isRetryableError(502), isTrue);
      });

      test('503 is retryable', () {
        expect(BatchRetryService.isRetryableError(503), isTrue);
      });

      test('504 is retryable', () {
        expect(BatchRetryService.isRetryableError(504), isTrue);
      });

      test('5xx series is retryable (e.g. 599)', () {
        expect(BatchRetryService.isRetryableError(599), isTrue);
      });

      test('400 is NOT retryable', () {
        expect(BatchRetryService.isRetryableError(400), isFalse);
      });

      test('401 is NOT retryable', () {
        expect(BatchRetryService.isRetryableError(401), isFalse);
      });

      test('404 is NOT retryable', () {
        expect(BatchRetryService.isRetryableError(404), isFalse);
      });

      test('200 is NOT retryable', () {
        expect(BatchRetryService.isRetryableError(200), isFalse);
      });

      test('301 is NOT retryable', () {
        expect(BatchRetryService.isRetryableError(301), isFalse);
      });
    });

    // ── shouldRetry ───────────────────────────────────────────────────────────

    group('shouldRetry — maxAttempts defaults to 3', () {
      test('should retry at attempt 0 for 503', () {
        expect(BatchRetryService.shouldRetry(503, 0), isTrue);
      });

      test('should retry at attempt 1 for 503', () {
        expect(BatchRetryService.shouldRetry(503, 1), isTrue);
      });

      test('should NOT retry at attempt 2 for 503 (exhausted)', () {
        // attempt 2 = 3rd attempt = maxAttempts - 1 → stop
        expect(BatchRetryService.shouldRetry(503, 2), isFalse);
      });

      test('should NOT retry at attempt 0 for 400 (permanent failure)', () {
        expect(BatchRetryService.shouldRetry(400, 0), isFalse);
      });

      test('should NOT retry at attempt 0 for 404 (permanent failure)', () {
        expect(BatchRetryService.shouldRetry(404, 0), isFalse);
      });

      test('should retry at attempt 0 for 429', () {
        expect(BatchRetryService.shouldRetry(429, 0), isTrue);
      });
    });

    group('shouldRetry — custom maxAttempts', () {
      test('allows more retries with maxAttempts = 5', () {
        expect(BatchRetryService.shouldRetry(500, 3, maxAttempts: 5), isTrue);
        expect(BatchRetryService.shouldRetry(500, 4, maxAttempts: 5), isFalse);
      });

      test('no retries with maxAttempts = 1', () {
        expect(BatchRetryService.shouldRetry(500, 0, maxAttempts: 1), isFalse);
      });

      test('retries with maxAttempts = 2 only at attempt 0', () {
        expect(BatchRetryService.shouldRetry(503, 0, maxAttempts: 2), isTrue);
        expect(BatchRetryService.shouldRetry(503, 1, maxAttempts: 2), isFalse);
      });
    });

    // ── delayFor — exponential backoff ────────────────────────────────────────

    group('delayFor — exponential backoff with jitter', () {
      test('attempt 0 has base delay around 2 seconds (with jitter)', () {
        final delay = BatchRetryService.delayFor(0);
        // base = 2s, max jitter = 2 × 0.3 = 0.6s → range [2000, 2600] ms
        expect(delay.inMilliseconds, greaterThanOrEqualTo(2000));
        expect(delay.inMilliseconds, lessThanOrEqualTo(2700));
      });

      test('attempt 1 has delay around 4 seconds (with jitter)', () {
        final delay = BatchRetryService.delayFor(1);
        // base = 4s, max jitter = 4 × 0.3 = 1.2s → range [4000, 5200] ms
        expect(delay.inMilliseconds, greaterThanOrEqualTo(4000));
        expect(delay.inMilliseconds, lessThanOrEqualTo(5300));
      });

      test('attempt 2 delay is between 8s and ~10.5s (with jitter)', () {
        final delay = BatchRetryService.delayFor(2);
        expect(delay.inMilliseconds, greaterThanOrEqualTo(8000));
        expect(delay.inMilliseconds, lessThanOrEqualTo(10500));
      });

      test('delay doubles between consecutive attempts (base growth)', () {
        final d0 = BatchRetryService.delayFor(0).inMilliseconds;
        final d1 = BatchRetryService.delayFor(1).inMilliseconds;
        // d1 should be roughly 2× d0 (exact comparison hard due to jitter)
        expect(d1, greaterThan(d0));
      });

      test('delay is capped at 60 seconds + jitter', () {
        // attempt 10: 2 × 2^10 = 2048 s → capped at 60 s + jitter
        final delay = BatchRetryService.delayFor(10);
        // 60 s + up to 30% of 60 s = up to 78 s
        expect(delay.inSeconds, lessThanOrEqualTo(78));
        expect(delay.inSeconds, greaterThanOrEqualTo(60));
      });

      test('delay is never negative', () {
        for (var i = 0; i < 10; i++) {
          expect(BatchRetryService.delayFor(i).inMilliseconds, isPositive);
        }
      });
    });

    // ── retryReasonFor ────────────────────────────────────────────────────────

    group('retryReasonFor', () {
      test('408 returns timeout message', () {
        final reason = BatchRetryService.retryReasonFor(408);
        expect(reason, contains('timed out'));
      });

      test('429 returns rate limit message', () {
        final reason = BatchRetryService.retryReasonFor(429);
        expect(reason.toLowerCase(), contains('rate limit'));
      });

      test('500 returns internal server error message', () {
        final reason = BatchRetryService.retryReasonFor(500);
        expect(reason.toLowerCase(), contains('internal server error'));
      });

      test('503 returns service unavailable message', () {
        final reason = BatchRetryService.retryReasonFor(503);
        expect(reason.toLowerCase(), contains('service unavailable'));
      });

      test('400 returns not-retrying message', () {
        final reason = BatchRetryService.retryReasonFor(400);
        expect(reason.toLowerCase(), contains('not retrying'));
      });

      test('401 returns authentication message', () {
        final reason = BatchRetryService.retryReasonFor(401);
        expect(
          reason.toLowerCase(),
          anyOf(contains('auth'), contains('unauthori')),
        );
      });

      test('403 returns access denied message', () {
        final reason = BatchRetryService.retryReasonFor(403);
        expect(
          reason.toLowerCase(),
          anyOf(contains('forbidden'), contains('access denied')),
        );
      });

      test('404 returns not-found message', () {
        final reason = BatchRetryService.retryReasonFor(404);
        expect(reason.toLowerCase(), contains('not found'));
      });

      test('generic 5xx returns retrying message', () {
        final reason = BatchRetryService.retryReasonFor(507);
        expect(reason.toLowerCase(), contains('retrying'));
      });

      test('unexpected status returns not-retrying message', () {
        final reason = BatchRetryService.retryReasonFor(302);
        expect(reason.toLowerCase(), contains('not retrying'));
      });

      test('reason is non-empty for all known codes', () {
        const codes = [
          400,
          401,
          403,
          404,
          408,
          409,
          410,
          422,
          429,
          500,
          502,
          503,
          504,
        ];
        for (final code in codes) {
          expect(BatchRetryService.retryReasonFor(code), isNotEmpty);
        }
      });
    });

    // ── retry policy consistency ──────────────────────────────────────────────

    group('retry policy consistency', () {
      test(
        'isPermanentFailure and isRetryableError are disjoint for key codes',
        () {
          const testCodes = [
            400,
            401,
            403,
            404,
            408,
            409,
            410,
            422,
            429,
            500,
            503,
          ];
          for (final code in testCodes) {
            final permanent = BatchRetryService.isPermanentFailure(code);
            final retryable = BatchRetryService.isRetryableError(code);
            // A code should not be both permanent AND retryable
            expect(
              permanent && retryable,
              isFalse,
              reason:
                  'Code $code is both permanent and retryable — inconsistency',
            );
          }
        },
      );

      test(
        'shouldRetry is false for all permanent failure codes at attempt 0',
        () {
          const permanentCodes = [400, 401, 403, 404, 409, 410, 422];
          for (final code in permanentCodes) {
            expect(
              BatchRetryService.shouldRetry(code, 0),
              isFalse,
              reason: 'Expected no retry for $code',
            );
          }
        },
      );

      test('shouldRetry is true for all retryable codes at attempt 0', () {
        const retryableCodes = [408, 429, 500, 502, 503, 504];
        for (final code in retryableCodes) {
          expect(
            BatchRetryService.shouldRetry(code, 0),
            isTrue,
            reason: 'Expected retry for $code',
          );
        }
      });
    });
  });
}
