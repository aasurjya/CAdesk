import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/dsc_vault/data/mappers/dsc_vault_mapper.dart';
import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';

void main() {
  group('DscVaultMapper', () {
    // -------------------------------------------------------------------------
    // DscCertificate: certFromJson / certToJson
    // -------------------------------------------------------------------------
    group('DscCertificate', () {
      group('certFromJson', () {
        test('maps all core fields from JSON', () {
          final json = {
            'id': 'dsc-001',
            'client_id': 'client-001',
            'client_name': 'Rajesh Kumar',
            'pan_or_din': 'ABCRS1234A',
            'cert_holder': 'RAJESH KUMAR',
            'issued_by': 'eMudhra',
            'expiry_date': '2027-04-01T00:00:00.000Z',
            'status': 'valid',
            'token_type': 'class3',
            'usage_count': 12,
            'last_used_at': '2026-03-10T00:00:00.000Z',
          };

          final cert = DscVaultMapper.certFromJson(json);

          expect(cert.id, 'dsc-001');
          expect(cert.clientId, 'client-001');
          expect(cert.clientName, 'Rajesh Kumar');
          expect(cert.panOrDin, 'ABCRS1234A');
          expect(cert.certHolder, 'RAJESH KUMAR');
          expect(cert.issuedBy, 'eMudhra');
          expect(cert.status, DscStatus.valid);
          expect(cert.tokenType, DscTokenType.class3);
          expect(cert.usageCount, 12);
          expect(cert.lastUsedAt, isNotNull);
        });

        test('handles null last_used_at', () {
          final json = {
            'id': 'dsc-002',
            'client_id': 'client-002',
            'client_name': 'Priya Nair',
            'pan_or_din': 'CNPPN5678P',
            'cert_holder': 'PRIYA NAIR',
            'issued_by': 'Sify',
            'expiry_date': '2026-08-15T00:00:00.000Z',
            'status': 'expiringSoon',
            'token_type': 'usbToken',
            'usage_count': 0,
            'last_used_at': null,
          };

          final cert = DscVaultMapper.certFromJson(json);
          expect(cert.lastUsedAt, isNull);
          expect(cert.usageCount, 0);
        });

        test('defaults status to valid for unknown value', () {
          final json = {
            'id': 'dsc-003',
            'client_id': 'c1',
            'client_name': 'Test',
            'pan_or_din': 'XXXXX1234X',
            'cert_holder': 'TEST',
            'issued_by': 'NSDL',
            'expiry_date': '2027-01-01T00:00:00.000Z',
            'status': 'unknownStatus',
            'token_type': 'class3',
            'usage_count': 0,
          };

          final cert = DscVaultMapper.certFromJson(json);
          expect(cert.status, DscStatus.valid);
        });

        test('defaults token_type to class3 for unknown value', () {
          final json = {
            'id': 'dsc-004',
            'client_id': 'c1',
            'client_name': 'Test',
            'pan_or_din': 'XXXXX1234X',
            'cert_holder': 'TEST',
            'issued_by': 'eMudhra',
            'expiry_date': '2027-01-01T00:00:00.000Z',
            'status': 'valid',
            'token_type': 'unknownType',
            'usage_count': 0,
          };

          final cert = DscVaultMapper.certFromJson(json);
          expect(cert.tokenType, DscTokenType.class3);
        });

        test('handles all DscStatus values', () {
          for (final status in DscStatus.values) {
            final json = {
              'id': 'dsc-status-${status.name}',
              'client_id': 'c1',
              'client_name': 'Test',
              'pan_or_din': 'XXXXX1234X',
              'cert_holder': 'TEST',
              'issued_by': 'eMudhra',
              'expiry_date': '2027-01-01T00:00:00.000Z',
              'status': status.name,
              'token_type': 'class3',
              'usage_count': 0,
            };
            final cert = DscVaultMapper.certFromJson(json);
            expect(cert.status, status);
          }
        });

        test('handles all DscTokenType values', () {
          for (final tokenType in DscTokenType.values) {
            final json = {
              'id': 'dsc-token-${tokenType.name}',
              'client_id': 'c1',
              'client_name': 'Test',
              'pan_or_din': 'XXXXX1234X',
              'cert_holder': 'TEST',
              'issued_by': 'eMudhra',
              'expiry_date': '2027-01-01T00:00:00.000Z',
              'status': 'valid',
              'token_type': tokenType.name,
              'usage_count': 0,
            };
            final cert = DscVaultMapper.certFromJson(json);
            expect(cert.tokenType, tokenType);
          }
        });
      });

      group('certToJson', () {
        late DscCertificate sampleCert;

        setUp(() {
          sampleCert = DscCertificate(
            id: 'dsc-json-001',
            clientId: 'client-json-001',
            clientName: 'Mehta & Sons',
            panOrDin: 'AABFM3456H',
            certHolder: 'MEHTA & SONS',
            issuedBy: 'eMudhra',
            expiryDate: DateTime(2027, 6, 30),
            status: DscStatus.valid,
            tokenType: DscTokenType.cloudDsc,
            usageCount: 5,
            lastUsedAt: DateTime(2026, 3, 1),
          );
        });

        test('includes all fields', () {
          final json = DscVaultMapper.certToJson(sampleCert);

          expect(json['id'], 'dsc-json-001');
          expect(json['client_id'], 'client-json-001');
          expect(json['client_name'], 'Mehta & Sons');
          expect(json['pan_or_din'], 'AABFM3456H');
          expect(json['cert_holder'], 'MEHTA & SONS');
          expect(json['issued_by'], 'eMudhra');
          expect(json['status'], 'valid');
          expect(json['token_type'], 'cloudDsc');
          expect(json['usage_count'], 5);
        });

        test('serializes expiry_date and last_used_at as ISO strings', () {
          final json = DscVaultMapper.certToJson(sampleCert);
          expect(json['expiry_date'], startsWith('2027-06-30'));
          expect(json['last_used_at'], startsWith('2026-03-01'));
        });

        test('serializes null last_used_at as null', () {
          // Create directly without lastUsedAt
          final cert = DscCertificate(
            id: 'dsc-nolast',
            clientId: 'c1',
            clientName: 'Test',
            panOrDin: 'XXXXX1234X',
            certHolder: 'TEST',
            issuedBy: 'eMudhra',
            expiryDate: DateTime(2027),
            status: DscStatus.valid,
            tokenType: DscTokenType.class3,
            usageCount: 0,
          );
          final json = DscVaultMapper.certToJson(cert);
          expect(json['last_used_at'], isNull);
        });

        test('round-trip certFromJson(certToJson) preserves all fields', () {
          final json = DscVaultMapper.certToJson(sampleCert);
          final restored = DscVaultMapper.certFromJson(json);

          expect(restored.id, sampleCert.id);
          expect(restored.clientId, sampleCert.clientId);
          expect(restored.panOrDin, sampleCert.panOrDin);
          expect(restored.certHolder, sampleCert.certHolder);
          expect(restored.issuedBy, sampleCert.issuedBy);
          expect(restored.status, sampleCert.status);
          expect(restored.tokenType, sampleCert.tokenType);
          expect(restored.usageCount, sampleCert.usageCount);
        });
      });
    });

    // -------------------------------------------------------------------------
    // PortalCredential: credFromJson / credToJson
    // -------------------------------------------------------------------------
    group('PortalCredential', () {
      group('credFromJson', () {
        test('maps all core fields from JSON', () {
          final json = {
            'id': 'cred-001',
            'client_id': 'client-001',
            'client_name': 'Rajesh Kumar',
            'portal_name': 'Income Tax Portal',
            'user_id': 'ABCRS1234A',
            'masked_password': '••••••ab12',
            'last_updated_at': '2026-01-01T00:00:00.000Z',
            'status': 'active',
            'consent_given': true,
            'consent_expires_at': '2027-01-01T00:00:00.000Z',
          };

          final cred = DscVaultMapper.credFromJson(json);

          expect(cred.id, 'cred-001');
          expect(cred.clientId, 'client-001');
          expect(cred.clientName, 'Rajesh Kumar');
          expect(cred.portalName, 'Income Tax Portal');
          expect(cred.userId, 'ABCRS1234A');
          expect(cred.maskedPassword, '••••••ab12');
          expect(cred.status, PortalCredStatus.active);
          expect(cred.consentGiven, isTrue);
          expect(cred.consentExpiresAt, isNotNull);
        });

        test('handles null consent_expires_at', () {
          final json = {
            'id': 'cred-002',
            'client_id': 'client-002',
            'client_name': 'Priya Nair',
            'portal_name': 'GST Portal',
            'user_id': '27CNPPN5678P1Z5',
            'masked_password': '••••••cd34',
            'last_updated_at': '2026-02-01T00:00:00.000Z',
            'status': 'active',
            'consent_given': true,
            'consent_expires_at': null,
          };

          final cred = DscVaultMapper.credFromJson(json);
          expect(cred.consentExpiresAt, isNull);
        });

        test('defaults consent_given to false when absent', () {
          final json = {
            'id': 'cred-003',
            'client_id': 'c1',
            'client_name': 'Test',
            'portal_name': 'MCA Portal',
            'user_id': 'user123',
            'masked_password': '••••1234',
            'last_updated_at': '2026-01-01T00:00:00.000Z',
            'status': 'unknown',
          };

          final cred = DscVaultMapper.credFromJson(json);
          expect(cred.consentGiven, isFalse);
        });

        test('defaults status to unknown for unknown value', () {
          final json = {
            'id': 'cred-004',
            'client_id': 'c1',
            'client_name': 'Test',
            'portal_name': 'Test Portal',
            'user_id': 'user123',
            'masked_password': '••••1234',
            'last_updated_at': '2026-01-01T00:00:00.000Z',
            'status': 'unknownStatus',
            'consent_given': false,
          };

          final cred = DscVaultMapper.credFromJson(json);
          expect(cred.status, PortalCredStatus.unknown);
        });
      });

      group('credToJson', () {
        late PortalCredential sampleCred;

        setUp(() {
          sampleCred = PortalCredential(
            id: 'cred-json-001',
            clientId: 'client-json-001',
            clientName: 'Mehta & Sons',
            portalName: 'TRACES Portal',
            userId: 'AABFM3456H',
            maskedPassword: '••••••ef56',
            lastUpdatedAt: DateTime(2026, 3, 1),
            status: PortalCredStatus.active,
            consentGiven: true,
            consentExpiresAt: DateTime(2027, 3, 1),
          );
        });

        test('includes all fields', () {
          final json = DscVaultMapper.credToJson(sampleCred);

          expect(json['id'], 'cred-json-001');
          expect(json['client_id'], 'client-json-001');
          expect(json['client_name'], 'Mehta & Sons');
          expect(json['portal_name'], 'TRACES Portal');
          expect(json['user_id'], 'AABFM3456H');
          expect(json['masked_password'], '••••••ef56');
          expect(json['status'], 'active');
          expect(json['consent_given'], isTrue);
        });

        test('serializes dates as ISO strings', () {
          final json = DscVaultMapper.credToJson(sampleCred);
          expect(json['last_updated_at'], startsWith('2026-03-01'));
          expect(json['consent_expires_at'], startsWith('2027-03-01'));
        });

        test('serializes null consent_expires_at as null', () {
          final credNoExpiry = PortalCredential(
            id: 'cred-noexpiry',
            clientId: 'c1',
            clientName: 'Test',
            portalName: 'Test Portal',
            userId: 'user123',
            maskedPassword: '••••1234',
            lastUpdatedAt: DateTime(2026, 1, 1),
            status: PortalCredStatus.active,
            consentGiven: true,
          );
          final json = DscVaultMapper.credToJson(credNoExpiry);
          expect(json['consent_expires_at'], isNull);
        });

        test('round-trip credFromJson(credToJson) preserves all fields', () {
          final json = DscVaultMapper.credToJson(sampleCred);
          final restored = DscVaultMapper.credFromJson(json);

          expect(restored.id, sampleCred.id);
          expect(restored.clientId, sampleCred.clientId);
          expect(restored.portalName, sampleCred.portalName);
          expect(restored.userId, sampleCred.userId);
          expect(restored.maskedPassword, sampleCred.maskedPassword);
          expect(restored.status, sampleCred.status);
          expect(restored.consentGiven, sampleCred.consentGiven);
        });
      });
    });
  });
}
