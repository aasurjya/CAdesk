import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_client.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document.dart';
import 'package:ca_app/features/client_portal/domain/services/client_portal_service.dart';

void main() {
  late ClientPortalService service;

  setUp(() {
    service = ClientPortalService.instance;
  });

  // ---------------------------------------------------------------------------
  // PortalClient model
  // ---------------------------------------------------------------------------
  group('PortalClient model', () {
    test('const constructor and field access', () {
      const client = PortalClient(
        clientId: 'c1',
        pan: 'ABCDE1234F',
        name: 'Ravi Kumar',
        email: 'ravi@example.com',
        mobile: '919876543210',
        portalStatus: PortalStatus.invited,
        caFirmId: 'firm1',
        totalDocuments: 0,
      );
      expect(client.clientId, 'c1');
      expect(client.pan, 'ABCDE1234F');
      expect(client.portalStatus, PortalStatus.invited);
      expect(client.inviteToken, isNull);
      expect(client.inviteExpiry, isNull);
      expect(client.lastLoginAt, isNull);
    });

    test('copyWith returns new instance with updated fields', () {
      const original = PortalClient(
        clientId: 'c1',
        pan: 'ABCDE1234F',
        name: 'Ravi Kumar',
        email: 'ravi@example.com',
        mobile: '919876543210',
        portalStatus: PortalStatus.invited,
        caFirmId: 'firm1',
        totalDocuments: 0,
      );
      final updated = original.copyWith(portalStatus: PortalStatus.active);
      expect(updated.portalStatus, PortalStatus.active);
      expect(original.portalStatus, PortalStatus.invited); // immutable
      expect(updated.clientId, original.clientId);
    });

    test('equality is based on clientId', () {
      const a = PortalClient(
        clientId: 'c1',
        pan: 'ABCDE1234F',
        name: 'Ravi Kumar',
        email: 'ravi@example.com',
        mobile: '919876543210',
        portalStatus: PortalStatus.invited,
        caFirmId: 'firm1',
        totalDocuments: 0,
      );
      final b = a.copyWith(name: 'Different Name');
      expect(a, equals(b)); // same clientId
      final c = a.copyWith(clientId: 'c2');
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with clientId', () {
      const a = PortalClient(
        clientId: 'c1',
        pan: 'ABCDE1234F',
        name: 'Ravi Kumar',
        email: 'ravi@example.com',
        mobile: '919876543210',
        portalStatus: PortalStatus.invited,
        caFirmId: 'firm1',
        totalDocuments: 0,
      );
      expect(a.hashCode, a.clientId.hashCode);
    });
  });

  // ---------------------------------------------------------------------------
  // PortalStatus enum
  // ---------------------------------------------------------------------------
  group('PortalStatus enum', () {
    test('all values are present', () {
      expect(
        PortalStatus.values,
        containsAll([
          PortalStatus.invited,
          PortalStatus.active,
          PortalStatus.inactive,
          PortalStatus.suspended,
        ]),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // SharedDocument model (new domain version)
  // ---------------------------------------------------------------------------
  group('SharedDocument model', () {
    final now = DateTime(2025, 6, 1, 10, 0);

    test('const constructor and defaults', () {
      final doc = SharedDocument(
        documentId: 'd1',
        clientId: 'c1',
        caFirmId: 'firm1',
        title: 'ITR-V',
        documentType: DocumentType.itrV,
        fileSize: 102400,
        mimeType: 'application/pdf',
        sharedAt: now,
        requiresESign: false,
        eSigned: false,
        status: DocumentStatus.shared,
      );
      expect(doc.documentId, 'd1');
      expect(doc.requiresESign, isFalse);
      expect(doc.eSigned, isFalse);
      expect(doc.viewedAt, isNull);
      expect(doc.downloadedAt, isNull);
      expect(doc.eSignedAt, isNull);
      expect(doc.expiresAt, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final doc = SharedDocument(
        documentId: 'd1',
        clientId: 'c1',
        caFirmId: 'firm1',
        title: 'Form 16',
        documentType: DocumentType.form16,
        fileSize: 51200,
        mimeType: 'application/pdf',
        sharedAt: now,
        requiresESign: true,
        eSigned: false,
        status: DocumentStatus.shared,
      );
      final viewed = doc.copyWith(viewedAt: now, status: DocumentStatus.viewed);
      expect(viewed.viewedAt, now);
      expect(viewed.status, DocumentStatus.viewed);
      expect(viewed.documentId, 'd1');
      expect(doc.viewedAt, isNull); // original unchanged
    });

    test('equality based on documentId', () {
      final doc = SharedDocument(
        documentId: 'd1',
        clientId: 'c1',
        caFirmId: 'firm1',
        title: 'Form 16',
        documentType: DocumentType.form16,
        fileSize: 51200,
        mimeType: 'application/pdf',
        sharedAt: now,
        requiresESign: false,
        eSigned: false,
        status: DocumentStatus.shared,
      );
      final other = doc.copyWith(title: 'Other Title');
      expect(doc, equals(other));
    });

    test('DocumentType enum has expected values', () {
      expect(
        DocumentType.values,
        containsAll([
          DocumentType.itrV,
          DocumentType.form16,
          DocumentType.gstCertificate,
          DocumentType.auditReport,
          DocumentType.invoice,
          DocumentType.other,
        ]),
      );
    });

    test('DocumentStatus enum has expected values', () {
      expect(
        DocumentStatus.values,
        containsAll([
          DocumentStatus.shared,
          DocumentStatus.viewed,
          DocumentStatus.downloaded,
          DocumentStatus.eSigned,
          DocumentStatus.expired,
        ]),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // ClientPortalService
  // ---------------------------------------------------------------------------
  group('ClientPortalService', () {
    test('is singleton', () {
      expect(ClientPortalService.instance, same(ClientPortalService.instance));
    });

    test('inviteClient creates PortalClient with invited status', () {
      final client = service.inviteClient(
        'ABCDE1234F',
        'Ravi Kumar',
        'ravi@example.com',
        '919876543210',
        'firm1',
      );
      expect(client.pan, 'ABCDE1234F');
      expect(client.name, 'Ravi Kumar');
      expect(client.email, 'ravi@example.com');
      expect(client.mobile, '919876543210');
      expect(client.caFirmId, 'firm1');
      expect(client.portalStatus, PortalStatus.invited);
      expect(client.totalDocuments, 0);
      expect(client.clientId, isNotEmpty);
    });

    test('inviteClient generates unique clientIds', () {
      final c1 = service.inviteClient(
        'ABCDE1234F',
        'A',
        'a@b.com',
        '91111',
        'firm1',
      );
      final c2 = service.inviteClient(
        'XYZAB5678G',
        'B',
        'b@c.com',
        '91222',
        'firm1',
      );
      expect(c1.clientId, isNot(equals(c2.clientId)));
    });

    test('generateInviteToken sets token and expiry 72h ahead', () {
      final client = service.inviteClient(
        'ABCDE1234F',
        'Ravi Kumar',
        'ravi@example.com',
        '919876543210',
        'firm1',
      );
      final before = DateTime.now();
      final withToken = service.generateInviteToken(client);
      final after = DateTime.now();

      expect(withToken.inviteToken, isNotNull);
      expect(withToken.inviteToken, isNotEmpty);
      expect(withToken.inviteExpiry, isNotNull);
      // Expiry should be ~72h from now
      final diff = withToken.inviteExpiry!.difference(before);
      expect(diff.inHours, greaterThanOrEqualTo(71));
      expect(diff.inHours, lessThanOrEqualTo(73));
      // Original unchanged (immutable)
      expect(client.inviteToken, isNull);
      expect(after.isAfter(before) || after == before, isTrue);
    });

    test('generateInviteToken does not change portalStatus', () {
      final client = service.inviteClient(
        'ABCDE1234F',
        'Ravi',
        'r@e.com',
        '91999',
        'firm1',
      );
      final withToken = service.generateInviteToken(client);
      expect(withToken.portalStatus, PortalStatus.invited);
    });

    test('activatePortal sets status to active when token matches', () {
      final client = service.inviteClient(
        'ABCDE1234F',
        'Ravi',
        'r@e.com',
        '91999',
        'firm1',
      );
      final withToken = service.generateInviteToken(client);
      final active = service.activatePortal(withToken, withToken.inviteToken!);
      expect(active.portalStatus, PortalStatus.active);
    });

    test('activatePortal throws on wrong token', () {
      final client = service.inviteClient(
        'ABCDE1234F',
        'Ravi',
        'r@e.com',
        '91999',
        'firm1',
      );
      final withToken = service.generateInviteToken(client);
      expect(
        () => service.activatePortal(withToken, 'wrong-token'),
        throwsArgumentError,
      );
    });

    test('activatePortal throws on expired token', () {
      final client = service.inviteClient(
        'ABCDE1234F',
        'Ravi',
        'r@e.com',
        '91999',
        'firm1',
      );
      final expired = client.copyWith(
        inviteToken: 'tok',
        inviteExpiry: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(() => service.activatePortal(expired, 'tok'), throwsArgumentError);
    });

    test('shareDocument creates SharedDocument with correct fields', () {
      final doc = service.shareDocument(
        'c1',
        'd1',
        'ITR-V 2024',
        DocumentType.itrV,
      );
      expect(doc.clientId, 'c1');
      expect(doc.documentId, 'd1');
      expect(doc.title, 'ITR-V 2024');
      expect(doc.documentType, DocumentType.itrV);
      expect(doc.requiresESign, isFalse);
      expect(doc.status, DocumentStatus.shared);
      expect(doc.eSigned, isFalse);
    });

    test('shareDocument with requiresESign=true sets flag', () {
      final doc = service.shareDocument(
        'c1',
        'd2',
        'Audit Report',
        DocumentType.auditReport,
        requiresESign: true,
      );
      expect(doc.requiresESign, isTrue);
    });

    test('markDocumentViewed updates viewedAt and status', () {
      final doc = service.shareDocument(
        'c1',
        'd1',
        'Form 16',
        DocumentType.form16,
      );
      final viewed = service.markDocumentViewed(doc);
      expect(viewed.viewedAt, isNotNull);
      expect(viewed.status, DocumentStatus.viewed);
      expect(doc.viewedAt, isNull); // original unchanged
    });

    test('markDocumentSigned updates eSigned, eSignedAt and status', () {
      final doc = service.shareDocument(
        'c1',
        'd1',
        'Audit Report',
        DocumentType.auditReport,
        requiresESign: true,
      );
      final signedAt = DateTime(2025, 6, 1, 14, 30);
      final signed = service.markDocumentSigned(doc, signedAt);
      expect(signed.eSigned, isTrue);
      expect(signed.eSignedAt, signedAt);
      expect(signed.status, DocumentStatus.eSigned);
      expect(doc.eSigned, isFalse); // original unchanged
    });
  });
}
