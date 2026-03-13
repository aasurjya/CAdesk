import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Bidirectional mapper between [PortalCredential] domain model and
/// Drift row / Supabase JSON representations.
///
/// Passwords are always stored encrypted. The mapper assumes:
/// - [encryptedPassword] on the domain model is already AES-encrypted
///   (via [CredentialEncryptionService]) before being passed here.
/// - Decryption is the caller's responsibility when consuming the domain model.
class PortalConnectorMapper {
  const PortalConnectorMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → domain model
  // ---------------------------------------------------------------------------

  static PortalCredential fromJson(Map<String, dynamic> json) {
    return PortalCredential(
      id: json['id'] as String,
      portalType: _safePortalType(json['portal_type'] as String? ?? ''),
      username: json['username'] as String?,
      encryptedPassword: json['encrypted_password'] as String?,
      grantToken: json['grant_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      lastSyncDate: json['last_sync_date'] != null
          ? DateTime.parse(json['last_sync_date'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // domain model → JSON (Supabase insert/update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(PortalCredential credential) {
    return {
      'id': credential.id,
      'portal_type': credential.portalType.name,
      'username': credential.username,
      'encrypted_password': credential.encryptedPassword,
      'grant_token': credential.grantToken,
      'refresh_token': credential.refreshToken,
      'expires_at': credential.expiresAt?.toIso8601String(),
      'last_sync_date': credential.lastSyncDate?.toIso8601String(),
      'status': credential.status,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → domain model
  // ---------------------------------------------------------------------------

  static PortalCredential fromRow(PortalCredentialsTableData row) {
    return PortalCredential(
      id: row.id,
      portalType: _safePortalType(row.portalType),
      username: row.username,
      encryptedPassword: row.encryptedPassword,
      grantToken: row.grantToken,
      refreshToken: row.refreshToken,
      expiresAt: row.expiresAt,
      lastSyncDate: row.lastSyncDate,
      status: row.status,
    );
  }

  // ---------------------------------------------------------------------------
  // domain model → Drift companion (insert/update)
  // ---------------------------------------------------------------------------

  static PortalCredentialsTableCompanion toCompanion(
    PortalCredential credential,
  ) {
    return PortalCredentialsTableCompanion(
      id: Value(credential.id),
      portalType: Value(credential.portalType.name),
      username: Value(credential.username),
      encryptedPassword: Value(credential.encryptedPassword),
      grantToken: Value(credential.grantToken),
      refreshToken: Value(credential.refreshToken),
      expiresAt: Value(credential.expiresAt),
      lastSyncDate: Value(credential.lastSyncDate),
      status: Value(credential.status),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static PortalType _safePortalType(String value) {
    try {
      return PortalType.values.byName(value);
    } catch (_) {
      return PortalType.itd; // safe fallback
    }
  }
}
