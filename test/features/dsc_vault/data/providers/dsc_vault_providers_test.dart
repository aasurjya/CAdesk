import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/dsc_vault/data/providers/dsc_vault_providers.dart';
import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';

void main() {
  group('DSC Vault Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // allDscCertificatesProvider
    // -------------------------------------------------------------------------
    group('allDscCertificatesProvider', () {
      test('initial state is non-empty list', () {
        final certs = container.read(allDscCertificatesProvider);
        expect(certs, isNotEmpty);
        expect(certs.length, greaterThanOrEqualTo(5));
      });

      test('all items are DscCertificate objects', () {
        final certs = container.read(allDscCertificatesProvider);
        expect(certs, everyElement(isA<DscCertificate>()));
      });

      test('list is unmodifiable', () {
        final certs = container.read(allDscCertificatesProvider);
        expect(() => certs.add(certs.first), throwsA(anything));
      });

      test('certificates span multiple statuses', () {
        final certs = container.read(allDscCertificatesProvider);
        final statuses = certs.map((c) => c.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(3));
      });

      test(
        'initial list contains valid, expiringSoon, expired and revoked',
        () {
          final certs = container.read(allDscCertificatesProvider);
          expect(certs.any((c) => c.status == DscStatus.valid), isTrue);
          expect(certs.any((c) => c.status == DscStatus.expiringSoon), isTrue);
          expect(certs.any((c) => c.status == DscStatus.expired), isTrue);
          expect(certs.any((c) => c.status == DscStatus.revoked), isTrue);
        },
      );

      test('all certificates have non-empty id and clientId', () {
        final certs = container.read(allDscCertificatesProvider);
        for (final cert in certs) {
          expect(cert.id, isNotEmpty);
          expect(cert.clientId, isNotEmpty);
        }
      });

      test('updateCertificate() replaces matching cert immutably', () {
        final original = container.read(allDscCertificatesProvider).first;
        final updated = original.copyWith(status: DscStatus.revoked);
        container
            .read(allDscCertificatesProvider.notifier)
            .updateCertificate(updated);
        final result = container.read(allDscCertificatesProvider);
        final found = result.firstWhere((c) => c.id == original.id);
        expect(found.status, DscStatus.revoked);
      });

      test('updateCertificate() preserves all other certs', () {
        final certs = container.read(allDscCertificatesProvider);
        final countBefore = certs.length;
        final updated = certs.first.copyWith(usageCount: 999);
        container
            .read(allDscCertificatesProvider.notifier)
            .updateCertificate(updated);
        final after = container.read(allDscCertificatesProvider);
        expect(after.length, countBefore);
      });

      test('updateCertificate() for non-existent id leaves list unchanged', () {
        final before = container.read(allDscCertificatesProvider);
        final ghost = DscCertificate(
          id: 'nonexistent',
          clientId: 'c-x',
          clientName: 'Ghost',
          panOrDin: 'AAAAX9999Z',
          certHolder: 'Ghost Holder',
          issuedBy: 'Test CA',
          expiryDate: DateTime(2027, 1, 1),
          status: DscStatus.valid,
          tokenType: DscTokenType.class3,
          usageCount: 0,
        );

        container
            .read(allDscCertificatesProvider.notifier)
            .updateCertificate(ghost);
        final after = container.read(allDscCertificatesProvider);
        expect(after.length, before.length);
        expect(after.any((c) => c.id == 'nonexistent'), isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // allPortalCredentialsProvider
    // -------------------------------------------------------------------------
    group('allPortalCredentialsProvider', () {
      test('initial state is non-empty list', () {
        final creds = container.read(allPortalCredentialsProvider);
        expect(creds, isNotEmpty);
        expect(creds.length, greaterThanOrEqualTo(4));
      });

      test('all items are PortalCredential objects', () {
        final creds = container.read(allPortalCredentialsProvider);
        expect(creds, everyElement(isA<PortalCredential>()));
      });

      test('list is unmodifiable', () {
        final creds = container.read(allPortalCredentialsProvider);
        expect(() => creds.add(creds.first), throwsA(anything));
      });

      test('initial list contains active and non-active credentials', () {
        final creds = container.read(allPortalCredentialsProvider);
        expect(creds.any((c) => c.status == PortalCredStatus.active), isTrue);
        expect(
          creds.any(
            (c) =>
                c.status == PortalCredStatus.expired ||
                c.status == PortalCredStatus.locked,
          ),
          isTrue,
        );
      });

      test('updateCredential() replaces matching credential immutably', () {
        final original = container.read(allPortalCredentialsProvider).first;
        final updated = original.copyWith(status: PortalCredStatus.locked);
        container
            .read(allPortalCredentialsProvider.notifier)
            .updateCredential(updated);
        final result = container.read(allPortalCredentialsProvider);
        final found = result.firstWhere((c) => c.id == original.id);
        expect(found.status, PortalCredStatus.locked);
      });

      test('updateCredential() preserves count', () {
        final before = container.read(allPortalCredentialsProvider).length;
        final first = container.read(allPortalCredentialsProvider).first;
        container
            .read(allPortalCredentialsProvider.notifier)
            .updateCredential(first.copyWith(maskedPassword: '••••••XXXX'));
        final after = container.read(allPortalCredentialsProvider);
        expect(after.length, before);
      });
    });

    // -------------------------------------------------------------------------
    // dscStatusFilterProvider
    // -------------------------------------------------------------------------
    group('dscStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(dscStatusFilterProvider), isNull);
      });

      test('can be set to valid', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.valid);
        expect(container.read(dscStatusFilterProvider), DscStatus.valid);
      });

      test('can be set to expiringSoon', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.expiringSoon);
        expect(container.read(dscStatusFilterProvider), DscStatus.expiringSoon);
      });

      test('can be cleared to null', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.expired);
        container.read(dscStatusFilterProvider.notifier).update(null);
        expect(container.read(dscStatusFilterProvider), isNull);
      });

      test('supports all DscStatus values', () {
        for (final status in DscStatus.values) {
          container.read(dscStatusFilterProvider.notifier).update(status);
          expect(container.read(dscStatusFilterProvider), status);
        }
      });
    });

    // -------------------------------------------------------------------------
    // filteredDscProvider
    // -------------------------------------------------------------------------
    group('filteredDscProvider', () {
      test('returns all certs when filter is null', () {
        final all = container.read(allDscCertificatesProvider);
        final filtered = container.read(filteredDscProvider);
        expect(filtered.length, all.length);
      });

      test('filters to valid only', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.valid);
        final filtered = container.read(filteredDscProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((c) => c.status == DscStatus.valid), isTrue);
      });

      test('filters to expiringSoon only', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.expiringSoon);
        final filtered = container.read(filteredDscProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((c) => c.status == DscStatus.expiringSoon),
          isTrue,
        );
      });

      test('filters to expired only', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.expired);
        final filtered = container.read(filteredDscProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((c) => c.status == DscStatus.expired), isTrue);
      });

      test('filters to revoked only', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.revoked);
        final filtered = container.read(filteredDscProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((c) => c.status == DscStatus.revoked), isTrue);
      });

      test('clearing filter returns all certs', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.valid);
        container.read(dscStatusFilterProvider.notifier).update(null);
        final all = container.read(allDscCertificatesProvider);
        final filtered = container.read(filteredDscProvider);
        expect(filtered.length, all.length);
      });

      test('filtered count is subset of total', () {
        container
            .read(dscStatusFilterProvider.notifier)
            .update(DscStatus.expiringSoon);
        final all = container.read(allDscCertificatesProvider);
        final filtered = container.read(filteredDscProvider);
        expect(filtered.length, lessThanOrEqualTo(all.length));
      });
    });

    // -------------------------------------------------------------------------
    // dscVaultSummaryProvider
    // -------------------------------------------------------------------------
    group('dscVaultSummaryProvider', () {
      test('returns a DscVaultSummary', () {
        final summary = container.read(dscVaultSummaryProvider);
        expect(summary, isA<DscVaultSummary>());
      });

      test('totalDsc matches total certificates count', () {
        final certs = container.read(allDscCertificatesProvider);
        final summary = container.read(dscVaultSummaryProvider);
        expect(summary.totalDsc, certs.length);
      });

      test('expiringSoon matches expiringSoon certs count', () {
        final certs = container.read(allDscCertificatesProvider);
        final expected = certs
            .where((c) => c.status == DscStatus.expiringSoon)
            .length;
        final summary = container.read(dscVaultSummaryProvider);
        expect(summary.expiringSoon, expected);
      });

      test('expired matches expired certs count', () {
        final certs = container.read(allDscCertificatesProvider);
        final expected = certs
            .where((c) => c.status == DscStatus.expired)
            .length;
        final summary = container.read(dscVaultSummaryProvider);
        expect(summary.expired, expected);
      });

      test('activePortals matches active credentials count', () {
        final creds = container.read(allPortalCredentialsProvider);
        final expected = creds
            .where((c) => c.status == PortalCredStatus.active)
            .length;
        final summary = container.read(dscVaultSummaryProvider);
        expect(summary.activePortals, expected);
      });

      test('totalDsc is positive', () {
        final summary = container.read(dscVaultSummaryProvider);
        expect(summary.totalDsc, greaterThan(0));
      });

      test('summary updates after cert status change', () {
        final certs = container.read(allDscCertificatesProvider);
        final validCert = certs.firstWhere((c) => c.status == DscStatus.valid);
        final summaryBefore = container.read(dscVaultSummaryProvider);

        // Change a valid cert to expired — expired count should increase
        container
            .read(allDscCertificatesProvider.notifier)
            .updateCertificate(validCert.copyWith(status: DscStatus.expired));
        final summaryAfter = container.read(dscVaultSummaryProvider);
        expect(summaryAfter.expired, summaryBefore.expired + 1);
      });
    });

    // -------------------------------------------------------------------------
    // DscCertificate computed properties
    // -------------------------------------------------------------------------
    group('DscCertificate computed properties', () {
      test('isExpired returns true for past expiry date', () {
        final cert = DscCertificate(
          id: 'test',
          clientId: 'c',
          clientName: 'Test',
          panOrDin: 'AAAAX1234Y',
          certHolder: 'Test Holder',
          issuedBy: 'eMudhra',
          expiryDate: DateTime(2020, 1, 1),
          status: DscStatus.expired,
          tokenType: DscTokenType.class3,
          usageCount: 0,
        );
        expect(cert.isExpired, isTrue);
      });

      test('isExpired returns false for future expiry date', () {
        final cert = DscCertificate(
          id: 'test',
          clientId: 'c',
          clientName: 'Test',
          panOrDin: 'AAAAX1234Y',
          certHolder: 'Test Holder',
          issuedBy: 'eMudhra',
          expiryDate: DateTime.now().add(const Duration(days: 365)),
          status: DscStatus.valid,
          tokenType: DscTokenType.class3,
          usageCount: 0,
        );
        expect(cert.isExpired, isFalse);
      });

      test('daysToExpiry is negative for expired cert', () {
        final cert = DscCertificate(
          id: 'test',
          clientId: 'c',
          clientName: 'Test',
          panOrDin: 'AAAAX1234Y',
          certHolder: 'Test Holder',
          issuedBy: 'eMudhra',
          expiryDate: DateTime(2020, 1, 1),
          status: DscStatus.expired,
          tokenType: DscTokenType.class3,
          usageCount: 0,
        );
        expect(cert.daysToExpiry, isNegative);
      });
    });

    // -------------------------------------------------------------------------
    // PortalCredential computed properties
    // -------------------------------------------------------------------------
    group('PortalCredential computed properties', () {
      test('maskedUserId masks all but last 4 chars', () {
        final cred = PortalCredential(
          id: 'c1',
          clientId: 'cl',
          clientName: 'Test',
          portalName: 'IT Portal',
          userId: 'ABCDE1234F',
          maskedPassword: '••••••1234',
          lastUpdatedAt: DateTime(2026, 1, 1),
          status: PortalCredStatus.active,
          consentGiven: true,
        );
        expect(cred.maskedUserId, '******234F');
      });

      test('maskedUserId returns userId as-is when <= 4 chars', () {
        final cred = PortalCredential(
          id: 'c2',
          clientId: 'cl',
          clientName: 'Test',
          portalName: 'IT Portal',
          userId: 'AB',
          maskedPassword: '••••1234',
          lastUpdatedAt: DateTime(2026, 1, 1),
          status: PortalCredStatus.active,
          consentGiven: true,
        );
        expect(cred.maskedUserId, 'AB');
      });

      test('isConsentActive is false when consentGiven is false', () {
        final cred = PortalCredential(
          id: 'c3',
          clientId: 'cl',
          clientName: 'Test',
          portalName: 'IT Portal',
          userId: 'USER001',
          maskedPassword: '••••1234',
          lastUpdatedAt: DateTime(2026, 1, 1),
          status: PortalCredStatus.active,
          consentGiven: false,
        );
        expect(cred.isConsentActive, isFalse);
      });

      test('isConsentActive is true when consentGiven and no expiry', () {
        final cred = PortalCredential(
          id: 'c4',
          clientId: 'cl',
          clientName: 'Test',
          portalName: 'IT Portal',
          userId: 'USER001',
          maskedPassword: '••••1234',
          lastUpdatedAt: DateTime(2026, 1, 1),
          status: PortalCredStatus.active,
          consentGiven: true,
        );
        expect(cred.isConsentActive, isTrue);
      });

      test('isConsentActive is false when consentExpiresAt is in the past', () {
        final cred = PortalCredential(
          id: 'c5',
          clientId: 'cl',
          clientName: 'Test',
          portalName: 'IT Portal',
          userId: 'USER001',
          maskedPassword: '••••1234',
          lastUpdatedAt: DateTime(2026, 1, 1),
          status: PortalCredStatus.active,
          consentGiven: true,
          consentExpiresAt: DateTime(2020, 1, 1),
        );
        expect(cred.isConsentActive, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // DscStatus enum labels
    // -------------------------------------------------------------------------
    group('DscStatus enum', () {
      test('all statuses have non-empty labels', () {
        for (final status in DscStatus.values) {
          expect(status.label, isNotEmpty);
        }
      });
    });

    // -------------------------------------------------------------------------
    // DscTokenType enum labels
    // -------------------------------------------------------------------------
    group('DscTokenType enum', () {
      test('all token types have non-empty labels', () {
        for (final type in DscTokenType.values) {
          expect(type.label, isNotEmpty);
        }
      });
    });
  });
}
