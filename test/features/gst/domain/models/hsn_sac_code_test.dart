import 'package:ca_app/features/gst/domain/models/hsn_sac_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HsnSacType enum', () {
    test('hsn → has correct label', () {
      expect(HsnSacType.hsn.label, 'HSN');
    });

    test('sac → has correct label', () {
      expect(HsnSacType.sac.label, 'SAC');
    });
  });

  group('HsnSacCode', () {
    HsnSacCode createCode({
      String code = '1006',
      String description = 'Rice',
      HsnSacType type = HsnSacType.hsn,
      int chapter = 10,
      double gstRate = 5.0,
      double cessRate = 0.0,
      bool isActive = true,
    }) {
      return HsnSacCode(
        code: code,
        description: description,
        type: type,
        chapter: chapter,
        gstRate: gstRate,
        cessRate: cessRate,
        isActive: isActive,
      );
    }

    test('creates with const constructor and correct field values', () {
      final code = createCode();

      expect(code.code, '1006');
      expect(code.description, 'Rice');
      expect(code.type, HsnSacType.hsn);
      expect(code.chapter, 10);
      expect(code.gstRate, 5.0);
      expect(code.cessRate, 0.0);
      expect(code.isActive, true);
    });

    test('copyWith → returns new instance with changed fields', () {
      final original = createCode();
      final copied = original.copyWith(
        description: 'Basmati Rice',
        gstRate: 12.0,
      );

      expect(copied.code, '1006');
      expect(copied.description, 'Basmati Rice');
      expect(copied.gstRate, 12.0);
      expect(copied.chapter, 10);
      // Original is unchanged (immutability)
      expect(original.description, 'Rice');
      expect(original.gstRate, 5.0);
    });

    test('copyWith with no args → returns equal instance', () {
      final original = createCode();
      final copied = original.copyWith();

      expect(copied, equals(original));
    });

    test('equality → same code and type are equal', () {
      final a = createCode(code: '1006', type: HsnSacType.hsn);
      final b = createCode(
        code: '1006',
        type: HsnSacType.hsn,
        description: 'Different',
      );

      expect(a, equals(b));
    });

    test('equality → different code are not equal', () {
      final a = createCode(code: '1006');
      final b = createCode(code: '1001');

      expect(a, isNot(equals(b)));
    });

    test('equality → same code but different type are not equal', () {
      final hsn = createCode(code: '9982', type: HsnSacType.hsn);
      final sac = createCode(code: '9982', type: HsnSacType.sac);

      expect(hsn, isNot(equals(sac)));
    });

    test('hashCode → equal objects have same hashCode', () {
      final a = createCode(code: '1006', type: HsnSacType.hsn);
      final b = createCode(code: '1006', type: HsnSacType.hsn);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('SAC code → creates correctly', () {
      final sac = createCode(
        code: '998221',
        description: 'Accounting services',
        type: HsnSacType.sac,
        chapter: 99,
        gstRate: 18.0,
      );

      expect(sac.type, HsnSacType.sac);
      expect(sac.code, '998221');
      expect(sac.gstRate, 18.0);
    });
  });
}
