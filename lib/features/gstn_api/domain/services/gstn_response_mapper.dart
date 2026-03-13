import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';

/// Maps raw GSTN API JSON responses to domain model instances.
///
/// All methods are pure functions — they do not mutate their inputs
/// and always return new model instances.
class GstnResponseMapper {
  /// Maps a filing-status JSON payload to [GstnFilingStatus].
  ///
  /// Expected keys: gstin, ret_period, status, arn (optional), dof (optional).
  /// Status code mapping: CNF → filed, SUB → submitted, SAV → saved, NF → notFiled.
  GstnFilingStatus mapFilingStatus(Map<String, dynamic> json) {
    final statusCode = json['status'] as String? ?? 'NF';
    final returnStatus = _mapStatusCode(statusCode);
    final arnValue = json['arn'] as String?;
    final dof = json['dof'] as String?;
    final filedAt = dof != null ? _parseDof(dof) : null;

    return GstnFilingStatus(
      gstin: json['gstin'] as String? ?? '',
      returnType: GstnReturnType.gstr1,
      period: json['ret_period'] as String? ?? '',
      status: returnStatus,
      arn: arnValue,
      filedAt: filedAt,
    );
  }

  /// Maps a GSTIN verification JSON payload to [GstnVerificationResult].
  ///
  /// Expects the GSTN API envelope with a nested `data` object.
  GstnVerificationResult mapVerification(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final sts = data['sts'] as String? ?? '';
    final dty = data['dty'] as String? ?? '';
    final rgdt = data['rgdt'] as String? ?? '01/01/2000';

    return GstnVerificationResult(
      gstin: data['gstnId'] as String? ?? '',
      legalName: data['lgnm'] as String? ?? '',
      tradeName: data['tradeNam'] as String?,
      registrationDate: _parseRegistrationDate(rgdt),
      status: _mapRegistrationStatus(sts),
      stateCode: data['stj'] as String? ?? '',
      constitutionType: data['ctj'] as String? ?? '',
      returnFilingFrequency: _mapFilingFrequency(dty),
    );
  }

  /// Maps a GSTR-2B JSON payload to [Gstr2bFetchResult].
  ///
  /// Monetary amounts are expected in paise (integer).
  Gstr2bFetchResult mapGstr2b(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'notGenerated';
    final genDate = json['gen_date'] as String?;

    return Gstr2bFetchResult(
      gstin: json['gstin'] as String? ?? '',
      period: json['period'] as String? ?? '',
      status: _mapGstr2bStatus(statusStr),
      totalIgstCredit: (json['igst'] as num?)?.toInt() ?? 0,
      totalCgstCredit: (json['cgst'] as num?)?.toInt() ?? 0,
      totalSgstCredit: (json['sgst'] as num?)?.toInt() ?? 0,
      entryCount: (json['entry_count'] as num?)?.toInt() ?? 0,
      generatedAt: genDate != null ? _parseDof(genDate) : null,
    );
  }

  /// Extracts the ARN field from a JSON payload.
  ///
  /// Returns null if the field is absent or explicitly null.
  String? extractArn(Map<String, dynamic> json) {
    return json['arn'] as String?;
  }

  /// Extracts the error code from a JSON payload.
  ///
  /// Returns null if the field is absent or explicitly null.
  String? extractErrorCode(Map<String, dynamic> json) {
    return json['error_code'] as String?;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  GstnReturnStatus _mapStatusCode(String code) {
    switch (code) {
      case 'CNF':
        return GstnReturnStatus.filed;
      case 'SUB':
        return GstnReturnStatus.submitted;
      case 'SAV':
        return GstnReturnStatus.saved;
      case 'NF':
        return GstnReturnStatus.notFiled;
      default:
        return GstnReturnStatus.notFiled;
    }
  }

  GstnRegistrationStatus _mapRegistrationStatus(String sts) {
    switch (sts.toLowerCase()) {
      case 'active':
        return GstnRegistrationStatus.active;
      case 'cancelled':
        return GstnRegistrationStatus.cancelled;
      case 'suspended':
        return GstnRegistrationStatus.suspended;
      default:
        return GstnRegistrationStatus.cancelled;
    }
  }

  ReturnFilingFrequency _mapFilingFrequency(String dty) {
    if (dty.toLowerCase().contains('composition') ||
        dty.toLowerCase().contains('quarterly')) {
      return ReturnFilingFrequency.quarterly;
    }
    return ReturnFilingFrequency.monthly;
  }

  Gstr2bStatus _mapGstr2bStatus(String status) {
    switch (status) {
      case 'generated':
        return Gstr2bStatus.generated;
      case 'notGenerated':
        return Gstr2bStatus.notGenerated;
      case 'processing':
        return Gstr2bStatus.processing;
      default:
        return Gstr2bStatus.notGenerated;
    }
  }

  /// Parses a date-of-filing string in "dd-MM-yyyy HH:mm:ss" format.
  DateTime _parseDof(String dof) {
    try {
      final parts = dof.split(' ');
      final dateParts = parts[0].split('-');
      final timeParts =
          parts.length > 1 ? parts[1].split(':') : ['0', '0', '0'];
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );
    } catch (_) {
      return DateTime(2000);
    }
  }

  /// Parses a registration date string in "dd/MM/yyyy" format.
  DateTime _parseRegistrationDate(String rgdt) {
    try {
      final parts = rgdt.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(2000);
    }
  }
}
