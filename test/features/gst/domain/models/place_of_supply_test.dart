import 'package:ca_app/features/gst/domain/models/place_of_supply.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GstTaxType enum', () {
    test('igst → exists', () {
      expect(GstTaxType.igst, isNotNull);
    });

    test('cgstSgst → exists', () {
      expect(GstTaxType.cgstSgst, isNotNull);
    });
  });

  group('SupplyType enum', () {
    test('goods → exists', () {
      expect(SupplyType.goods, isNotNull);
    });

    test('services → exists', () {
      expect(SupplyType.services, isNotNull);
    });
  });

  group('GstSupplyCategory enum', () {
    test('all categories exist', () {
      expect(GstSupplyCategory.values.length, greaterThanOrEqualTo(6));
      expect(GstSupplyCategory.regular, isNotNull);
      expect(GstSupplyCategory.billToShipTo, isNotNull);
      expect(GstSupplyCategory.installedAtSite, isNotNull);
      expect(GstSupplyCategory.importGoods, isNotNull);
      expect(GstSupplyCategory.exportGoods, isNotNull);
      expect(GstSupplyCategory.sez, isNotNull);
    });
  });

  group('PlaceOfSupplyResult', () {
    PlaceOfSupplyResult createResult({
      String supplierStateCode = '27',
      String recipientStateCode = '27',
      String placeOfSupplyStateCode = '27',
      bool isInterState = false,
      GstTaxType taxType = GstTaxType.cgstSgst,
      String applicableSection = 'Section 12(2)',
      String reason = 'Same state supply',
    }) {
      return PlaceOfSupplyResult(
        supplierStateCode: supplierStateCode,
        recipientStateCode: recipientStateCode,
        placeOfSupplyStateCode: placeOfSupplyStateCode,
        isInterState: isInterState,
        taxType: taxType,
        applicableSection: applicableSection,
        reason: reason,
      );
    }

    test('creates with correct field values', () {
      final result = createResult();

      expect(result.supplierStateCode, '27');
      expect(result.recipientStateCode, '27');
      expect(result.placeOfSupplyStateCode, '27');
      expect(result.isInterState, false);
      expect(result.taxType, GstTaxType.cgstSgst);
      expect(result.applicableSection, 'Section 12(2)');
      expect(result.reason, 'Same state supply');
    });

    test('copyWith → returns new instance with changed fields', () {
      final original = createResult();
      final copied = original.copyWith(
        recipientStateCode: '29',
        placeOfSupplyStateCode: '29',
        isInterState: true,
        taxType: GstTaxType.igst,
      );

      expect(copied.supplierStateCode, '27');
      expect(copied.recipientStateCode, '29');
      expect(copied.isInterState, true);
      expect(copied.taxType, GstTaxType.igst);
      // Original unchanged
      expect(original.recipientStateCode, '27');
      expect(original.isInterState, false);
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
      final a = createResult(supplierStateCode: '27');
      final b = createResult(supplierStateCode: '29');

      expect(a, isNot(equals(b)));
    });

    test('hashCode → equal objects have same hashCode', () {
      final a = createResult();
      final b = createResult();

      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
