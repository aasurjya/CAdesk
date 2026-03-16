import 'package:ca_app/features/msme/domain/services/msme_vendor_verification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MsmeVerificationResult', () {
    test('creates with correct field values', () {
      const result = MsmeVerificationResult(
        udyamNumber: 'UDYAM-MH-01-0012345',
        isVerified: true,
        category: 'SMALL',
        enterpriseName: 'ABC Enterprises',
      );

      expect(result.udyamNumber, 'UDYAM-MH-01-0012345');
      expect(result.isVerified, isTrue);
      expect(result.category, 'SMALL');
      expect(result.enterpriseName, 'ABC Enterprises');
    });

    test('equality — same fields are equal', () {
      const a = MsmeVerificationResult(
        udyamNumber: 'UDYAM-MH-01-0012345',
        isVerified: true,
        category: 'MICRO',
        enterpriseName: 'Test Co',
      );
      const b = MsmeVerificationResult(
        udyamNumber: 'UDYAM-MH-01-0012345',
        isVerified: true,
        category: 'MICRO',
        enterpriseName: 'Test Co',
      );

      expect(a, equals(b));
    });

    test('equality — different isVerified are not equal', () {
      const a = MsmeVerificationResult(
        udyamNumber: 'UDYAM-MH-01-0012345',
        isVerified: true,
        category: 'MICRO',
        enterpriseName: 'Test Co',
      );
      const b = MsmeVerificationResult(
        udyamNumber: 'UDYAM-MH-01-0012345',
        isVerified: false,
        category: 'MICRO',
        enterpriseName: 'Test Co',
      );

      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent for equal objects', () {
      const a = MsmeVerificationResult(
        udyamNumber: 'UDYAM-MH-01-0012345',
        isVerified: true,
        category: 'MICRO',
        enterpriseName: 'Test Co',
      );
      const b = MsmeVerificationResult(
        udyamNumber: 'UDYAM-MH-01-0012345',
        isVerified: true,
        category: 'MICRO',
        enterpriseName: 'Test Co',
      );

      expect(a.hashCode, b.hashCode);
    });
  });

  group('MsmeVendorVerificationService', () {
    final service = MsmeVendorVerificationService.instance;

    test('singleton instance is always the same object', () {
      expect(
        identical(MsmeVendorVerificationService.instance, service),
        isTrue,
      );
    });

    group('verifyMsmeStatus', () {
      test('returns verified result for valid Udyam number', () async {
        final result = await service.verifyMsmeStatus('UDYAM-MH-01-0012345');

        expect(result.isVerified, isTrue);
        expect(result.udyamNumber, 'UDYAM-MH-01-0012345');
        expect(result.category, isNotEmpty);
        expect(result.enterpriseName, isNotEmpty);
      });

      test('returns category MICRO for mock response', () async {
        final result = await service.verifyMsmeStatus('UDYAM-KA-10-9876543');

        expect(result.category, 'MICRO');
        expect(result.enterpriseName, 'Mock Enterprise');
      });

      test('returns unverified result for empty Udyam number', () async {
        final result = await service.verifyMsmeStatus('');

        expect(result.isVerified, isFalse);
        expect(result.udyamNumber, '');
        expect(result.category, '');
        expect(result.enterpriseName, '');
      });

      test('preserves the Udyam number in the result', () async {
        const udyamNumber = 'UDYAM-TN-05-0054321';
        final result = await service.verifyMsmeStatus(udyamNumber);
        expect(result.udyamNumber, udyamNumber);
      });

      test('returns a Future that completes successfully', () {
        expect(service.verifyMsmeStatus('UDYAM-DL-01-0001111'), completes);
      });
    });
  });
}
