import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_connector/data/repositories/secure_credential_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

// ---------------------------------------------------------------------------
// In-memory mock that avoids platform channels.
// ---------------------------------------------------------------------------

class MockSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.unmodifiable(_store);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }

  @override
  // ignore: override_on_non_overriding_member
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PortalCredential _makeCredential({
  String id = 'cred-001',
  PortalType portalType = PortalType.itd,
  String? username = 'ABCDE1234F',
  String? encryptedPassword = 'iv:cipher',
  String? grantToken,
  String? refreshToken,
  DateTime? expiresAt,
  DateTime? lastSyncDate,
  String? status = 'active',
}) {
  return PortalCredential(
    id: id,
    portalType: portalType,
    username: username,
    encryptedPassword: encryptedPassword,
    grantToken: grantToken,
    refreshToken: refreshToken,
    expiresAt: expiresAt,
    lastSyncDate: lastSyncDate,
    status: status,
  );
}

void main() {
  late MockSecureStorage mockStorage;
  late SecureCredentialRepository repository;

  setUp(() {
    mockStorage = MockSecureStorage();
    repository = SecureCredentialRepository(storage: mockStorage);
  });

  // -------------------------------------------------------------------------
  // storeCredential
  // -------------------------------------------------------------------------
  group('storeCredential', () {
    test('stores and returns the credential id', () async {
      final credential = _makeCredential();
      final id = await repository.storeCredential(credential);
      expect(id, credential.id);
    });

    test('stores credential for each portal type', () async {
      for (final type in PortalType.values) {
        final cred = _makeCredential(id: 'id-${type.name}', portalType: type);
        final id = await repository.storeCredential(cred);
        expect(id, cred.id);
      }
    });
  });

  // -------------------------------------------------------------------------
  // getCredential
  // -------------------------------------------------------------------------
  group('getCredential', () {
    test('returns null when no credential stored', () async {
      final result = await repository.getCredential(PortalType.itd);
      expect(result, isNull);
    });

    test('returns stored credential with all fields', () async {
      final expiresAt = DateTime.utc(2026, 12, 31);
      final lastSync = DateTime.utc(2026, 3, 19);
      final credential = _makeCredential(
        grantToken: 'grant-abc',
        refreshToken: 'refresh-xyz',
        expiresAt: expiresAt,
        lastSyncDate: lastSync,
      );

      await repository.storeCredential(credential);
      final retrieved = await repository.getCredential(PortalType.itd);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, credential.id);
      expect(retrieved.portalType, PortalType.itd);
      expect(retrieved.username, 'ABCDE1234F');
      expect(retrieved.encryptedPassword, 'iv:cipher');
      expect(retrieved.grantToken, 'grant-abc');
      expect(retrieved.refreshToken, 'refresh-xyz');
      expect(retrieved.expiresAt, expiresAt);
      expect(retrieved.lastSyncDate, lastSync);
      expect(retrieved.status, 'active');
    });

    test('returns null for a different portal type', () async {
      await repository.storeCredential(_makeCredential());
      final result = await repository.getCredential(PortalType.gstn);
      expect(result, isNull);
    });

    test(
      'retrieves credentials for all 5 portal types independently',
      () async {
        for (final type in PortalType.values) {
          await repository.storeCredential(
            _makeCredential(id: 'id-${type.name}', portalType: type),
          );
        }
        for (final type in PortalType.values) {
          final result = await repository.getCredential(type);
          expect(result, isNotNull);
          expect(result!.id, 'id-${type.name}');
          expect(result.portalType, type);
        }
      },
    );

    test('handles credential with only required fields', () async {
      const minimal = PortalCredential(id: 'min-1', portalType: PortalType.mca);
      await repository.storeCredential(minimal);
      final retrieved = await repository.getCredential(PortalType.mca);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'min-1');
      expect(retrieved.username, isNull);
      expect(retrieved.encryptedPassword, isNull);
      expect(retrieved.grantToken, isNull);
      expect(retrieved.refreshToken, isNull);
      expect(retrieved.expiresAt, isNull);
      expect(retrieved.lastSyncDate, isNull);
      expect(retrieved.status, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // updateCredential
  // -------------------------------------------------------------------------
  group('updateCredential', () {
    test('returns false when credential does not exist', () async {
      final credential = _makeCredential();
      final result = await repository.updateCredential(credential);
      expect(result, isFalse);
    });

    test('updates existing credential and returns true', () async {
      final original = _makeCredential(status: 'active');
      await repository.storeCredential(original);

      final updated = original.copyWith(
        username: 'NEWPAN1234X',
        status: 'connected',
      );
      final result = await repository.updateCredential(updated);
      expect(result, isTrue);

      final retrieved = await repository.getCredential(PortalType.itd);
      expect(retrieved!.username, 'NEWPAN1234X');
      expect(retrieved.status, 'connected');
    });
  });

  // -------------------------------------------------------------------------
  // deleteCredential
  // -------------------------------------------------------------------------
  group('deleteCredential', () {
    test('returns false when credential does not exist', () async {
      final result = await repository.deleteCredential(PortalType.traces);
      expect(result, isFalse);
    });

    test('deletes existing credential and returns true', () async {
      await repository.storeCredential(
        _makeCredential(portalType: PortalType.traces),
      );
      final result = await repository.deleteCredential(PortalType.traces);
      expect(result, isTrue);

      final retrieved = await repository.getCredential(PortalType.traces);
      expect(retrieved, isNull);
    });

    test('also removes associated sync status', () async {
      await repository.storeCredential(
        _makeCredential(portalType: PortalType.epfo),
      );
      await repository.updateSyncStatus(PortalType.epfo, 'synced');
      expect(await repository.getSyncStatus(PortalType.epfo), 'synced');

      await repository.deleteCredential(PortalType.epfo);
      expect(await repository.getSyncStatus(PortalType.epfo), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // getSyncStatus
  // -------------------------------------------------------------------------
  group('getSyncStatus', () {
    test('returns null when no status stored', () async {
      final result = await repository.getSyncStatus(PortalType.gstn);
      expect(result, isNull);
    });

    test('returns the stored status string', () async {
      await repository.storeCredential(
        _makeCredential(portalType: PortalType.gstn),
      );
      await repository.updateSyncStatus(PortalType.gstn, 'syncing');
      final result = await repository.getSyncStatus(PortalType.gstn);
      expect(result, 'syncing');
    });
  });

  // -------------------------------------------------------------------------
  // updateSyncStatus
  // -------------------------------------------------------------------------
  group('updateSyncStatus', () {
    test('returns false when credential does not exist', () async {
      final result = await repository.updateSyncStatus(
        PortalType.mca,
        'synced',
      );
      expect(result, isFalse);
    });

    test('updates sync status and returns true', () async {
      await repository.storeCredential(
        _makeCredential(portalType: PortalType.mca),
      );
      final result = await repository.updateSyncStatus(PortalType.mca, 'error');
      expect(result, isTrue);

      final status = await repository.getSyncStatus(PortalType.mca);
      expect(status, 'error');
    });

    test('overwrites previous sync status', () async {
      await repository.storeCredential(
        _makeCredential(portalType: PortalType.itd),
      );
      await repository.updateSyncStatus(PortalType.itd, 'syncing');
      await repository.updateSyncStatus(PortalType.itd, 'synced');
      final status = await repository.getSyncStatus(PortalType.itd);
      expect(status, 'synced');
    });
  });
}
