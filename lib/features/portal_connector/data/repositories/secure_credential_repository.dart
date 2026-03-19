import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

/// [PortalCredentialRepository] backed by [FlutterSecureStorage].
///
/// Each credential is serialised to JSON and stored under a deterministic key
/// derived from the [PortalType].  Sync-status strings are stored separately
/// so they can be updated without touching the credential payload.
///
/// Key scheme:
/// - Credential → `portal_credential_{portalType.name}`
/// - Sync status → `portal_sync_{portalType.name}`
class SecureCredentialRepository implements PortalCredentialRepository {
  SecureCredentialRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // ---------------------------------------------------------------------------
  // Key helpers
  // ---------------------------------------------------------------------------

  static String _credentialKey(PortalType type) =>
      'portal_credential_${type.name}';

  static String _syncKey(PortalType type) => 'portal_sync_${type.name}';

  // ---------------------------------------------------------------------------
  // Serialisation helpers
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _toJson(PortalCredential credential) {
    return {
      'id': credential.id,
      'portalType': credential.portalType.name,
      if (credential.username != null) 'username': credential.username,
      if (credential.encryptedPassword != null)
        'encryptedPassword': credential.encryptedPassword,
      if (credential.grantToken != null) 'grantToken': credential.grantToken,
      if (credential.refreshToken != null)
        'refreshToken': credential.refreshToken,
      if (credential.expiresAt != null)
        'expiresAt': credential.expiresAt!.toIso8601String(),
      if (credential.lastSyncDate != null)
        'lastSyncDate': credential.lastSyncDate!.toIso8601String(),
      if (credential.status != null) 'status': credential.status,
    };
  }

  static PortalCredential _fromJson(Map<String, dynamic> json) {
    return PortalCredential(
      id: json['id'] as String,
      portalType: PortalType.values.firstWhere(
        (t) => t.name == json['portalType'] as String,
      ),
      username: json['username'] as String?,
      encryptedPassword: json['encryptedPassword'] as String?,
      grantToken: json['grantToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      lastSyncDate: json['lastSyncDate'] != null
          ? DateTime.parse(json['lastSyncDate'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // PortalCredentialRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Future<String> storeCredential(PortalCredential credential) async {
    final key = _credentialKey(credential.portalType);
    final jsonString = jsonEncode(_toJson(credential));
    await _storage.write(key: key, value: jsonString);
    return credential.id;
  }

  @override
  Future<PortalCredential?> getCredential(PortalType portalType) async {
    final key = _credentialKey(portalType);
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return _fromJson(json);
  }

  @override
  Future<bool> updateCredential(PortalCredential credential) async {
    final key = _credentialKey(credential.portalType);
    final existing = await _storage.read(key: key);
    if (existing == null) return false;
    final jsonString = jsonEncode(_toJson(credential));
    await _storage.write(key: key, value: jsonString);
    return true;
  }

  @override
  Future<bool> deleteCredential(PortalType portalType) async {
    final key = _credentialKey(portalType);
    final existing = await _storage.read(key: key);
    if (existing == null) return false;
    await _storage.delete(key: key);
    // Also clean up associated sync status.
    await _storage.delete(key: _syncKey(portalType));
    return true;
  }

  @override
  Future<String?> getSyncStatus(PortalType portalType) async {
    final key = _syncKey(portalType);
    return _storage.read(key: key);
  }

  @override
  Future<bool> updateSyncStatus(PortalType portalType, String status) async {
    // Only allow updating sync status when a credential exists.
    final credKey = _credentialKey(portalType);
    final existing = await _storage.read(key: credKey);
    if (existing == null) return false;
    await _storage.write(key: _syncKey(portalType), value: status);
    return true;
  }
}
