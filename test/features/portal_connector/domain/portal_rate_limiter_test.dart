import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/services/portal_rate_limiter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 12, 0, 0);

  group('PortalRateLimiter — initial state', () {
    test('all portals are allowed with empty history', () {
      const limiter = PortalRateLimiter();
      for (final portal in Portal.values) {
        expect(
          limiter.isAllowed(portal, now: t0),
          isTrue,
          reason: 'Expected $portal to be allowed with empty history',
        );
      }
    });

    test('computeWaitTime is zero for all portals when empty', () {
      const limiter = PortalRateLimiter();
      for (final portal in Portal.values) {
        expect(limiter.computeWaitTime(portal, now: t0), Duration.zero);
      }
    });
  });

  group('PortalRateLimiter — ITD (10 req/min)', () {
    test('allows up to 10 requests within 60 seconds', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 10; i++) {
        expect(
          limiter.isAllowed(Portal.itd, now: t0.add(Duration(seconds: i))),
          isTrue,
        );
        limiter = limiter.recordRequest(
          Portal.itd,
          t0.add(Duration(seconds: i)),
        );
      }
    });

    test('blocks 11th request within same 60-second window', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 10; i++) {
        limiter = limiter.recordRequest(
          Portal.itd,
          t0.add(Duration(seconds: i)),
        );
      }
      // Check isAllowed at t0 + 9s (all 10 are still inside the window)
      expect(
        limiter.isAllowed(Portal.itd, now: t0.add(const Duration(seconds: 9))),
        isFalse,
      );
    });

    test('allows request after 60-second window has passed', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 10; i++) {
        limiter = limiter.recordRequest(Portal.itd, t0);
      }
      // At t0 + 61s the oldest entry (t0) is older than 60s — window is clear.
      final t61 = t0.add(const Duration(seconds: 61));
      expect(limiter.isAllowed(Portal.itd, now: t61), isTrue);
    });

    test('recordRequest returns new immutable instance', () {
      const limiter = PortalRateLimiter();
      final updated = limiter.recordRequest(Portal.itd, t0);
      expect(identical(limiter, updated), isFalse);
    });
  });

  group('PortalRateLimiter — GSTN (20 req/min)', () {
    test('allows up to 20 requests', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 20; i++) {
        expect(
          limiter.isAllowed(Portal.gstn, now: t0.add(Duration(seconds: i))),
          isTrue,
        );
        limiter = limiter.recordRequest(
          Portal.gstn,
          t0.add(Duration(seconds: i)),
        );
      }
    });

    test('blocks 21st request within same window', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 20; i++) {
        limiter = limiter.recordRequest(
          Portal.gstn,
          t0.add(Duration(seconds: i)),
        );
      }
      expect(
        limiter.isAllowed(
          Portal.gstn,
          now: t0.add(const Duration(seconds: 19)),
        ),
        isFalse,
      );
    });
  });

  group('PortalRateLimiter — TRACES (5 req/min)', () {
    test('allows up to 5 requests', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 5; i++) {
        expect(
          limiter.isAllowed(Portal.traces, now: t0.add(Duration(seconds: i))),
          isTrue,
        );
        limiter = limiter.recordRequest(
          Portal.traces,
          t0.add(Duration(seconds: i)),
        );
      }
    });

    test('blocks 6th request within same window', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 5; i++) {
        limiter = limiter.recordRequest(
          Portal.traces,
          t0.add(Duration(seconds: i)),
        );
      }
      expect(
        limiter.isAllowed(
          Portal.traces,
          now: t0.add(const Duration(seconds: 4)),
        ),
        isFalse,
      );
    });
  });

  group('PortalRateLimiter — MCA (10 req/min)', () {
    test('blocks 11th request', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 10; i++) {
        limiter = limiter.recordRequest(
          Portal.mca,
          t0.add(Duration(seconds: i)),
        );
      }
      expect(
        limiter.isAllowed(Portal.mca, now: t0.add(const Duration(seconds: 9))),
        isFalse,
      );
    });
  });

  group('PortalRateLimiter — computeWaitTime', () {
    test('returns zero Duration when allowed', () {
      const limiter = PortalRateLimiter();
      expect(limiter.computeWaitTime(Portal.itd, now: t0), Duration.zero);
    });

    test('returns positive Duration when rate-limited', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 10; i++) {
        limiter = limiter.recordRequest(
          Portal.itd,
          t0.add(Duration(seconds: i)),
        );
      }
      // Check wait time at t0 + 9s (within the window, still blocked)
      final wait = limiter.computeWaitTime(
        Portal.itd,
        now: t0.add(const Duration(seconds: 9)),
      );
      expect(wait.inMilliseconds, greaterThan(0));
    });

    test('TRACES wait time does not exceed 60 seconds', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 5; i++) {
        limiter = limiter.recordRequest(
          Portal.traces,
          t0.add(Duration(seconds: i)),
        );
      }
      final wait = limiter.computeWaitTime(
        Portal.traces,
        now: t0.add(const Duration(seconds: 4)),
      );
      expect(wait.inSeconds, lessThanOrEqualTo(60));
    });
  });

  group('PortalRateLimiter — portals independent', () {
    test('rate-limiting ITD does not affect GSTN', () {
      var limiter = const PortalRateLimiter();
      for (var i = 0; i < 10; i++) {
        limiter = limiter.recordRequest(
          Portal.itd,
          t0.add(Duration(seconds: i)),
        );
      }
      final checkAt = t0.add(const Duration(seconds: 9));
      expect(limiter.isAllowed(Portal.itd, now: checkAt), isFalse);
      expect(limiter.isAllowed(Portal.gstn, now: checkAt), isTrue);
    });
  });
}
