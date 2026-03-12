import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';

/// Stateless serializer that converts [Gstr3bFormData] to GSTN API v3.0 JSON.
///
/// Produces the standard GSTN portal JSON format for GSTR-3B upload.
/// All amount fields are formatted as strings with 2 decimal places.
///
/// JSON structure mirrors the GSTN API v3.0 spec:
/// - `sup_details`: Table 3.1 outward supply and RCM liability sections.
/// - `itc_elg`: Table 4 ITC available, reversed, and net amounts.
/// - `intr_ltfee`: Interest and late fee (defaulted to zero).
class Gstr3bJsonSerializer {
  Gstr3bJsonSerializer._();

  static final Gstr3bJsonSerializer instance = Gstr3bJsonSerializer._();

  /// Serializes a GSTR-3B form into a GSTN API v3.0 [GstrExportResult].
  ///
  /// [data] – the summary tax return data for the period.
  /// [gstin] – GSTIN of the filing taxpayer.
  /// [period] – filing period in MMYYYY format, e.g. "032024".
  GstrExportResult serialize(
    Gstr3bFormData data,
    String gstin,
    String period,
  ) {
    final payload = <String, Object?>{
      'gstin': gstin,
      'ret_period': period,
      'sup_details': _buildSupDetails(data.taxLiability),
      'itc_elg': _buildItcElg(data.itcClaimed),
      'intr_ltfee': _buildIntrLtfee(),
    };

    return GstrExportResult(
      returnType: GstrReturnType.gstr3b,
      gstin: gstin,
      period: period,
      jsonPayload: jsonEncode(payload),
      sectionCount: 3,
      exportedAt: DateTime.now(),
      validationErrors: const [],
    );
  }

  // ---------------------------------------------------------------------------
  // Section builders
  // ---------------------------------------------------------------------------

  Map<String, Object?> _buildSupDetails(Gstr3bTaxLiability liability) {
    return {
      'osup_det': _taxRowToJson(liability.outwardTaxable),
      'osup_zero': _taxRowToJson(liability.outwardZeroRated),
      'osup_nil_exmp': {
        'txval': _fmt(
          liability.otherOutward.igst +
          liability.otherOutward.cgst +
          liability.otherOutward.sgst +
          liability.otherOutward.cess,
        ),
      },
      'isup_rev': _taxRowToJson(liability.inwardRcm),
      'osup_det_non_gst': {
        'txval': _fmt(
          liability.nonGstOutward.igst +
          liability.nonGstOutward.cgst +
          liability.nonGstOutward.sgst +
          liability.nonGstOutward.cess,
        ),
      },
    };
  }

  Map<String, Object?> _taxRowToJson(Gstr3bTaxRow row) {
    return {
      'txval': _fmt(row.igst + row.cgst + row.sgst + row.cess),
      'iamt': _fmt(row.igst),
      'camt': _fmt(row.cgst),
      'samt': _fmt(row.sgst),
      'csamt': _fmt(row.cess),
    };
  }

  Map<String, Object?> _buildItcElg(Gstr3bItcClaimed itc) {
    return {
      'itc_avl': _buildItcAvl(itc),
      'itc_rev': _buildItcRev(itc),
      'itc_net': _itcRowToJson(itc.netItcAvailable),
      'itc_inelg': _buildItcInelg(itc),
    };
  }

  List<Map<String, Object?>> _buildItcAvl(Gstr3bItcClaimed itc) {
    return [
      {'ty': 'IMPG', ..._itcRowToJson(itc.importGoods)},
      {'ty': 'IMPS', ..._itcRowToJson(itc.importServices)},
      {'ty': 'ISRC', ..._itcRowToJson(itc.inwardRcm)},
      {'ty': 'ISD', ..._itcRowToJson(itc.isd)},
      {'ty': 'OTH', ..._itcRowToJson(itc.otherItc)},
    ];
  }

  List<Map<String, Object?>> _buildItcRev(Gstr3bItcClaimed itc) {
    return [
      {'ty': 'RUL', ..._itcRowToJson(itc.reversedSection17_5)},
      {'ty': 'OTH', ..._itcRowToJson(itc.reversedOthers)},
    ];
  }

  List<Map<String, Object?>> _buildItcInelg(Gstr3bItcClaimed itc) {
    return [
      {'ty': 'RUL', ..._itcRowToJson(itc.ineligibleRule38)},
      {'ty': 'OTH', ..._itcRowToJson(itc.ineligibleOthers)},
    ];
  }

  Map<String, Object?> _itcRowToJson(ItcRow row) {
    return {
      'iamt': _fmt(row.igst),
      'camt': _fmt(row.cgst),
      'samt': _fmt(row.sgst),
      'csamt': _fmt(row.cess),
    };
  }

  Map<String, Object?> _buildIntrLtfee() {
    return {
      'intr_details': {
        'iamt': _fmt(0),
        'camt': _fmt(0),
        'samt': _fmt(0),
        'csamt': _fmt(0),
      },
      'ltfee_details': {
        'iamt': _fmt(0),
        'camt': _fmt(0),
        'samt': _fmt(0),
        'csamt': _fmt(0),
      },
    };
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  /// Formats a [double] amount as a 2-decimal String (GSTN API convention).
  String _fmt(double amount) => amount.toStringAsFixed(2);
}
