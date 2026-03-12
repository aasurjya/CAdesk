import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';

/// Static service that builds GSTR-3B form data from outward invoices
/// and inward ITC entries (from GSTR-2B).
///
/// GSTR-3B population logic:
///
/// **Table 3.1 (Outward Tax Liability):**
/// - 3.1(a): Non-RCM, non-export taxable supplies
/// - 3.1(b): Export/SEZ supplies (zero-rated)
/// - 3.1(d): Inward supplies on which RCM is payable
///
/// **Table 4 (ITC):**
/// - 4(A)(3): RCM ITC entries from GSTR-2B
/// - 4(A)(5): All other eligible ITC entries from GSTR-2B
///
/// Usage:
/// ```dart
/// final gstr3b = Gstr3bBuilderService.build(
///   gstin: '27AABCU9603R1ZM',
///   periodMonth: 1,
///   periodYear: 2026,
///   outwardInvoices: invoiceList,
///   itcEntries: gstr2bEntries,
/// );
/// ```
class Gstr3bBuilderService {
  Gstr3bBuilderService._();

  /// Builds a [Gstr3bFormData] from the provided invoices and ITC entries.
  ///
  /// [outwardInvoices]: outward supply invoices issued by the taxpayer.
  /// [itcEntries]: inward ITC entries pulled from GSTR-2B.
  /// [exemptSupplies]: pre-computed exempt/nil-rated/non-GST figures;
  ///   defaults to all-zero if not provided.
  static Gstr3bFormData build({
    required String gstin,
    required int periodMonth,
    required int periodYear,
    required List<GstInvoice> outwardInvoices,
    required List<Gstr2bEntry> itcEntries,
    Gstr3bExemptSupplies? exemptSupplies,
  }) {
    final taxLiability = _buildTaxLiability(outwardInvoices);
    final itcClaimed = _buildItcClaimed(itcEntries);
    final exempt =
        exemptSupplies ??
        const Gstr3bExemptSupplies(
          interStateExempt: 0,
          intraStateExempt: 0,
          interStateNilRated: 0,
          intraStateNilRated: 0,
          interStateNonGst: 0,
          intraStateNonGst: 0,
        );

    return Gstr3bFormData(
      gstin: gstin,
      periodMonth: periodMonth,
      periodYear: periodYear,
      taxLiability: taxLiability,
      itcClaimed: itcClaimed,
      exemptSupplies: exempt,
    );
  }

  /// Builds Table 3.1 tax liability from outward invoices.
  static Gstr3bTaxLiability _buildTaxLiability(List<GstInvoice> invoices) {
    var outwardIgst = 0.0;
    var outwardCgst = 0.0;
    var outwardSgst = 0.0;
    var outwardCess = 0.0;

    var zeroRatedIgst = 0.0;
    var zeroRatedCgst = 0.0;
    var zeroRatedSgst = 0.0;
    var zeroRatedCess = 0.0;

    var rcmIgst = 0.0;
    var rcmCgst = 0.0;
    var rcmSgst = 0.0;
    var rcmCess = 0.0;

    for (final invoice in invoices) {
      if (invoice.isExport) {
        // 3.1(b): Zero-rated exports.
        zeroRatedIgst += invoice.totalIgst;
        zeroRatedCgst += invoice.totalCgst;
        zeroRatedSgst += invoice.totalSgst;
        zeroRatedCess += invoice.totalCess;
      } else if (invoice.reverseCharge) {
        // 3.1(d): Inward RCM liability.
        rcmIgst += invoice.totalIgst;
        rcmCgst += invoice.totalCgst;
        rcmSgst += invoice.totalSgst;
        rcmCess += invoice.totalCess;
      } else {
        // 3.1(a): Regular outward taxable supplies.
        outwardIgst += invoice.totalIgst;
        outwardCgst += invoice.totalCgst;
        outwardSgst += invoice.totalSgst;
        outwardCess += invoice.totalCess;
      }
    }

    final zero = Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

    return Gstr3bTaxLiability(
      outwardTaxable: Gstr3bTaxRow(
        igst: outwardIgst,
        cgst: outwardCgst,
        sgst: outwardSgst,
        cess: outwardCess,
      ),
      outwardZeroRated: Gstr3bTaxRow(
        igst: zeroRatedIgst,
        cgst: zeroRatedCgst,
        sgst: zeroRatedSgst,
        cess: zeroRatedCess,
      ),
      otherOutward: zero,
      inwardRcm: Gstr3bTaxRow(
        igst: rcmIgst,
        cgst: rcmCgst,
        sgst: rcmSgst,
        cess: rcmCess,
      ),
      nonGstOutward: zero,
    );
  }

  /// Builds Table 4 ITC data from GSTR-2B inward entries.
  static Gstr3bItcClaimed _buildItcClaimed(List<Gstr2bEntry> entries) {
    var rcmIgst = 0.0;
    var rcmCgst = 0.0;
    var rcmSgst = 0.0;
    var rcmCess = 0.0;

    var otherIgst = 0.0;
    var otherCgst = 0.0;
    var otherSgst = 0.0;
    var otherCess = 0.0;

    for (final entry in entries) {
      if (entry.itcAvailable != ItcAvailability.yes) {
        continue;
      }

      if (entry.reverseCharge) {
        // 4(A)(3): Inward RCM ITC.
        rcmIgst += entry.igst;
        rcmCgst += entry.cgst;
        rcmSgst += entry.sgst;
        rcmCess += entry.cess;
      } else {
        // 4(A)(5): All other eligible ITC from GSTR-2B.
        otherIgst += entry.igst;
        otherCgst += entry.cgst;
        otherSgst += entry.sgst;
        otherCess += entry.cess;
      }
    }

    final zero = ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);
    final rcmRow = ItcRow(
      igst: rcmIgst,
      cgst: rcmCgst,
      sgst: rcmSgst,
      cess: rcmCess,
    );
    final otherRow = ItcRow(
      igst: otherIgst,
      cgst: otherCgst,
      sgst: otherSgst,
      cess: otherCess,
    );

    // Net ITC = sum of available rows (no reversals computed automatically;
    // reversals must be provided externally).
    final netIgst = rcmIgst + otherIgst;
    final netCgst = rcmCgst + otherCgst;
    final netSgst = rcmSgst + otherSgst;
    final netCess = rcmCess + otherCess;

    return Gstr3bItcClaimed(
      importGoods: zero,
      importServices: zero,
      inwardRcm: rcmRow,
      isd: zero,
      otherItc: otherRow,
      reversedSection17_5: zero,
      reversedOthers: zero,
      netItcAvailable: ItcRow(
        igst: netIgst,
        cgst: netCgst,
        sgst: netSgst,
        cess: netCess,
      ),
      ineligibleRule38: zero,
      ineligibleOthers: zero,
    );
  }
}
