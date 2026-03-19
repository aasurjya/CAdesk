import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/domain/services/document_sharing_service.dart';

void main() {
  group('DocumentSharingService', () {
    // Use the singleton but test each behaviour independently.
    // Since the singleton accumulates state we use unique IDs per test.
    final service = DocumentSharingService.instance;

    // -------------------------------------------------------------------------
    // createShareLink
    // -------------------------------------------------------------------------

    group('createShareLink', () {
      test('returns a SharedDocumentLink with the given documentId', () {
        final link = service.createShareLink(
          'doc-001',
          'client-001',
          const Duration(days: 7),
        );

        expect(link.documentId, equals('doc-001'));
      });

      test('returns a link with the given clientId', () {
        final link = service.createShareLink(
          'doc-002',
          'client-002',
          const Duration(days: 1),
        );

        expect(link.clientId, equals('client-002'));
      });

      test('signedUrl is non-empty', () {
        final link = service.createShareLink(
          'doc-003',
          'client-003',
          const Duration(hours: 1),
        );

        expect(link.signedUrl, isNotEmpty);
      });

      test('signedUrl contains the documentId', () {
        final link = service.createShareLink(
          'doc-url-test',
          'client-004',
          const Duration(days: 1),
        );

        expect(link.signedUrl, contains('doc-url-test'));
      });

      test('signedUrl is a valid URL string with scheme', () {
        final link = service.createShareLink(
          'doc-005',
          'client-005',
          const Duration(days: 7),
        );

        expect(link.signedUrl, startsWith('https://'));
      });

      test('linkId is non-empty', () {
        final link = service.createShareLink(
          'doc-006',
          'client-006',
          const Duration(days: 1),
        );

        expect(link.linkId, isNotEmpty);
      });

      test('two links for the same document have different linkIds', () {
        final l1 = service.createShareLink(
          'doc-same',
          'client-007',
          const Duration(days: 1),
        );
        final l2 = service.createShareLink(
          'doc-same',
          'client-007',
          const Duration(days: 1),
        );

        expect(l1.linkId, isNot(equals(l2.linkId)));
      });

      test('isActive is true on creation', () {
        final link = service.createShareLink(
          'doc-active',
          'client-008',
          const Duration(days: 1),
        );

        expect(link.isActive, isTrue);
      });

      test('link is not expired immediately after creation', () {
        final link = service.createShareLink(
          'doc-not-expired',
          'client-009',
          const Duration(hours: 24),
        );

        expect(link.isExpired, isFalse);
      });

      test('expiresAt is approximately now + validity', () {
        final before = DateTime.now();
        final link = service.createShareLink(
          'doc-expiry',
          'client-010',
          const Duration(hours: 48),
        );
        final after = DateTime.now();

        final minExpiry = before.add(const Duration(hours: 48));
        final maxExpiry = after.add(const Duration(hours: 48));

        expect(
          link.expiresAt.isAfter(minExpiry) ||
              link.expiresAt.isAtSameMomentAs(minExpiry),
          isTrue,
        );
        expect(
          link.expiresAt.isBefore(maxExpiry) ||
              link.expiresAt.isAtSameMomentAs(maxExpiry),
          isTrue,
        );
      });

      test('documentName defaults to empty string when omitted', () {
        final link = service.createShareLink(
          'doc-no-name',
          'client-011',
          const Duration(days: 1),
        );

        expect(link.documentName, equals(''));
      });

      test('documentName is preserved when provided', () {
        final link = service.createShareLink(
          'doc-named',
          'client-012',
          const Duration(days: 1),
          documentName: 'ITR Acknowledgement',
        );

        expect(link.documentName, equals('ITR Acknowledgement'));
      });

      test('throws ArgumentError for empty documentId', () {
        expect(
          () => service.createShareLink(
            '',
            'client-013',
            const Duration(days: 1),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for empty clientId', () {
        expect(
          () => service.createShareLink('doc-014', '', const Duration(days: 1)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // -------------------------------------------------------------------------
    // getSharedDocuments
    // -------------------------------------------------------------------------

    group('getSharedDocuments', () {
      test('returns empty list when no links created for client', () {
        final docs = service.getSharedDocuments('client-no-docs-xyz');
        expect(docs, isEmpty);
      });

      test('returns active link for client', () {
        service.createShareLink(
          'doc-shared-a',
          'client-shared-1',
          const Duration(days: 7),
        );

        final docs = service.getSharedDocuments('client-shared-1');

        expect(docs.any((l) => l.documentId == 'doc-shared-a'), isTrue);
      });

      test('does not return links for other clients', () {
        service.createShareLink(
          'doc-client-a',
          'client-filter-a',
          const Duration(days: 7),
        );
        service.createShareLink(
          'doc-client-b',
          'client-filter-b',
          const Duration(days: 7),
        );

        final docsA = service.getSharedDocuments('client-filter-a');

        expect(docsA.every((l) => l.clientId == 'client-filter-a'), isTrue);
      });

      test('does not return revoked links', () {
        final link = service.createShareLink(
          'doc-will-revoke',
          'client-revoked-docs',
          const Duration(days: 7),
        );

        service.revokeLink(link.linkId);

        final docs = service.getSharedDocuments('client-revoked-docs');

        expect(docs.any((l) => l.linkId == link.linkId), isFalse);
      });

      test('returns multiple active links for the same client', () {
        service.createShareLink(
          'doc-multi-1',
          'client-multi',
          const Duration(days: 7),
        );
        service.createShareLink(
          'doc-multi-2',
          'client-multi',
          const Duration(days: 7),
        );

        final docs = service.getSharedDocuments('client-multi');

        expect(
          docs.where((l) => l.clientId == 'client-multi').length,
          greaterThanOrEqualTo(2),
        );
      });
    });

    // -------------------------------------------------------------------------
    // getAllLinksForClient
    // -------------------------------------------------------------------------

    group('getAllLinksForClient', () {
      test('returns both active and revoked links', () {
        final link = service.createShareLink(
          'doc-all-links',
          'client-all-links',
          const Duration(days: 7),
        );

        service.revokeLink(link.linkId);

        final allLinks = service.getAllLinksForClient('client-all-links');

        expect(allLinks.any((l) => l.linkId == link.linkId), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // revokeLink
    // -------------------------------------------------------------------------

    group('revokeLink', () {
      test('sets isActive to false on the stored link', () {
        final link = service.createShareLink(
          'doc-revoke',
          'client-revoke-1',
          const Duration(days: 7),
        );

        service.revokeLink(link.linkId);

        final stored = service.findLink(link.linkId);
        expect(stored, isNotNull);
        expect(stored!.isActive, isFalse);
      });

      test('revokeLink with unknown linkId is a no-op (no error)', () {
        expect(
          () => service.revokeLink('non-existent-link-id-xyz'),
          returnsNormally,
        );
      });

      test('revokeLink is idempotent', () {
        final link = service.createShareLink(
          'doc-revoke-idem',
          'client-revoke-2',
          const Duration(days: 1),
        );

        service.revokeLink(link.linkId);
        expect(() => service.revokeLink(link.linkId), returnsNormally);

        final stored = service.findLink(link.linkId);
        expect(stored!.isActive, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // revokeAllForClient
    // -------------------------------------------------------------------------

    group('revokeAllForClient', () {
      test('deactivates all active links for the client', () {
        service.createShareLink(
          'doc-bulk-1',
          'client-bulk-revoke',
          const Duration(days: 7),
        );
        service.createShareLink(
          'doc-bulk-2',
          'client-bulk-revoke',
          const Duration(days: 7),
        );

        service.revokeAllForClient('client-bulk-revoke');

        final remaining = service.getSharedDocuments('client-bulk-revoke');
        expect(remaining, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // findLink
    // -------------------------------------------------------------------------

    group('findLink', () {
      test('returns the link when it exists', () {
        final link = service.createShareLink(
          'doc-find',
          'client-find',
          const Duration(days: 1),
        );

        final found = service.findLink(link.linkId);
        expect(found, isNotNull);
        expect(found!.documentId, equals('doc-find'));
      });

      test('returns null when link does not exist', () {
        final found = service.findLink('non-existent-xyz-abc');
        expect(found, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // SharedDocumentLink model
    // -------------------------------------------------------------------------

    group('SharedDocumentLink', () {
      final link = SharedDocumentLink(
        linkId: 'lnk-001',
        documentId: 'doc-001',
        documentName: 'ITR Ack',
        clientId: 'client-001',
        signedUrl:
            'https://docs.caapp.in/share/doc-001?linkId=lnk-001&exp=9999',
        expiresAt: DateTime(2099),
        isActive: true,
      );

      test('isExpired is false for future expiresAt', () {
        expect(link.isExpired, isFalse);
      });

      test('isExpired is true for past expiresAt', () {
        final expired = link.copyWith(expiresAt: DateTime(2000));
        expect(expired.isExpired, isTrue);
      });

      test('copyWith preserves unchanged fields', () {
        final copy = link.copyWith(isActive: false);

        expect(copy.linkId, equals('lnk-001'));
        expect(copy.documentId, equals('doc-001'));
        expect(copy.isActive, isFalse);
      });

      test('equality based on linkId, documentId, and clientId', () {
        final a = SharedDocumentLink(
          linkId: 'lnk-eq',
          documentId: 'doc-eq',
          documentName: 'Name A',
          clientId: 'client-eq',
          signedUrl: 'https://a.com',
          expiresAt: DateTime(2099),
          isActive: true,
        );
        final b = SharedDocumentLink(
          linkId: 'lnk-eq',
          documentId: 'doc-eq',
          documentName: 'Name B',
          clientId: 'client-eq',
          signedUrl: 'https://b.com',
          expiresAt: DateTime(2099),
          isActive: false,
        );
        expect(a, equals(b));
      });

      test('toString includes linkId, documentId, clientId, and isActive', () {
        expect(link.toString(), contains('lnk-001'));
        expect(link.toString(), contains('doc-001'));
        expect(link.toString(), contains('client-001'));
      });
    });
  });
}
