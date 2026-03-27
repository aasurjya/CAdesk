import 'dart:math';

/// Permission a client can hold on the portal.
enum PortalPermission {
  viewDocuments,
  downloadDocuments,
  submitQueries,
  viewInvoices,
  makePayments,
}

/// Immutable time-limited access token for a client portal session.
class PortalAccessToken {
  const PortalAccessToken({
    required this.clientId,
    required this.token,
    required this.expiresAt,
    required this.permissions,
  });

  /// Client this token was issued to.
  final String clientId;

  /// Opaque token string — treat as a secret.
  final String token;

  /// Hard expiry: the token is invalid at or after this instant.
  final DateTime expiresAt;

  /// Permissions granted by this token.
  final List<PortalPermission> permissions;

  /// Returns `true` when [DateTime.now()] is before [expiresAt].
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  PortalAccessToken copyWith({
    String? clientId,
    String? token,
    DateTime? expiresAt,
    List<PortalPermission>? permissions,
  }) {
    return PortalAccessToken(
      clientId: clientId ?? this.clientId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortalAccessToken &&
        other.clientId == clientId &&
        other.token == token &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => Object.hash(clientId, token, expiresAt);

  @override
  String toString() =>
      'PortalAccessToken(clientId: $clientId, expiresAt: $expiresAt)';
}

/// Domain service that manages time-limited portal access tokens.
///
/// Stateless singleton — all state is in the returned [PortalAccessToken]
/// values and the revocation registry held by the caller / repository layer.
///
/// Token lifecycle:
/// 1. [generateToken] — issues a new token with an expiry and permission set.
/// 2. [validateToken] — confirms the token is authentic and not expired.
/// 3. [revokeAccess]  — marks a client as revoked; subsequent [validateToken]
///    calls for that client return `false`.
///
/// The default permission set grants all five [PortalPermission] values.
/// Callers that need restricted access should pass a custom [permissions] list.
class PortalAccessService {
  PortalAccessService._();

  static final PortalAccessService instance = PortalAccessService._();

  /// Tokens generated in this session, keyed by [PortalAccessToken.token].
  ///
  /// This in-memory registry is used for validation. A production
  /// implementation would persist tokens in a secure data store.
  final Map<String, PortalAccessToken> _activeTokens = {};

  /// Clients whose access has been explicitly revoked.
  final Set<String> _revokedClients = {};

  final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a time-limited [PortalAccessToken] for [clientId].
  ///
  /// [validity] controls how long the token remains valid (e.g. 24 hours).
  /// [permissions] defaults to all five portal permissions if omitted.
  ///
  /// Any previous tokens issued to the same client remain valid until they
  /// expire individually — revoking all at once requires calling [revokeAccess].
  ///
  /// Throws [ArgumentError] if [clientId] is empty.
  PortalAccessToken generateToken(
    String clientId,
    Duration validity, {
    List<PortalPermission> permissions = PortalPermission.values,
  }) {
    if (clientId.isEmpty) {
      throw ArgumentError.value(clientId, 'clientId', 'must not be empty');
    }

    final token = PortalAccessToken(
      clientId: clientId,
      token: _generateSecureToken(),
      expiresAt: DateTime.now().add(validity),
      permissions: List.unmodifiable(permissions),
    );

    _activeTokens[token.token] = token;
    return token;
  }

  /// Returns `true` when [token] is known, not expired, and the client has
  /// not been revoked via [revokeAccess].
  ///
  /// Returns `false` for any of:
  /// - Token string not found in the registry.
  /// - Token past [PortalAccessToken.expiresAt].
  /// - Client is in the revocation list.
  bool validateToken(PortalAccessToken token) {
    final stored = _activeTokens[token.token];
    if (stored == null) return false;
    if (stored.isExpired) return false;
    if (_revokedClients.contains(stored.clientId)) return false;
    return true;
  }

  /// Revokes all portal access for [clientId].
  ///
  /// After this call, [validateToken] returns `false` for any token
  /// belonging to [clientId], even if the token itself has not expired.
  /// Existing [PortalAccessToken] objects are not mutated.
  void revokeAccess(String clientId) {
    _revokedClients.add(clientId);
    // Remove all in-memory tokens for this client to free memory.
    _activeTokens.removeWhere((_, t) => t.clientId == clientId);
  }

  /// Returns `true` if [clientId] has been revoked.
  bool isRevoked(String clientId) => _revokedClients.contains(clientId);

  /// Removes expired tokens from the in-memory registry.
  ///
  /// Call periodically (e.g. on app resume) to keep memory usage bounded.
  void pruneExpiredTokens() {
    _activeTokens.removeWhere((_, t) => t.isExpired);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Generates a 48-character cryptographically random hex string.
  String _generateSecureToken() {
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
