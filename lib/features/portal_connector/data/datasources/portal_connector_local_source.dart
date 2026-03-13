import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_connector/data/mappers/portal_connector_mapper.dart';
import 'package:ca_app/features/portal_connector/data/services/credential_encryption_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Local SQLite data source for portal credentials via Drift.
///
/// Encryption is applied transparently:
/// - On write: plaintext password (if any raw value) is encrypted before storage.
/// - On read: the encrypted blob is returned as-is on the domain model;
///   callers decrypt via [CredentialEncryptionService.decrypt] when needed.
///
/// In practice the domain model carries [encryptedPassword] at all times —
/// plaintext is never persisted.
class PortalConnectorLocalSource {
  const PortalConnectorLocalSource(this._db);

  final AppDatabase _db;

  /// Store [credential] after ensuring the password field is encrypted.
  /// Returns the stored credential ID.
  Future<String> storeCredential(PortalCredential credential) async {
    final safe = await _ensureEncrypted(credential);
    final companion = PortalConnectorMapper.toCompanion(safe);
    return _db.portalConnectorDao.storeCredential(companion);
  }

  /// Retrieve the stored [PortalCredential] for [portalType], or `null`.
  Future<PortalCredential?> getCredential(PortalType portalType) async {
    final row =
        await _db.portalConnectorDao.getCredential(portalType.name);
    return row != null ? PortalConnectorMapper.fromRow(row) : null;
  }

  /// Replace an existing credential record.
  /// Returns `true` on success.
  Future<bool> updateCredential(PortalCredential credential) async {
    final safe = await _ensureEncrypted(credential);
    final companion = PortalConnectorMapper.toCompanion(safe);
    return _db.portalConnectorDao.updateCredential(companion);
  }

  /// Remove the credential for [portalType].
  Future<bool> deleteCredential(PortalType portalType) =>
      _db.portalConnectorDao.deleteCredential(portalType.name);

  /// Return the current sync-status string for [portalType].
  Future<String?> getSyncStatus(PortalType portalType) =>
      _db.portalConnectorDao.getSyncStatus(portalType.name);

  /// Update the sync-status string for [portalType].
  Future<bool> updateSyncStatus(PortalType portalType, String status) =>
      _db.portalConnectorDao.updateSyncStatus(portalType.name, status);

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// If the credential has a plaintext-looking password (not already in
  /// "IV:ciphertext" format), encrypt it before persisting.
  Future<PortalCredential> _ensureEncrypted(
    PortalCredential credential,
  ) async {
    final raw = credential.encryptedPassword;
    if (raw == null || raw.contains(':')) {
      // Already encrypted or absent — no-op.
      return credential;
    }
    final encrypted = await CredentialEncryptionService.encrypt(raw);
    return credential.copyWith(encryptedPassword: encrypted);
  }
}
