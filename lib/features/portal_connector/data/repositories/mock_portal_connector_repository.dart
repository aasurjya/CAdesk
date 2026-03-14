import 'package:uuid/uuid.dart';

import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

/// In-memory mock implementation of [PortalCredentialRepository].
///
/// Returns realistic stub data without hitting any database or network.
/// Intended for development, testing, and UI prototyping.
class MockPortalCredentialRepository implements PortalCredentialRepository {
  MockPortalCredentialRepository() {
    // Seed with one connected portal for each type to illustrate real state.
    for (final type in PortalType.values) {
      final id = const Uuid().v4();
      _store[type] = PortalCredential(
        id: id,
        portalType: type,
        username: '${type.name}_user@example.com',
        encryptedPassword: 'MOCK_IV:MOCK_CIPHER',
        status: type == PortalType.itd || type == PortalType.gstn
            ? 'connected'
            : 'disconnected',
        lastSyncDate: type == PortalType.itd ? DateTime(2026, 3, 10) : null,
      );
    }
  }

  final Map<PortalType, PortalCredential> _store = {};
  final _syncStatuses = <PortalType, String>{};

  @override
  Future<String> storeCredential(PortalCredential credential) async {
    final stored = _store.containsKey(credential.portalType)
        ? credential
        : credential;
    _store[credential.portalType] = stored;
    return stored.id;
  }

  @override
  Future<PortalCredential?> getCredential(PortalType portalType) async =>
      _store[portalType];

  @override
  Future<bool> updateCredential(PortalCredential credential) async {
    if (!_store.containsKey(credential.portalType)) return false;
    _store[credential.portalType] = credential;
    return true;
  }

  @override
  Future<bool> deleteCredential(PortalType portalType) async {
    if (!_store.containsKey(portalType)) return false;
    _store.remove(portalType);
    return true;
  }

  @override
  Future<String?> getSyncStatus(PortalType portalType) async {
    // Return explicit sync status if set, otherwise fall back to credential status.
    if (_syncStatuses.containsKey(portalType)) {
      return _syncStatuses[portalType];
    }
    return _store[portalType]?.status;
  }

  @override
  Future<bool> updateSyncStatus(PortalType portalType, String status) async {
    if (!_store.containsKey(portalType)) return false;
    _syncStatuses[portalType] = status;
    _store[portalType] = _store[portalType]!.copyWith(status: status);
    return true;
  }
}
