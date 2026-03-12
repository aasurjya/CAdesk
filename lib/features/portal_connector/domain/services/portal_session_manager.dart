import 'dart:math' as math;

import 'package:ca_app/features/portal_connector/domain/models/portal_credentials.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_session.dart';

/// Session lifetimes per portal.
const Map<Portal, Duration> _kSessionLifetimes = {
  Portal.itd: Duration(hours: 8),
  Portal.gstn: Duration(hours: 4),
  Portal.traces: Duration(hours: 2),
  Portal.mca: Duration(hours: 8),
  Portal.epfo: Duration(hours: 8),
  Portal.nic: Duration(hours: 8),
};

const Duration _kDefaultLifetime = Duration(hours: 8);

/// Stateless utility class for portal session lifecycle management.
///
/// All methods are pure functions — they return new [PortalSession] instances
/// and never mutate existing objects.
class PortalSessionManager {
  PortalSessionManager._();

  /// Create a new active [PortalSession] for the given [credentials] at [now].
  static PortalSession createSession(
    PortalCredentials credentials,
    DateTime now,
  ) {
    final lifetime =
        _kSessionLifetimes[credentials.portal] ?? _kDefaultLifetime;
    return PortalSession(
      sessionId: _generateSessionId(),
      portal: credentials.portal,
      userId: credentials.userId,
      createdAt: now,
      lastActivityAt: now,
      isActive: true,
      expiresAt: now.add(lifetime),
    );
  }

  /// Refresh [session] at [now], extending its expiry by the portal lifetime.
  ///
  /// Returns a new [PortalSession] — the original is unchanged.
  static PortalSession refreshSession(PortalSession session, DateTime now) {
    final lifetime = _kSessionLifetimes[session.portal] ?? _kDefaultLifetime;
    return session.copyWith(lastActivityAt: now, expiresAt: now.add(lifetime));
  }

  /// Invalidate [session] by marking it inactive.
  ///
  /// Returns a new [PortalSession] with [isActive] = `false`.
  static PortalSession invalidateSession(PortalSession session) {
    return session.copyWith(isActive: false);
  }

  /// Returns `true` when [session] has passed its [PortalSession.expiresAt]
  /// relative to [now].
  static bool isExpired(PortalSession session, DateTime now) {
    return session.isExpired(now);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static final math.Random _random = math.Random.secure();

  /// Generate a random session ID of 24 hex characters.
  static String _generateSessionId() {
    const chars = '0123456789abcdef';
    final buffer = StringBuffer();
    for (var i = 0; i < 24; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}
