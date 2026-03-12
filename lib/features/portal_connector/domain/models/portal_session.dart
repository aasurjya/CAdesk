import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

/// Immutable model representing an authenticated session with a government portal.
class PortalSession {
  const PortalSession({
    required this.sessionId,
    required this.portal,
    required this.userId,
    required this.createdAt,
    required this.lastActivityAt,
    required this.isActive,
    required this.expiresAt,
  });

  /// Unique session identifier.
  final String sessionId;

  /// Portal this session belongs to.
  final Portal portal;

  /// Authenticated user identifier.
  final String userId;

  /// When the session was created.
  final DateTime createdAt;

  /// Timestamp of the most recent API activity on this session.
  final DateTime lastActivityAt;

  /// Whether the session is currently active (not explicitly invalidated).
  final bool isActive;

  /// Absolute expiry timestamp for this session.
  final DateTime expiresAt;

  /// Returns `true` when [now] is at or after [expiresAt].
  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  PortalSession copyWith({
    String? sessionId,
    Portal? portal,
    String? userId,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    bool? isActive,
    DateTime? expiresAt,
  }) {
    return PortalSession(
      sessionId: sessionId ?? this.sessionId,
      portal: portal ?? this.portal,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortalSession &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          portal == other.portal &&
          userId == other.userId &&
          createdAt == other.createdAt &&
          lastActivityAt == other.lastActivityAt &&
          isActive == other.isActive &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(
        sessionId,
        portal,
        userId,
        createdAt,
        lastActivityAt,
        isActive,
        expiresAt,
      );
}
