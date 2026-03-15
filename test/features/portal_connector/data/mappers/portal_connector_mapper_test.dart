import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_connector/data/mappers/portal_connector_mapper.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

void main() {
  group('PortalConnectorMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'cred-001',
          'portal_type': 'itd',
          'username': 'ABCDE1234F',
          'encrypted_password': 'IV:ciphertext_aes_encrypted',
          'grant_token': 'grant_abc123',
          'refresh_token': 'refresh_xyz789',
          'expires_at': '2025-12-31T23:59:59.000Z',
          'last_sync_date': '2025-09-01T10:00:00.000Z',
          'status': 'active',
        };

        final credential = PortalConnectorMapper.fromJson(json);

        expect(credential.id, 'cred-001');
        expect(credential.portalType, PortalType.itd);
        expect(credential.username, 'ABCDE1234F');
        expect(credential.encryptedPassword, 'IV:ciphertext_aes_encrypted');
        expect(credential.grantToken, 'grant_abc123');
        expect(credential.refreshToken, 'refresh_xyz789');
        expect(credential.expiresAt, isNotNull);
        expect(credential.lastSyncDate, isNotNull);
        expect(credential.status, 'active');
      });

      test('handles all null optional fields', () {
        final json = {
          'id': 'cred-002',
          'portal_type': 'gstn',
        };

        final credential = PortalConnectorMapper.fromJson(json);
        expect(credential.username, isNull);
        expect(credential.encryptedPassword, isNull);
        expect(credential.grantToken, isNull);
        expect(credential.refreshToken, isNull);
        expect(credential.expiresAt, isNull);
        expect(credential.lastSyncDate, isNull);
        expect(credential.status, isNull);
        expect(credential.portalType, PortalType.gstn);
      });

      test('defaults portal_type to itd for unknown value', () {
        final json = {
          'id': 'cred-003',
          'portal_type': 'unknownPortal',
        };

        final credential = PortalConnectorMapper.fromJson(json);
        expect(credential.portalType, PortalType.itd);
      });

      test('handles all PortalType values', () {
        for (final portalType in PortalType.values) {
          final json = {
            'id': 'cred-portal-${portalType.name}',
            'portal_type': portalType.name,
          };
          final credential = PortalConnectorMapper.fromJson(json);
          expect(credential.portalType, portalType);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final credential = PortalCredential(
          id: 'cred-json-001',
          portalType: PortalType.traces,
          username: 'TRACES_USER_001',
          encryptedPassword: 'ENC:encrypted_password_value',
          grantToken: null,
          refreshToken: null,
          expiresAt: DateTime.utc(2026, 3, 31),
          lastSyncDate: DateTime.utc(2025, 9, 1),
          status: 'connected',
        );

        final json = PortalConnectorMapper.toJson(credential);

        expect(json['id'], 'cred-json-001');
        expect(json['portal_type'], 'traces');
        expect(json['username'], 'TRACES_USER_001');
        expect(json['encrypted_password'], 'ENC:encrypted_password_value');
        expect(json['grant_token'], isNull);
        expect(json['refresh_token'], isNull);
        expect(json['expires_at'], isNotNull);
        expect(json['status'], 'connected');

        final restored = PortalConnectorMapper.fromJson(json);
        expect(restored.id, credential.id);
        expect(restored.portalType, credential.portalType);
        expect(restored.username, credential.username);
        expect(restored.status, credential.status);
      });

      test('serializes fully null credential correctly', () {
        const credential = PortalCredential(
          id: 'cred-empty',
          portalType: PortalType.epfo,
        );

        final json = PortalConnectorMapper.toJson(credential);
        expect(json['portal_type'], 'epfo');
        expect(json['username'], isNull);
        expect(json['encrypted_password'], isNull);
        expect(json['grant_token'], isNull);
        expect(json['expires_at'], isNull);
        expect(json['status'], isNull);
      });

      test('serializes mca portal type correctly', () {
        const credential = PortalCredential(
          id: 'cred-mca',
          portalType: PortalType.mca,
          username: 'mca_user',
          status: 'active',
        );

        final json = PortalConnectorMapper.toJson(credential);
        expect(json['portal_type'], 'mca');
        expect(json['username'], 'mca_user');
      });
    });
  });
}
