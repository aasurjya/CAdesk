import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr1_export_service.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr2_export_service.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr_checksum_service.dart';

/// Stateless dispatcher that routes ITR form data to the appropriate
/// export service and produces an [ItrExportResult].
///
/// Supported form types:
/// - [Itr1FormData] → [Itr1ExportService]
/// - [Itr2FormData] → [Itr2ExportService]
///
/// Usage:
/// ```dart
/// final result = ItrExportEngine.export(formData, '2024-25');
/// ```
class ItrExportEngine {
  ItrExportEngine._();

  /// Exports [itrFormData] for [assessmentYear] using the appropriate service.
  ///
  /// Throws [ArgumentError] if [itrFormData] is not a supported form type.
  static ItrExportResult export(Object itrFormData, String assessmentYear) {
    switch (itrFormData) {
      case final Itr1FormData data:
        return Itr1ExportService.export(data, assessmentYear);
      case final Itr2FormData data:
        return Itr2ExportService.export(data, assessmentYear);
      default:
        throw ArgumentError(
          'Unsupported ITR form data type: ${itrFormData.runtimeType}. '
          'Supported types: Itr1FormData, Itr2FormData.',
        );
    }
  }

  /// Detects the [ItrType] from the runtime type of [formData].
  ///
  /// Throws [ArgumentError] if [formData] is not a recognised ITR form type.
  static ItrType detectItrType(Object formData) {
    if (formData is Itr1FormData) return ItrType.itr1;
    if (formData is Itr2FormData) return ItrType.itr2;
    throw ArgumentError(
      'Cannot detect ITR type for ${formData.runtimeType}.',
    );
  }

  /// Computes the SHA-256 hex checksum of [jsonPayload].
  ///
  /// Delegates to [ItrChecksumService.computeSha256].
  static String computeChecksum(String jsonPayload) =>
      ItrChecksumService.computeSha256(jsonPayload);
}
