import 'package:ca_app/features/gst/domain/services/itc_eligibility_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItcEligibilityEngine.isEligible', () {
    test('motor vehicle (SAC 9601) → ineligible under section 17(5)', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '9601',
        description: 'Motor vehicle for personal use',
      );
      expect(result.isEligible, false);
      expect(result.section17_5Category, isNotNull);
    });

    test('food and beverages (SAC 9963) → ineligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '9963',
        description: 'Food and beverages',
      );
      expect(result.isEligible, false);
      expect(result.section17_5Category, isNotNull);
    });

    test('beauty treatment (SAC 9997) → ineligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '9997',
        description: 'beauty treatment services',
      );
      expect(result.isEligible, false);
    });

    test('health services (SAC 9993) → ineligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '9993',
        description: 'Health and fitness services',
      );
      expect(result.isEligible, false);
    });

    test('club membership (SAC 9995) → ineligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '9995',
        description: 'Club membership',
      );
      expect(result.isEligible, false);
    });

    test('works contract for immovable property (SAC 9954) → ineligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '9954',
        description: 'Works contract for construction of building',
      );
      expect(result.isEligible, false);
    });

    test('eligible ITC (software HSN 8523) → eligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '8523',
        description: 'Software media',
      );
      expect(result.isEligible, true);
      expect(result.section17_5Category, isNull);
    });

    test('eligible ITC (office supplies HSN 4820) → eligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '4820',
        description: 'Office stationery',
      );
      expect(result.isEligible, true);
      expect(result.reason, isNotEmpty);
    });

    test('travel benefits (SAC 9964) → ineligible', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '9964',
        description: 'Travel benefits to employees',
      );
      expect(result.isEligible, false);
    });

    test('eligible ITC → section17_5Category is null', () {
      final result = ItcEligibilityEngine.check(
        sacHsnCode: '8471',
        description: 'Computer hardware',
      );
      expect(result.section17_5Category, isNull);
      expect(result.isEligible, true);
    });
  });

  group('ItcEligibilityResult', () {
    test('copyWith → returns new instance with updated fields', () {
      const original = ItcEligibilityResult(
        isEligible: false,
        section17_5Category: 'Motor vehicles',
        reason: 'Blocked under Section 17(5)',
      );
      final updated = original.copyWith(
        isEligible: true,
        section17_5Category: null,
      );
      expect(updated.isEligible, true);
      expect(updated.section17_5Category, isNull);
      expect(updated.reason, original.reason);
    });

    test('copyWith → preserves all fields when called with no args', () {
      const original = ItcEligibilityResult(
        isEligible: true,
        section17_5Category: null,
        reason: 'Eligible ITC',
      );
      final copy = original.copyWith();
      expect(copy, equals(original));
      expect(copy.hashCode, original.hashCode);
    });

    test('equality → equal when all fields match', () {
      const a = ItcEligibilityResult(
        isEligible: false,
        section17_5Category: 'Food',
        reason: 'Blocked',
      );
      const b = ItcEligibilityResult(
        isEligible: false,
        section17_5Category: 'Food',
        reason: 'Blocked',
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('ItcEligibilityEngine.checkAll', () {
    test('returns results for all provided SAC/HSN codes', () {
      final codes = [
        ('9601', 'Motor car'),
        ('8471', 'Laptop'),
        ('9963', 'Restaurant food'),
      ];
      final results = ItcEligibilityEngine.checkAll(codes);
      expect(results.length, 3);
      expect(results[0].isEligible, false);
      expect(results[1].isEligible, true);
      expect(results[2].isEligible, false);
    });
  });
}
