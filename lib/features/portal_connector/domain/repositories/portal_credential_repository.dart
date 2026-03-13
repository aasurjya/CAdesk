import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Abstract contract for credential storage and sync-status management
/// of government portal integrations.
///
/// Concrete implementations (real Drift+Supabase or mock) fulfil these
/// operations. No storage or encryption details leak through this interface.
abstract class PortalCredentialRepository {
  /// Persist [credential] and return its stored ID.
  Future<String> storeCredential(PortalCredential credential);

  /// Retrieve the stored credential for [portalType], or `null` if absent.
  Future<PortalCredential?> getCredential(PortalType portalType);

  /// Replace an existing credential record with [credential].
  /// Returns `true` on success, `false` if the credential was not found.
  Future<bool> updateCredential(PortalCredential credential);

  /// Remove the credential for [portalType].
  /// Returns `true` on success, `false` if not found.
  Future<bool> deleteCredential(PortalType portalType);

  /// Return the latest sync-status string for [portalType], or `null`.
  Future<String?> getSyncStatus(PortalType portalType);

  /// Update the sync-status string for [portalType] to [status].
  /// Returns `true` on success, `false` if the credential was not found.
  Future<bool> updateSyncStatus(PortalType portalType, String status);
}
