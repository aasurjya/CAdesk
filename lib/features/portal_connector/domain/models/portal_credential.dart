/// Supported government portals for credential storage and sync tracking.
enum PortalType {
  itd('Income Tax Department'),
  gstn('GST Network'),
  traces('TRACES'),
  mca('Ministry of Corporate Affairs'),
  epfo('EPFO');

  const PortalType(this.label);

  final String label;
}

/// Immutable model holding stored credentials for a government portal.
///
/// Passwords are NEVER stored in plain text — only [encryptedPassword]
/// (AES-encrypted via [CredentialEncryptionService]) is persisted.
class PortalCredential {
  const PortalCredential({
    required this.id,
    required this.portalType,
    this.username,
    this.encryptedPassword,
    this.grantToken,
    this.refreshToken,
    this.expiresAt,
    this.lastSyncDate,
    this.status,
  });

  /// Unique identifier (UUID).
  final String id;

  /// Target portal.
  final PortalType portalType;

  /// Portal login username (e.g. PAN, GSTIN login).
  final String? username;

  /// AES-encrypted password in "IV:ciphertext" format.
  /// Never store plaintext passwords.
  final String? encryptedPassword;

  /// OAuth grant token for token-based portals.
  final String? grantToken;

  /// OAuth refresh token.
  final String? refreshToken;

  /// Token expiry timestamp.
  final DateTime? expiresAt;

  /// Timestamp of the last successful sync with this portal.
  final DateTime? lastSyncDate;

  /// Sync/connection status string (e.g. 'active', 'connected', 'error').
  final String? status;

  /// Whether the token has not expired yet.
  bool get isTokenValid {
    if (grantToken == null && refreshToken == null) return false;
    if (expiresAt == null) return true; // no expiry = still valid
    return expiresAt!.isAfter(DateTime.now());
  }

  PortalCredential copyWith({
    String? id,
    PortalType? portalType,
    String? username,
    String? encryptedPassword,
    String? grantToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? lastSyncDate,
    String? status,
  }) {
    return PortalCredential(
      id: id ?? this.id,
      portalType: portalType ?? this.portalType,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      grantToken: grantToken ?? this.grantToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortalCredential &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          portalType == other.portalType &&
          username == other.username &&
          encryptedPassword == other.encryptedPassword &&
          grantToken == other.grantToken &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt &&
          lastSyncDate == other.lastSyncDate &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        portalType,
        username,
        encryptedPassword,
        grantToken,
        refreshToken,
        expiresAt,
        lastSyncDate,
        status,
      );

  @override
  String toString() =>
      'PortalCredential(id: $id, portalType: ${portalType.name}, '
      'username: $username, status: $status)';
}
