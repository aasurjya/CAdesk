import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr1_json_serializer.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr3b_json_serializer.dart';

/// Stateless batch exporter for bulk GSTN JSON export across multiple periods.
///
/// Delegates individual serialization to [Gstr1JsonSerializer] and
/// [Gstr3bJsonSerializer], converting each form's period fields into the
/// MMYYYY string expected by the GSTN API.
class GstrBatchExporter {
  GstrBatchExporter._();

  static final GstrBatchExporter instance = GstrBatchExporter._();

  /// Exports a list of GSTR-1 returns for the given [gstin].
  ///
  /// Each form's [Gstr1FormData.periodMonth] and [Gstr1FormData.periodYear]
  /// are used to derive the MMYYYY period string.
  ///
  /// Returns an unmodifiable list preserving the input order.
  List<GstrExportResult> exportBatch(
    List<Gstr1FormData> returns,
    String gstin,
  ) {
    final results = returns.map((form) {
      final period = _toPeriod(form.periodMonth, form.periodYear);
      return Gstr1JsonSerializer.instance.serialize(form, gstin, period);
    }).toList();

    return List.unmodifiable(results);
  }

  /// Exports a list of GSTR-3B returns for the given [gstin].
  ///
  /// Each form's [Gstr3bFormData.periodMonth] and [Gstr3bFormData.periodYear]
  /// are used to derive the MMYYYY period string.
  ///
  /// Returns an unmodifiable list preserving the input order.
  List<GstrExportResult> exportGstr3bBatch(
    List<Gstr3bFormData> returns,
    String gstin,
  ) {
    final results = returns.map((form) {
      final period = _toPeriod(form.periodMonth, form.periodYear);
      return Gstr3bJsonSerializer.instance.serialize(form, gstin, period);
    }).toList();

    return List.unmodifiable(results);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts an integer month (1–12) and year to MMYYYY string.
  String _toPeriod(int month, int year) {
    final mm = month.toString().padLeft(2, '0');
    return '$mm$year';
  }
}
