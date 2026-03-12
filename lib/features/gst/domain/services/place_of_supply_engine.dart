import 'package:ca_app/features/gst/domain/models/place_of_supply.dart';

/// Static service implementing Place of Supply rules under Sections 10–13
/// of the IGST Act, 2017.
class PlaceOfSupplyEngine {
  PlaceOfSupplyEngine._();

  /// Indian state/UT code master (01–38).
  static const Map<String, String> _stateCodes = {
    '01': 'Jammu & Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '25': 'Daman & Diu',
    '26': 'Dadra & Nagar Haveli',
    '27': 'Maharashtra',
    '28': 'Andhra Pradesh',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman & Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh (New)',
    '38': 'Ladakh',
  };

  /// Determines the place of supply and applicable tax type.
  ///
  /// Implements Sections 10–13 of the IGST Act:
  /// - Section 10: Place of supply of goods (other than import/export)
  /// - Section 11: Place of supply of goods (import/export)
  /// - Section 12: Place of supply of services (supplier and recipient in India)
  /// - Section 13: Place of supply of services (international)
  static PlaceOfSupplyResult determine({
    required String supplierStateCode,
    required String recipientStateCode,
    required SupplyType supplyType,
    GstSupplyCategory category = GstSupplyCategory.regular,
  }) {
    // Import, export, and SEZ are always inter-state (IGST).
    if (category == GstSupplyCategory.importGoods ||
        category == GstSupplyCategory.exportGoods) {
      return PlaceOfSupplyResult(
        supplierStateCode: supplierStateCode,
        recipientStateCode: recipientStateCode,
        placeOfSupplyStateCode: recipientStateCode,
        isInterState: true,
        taxType: GstTaxType.igst,
        applicableSection: 'Section 13 IGST Act',
        reason: category == GstSupplyCategory.importGoods
            ? 'Import of goods — deemed inter-state supply'
            : 'Export of goods — deemed inter-state supply',
      );
    }

    if (category == GstSupplyCategory.sez) {
      return PlaceOfSupplyResult(
        supplierStateCode: supplierStateCode,
        recipientStateCode: recipientStateCode,
        placeOfSupplyStateCode: recipientStateCode,
        isInterState: true,
        taxType: GstTaxType.igst,
        applicableSection: 'Section 8(1) IGST Act',
        reason: 'Supply to/from SEZ — deemed inter-state supply',
      );
    }

    // Bill-to-ship-to: place of supply = delivery location (recipient).
    if (category == GstSupplyCategory.billToShipTo) {
      final isInterState = supplierStateCode != recipientStateCode;
      return PlaceOfSupplyResult(
        supplierStateCode: supplierStateCode,
        recipientStateCode: recipientStateCode,
        placeOfSupplyStateCode: recipientStateCode,
        isInterState: isInterState,
        taxType: isInterState ? GstTaxType.igst : GstTaxType.cgstSgst,
        applicableSection: 'Section 10(1)(b) IGST Act',
        reason: 'Bill-to-ship-to — place of supply is delivery location',
      );
    }

    // Installed at site: place of supply = installation location (recipient).
    if (category == GstSupplyCategory.installedAtSite) {
      final isInterState = supplierStateCode != recipientStateCode;
      return PlaceOfSupplyResult(
        supplierStateCode: supplierStateCode,
        recipientStateCode: recipientStateCode,
        placeOfSupplyStateCode: recipientStateCode,
        isInterState: isInterState,
        taxType: isInterState ? GstTaxType.igst : GstTaxType.cgstSgst,
        applicableSection: 'Section 10(1)(d) IGST Act',
        reason:
            'Goods installed at site — place of supply is installation location',
      );
    }

    // Regular supply — determine based on supplier vs recipient state.
    final isInterState = supplierStateCode != recipientStateCode;
    final String section;
    if (supplyType == SupplyType.goods) {
      section = isInterState
          ? 'Section 10(1)(a) IGST Act'
          : 'Section 10(1)(a) IGST Act';
    } else {
      section = isInterState
          ? 'Section 12(2) IGST Act'
          : 'Section 12(2) IGST Act';
    }

    return PlaceOfSupplyResult(
      supplierStateCode: supplierStateCode,
      recipientStateCode: recipientStateCode,
      placeOfSupplyStateCode: recipientStateCode,
      isInterState: isInterState,
      taxType: isInterState ? GstTaxType.igst : GstTaxType.cgstSgst,
      applicableSection: section,
      reason: isInterState
          ? 'Inter-state supply — supplier ($supplierStateCode) and '
                'recipient ($recipientStateCode) in different states'
          : 'Intra-state supply — both parties in state $supplierStateCode',
    );
  }

  /// Returns whether [code] is a valid Indian state/UT code (01–38).
  static bool isValidStateCode(String code) {
    return _stateCodes.containsKey(code);
  }

  /// Returns the state/UT name for the given [code], or null if invalid.
  static String? getStateName(String code) {
    return _stateCodes[code];
  }
}
