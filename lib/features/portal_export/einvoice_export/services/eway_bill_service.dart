import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';

/// Threshold value (INR) above which an e-Way Bill is required for goods.
const _eWayBillThreshold = 50000.0;

/// Mock distance in km returned for any two pincodes.
const _mockDistanceKm = 100;

/// Stateless service for e-Way Bill eligibility checks and payload generation.
///
/// All methods are static; this class cannot be instantiated.
/// Distance computation uses a mock (always returns 100 km) — replace with a
/// real implementation when the distance API is available.
class EWayBillService {
  EWayBillService._();

  /// Returns true when an e-Way Bill is required for [req].
  ///
  /// e-Way Bill is required when ALL of the following conditions are met:
  /// 1. Total invoice value > ₹50,000.
  /// 2. The supply includes at least one goods item (not all services).
  /// 3. Distance between seller and buyer pincodes > 50 km (mock: always true).
  static bool isEWayBillRequired(EInvoiceRequest req) {
    final totVal = req.valDtls.totInvVal;
    if (totVal <= _eWayBillThreshold) return false;

    final hasGoods = req.itemList
        .any((EInvoiceItem i) => i.isServc == EInvoiceIsServc.no);
    if (!hasGoods) return false;

    final distance = computeDistance(
      req.sellerDtls.pincode.toString(),
      req.buyerDtls.pincode.toString(),
    );
    return distance > 50;
  }

  /// Builds the e-Way Bill generation payload map for the NIC EWB API.
  ///
  /// [transMode] transport mode code: '1' = road, '2' = rail, '3' = air,
  /// '4' = ship.
  /// [vehicleNum] vehicle registration number (e.g. 'KA01AB1234').
  static Map<String, dynamic> buildEWayBillPayload(
    EInvoiceRequest req,
    String transMode,
    String vehicleNum,
  ) {
    return {
      'supplyType': req.tranDtls.supTyp,
      'docType': req.docDtls.typ,
      'docNo': req.docDtls.no,
      'docDate': _formatDate(req.docDtls.dt),
      'fromGstin': req.sellerDtls.gstin,
      'fromPincode': req.sellerDtls.pincode,
      'toGstin': req.buyerDtls.gstin,
      'toPincode': req.buyerDtls.pincode,
      'totInvValue': req.valDtls.totInvVal,
      'transMode': transMode,
      'vehicleNo': vehicleNum,
    };
  }

  /// Returns the distance in km between [fromPincode] and [toPincode].
  ///
  /// This is a mock implementation that always returns 100 km.
  /// Replace with a real distance lookup when the API is available.
  static int computeDistance(String fromPincode, String toPincode) =>
      _mockDistanceKm;

  // ── Private helpers ───────────────────────────────────────────────────

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
