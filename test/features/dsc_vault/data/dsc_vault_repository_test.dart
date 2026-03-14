import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/dsc_vault/data/repositories/mock_dsc_vault_repository.dart';
import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';

void main() {
  late MockDscVaultRepository repo;

  setUp(() {
    repo = MockDscVaultRepository();
  });

  group('MockDscVaultRepository - DscCertificate', () {
    test('getAllCertificates returns non-empty seeded list', () async {
      final certs = await repo.getAllCertificates();
      expect(certs, isNotEmpty);
    });

    test('getCertificatesByClient filters correctly', () async {
      final certs = await repo.getCertificatesByClient('mock-client-001');
      for (final c in certs) {
        expect(c.clientId, 'mock-client-001');
      }
    });

    test('getCertificatesByClient returns empty for unknown client', () async {
      final certs = await repo.getCertificatesByClient('no-such-client');
      expect(certs, isEmpty);
    });

    test('getCertificatesByStatus filters by status', () async {
      final certs = await repo.getCertificatesByStatus(DscStatus.valid);
      for (final c in certs) {
        expect(c.status, DscStatus.valid);
      }
    });

    test('insertCertificate adds entry and returns id', () async {
      final cert = DscCertificate(
        id: 'dsc-new-001',
        clientId: 'mock-client-001',
        clientName: 'Test Client',
        panOrDin: 'ABCDE1234F',
        certHolder: 'Test Holder',
        issuedBy: 'eMudhra',
        expiryDate: DateTime(2027, 12, 31),
        status: DscStatus.valid,
        tokenType: DscTokenType.class3,
        usageCount: 0,
      );
      final id = await repo.insertCertificate(cert);
      expect(id, 'dsc-new-001');

      final all = await repo.getAllCertificates();
      expect(all.any((c) => c.id == 'dsc-new-001'), isTrue);
    });

    test('updateCertificate updates status and returns true', () async {
      final all = await repo.getAllCertificates();
      final first = all.first;
      final updated = first.copyWith(status: DscStatus.revoked);
      final success = await repo.updateCertificate(updated);
      expect(success, isTrue);

      final refetched = await repo.getAllCertificates();
      final found = refetched.firstWhere((c) => c.id == first.id);
      expect(found.status, DscStatus.revoked);
    });

    test('updateCertificate returns false for non-existent id', () async {
      final ghost = DscCertificate(
        id: 'non-existent-dsc',
        clientId: 'c1',
        clientName: 'Ghost',
        panOrDin: 'ZZZZZ9999Z',
        certHolder: 'Nobody',
        issuedBy: 'Unknown',
        expiryDate: DateTime(2020, 1, 1),
        status: DscStatus.expired,
        tokenType: DscTokenType.usbToken,
        usageCount: 0,
      );
      final success = await repo.updateCertificate(ghost);
      expect(success, isFalse);
    });

    test('deleteCertificate removes entry and returns true', () async {
      final all = await repo.getAllCertificates();
      final target = all.first;
      final deleted = await repo.deleteCertificate(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllCertificates();
      expect(remaining.any((c) => c.id == target.id), isFalse);
    });

    test('deleteCertificate returns false for non-existent id', () async {
      final deleted = await repo.deleteCertificate('no-such-id');
      expect(deleted, isFalse);
    });
  });

  group('MockDscVaultRepository - PortalCredential', () {
    test('getAllCredentials returns non-empty seeded list', () async {
      final creds = await repo.getAllCredentials();
      expect(creds, isNotEmpty);
    });

    test('getCredentialsByClient filters correctly', () async {
      final creds = await repo.getCredentialsByClient('mock-client-001');
      for (final c in creds) {
        expect(c.clientId, 'mock-client-001');
      }
    });

    test('getCredentialsByClient returns empty for unknown client', () async {
      final creds = await repo.getCredentialsByClient('no-such-client');
      expect(creds, isEmpty);
    });

    test('insertCredential adds entry and returns id', () async {
      final cred = PortalCredential(
        id: 'cred-new-001',
        clientId: 'mock-client-001',
        clientName: 'Test Client',
        portalName: 'Income Tax Portal',
        userId: 'ABCDE1234F',
        maskedPassword: '••••••ab12',
        lastUpdatedAt: DateTime(2026, 3, 1),
        status: PortalCredStatus.active,
        consentGiven: true,
      );
      final id = await repo.insertCredential(cred);
      expect(id, 'cred-new-001');
    });

    test('updateCredential returns true on success', () async {
      final all = await repo.getAllCredentials();
      final first = all.first;
      final updated = first.copyWith(status: PortalCredStatus.expired);
      final success = await repo.updateCredential(updated);
      expect(success, isTrue);
    });

    test('updateCredential returns false for non-existent id', () async {
      final ghost = PortalCredential(
        id: 'non-existent-cred',
        clientId: 'c1',
        clientName: 'Ghost',
        portalName: 'Unknown',
        userId: 'nobody',
        maskedPassword: '••••',
        lastUpdatedAt: DateTime(2020, 1, 1),
        status: PortalCredStatus.unknown,
        consentGiven: false,
      );
      final success = await repo.updateCredential(ghost);
      expect(success, isFalse);
    });

    test('deleteCredential removes entry and returns true', () async {
      final all = await repo.getAllCredentials();
      final target = all.first;
      final deleted = await repo.deleteCredential(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllCredentials();
      expect(remaining.any((c) => c.id == target.id), isFalse);
    });

    test('deleteCredential returns false for non-existent id', () async {
      final deleted = await repo.deleteCredential('no-such-id');
      expect(deleted, isFalse);
    });
  });
}
