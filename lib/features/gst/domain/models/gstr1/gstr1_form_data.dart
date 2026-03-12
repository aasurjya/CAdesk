import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_at.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnur.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';

/// Immutable top-level aggregator for a GSTR-1 return.
///
/// Holds all table-wise classified invoice data for a single filing period.
/// Provides aggregate totals across all tables for validation and submission.
class Gstr1FormData {
  const Gstr1FormData({
    required this.gstin,
    required this.periodMonth,
    required this.periodYear,
    required this.b2bInvoices,
    required this.b2cInvoices,
    required this.creditDebitNotes,
    required this.creditDebitNotesUnregistered,
    required this.exports,
    required this.advanceTax,
  });

  /// GSTIN of the registered taxpayer filing this return.
  final String gstin;

  /// Tax period month (1–12).
  final int periodMonth;

  /// Tax period year.
  final int periodYear;

  /// Table 4A: B2B taxable supplies to registered recipients.
  final List<Gstr1B2bInvoice> b2bInvoices;

  /// Tables 5A/5B: Supplies to unregistered recipients (B2CL + B2CS).
  final List<Gstr1B2cInvoice> b2cInvoices;

  /// Table 9B: Credit/debit notes to registered recipients (CDNR).
  final List<Gstr1Cdnr> creditDebitNotes;

  /// Table 9C: Credit/debit notes to unregistered recipients (CDNUR).
  final List<Gstr1Cdnur> creditDebitNotesUnregistered;

  /// Tables 6B/6C: Exports with/without payment of IGST.
  final List<Gstr1Exp> exports;

  /// Table 11A: Tax liability on advances received.
  final List<Gstr1At> advanceTax;

  /// Human-readable period label (e.g. 'Jan 2026').
  String get periodLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[periodMonth - 1]} $periodYear';
  }

  /// Sum of all taxable values across all tables.
  double get totalTaxableValue {
    var total = 0.0;
    for (final inv in b2bInvoices) {
      total += inv.taxableValue;
    }
    for (final inv in b2cInvoices) {
      total += inv.taxableValue;
    }
    for (final exp in exports) {
      total += exp.taxableValue;
    }
    for (final at in advanceTax) {
      total += at.advanceAmount;
    }
    return total;
  }

  /// Sum of all IGST across all tables.
  double get totalIgst {
    var total = 0.0;
    for (final inv in b2bInvoices) {
      total += inv.igst;
    }
    for (final inv in b2cInvoices) {
      total += inv.igst;
    }
    for (final exp in exports) {
      total += exp.igst;
    }
    for (final at in advanceTax) {
      total += at.igst;
    }
    return total;
  }

  /// Sum of all CGST across all tables.
  double get totalCgst {
    var total = 0.0;
    for (final inv in b2bInvoices) {
      total += inv.cgst;
    }
    for (final inv in b2cInvoices) {
      total += inv.cgst;
    }
    for (final at in advanceTax) {
      total += at.cgst;
    }
    return total;
  }

  /// Sum of all SGST across all tables.
  double get totalSgst {
    var total = 0.0;
    for (final inv in b2bInvoices) {
      total += inv.sgst;
    }
    for (final inv in b2cInvoices) {
      total += inv.sgst;
    }
    for (final at in advanceTax) {
      total += at.sgst;
    }
    return total;
  }

  /// Sum of all CESS across all tables.
  double get totalCess {
    var total = 0.0;
    for (final inv in b2bInvoices) {
      total += inv.cess;
    }
    for (final inv in b2cInvoices) {
      total += inv.cess;
    }
    for (final exp in exports) {
      total += exp.cess;
    }
    for (final at in advanceTax) {
      total += at.cess;
    }
    return total;
  }

  Gstr1FormData copyWith({
    String? gstin,
    int? periodMonth,
    int? periodYear,
    List<Gstr1B2bInvoice>? b2bInvoices,
    List<Gstr1B2cInvoice>? b2cInvoices,
    List<Gstr1Cdnr>? creditDebitNotes,
    List<Gstr1Cdnur>? creditDebitNotesUnregistered,
    List<Gstr1Exp>? exports,
    List<Gstr1At>? advanceTax,
  }) {
    return Gstr1FormData(
      gstin: gstin ?? this.gstin,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      b2bInvoices: b2bInvoices ?? this.b2bInvoices,
      b2cInvoices: b2cInvoices ?? this.b2cInvoices,
      creditDebitNotes: creditDebitNotes ?? this.creditDebitNotes,
      creditDebitNotesUnregistered:
          creditDebitNotesUnregistered ?? this.creditDebitNotesUnregistered,
      exports: exports ?? this.exports,
      advanceTax: advanceTax ?? this.advanceTax,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr1FormData &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          periodMonth == other.periodMonth &&
          periodYear == other.periodYear;

  @override
  int get hashCode => Object.hash(gstin, periodMonth, periodYear);
}
