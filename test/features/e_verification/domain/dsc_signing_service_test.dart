import 'package:ca_app/features/e_verification/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';
import 'package:ca_app/features/e_verification/domain/services/dsc_signing_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── detectAvailableTokens ────────────────────────────────────────────

  group('DscSigningService.detectAvailableTokens', () {
    test('returns a non-empty list of certificates', () {
      final certs = DscSigningService.detectAvailableTokens();
      expect(certs, isNotEmpty);
    });

    test('test certificate has serial TEST001', () {
      final certs = DscSigningService.detectAvailableTokens();
      final testCert = certs.firstWhere((c) => c.serialNumber == 'TEST001');
      expect(testCert.serialNumber, 'TEST001');
    });

    test('test certificate subject contains Test User', () {
      final certs = DscSigningService.detectAvailableTokens();
      final testCert = certs.firstWhere((c) => c.serialNumber == 'TEST001');
      expect(testCert.subjectName, contains('Test User'));
    });

    test('test certificate is valid (not expired)', () {
      final certs = DscSigningService.detectAvailableTokens();
      final testCert = certs.firstWhere((c) => c.serialNumber == 'TEST001');
      expect(testCert.isExpired, isFalse);
    });

    test('test certificate has digitalSignature key usage', () {
      final certs = DscSigningService.detectAvailableTokens();
      final testCert = certs.firstWhere((c) => c.serialNumber == 'TEST001');
      expect(testCert.keyUsage, contains('digitalSignature'));
    });

    test('test certificate valid for approximately 2 years from now', () {
      final certs = DscSigningService.detectAvailableTokens();
      final testCert = certs.firstWhere((c) => c.serialNumber == 'TEST001');
      // At least 1.5 years (540 days) remaining
      expect(testCert.daysUntilExpiry, greaterThan(540));
    });
  });

  // ── createSigningRequest ─────────────────────────────────────────────

  group('DscSigningService.createSigningRequest', () {
    test('returns SigningRequest with pending status', () {
      final req = DscSigningService.createSigningRequest(
        'abc123hash',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      expect(req.status, SigningStatus.pending);
    });

    test('stores documentHash correctly', () {
      final req = DscSigningService.createSigningRequest(
        'abc123hash',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      expect(req.documentHash, 'abc123hash');
    });

    test('stores documentType correctly', () {
      final req = DscSigningService.createSigningRequest(
        'abc123hash',
        DocumentType.gstReturn,
        'ABCDE1234F',
      );
      expect(req.documentType, DocumentType.gstReturn);
    });

    test('stores signerPan correctly', () {
      final req = DscSigningService.createSigningRequest(
        'abc123hash',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      expect(req.signerPan, 'ABCDE1234F');
    });

    test('generates unique requestId for each call', () {
      final req1 = DscSigningService.createSigningRequest(
        'hash1',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      final req2 = DscSigningService.createSigningRequest(
        'hash2',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      expect(req1.requestId, isNot(equals(req2.requestId)));
    });

    test('signedAt is null for new request', () {
      final req = DscSigningService.createSigningRequest(
        'abc123hash',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      expect(req.signedAt, isNull);
    });

    test('signature is null for new request', () {
      final req = DscSigningService.createSigningRequest(
        'abc123hash',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      expect(req.signature, isNull);
    });
  });

  // ── signDocument ─────────────────────────────────────────────────────

  group('DscSigningService.signDocument', () {
    late DscCertificate testCert;
    late SigningRequest pendingRequest;

    setUp(() {
      testCert = DscSigningService.detectAvailableTokens()
          .firstWhere((c) => c.serialNumber == 'TEST001');
      pendingRequest = DscSigningService.createSigningRequest(
        'deadbeef1234567890abcdef',
        DocumentType.itrV,
        'ABCDE1234F',
      );
    });

    test('returns request with signed status', () {
      final signed = DscSigningService.signDocument(pendingRequest, testCert);
      expect(signed.status, SigningStatus.signed);
    });

    test('returned request has non-null signature', () {
      final signed = DscSigningService.signDocument(pendingRequest, testCert);
      expect(signed.signature, isNotNull);
      expect(signed.signature, isNotEmpty);
    });

    test('returned request has signedAt timestamp', () {
      final signed = DscSigningService.signDocument(pendingRequest, testCert);
      expect(signed.signedAt, isNotNull);
    });

    test('signature is deterministic for same inputs', () {
      final signed1 = DscSigningService.signDocument(pendingRequest, testCert);
      final signed2 = DscSigningService.signDocument(pendingRequest, testCert);
      expect(signed1.signature, equals(signed2.signature));
    });

    test('original request is not mutated', () {
      DscSigningService.signDocument(pendingRequest, testCert);
      expect(pendingRequest.status, SigningStatus.pending);
      expect(pendingRequest.signature, isNull);
    });

    test('fails when certificate is expired', () {
      final expiredCert = DscCertificate(
        tokenId: 'tok-expired',
        subjectName: 'CN=Expired User',
        issuer: 'CN=Test CA',
        serialNumber: 'EXP001',
        validFrom: DateTime(2020),
        validTo: DateTime(2021),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      final result = DscSigningService.signDocument(pendingRequest, expiredCert);
      expect(result.status, SigningStatus.failed);
    });

    test('fails when certificate lacks digitalSignature key usage', () {
      final invalidCert = DscCertificate(
        tokenId: 'tok-invalid',
        subjectName: 'CN=Invalid User',
        issuer: 'CN=Test CA',
        serialNumber: 'INV001',
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validTo: DateTime.now().add(const Duration(days: 365)),
        keyUsage: const ['keyEncipherment'],
      );
      final result = DscSigningService.signDocument(pendingRequest, invalidCert);
      expect(result.status, SigningStatus.failed);
    });
  });

  // ── verifySignature ───────────────────────────────────────────────────

  group('DscSigningService.verifySignature', () {
    late DscCertificate testCert;

    setUp(() {
      testCert = DscSigningService.detectAvailableTokens()
          .firstWhere((c) => c.serialNumber == 'TEST001');
    });

    test('verifies a correctly signed request → true', () {
      final pending = DscSigningService.createSigningRequest(
        'deadbeef',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      final signed = DscSigningService.signDocument(pending, testCert);
      expect(DscSigningService.verifySignature(signed, testCert), isTrue);
    });

    test('rejects unsigned request → false', () {
      final pending = DscSigningService.createSigningRequest(
        'deadbeef',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      expect(DscSigningService.verifySignature(pending, testCert), isFalse);
    });

    test('rejects tampered signature → false', () {
      final pending = DscSigningService.createSigningRequest(
        'deadbeef',
        DocumentType.itrV,
        'ABCDE1234F',
      );
      final tampered = pending.copyWith(
        signature: 'invalidsignature',
        status: SigningStatus.signed,
      );
      expect(DscSigningService.verifySignature(tampered, testCert), isFalse);
    });
  });

  // ── isTokenValid ──────────────────────────────────────────────────────

  group('DscSigningService.isTokenValid', () {
    test('valid test certificate → true', () {
      final cert = DscSigningService.detectAvailableTokens()
          .firstWhere((c) => c.serialNumber == 'TEST001');
      expect(DscSigningService.isTokenValid(cert), isTrue);
    });

    test('expired certificate → false', () {
      final expired = DscCertificate(
        tokenId: 'tok-exp',
        subjectName: 'CN=Expired',
        issuer: 'CN=CA',
        serialNumber: 'EXP001',
        validFrom: DateTime(2020),
        validTo: DateTime(2021),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      expect(DscSigningService.isTokenValid(expired), isFalse);
    });

    test('missing digitalSignature key usage → false', () {
      final invalid = DscCertificate(
        tokenId: 'tok-inv',
        subjectName: 'CN=Invalid',
        issuer: 'CN=CA',
        serialNumber: 'INV002',
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validTo: DateTime.now().add(const Duration(days: 365)),
        keyUsage: const ['keyEncipherment'],
      );
      expect(DscSigningService.isTokenValid(invalid), isFalse);
    });

    test('certificate with both required usages → true', () {
      final valid = DscCertificate(
        tokenId: 'tok-valid',
        subjectName: 'CN=Valid User',
        issuer: 'CN=Test CA',
        serialNumber: 'VAL001',
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validTo: DateTime.now().add(const Duration(days: 365)),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      expect(DscSigningService.isTokenValid(valid), isTrue);
    });
  });
}
