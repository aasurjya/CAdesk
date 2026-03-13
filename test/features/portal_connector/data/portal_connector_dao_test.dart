import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/data/mappers/portal_connector_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  int testCounter = 0;

  setUpAll(() async {
    database = _createTestDatabase();
  });

  tearDownAll(() async {
    await database.close();
  });

  PortalCredential createTestCredential({
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
    testCounter++;
    return PortalCredential(
      id: id ?? 'cred-$testCounter',
      portalType: portalType ?? PortalType.itd,
      username: username ?? 'user$testCounter',
      encryptedPassword: encryptedPassword ?? 'enc-pass-$testCounter',
      grantToken: grantToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      lastSyncDate: lastSyncDate,
      status: status ?? 'active',
    );
  }

  group('PortalConnectorDao', () {
    group('storeCredential', () {
      test('stores credential and returns non-empty id', () async {
        final cred = createTestCredential();
        final companion = PortalConnectorMapper.toCompanion(cred);
        final id = await database.portalConnectorDao.storeCredential(companion);
        expect(id, isNotEmpty);
      });

      test('stored credential has correct portal type', () async {
        final cred = createTestCredential(portalType: PortalType.gstn);
        final companion = PortalConnectorMapper.toCompanion(cred);
        await database.portalConnectorDao.storeCredential(companion);
        final retrieved = await database.portalConnectorDao
            .getCredential(PortalType.gstn.name);
        expect(retrieved?.portalType, PortalType.gstn.name);
      });

      test('stored credential has correct username', () async {
        final cred = createTestCredential(
          portalType: PortalType.traces,
          username: 'traces_user',
        );
        final companion = PortalConnectorMapper.toCompanion(cred);
        await database.portalConnectorDao.storeCredential(companion);
        final retrieved = await database.portalConnectorDao
            .getCredential(PortalType.traces.name);
        expect(retrieved?.username, 'traces_user');
      });

      test('stored credential has correct encrypted password', () async {
        final cred = createTestCredential(
          portalType: PortalType.mca,
          encryptedPassword: 'IV123:ciphertext456',
        );
        final companion = PortalConnectorMapper.toCompanion(cred);
        await database.portalConnectorDao.storeCredential(companion);
        final retrieved = await database.portalConnectorDao
            .getCredential(PortalType.mca.name);
        expect(retrieved?.encryptedPassword, 'IV123:ciphertext456');
      });

      test('stores credential with tokens', () async {
        final cred = createTestCredential(
          portalType: PortalType.epfo,
          grantToken: 'grant-abc',
          refreshToken: 'refresh-xyz',
          expiresAt: DateTime(2026, 12, 31),
        );
        final companion = PortalConnectorMapper.toCompanion(cred);
        await database.portalConnectorDao.storeCredential(companion);
        final retrieved = await database.portalConnectorDao
            .getCredential(PortalType.epfo.name);
        expect(retrieved?.grantToken, 'grant-abc');
        expect(retrieved?.refreshToken, 'refresh-xyz');
        expect(retrieved?.expiresAt, isNotNull);
      });
    });

    group('getCredential', () {
      test('returns null for non-existent portal type', () async {
        // Use a unique portal type not stored in this test group
        final result = await database.portalConnectorDao
            .getCredential('non_existent_portal');
        expect(result, isNull);
      });

      test('returns correct credential for stored portal type', () async {
        final cred = createTestCredential(
          portalType: PortalType.itd,
          username: 'itd_user',
        );
        final companion = PortalConnectorMapper.toCompanion(cred);
        await database.portalConnectorDao.storeCredential(companion);
        final retrieved = await database.portalConnectorDao
            .getCredential(PortalType.itd.name);
        expect(retrieved, isNotNull);
        expect(retrieved?.username, 'itd_user');
      });
    });

    group('updateCredential', () {
      test('updates credential and returns true', () async {
        final cred = createTestCredential(
          portalType: PortalType.gstn,
          username: 'original_user',
        );
        final companion = PortalConnectorMapper.toCompanion(cred);
        await database.portalConnectorDao.storeCredential(companion);

        final updated = cred.copyWith(
          username: 'updated_user',
          status: 'connected',
        );
        final success = await database.portalConnectorDao.updateCredential(
          PortalConnectorMapper.toCompanion(updated),
        );
        expect(success, isTrue);
      });

      test('updated credential reflects new values', () async {
        final cred = createTestCredential(
          portalType: PortalType.traces,
          username: 'old_traces_user',
        );
        await database.portalConnectorDao.storeCredential(
          PortalConnectorMapper.toCompanion(cred),
        );

        final updated = cred.copyWith(username: 'new_traces_user');
        await database.portalConnectorDao.updateCredential(
          PortalConnectorMapper.toCompanion(updated),
        );

        final retrieved = await database.portalConnectorDao
            .getCredential(PortalType.traces.name);
        expect(retrieved?.username, 'new_traces_user');
      });

      test('returns false when updating non-existent credential', () async {
        final cred = createTestCredential(id: 'non-existent-id');
        final success = await database.portalConnectorDao.updateCredential(
          PortalConnectorMapper.toCompanion(cred),
        );
        expect(success, isFalse);
      });
    });

    group('deleteCredential', () {
      test('deletes credential and returns true', () async {
        final cred = createTestCredential(portalType: PortalType.mca);
        await database.portalConnectorDao.storeCredential(
          PortalConnectorMapper.toCompanion(cred),
        );

        final success = await database.portalConnectorDao
            .deleteCredential(PortalType.mca.name);
        expect(success, isTrue);
      });

      test('deleted credential is no longer retrievable', () async {
        final cred = createTestCredential(portalType: PortalType.epfo);
        await database.portalConnectorDao.storeCredential(
          PortalConnectorMapper.toCompanion(cred),
        );

        await database.portalConnectorDao
            .deleteCredential(PortalType.epfo.name);
        final retrieved = await database.portalConnectorDao
            .getCredential(PortalType.epfo.name);
        expect(retrieved, isNull);
      });

      test('returns false when deleting non-existent portal type', () async {
        final success = await database.portalConnectorDao
            .deleteCredential('not_here');
        expect(success, isFalse);
      });
    });

    group('getSyncStatus', () {
      test('returns null for portal with no status set', () async {
        final result = await database.portalConnectorDao
            .getSyncStatus('portal_without_status');
        expect(result, isNull);
      });

      test('returns status string after updateSyncStatus', () async {
        final cred = createTestCredential(
          portalType: PortalType.itd,
          status: 'active',
        );
        await database.portalConnectorDao.storeCredential(
          PortalConnectorMapper.toCompanion(cred),
        );

        await database.portalConnectorDao.updateSyncStatus(
          PortalType.itd.name,
          'syncing',
        );
        final result = await database.portalConnectorDao
            .getSyncStatus(PortalType.itd.name);
        expect(result, 'syncing');
      });
    });

    group('updateSyncStatus', () {
      test('updates sync status and returns true', () async {
        final cred = createTestCredential(
          portalType: PortalType.gstn,
          status: 'active',
        );
        await database.portalConnectorDao.storeCredential(
          PortalConnectorMapper.toCompanion(cred),
        );

        final success = await database.portalConnectorDao.updateSyncStatus(
          PortalType.gstn.name,
          'last_sync_success',
        );
        expect(success, isTrue);
      });

      test('returns false when updating status for non-existent portal', () async {
        final success = await database.portalConnectorDao.updateSyncStatus(
          'non_existent',
          'syncing',
        );
        expect(success, isFalse);
      });
    });

    group('PortalCredential model', () {
      test('copyWith creates new instance without mutation', () {
        const original = PortalCredential(
          id: 'id-1',
          portalType: PortalType.itd,
          username: 'user1',
          status: 'active',
        );
        final updated = original.copyWith(username: 'user2');

        expect(original.username, 'user1');
        expect(updated.username, 'user2');
        expect(updated.id, 'id-1');
        expect(updated.portalType, PortalType.itd);
      });

      test('copyWith preserves nullable fields', () {
        final original = PortalCredential(
          id: 'id-2',
          portalType: PortalType.gstn,
          username: 'gstn_user',
          grantToken: 'token-abc',
          refreshToken: 'refresh-abc',
          expiresAt: DateTime(2026, 6, 1),
          lastSyncDate: DateTime(2026, 3, 10),
          status: 'connected',
        );
        final updated = original.copyWith(status: 'disconnected');

        expect(updated.grantToken, 'token-abc');
        expect(updated.refreshToken, 'refresh-abc');
        expect(updated.expiresAt, DateTime(2026, 6, 1));
        expect(updated.lastSyncDate, DateTime(2026, 3, 10));
      });

      test('equality holds for same values', () {
        const a = PortalCredential(
          id: 'eq-1',
          portalType: PortalType.mca,
          username: 'same',
          status: 'active',
        );
        const b = PortalCredential(
          id: 'eq-1',
          portalType: PortalType.mca,
          username: 'same',
          status: 'active',
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('inequality for different portal types', () {
        const a = PortalCredential(
          id: 'id-x',
          portalType: PortalType.itd,
          username: 'user',
          status: 'active',
        );
        const b = PortalCredential(
          id: 'id-x',
          portalType: PortalType.gstn,
          username: 'user',
          status: 'active',
        );
        expect(a, isNot(equals(b)));
      });

      test('PortalType enum has all 5 required values', () {
        expect(PortalType.values.length, 5);
        expect(PortalType.values, contains(PortalType.itd));
        expect(PortalType.values, contains(PortalType.gstn));
        expect(PortalType.values, contains(PortalType.traces));
        expect(PortalType.values, contains(PortalType.mca));
        expect(PortalType.values, contains(PortalType.epfo));
      });
    });

    group('PortalConnectorMapper', () {
      test('toCompanion round-trips via fromRow', () async {
        final cred = PortalCredential(
          id: 'mapper-test-1',
          portalType: PortalType.itd,
          username: 'mapper_user',
          encryptedPassword: 'IV:cipher',
          grantToken: 'gt',
          refreshToken: 'rt',
          expiresAt: DateTime(2026, 12, 31, 0, 0, 0),
          lastSyncDate: DateTime(2026, 3, 1, 0, 0, 0),
          status: 'active',
        );
        final companion = PortalConnectorMapper.toCompanion(cred);
        await database.portalConnectorDao.storeCredential(companion);

        final row = await database.portalConnectorDao
            .getCredential(PortalType.itd.name);
        expect(row, isNotNull);
        final mapped = PortalConnectorMapper.fromRow(row!);

        expect(mapped.id, cred.id);
        expect(mapped.portalType, cred.portalType);
        expect(mapped.username, cred.username);
        expect(mapped.encryptedPassword, cred.encryptedPassword);
        expect(mapped.grantToken, cred.grantToken);
        expect(mapped.refreshToken, cred.refreshToken);
        expect(mapped.status, cred.status);
      });

      test('fromJson parses JSON correctly', () {
        final json = {
          'id': 'json-1',
          'portal_type': 'gstn',
          'username': 'gstn_json_user',
          'encrypted_password': 'IV:enc',
          'grant_token': null,
          'refresh_token': null,
          'expires_at': null,
          'last_sync_date': null,
          'status': 'connected',
        };
        final cred = PortalConnectorMapper.fromJson(json);
        expect(cred.id, 'json-1');
        expect(cred.portalType, PortalType.gstn);
        expect(cred.username, 'gstn_json_user');
        expect(cred.status, 'connected');
      });

      test('toJson produces correct keys', () {
        const cred = PortalCredential(
          id: 'to-json-1',
          portalType: PortalType.traces,
          username: 'traces_json',
          encryptedPassword: 'IV:enc',
          status: 'active',
        );
        final json = PortalConnectorMapper.toJson(cred);
        expect(json['id'], 'to-json-1');
        expect(json['portal_type'], 'traces');
        expect(json['username'], 'traces_json');
        expect(json['encrypted_password'], 'IV:enc');
        expect(json['status'], 'active');
      });

      test('fromJson handles unknown portal type gracefully', () {
        final json = {
          'id': 'fallback-1',
          'portal_type': 'unknown_portal',
          'username': 'u',
          'encrypted_password': null,
          'grant_token': null,
          'refresh_token': null,
          'expires_at': null,
          'last_sync_date': null,
          'status': 'active',
        };
        final cred = PortalConnectorMapper.fromJson(json);
        expect(cred.portalType, PortalType.itd); // fallback
      });
    });
  });
}
