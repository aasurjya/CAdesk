import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

/// Per-portal request-rate limits (requests per 60-second rolling window).
const Map<Portal, int> _kRateLimits = {
  Portal.itd: 10,
  Portal.gstn: 20,
  Portal.traces: 5,
  Portal.mca: 10,
  Portal.epfo: 10,
  Portal.nic: 10,
};

const Duration _kWindow = Duration(seconds: 60);

/// Immutable token-bucket rate limiter that tracks requests per portal.
///
/// Uses a rolling 60-second window backed by a [List<DateTime>] per portal.
/// All mutation operations return a new [PortalRateLimiter] — the original
/// is never modified.
///
/// The optional [now] parameter on [isAllowed] and [computeWaitTime] allows
/// deterministic testing without `DateTime.now()` side-effects.
class PortalRateLimiter {
  const PortalRateLimiter({
    Map<Portal, List<DateTime>>? history,
  }) : _history = history ?? const {};

  /// Internal request history keyed by portal.
  final Map<Portal, List<DateTime>> _history;

  /// Returns `true` when [portal] has not exceeded its rate limit.
  ///
  /// [now] defaults to [DateTime.now()] when omitted.
  bool isAllowed(Portal portal, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final active = _activeRequests(portal, effectiveNow);
    return active < (_kRateLimits[portal] ?? 10);
  }

  /// Records a request for [portal] at [at] and returns a new [PortalRateLimiter].
  PortalRateLimiter recordRequest(Portal portal, DateTime at) {
    final existing = List<DateTime>.from(_history[portal] ?? const <DateTime>[]);
    existing.add(at);
    final updated = Map<Portal, List<DateTime>>.from(_history);
    updated[portal] = existing;
    return PortalRateLimiter(history: updated);
  }

  /// Returns [Duration.zero] when [portal] is allowed, otherwise the time
  /// until the oldest in-window request ages out.
  ///
  /// [now] defaults to [DateTime.now()] when omitted.
  Duration computeWaitTime(Portal portal, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    if (isAllowed(portal, now: effectiveNow)) return Duration.zero;

    final timestamps = _windowedTimestamps(portal, effectiveNow);
    if (timestamps.isEmpty) return Duration.zero;

    // Oldest timestamp + 60s tells us when the next slot opens.
    final oldest = timestamps.reduce((a, b) => a.isBefore(b) ? a : b);
    final slotOpensAt = oldest.add(_kWindow);
    final wait = slotOpensAt.difference(effectiveNow);
    return wait.isNegative ? Duration.zero : wait;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Count of requests in the rolling window ending at [now].
  int _activeRequests(Portal portal, DateTime now) =>
      _windowedTimestamps(portal, now).length;

  /// Timestamps within the [_kWindow] rolling window ending at [now].
  List<DateTime> _windowedTimestamps(Portal portal, DateTime now) {
    final cutoff = now.subtract(_kWindow);
    return (_history[portal] ?? const <DateTime>[])
        .where((t) => t.isAfter(cutoff))
        .toList();
  }
}
