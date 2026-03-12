import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';
import 'package:ca_app/features/portal_parser/models/gstr2b_data.dart';

/// Stateless singleton parser for GSTR-2B JSON files downloaded from the GST
/// portal.
///
/// All credit amounts in the returned models are in **paise**
/// (input rupee values are multiplied by 100).
class Gstr2bParser {
  Gstr2bParser._();

  static final Gstr2bParser instance = Gstr2bParser._();

  // --------------- public API ---------------

  /// Parses [jsonContent] (GSTR-2B portal JSON) into [Gstr2bData].
  ///
  /// Expected top-level structure:
  /// ```json
  /// {
  ///   "data": {
  ///     "gstin": "...",
  ///     "rtnprd": "...",
  ///     "docdata": {
  ///       "b2b": [
  ///         {
  ///           "ctin": "...",
  ///           "trdnm": "...",
  ///           "inv": [...]
  ///         }
  ///       ]
  ///     }
  ///   }
  /// }
  /// ```
  Gstr2bData parseJson(String jsonContent) {
    final root = jsonDecode(jsonContent) as Map<String, Object?>;
    final data = root['data'] as Map<String, Object?>? ?? {};

    final gstin = (data['gstin'] as String?) ?? '';
    final returnPeriod = (data['rtnprd'] as String?) ?? '';
    final docdata = data['docdata'] as Map<String, Object?>? ?? {};

    final b2bSuppliers = docdata['b2b'] as List<Object?>? ?? [];

    final entries = _parseB2bEntries(b2bSuppliers);

    final totalIgst = entries.fold<int>(
      0,
      (sum, e) => sum + (e.igst * 100).round(),
    );
    final totalCgst = entries.fold<int>(
      0,
      (sum, e) => sum + (e.cgst * 100).round(),
    );
    final totalSgst = entries.fold<int>(
      0,
      (sum, e) => sum + (e.sgst * 100).round(),
    );

    return Gstr2bData(
      gstin: gstin,
      returnPeriod: returnPeriod,
      b2bEntries: entries,
      totalIgstCredit: totalIgst,
      totalCgstCredit: totalCgst,
      totalSgstCredit: totalSgst,
    );
  }

  // --------------- private helpers ---------------

  List<Gstr2bEntry> _parseB2bEntries(List<Object?> suppliers) {
    final entries = <Gstr2bEntry>[];
    for (final supplier in suppliers) {
      if (supplier is! Map<String, Object?>) continue;
      final gstin = (supplier['ctin'] as String?) ?? '';
      final name = (supplier['trdnm'] as String?) ?? '';
      final invoices = supplier['inv'] as List<Object?>? ?? [];
      for (final inv in invoices) {
        if (inv is! Map<String, Object?>) continue;
        entries.add(_mapToGstr2bEntry(gstin, name, inv));
      }
    }
    return entries;
  }

  Gstr2bEntry _mapToGstr2bEntry(
    String supplierGstin,
    String supplierName,
    Map<String, Object?> inv,
  ) {
    final invoiceNumber = (inv['inum'] as String?) ?? '';
    final dateStr = (inv['idt'] as String?) ?? '';
    final invoiceValue = _toDouble(inv['val']);
    final taxableValue = _toDouble(inv['taxval']);
    final igst = _toDouble(inv['igst']);
    final cgst = _toDouble(inv['cgst']);
    final sgst = _toDouble(inv['sgst']);
    final cess = _toDouble(inv['cess']);
    final placeOfSupply = (inv['pos'] as String?) ?? '';
    final rchrgStr = (inv['rchrg'] as String?) ?? 'N';
    final itcAvlStr = (inv['itcavl'] as String?) ?? 'Y';

    return Gstr2bEntry(
      supplierGstin: supplierGstin,
      supplierName: supplierName,
      invoiceNumber: invoiceNumber,
      invoiceDate: _parseDdMmYyyy(dateStr) ?? DateTime(1970),
      invoiceValue: invoiceValue,
      taxableValue: taxableValue,
      igst: igst,
      cgst: cgst,
      sgst: sgst,
      cess: cess,
      placeOfSupply: placeOfSupply,
      reverseCharge: rchrgStr.toUpperCase() == 'Y',
      itcAvailable: _parseItcAvailability(itcAvlStr),
    );
  }

  ItcAvailability _parseItcAvailability(String code) {
    switch (code.toUpperCase()) {
      case 'Y':
        return ItcAvailability.yes;
      case 'N':
        return ItcAvailability.no;
      default:
        return ItcAvailability.partial;
    }
  }

  DateTime? _parseDdMmYyyy(String dateStr) {
    if (dateStr.isEmpty) return null;
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
