import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

/// Immutable model holding authentication credentials for a government portal.
///
/// Passwords are NEVER stored in plain text — only [passwordHash] is kept.
class PortalCredentials {
  const PortalCredentials({
    required this.portal,
    required this.userId,
    required this.passwordHash,
    this.sessionToken,
    this.tokenExpiry,
  });

  /// Target portal.
  final Portal portal;

  /// Portal-specific user identifier (e.g. PAN, GSTIN login).
  final String userId;

  /// Hashed password — plaintext is never stored.
  final String passwordHash;

  /// Active session token (nullable — absent until authenticated).
  final String? sessionToken;

  /// Expiry timestamp of [sessionToken] (nullable).
  final DateTime? tokenExpiry;

  /// `true` when a [sessionToken] exists and has not yet expired.
  bool get isTokenValid {
    if (sessionToken == null || tokenExpiry == null) return false;
    return tokenExpiry!.isAfter(DateTime.now());
  }

  PortalCredentials copyWith({
    Portal? portal,
    String? userId,
    String? passwordHash,
    String? sessionToken,
    DateTime? tokenExpiry,
  }) {
    return PortalCredentials(
      portal: portal ?? this.portal,
      userId: userId ?? this.userId,
      passwordHash: passwordHash ?? this.passwordHash,
      sessionToken: sessionToken ?? this.sessionToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortalCredentials &&
          runtimeType == other.runtimeType &&
          portal == other.portal &&
          userId == other.userId &&
          passwordHash == other.passwordHash &&
          sessionToken == other.sessionToken &&
          tokenExpiry == other.tokenExpiry;

  @override
  int get hashCode =>
      Object.hash(portal, userId, passwordHash, sessionToken, tokenExpiry);
}
