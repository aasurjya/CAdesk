import 'package:ca_app/features/gst/domain/models/place_of_supply.dart';
import 'package:ca_app/features/gst/domain/services/place_of_supply_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceOfSupplyEngine.determine', () {
    test('same state (27 → 27) → CGST+SGST', () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '27',
        supplyType: SupplyType.goods,
      );

      expect(result.isInterState, false);
      expect(result.taxType, GstTaxType.cgstSgst);
      expect(result.placeOfSupplyStateCode, '27');
    });

    test('different state (27 → 29) → IGST', () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '29',
        supplyType: SupplyType.goods,
      );

      expect(result.isInterState, true);
      expect(result.taxType, GstTaxType.igst);
    });

    test('import goods → IGST', () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '29',
        supplyType: SupplyType.goods,
        category: GstSupplyCategory.importGoods,
      );

      expect(result.isInterState, true);
      expect(result.taxType, GstTaxType.igst);
      expect(result.applicableSection, contains('13'));
    });

    test('export goods → IGST', () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '27',
        supplyType: SupplyType.goods,
        category: GstSupplyCategory.exportGoods,
      );

      expect(result.isInterState, true);
      expect(result.taxType, GstTaxType.igst);
      expect(result.applicableSection, contains('13'));
    });

    test('SEZ supply → IGST', () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '27',
        supplyType: SupplyType.goods,
        category: GstSupplyCategory.sez,
      );

      expect(result.isInterState, true);
      expect(result.taxType, GstTaxType.igst);
    });

    test('bill-to-ship-to → place of supply is ship-to (recipient) location',
        () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '29',
        supplyType: SupplyType.goods,
        category: GstSupplyCategory.billToShipTo,
      );

      // In bill-to-ship-to, place of supply = location of goods delivery
      // which is the recipient state code
      expect(result.placeOfSupplyStateCode, '29');
      expect(result.isInterState, true);
      expect(result.taxType, GstTaxType.igst);
    });

    test('services same state → CGST+SGST', () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '27',
        supplyType: SupplyType.services,
      );

      expect(result.isInterState, false);
      expect(result.taxType, GstTaxType.cgstSgst);
    });

    test('services different state → IGST', () {
      final result = PlaceOfSupplyEngine.determine(
        supplierStateCode: '27',
        recipientStateCode: '29',
        supplyType: SupplyType.services,
      );

      expect(result.isInterState, true);
      expect(result.taxType, GstTaxType.igst);
    });
  });

  group('PlaceOfSupplyEngine.isValidStateCode', () {
    test('"01" (Jammu & Kashmir) → valid', () {
      expect(PlaceOfSupplyEngine.isValidStateCode('01'), isTrue);
    });

    test('"27" (Maharashtra) → valid', () {
      expect(PlaceOfSupplyEngine.isValidStateCode('27'), isTrue);
    });

    test('"38" (Ladakh) → valid', () {
      expect(PlaceOfSupplyEngine.isValidStateCode('38'), isTrue);
    });

    test('"00" → invalid', () {
      expect(PlaceOfSupplyEngine.isValidStateCode('00'), isFalse);
    });

    test('"39" → invalid', () {
      expect(PlaceOfSupplyEngine.isValidStateCode('39'), isFalse);
    });

    test('"ABC" → invalid', () {
      expect(PlaceOfSupplyEngine.isValidStateCode('ABC'), isFalse);
    });

    test('empty → invalid', () {
      expect(PlaceOfSupplyEngine.isValidStateCode(''), isFalse);
    });
  });

  group('PlaceOfSupplyEngine.getStateName', () {
    test('"27" → Maharashtra', () {
      expect(PlaceOfSupplyEngine.getStateName('27'), 'Maharashtra');
    });

    test('"29" → Karnataka', () {
      expect(PlaceOfSupplyEngine.getStateName('29'), 'Karnataka');
    });

    test('"01" → Jammu & Kashmir', () {
      expect(PlaceOfSupplyEngine.getStateName('01'), 'Jammu & Kashmir');
    });

    test('"38" → Ladakh', () {
      expect(PlaceOfSupplyEngine.getStateName('38'), 'Ladakh');
    });

    test('invalid code → null', () {
      expect(PlaceOfSupplyEngine.getStateName('00'), isNull);
    });
  });
}
