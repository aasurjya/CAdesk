import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';

/// Stateless serializer that converts [Gstr1FormData] to GSTN API v3.0 JSON.
///
/// Produces the standard GSTN portal JSON format for GSTR-1 upload.
/// All amount fields are formatted as strings with 2 decimal places.
/// Sections are only emitted when they contain at least one entry.
class Gstr1JsonSerializer {
  Gstr1JsonSerializer._();

  static final Gstr1JsonSerializer instance = Gstr1JsonSerializer._();

  /// Serializes a GSTR-1 form into a GSTN API v3.0 [GstrExportResult].
  ///
  /// [data] – the classified invoice data for the return period.
  /// [gstin] – GSTIN of the filing taxpayer (overrides data.gstin for the
  ///   output field, keeping the caller in control of portal identity).
  /// [period] – filing period in MMYYYY format, e.g. "032024".
  GstrExportResult serialize(
    Gstr1FormData data,
    String gstin,
    String period,
  ) {
    final payload = <String, Object?>{
      'gstin': gstin,
      'fp': period,
    };

    var sectionCount = 0;

    final b2b = _buildB2b(data.b2bInvoices);
    if (b2b.isNotEmpty) {
      payload['b2b'] = b2b;
      sectionCount++;
    }

    final b2csEntries = data.b2cInvoices
        .where((i) => i.category == B2cCategory.small)
        .toList();
    if (b2csEntries.isNotEmpty) {
      payload['b2cs'] = _buildB2cs(b2csEntries);
      sectionCount++;
    }

    final b2clEntries = data.b2cInvoices
        .where((i) => i.category == B2cCategory.large)
        .toList();
    if (b2clEntries.isNotEmpty) {
      payload['b2cl'] = _buildB2cl(b2clEntries);
      sectionCount++;
    }

    if (data.creditDebitNotes.isNotEmpty) {
      payload['cdnr'] = _buildCdnr(data.creditDebitNotes);
      sectionCount++;
    }

    if (data.exports.isNotEmpty) {
      payload['exp'] = _buildExp(data.exports);
      sectionCount++;
    }

    return GstrExportResult(
      returnType: GstrReturnType.gstr1,
      gstin: gstin,
      period: period,
      jsonPayload: jsonEncode(payload),
      sectionCount: sectionCount,
      exportedAt: DateTime.now(),
      validationErrors: const [],
    );
  }

  // ---------------------------------------------------------------------------
  // Section builders
  // ---------------------------------------------------------------------------

  List<Map<String, Object?>> _buildB2b(List<Gstr1B2bInvoice> invoices) {
    // Group by recipient GSTIN
    final grouped = <String, List<Gstr1B2bInvoice>>{};
    for (final inv in invoices) {
      (grouped[inv.recipientGstin] ??= []).add(inv);
    }

    return grouped.entries.map((entry) {
      return {
        'ctin': entry.key,
        'inv': entry.value.map(_invoiceToB2bJson).toList(),
      };
    }).toList();
  }

  Map<String, Object?> _invoiceToB2bJson(Gstr1B2bInvoice inv) {
    return {
      'inum': inv.invoiceNumber,
      'idt': _formatDate(inv.invoiceDate),
      'val': _fmt(inv.invoiceValue),
      'pos': inv.placeOfSupply,
      'rchrg': inv.reverseCharge ? 'Y' : 'N',
      'itms': [
        {
          'num': 1,
          'itm_det': {
            'txval': _fmt(inv.taxableValue),
            'rt': inv.gstRate,
            'iamt': _fmt(inv.igst),
            'camt': _fmt(inv.cgst),
            'samt': _fmt(inv.sgst),
            'csamt': _fmt(inv.cess),
          },
        },
      ],
    };
  }

  List<Map<String, Object?>> _buildB2cs(List<Gstr1B2cInvoice> invoices) {
    return invoices.map((inv) {
      return {
        'typ': 'OE',
        'pos': inv.placeOfSupply,
        'rt': inv.gstRate,
        'txval': _fmt(inv.taxableValue),
        'iamt': _fmt(inv.igst),
        'camt': _fmt(inv.cgst),
        'samt': _fmt(inv.sgst),
        'csamt': _fmt(inv.cess),
      };
    }).toList();
  }

  List<Map<String, Object?>> _buildB2cl(List<Gstr1B2cInvoice> invoices) {
    // Group by place of supply
    final grouped = <String, List<Gstr1B2cInvoice>>{};
    for (final inv in invoices) {
      (grouped[inv.placeOfSupply] ??= []).add(inv);
    }

    return grouped.entries.map((entry) {
      return <String, Object?>{
        'pos': entry.key,
        'inv': entry.value.map(_invoiceToB2clJson).toList(),
      };
    }).toList();
  }

  Map<String, Object?> _invoiceToB2clJson(Gstr1B2cInvoice inv) {
    return {
      'inum': inv.invoiceNumber,
      'idt': _formatDate(inv.invoiceDate),
      'val': _fmt(inv.invoiceValue),
      'itms': [
        {
          'num': 1,
          'itm_det': {
            'txval': _fmt(inv.taxableValue),
            'rt': inv.gstRate,
            'iamt': _fmt(inv.igst),
            'csamt': _fmt(inv.cess),
          },
        },
      ],
    };
  }

  List<Map<String, Object?>> _buildCdnr(List<Gstr1Cdnr> notes) {
    // Group by recipient GSTIN
    final grouped = <String, List<Gstr1Cdnr>>{};
    for (final note in notes) {
      (grouped[note.recipientGstin] ??= []).add(note);
    }

    return grouped.entries.map((entry) {
      return {
        'ctin': entry.key,
        'nt': entry.value.map(_noteToJson).toList(),
      };
    }).toList();
  }

  Map<String, Object?> _noteToJson(Gstr1Cdnr note) {
    final noteTypeCode = note.noteType == CdnrNoteType.creditNote ? 'C' : 'D';
    return {
      'ntNum': note.noteNumber,
      'ntDt': _formatDate(note.noteDate),
      'ntty': noteTypeCode,
      'val': _fmt(note.noteValue),
      'pos': note.placeOfSupply,
      'rchrg': 'N',
      'itms': [
        {
          'num': 1,
          'itm_det': {
            'txval': _fmt(note.taxableValue),
            'rt': note.gstRate,
            'iamt': _fmt(note.igst),
            'camt': _fmt(note.cgst),
            'samt': _fmt(note.sgst),
            'csamt': _fmt(note.cess),
          },
        },
      ],
    };
  }

  List<Map<String, Object?>> _buildExp(List<Gstr1Exp> exports) {
    // Group by export type
    final grouped = <String, List<Gstr1Exp>>{};
    for (final exp in exports) {
      (grouped[exp.exportType.label] ??= []).add(exp);
    }

    return grouped.entries.map((entry) {
      return <String, Object?>{
        'expTyp': entry.key,
        'inv': entry.value.map(_expInvoiceToJson).toList(),
      };
    }).toList();
  }

  Map<String, Object?> _expInvoiceToJson(Gstr1Exp exp) {
    final json = <String, Object?>{
      'inum': exp.invoiceNumber,
      'idt': _formatDate(exp.invoiceDate),
      'val': _fmt(exp.invoiceValue),
      'fc': _fmt(exp.foreignCurrencyValue),
      'cur': exp.currencyCode,
      'itms': [
        {
          'txval': _fmt(exp.taxableValue),
          'rt': exp.gstRate,
          'iamt': _fmt(exp.igst),
          'csamt': _fmt(exp.cess),
        },
      ],
    };
    if (exp.shippingBillNumber != null) {
      json['sbNum'] = exp.shippingBillNumber;
    }
    if (exp.shippingBillDate != null) {
      json['sbDt'] = _formatDate(exp.shippingBillDate!);
    }
    if (exp.portCode != null) {
      json['pCode'] = exp.portCode;
    }
    return json;
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  /// Formats a [double] amount as a 2-decimal String (GSTN API convention).
  String _fmt(double amount) => amount.toStringAsFixed(2);

  /// Formats a [DateTime] as "DD-MM-YYYY" (GSTN API date format).
  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd-$mm-${date.year}';
  }
}
