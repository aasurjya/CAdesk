import 'package:ca_app/features/gst/domain/models/reverse_charge.dart';
import 'package:ca_app/features/gst/domain/services/rcm_detection_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RcmDetectionEngine.detect — Section 9(3) notified services', () {
    test('legal services by advocate (9982) → RCM applicable', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '9982',
        isSupplierRegistered: true,
      );

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_3);
      expect(result.selfInvoiceRequired, true);
    });

    test('GTA services (9965) → RCM applicable', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '9965',
        isSupplierRegistered: true,
      );

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_3);
    });

    test('GTA services (9967) → RCM applicable', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '9967',
        isSupplierRegistered: true,
      );

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_3);
    });

    test('security/manpower services (9985) → RCM applicable', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '9985',
        isSupplierRegistered: true,
      );

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_3);
    });

    test('renting of motor vehicle (9966) → RCM applicable', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '9966',
        isSupplierRegistered: true,
      );

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_3);
    });
  });

  group('RcmDetectionEngine.detect — Section 9(4)', () {
    test('unregistered supplier → RCM applicable', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '998314',
        isSupplierRegistered: false,
      );

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_4);
      expect(result.selfInvoiceRequired, true);
    });
  });

  group('RcmDetectionEngine.detect — Section 9(5)', () {
    test('e-commerce operator → RCM applicable', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '998314',
        isSupplierRegistered: true,
        isEcommerce: true,
      );

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_5);
    });
  });

  group('RcmDetectionEngine.detect — no RCM', () {
    test('registered supplier with non-notified SAC → no RCM', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '998314',
        isSupplierRegistered: true,
      );

      expect(result.isRcmApplicable, false);
      expect(result.rcmSection, RcmSection.none);
      expect(result.selfInvoiceRequired, false);
    });
  });

  group('RcmDetectionEngine.detect — self-invoice requirement', () {
    test('Section 9(3) → self-invoice required', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '9982',
        isSupplierRegistered: true,
      );

      expect(result.selfInvoiceRequired, true);
    });

    test('Section 9(4) unregistered → self-invoice required', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '998314',
        isSupplierRegistered: false,
      );

      expect(result.selfInvoiceRequired, true);
    });

    test('no RCM → self-invoice not required', () {
      final result = RcmDetectionEngine.detect(
        sacCode: '998314',
        isSupplierRegistered: true,
      );

      expect(result.selfInvoiceRequired, false);
    });
  });

  group('RcmDetectionEngine.getNotifiedServices', () {
    test('returns list of notified service categories', () {
      final services = RcmDetectionEngine.getNotifiedServices();

      expect(services, isNotEmpty);
      expect(services.length, greaterThanOrEqualTo(10));
    });
  });
}
