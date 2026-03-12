import 'package:ca_app/features/gst/domain/models/reverse_charge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RcmSection enum', () {
    test('all sections exist', () {
      expect(RcmSection.values.length, 4);
      expect(RcmSection.section9_3, isNotNull);
      expect(RcmSection.section9_4, isNotNull);
      expect(RcmSection.section9_5, isNotNull);
      expect(RcmSection.none, isNotNull);
    });
  });

  group('RcmResult', () {
    RcmResult createResult({
      bool isRcmApplicable = true,
      RcmSection rcmSection = RcmSection.section9_3,
      String? serviceCategory = 'Legal services',
      String reason = 'Notified under Section 9(3)',
      bool selfInvoiceRequired = true,
    }) {
      return RcmResult(
        isRcmApplicable: isRcmApplicable,
        rcmSection: rcmSection,
        serviceCategory: serviceCategory,
        reason: reason,
        selfInvoiceRequired: selfInvoiceRequired,
      );
    }

    test('creates with correct field values', () {
      final result = createResult();

      expect(result.isRcmApplicable, true);
      expect(result.rcmSection, RcmSection.section9_3);
      expect(result.serviceCategory, 'Legal services');
      expect(result.reason, 'Notified under Section 9(3)');
      expect(result.selfInvoiceRequired, true);
    });

    test('copyWith → returns new instance with changed fields', () {
      final original = createResult();
      final copied = original.copyWith(
        isRcmApplicable: false,
        rcmSection: RcmSection.none,
        reason: 'Not applicable',
        selfInvoiceRequired: false,
      );

      expect(copied.isRcmApplicable, false);
      expect(copied.rcmSection, RcmSection.none);
      expect(copied.reason, 'Not applicable');
      expect(copied.selfInvoiceRequired, false);
      // Original unchanged
      expect(original.isRcmApplicable, true);
    });

    test('copyWith with no args → returns equal instance', () {
      final original = createResult();
      final copied = original.copyWith();

      expect(copied, equals(original));
    });

    test('equality → same fields are equal', () {
      final a = createResult();
      final b = createResult();

      expect(a, equals(b));
    });

    test('equality → different fields are not equal', () {
      final a = createResult(isRcmApplicable: true);
      final b = createResult(isRcmApplicable: false, rcmSection: RcmSection.none);

      expect(a, isNot(equals(b)));
    });

    test('hashCode → equal objects have same hashCode', () {
      final a = createResult();
      final b = createResult();

      expect(a.hashCode, equals(b.hashCode));
    });

    test('null serviceCategory → creates correctly', () {
      final result = createResult(
        isRcmApplicable: false,
        rcmSection: RcmSection.none,
        serviceCategory: null,
      );

      expect(result.serviceCategory, isNull);
    });
  });
}
