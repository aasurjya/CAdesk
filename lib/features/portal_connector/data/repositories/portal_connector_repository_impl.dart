import 'package:ca_app/features/portal_connector/data/datasources/portal_connector_local_source.dart';
import 'package:ca_app/features/portal_connector/data/datasources/portal_connector_remote_source.dart';
import 'package:ca_app/features/portal_connector/data/mappers/portal_connector_mapper.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

/// Real implementation of [PortalCredentialRepository].
///
/// Write-through strategy:
/// - Writes go to remote first, then cache locally on success.
/// - Reads prefer remote; fall back to local cache on network failure.
///
/// Passwords are never stored in plaintext — [PortalConnectorLocalSource]
/// encrypts before write and the remote always receives encrypted values.
class PortalConnectorRepositoryImpl implements PortalCredentialRepository {
  const PortalConnectorRepositoryImpl({
    required this.local,
    required this.remote,
  });

  final PortalConnectorLocalSource local;
  final PortalConnectorRemoteSource remote;

  @override
  Future<String> storeCredential(PortalCredential credential) async {
    try {
      final json = PortalConnectorMapper.toJson(credential);
      final inserted = await remote.insert(json);
      final fromRemote = PortalConnectorMapper.fromJson(inserted);
      await local.storeCredential(fromRemote);
      return fromRemote.id;
    } catch (_) {
      // Fallback: persist locally only (sync later)
      return local.storeCredential(credential);
    }
  }

  @override
  Future<PortalCredential?> getCredential(PortalType portalType) async {
    try {
      final json = await remote.fetchByPortalType(portalType.name);
      if (json == null) return null;
      final cred = PortalConnectorMapper.fromJson(json);
      await local.storeCredential(cred);
      return cred;
    } catch (_) {
      return local.getCredential(portalType);
    }
  }

  @override
  Future<bool> updateCredential(PortalCredential credential) async {
    try {
      final json = PortalConnectorMapper.toJson(credential);
      await remote.update(credential.id, json);
      await local.updateCredential(credential);
      return true;
    } catch (_) {
      return local.updateCredential(credential);
    }
  }

  @override
  Future<bool> deleteCredential(PortalType portalType) async {
    try {
      await remote.deleteByPortalType(portalType.name);
      return local.deleteCredential(portalType);
    } catch (_) {
      return local.deleteCredential(portalType);
    }
  }

  @override
  Future<String?> getSyncStatus(PortalType portalType) async {
    try {
      final json = await remote.fetchByPortalType(portalType.name);
      if (json == null) return null;
      return json['status'] as String?;
    } catch (_) {
      return local.getSyncStatus(portalType);
    }
  }

  @override
  Future<bool> updateSyncStatus(PortalType portalType, String status) async {
    try {
      await remote.updateStatus(portalType.name, status);
      return local.updateSyncStatus(portalType, status);
    } catch (_) {
      return local.updateSyncStatus(portalType, status);
    }
  }
}
