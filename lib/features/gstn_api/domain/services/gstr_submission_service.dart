import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Result models
// ---------------------------------------------------------------------------

/// Filing status of a GST return on the GSTN portal.
enum GstrFilingStatusCode {
  notFiled(label: 'Not Filed', code: 'NF'),
  saved(label: 'Saved', code: 'SAV'),
  submitted(label: 'Submitted', code: 'SUB'),
  filed(label: 'Filed', code: 'FIL'),
  processed(label: 'Processed', code: 'PRO'),
  rejected(label: 'Rejected', code: 'REJ');

  const GstrFilingStatusCode({required this.label, required this.code});

  final String label;
  final String code;

  static GstrFilingStatusCode fromCode(String code) {
    switch (code.toUpperCase().trim()) {
      case 'SAV':
        return GstrFilingStatusCode.saved;
      case 'SUB':
        return GstrFilingStatusCode.submitted;
      case 'FIL':
      case 'CNF':
        return GstrFilingStatusCode.filed;
      case 'PRO':
        return GstrFilingStatusCode.processed;
      case 'REJ':
        return GstrFilingStatusCode.rejected;
      default:
        return GstrFilingStatusCode.notFiled;
    }
  }
}

/// Result of saving a draft GSTR-1 payload.
@immutable
class GstrSaveResult {
  const GstrSaveResult({
    required this.gstin,
    required this.period,
    required this.returnType,
    required this.success,
    this.referenceId,
    this.errorMessage,
  });

  final String gstin;
  final String period;
  final String returnType;
  final bool success;

  /// Reference ID returned by GSTN on successful save.
  final String? referenceId;

  /// Error description when [success] is false.
  final String? errorMessage;

  GstrSaveResult copyWith({
    String? gstin,
    String? period,
    String? returnType,
    bool? success,
    String? referenceId,
    String? errorMessage,
  }) {
    return GstrSaveResult(
      gstin: gstin ?? this.gstin,
      period: period ?? this.period,
      returnType: returnType ?? this.returnType,
      success: success ?? this.success,
      referenceId: referenceId ?? this.referenceId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstrSaveResult &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          period == other.period &&
          returnType == other.returnType &&
          success == other.success;

  @override
  int get hashCode => Object.hash(gstin, period, returnType, success);
}

/// Result of submitting a saved GSTR-1 return (locks it for filing).
@immutable
class GstrSubmitResult {
  const GstrSubmitResult({
    required this.gstin,
    required this.period,
    required this.returnType,
    required this.success,
    this.submissionToken,
    this.errorMessage,
  });

  final String gstin;
  final String period;
  final String returnType;
  final bool success;

  /// Token required for the subsequent EVC filing step.
  final String? submissionToken;

  final String? errorMessage;

  GstrSubmitResult copyWith({
    String? gstin,
    String? period,
    String? returnType,
    bool? success,
    String? submissionToken,
    String? errorMessage,
  }) {
    return GstrSubmitResult(
      gstin: gstin ?? this.gstin,
      period: period ?? this.period,
      returnType: returnType ?? this.returnType,
      success: success ?? this.success,
      submissionToken: submissionToken ?? this.submissionToken,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstrSubmitResult &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          period == other.period &&
          success == other.success;

  @override
  int get hashCode => Object.hash(gstin, period, success);
}

/// Result of filing a GSTR-1 return using an EVC OTP.
@immutable
class GstrFileResult {
  const GstrFileResult({
    required this.gstin,
    required this.period,
    required this.returnType,
    required this.success,
    this.arn,
    this.filedAt,
    this.errorMessage,
  });

  final String gstin;
  final String period;
  final String returnType;
  final bool success;

  /// Acknowledgement Reference Number assigned after successful filing.
  final String? arn;

  /// Timestamp when the return was filed.
  final DateTime? filedAt;

  final String? errorMessage;

  GstrFileResult copyWith({
    String? gstin,
    String? period,
    String? returnType,
    bool? success,
    String? arn,
    DateTime? filedAt,
    String? errorMessage,
  }) {
    return GstrFileResult(
      gstin: gstin ?? this.gstin,
      period: period ?? this.period,
      returnType: returnType ?? this.returnType,
      success: success ?? this.success,
      arn: arn ?? this.arn,
      filedAt: filedAt ?? this.filedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstrFileResult &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          period == other.period &&
          success == other.success;

  @override
  int get hashCode => Object.hash(gstin, period, success);
}

/// Current status of a GST return filing.
@immutable
class GstrFilingStatus {
  const GstrFilingStatus({
    required this.gstin,
    required this.period,
    required this.returnType,
    required this.statusCode,
    this.arn,
    this.filedAt,
    this.lastUpdatedAt,
  });

  final String gstin;
  final String period;
  final String returnType;
  final GstrFilingStatusCode statusCode;

  /// Acknowledgement Reference Number; non-null once [statusCode] is filed.
  final String? arn;

  /// Filing timestamp; non-null once [statusCode] is filed.
  final DateTime? filedAt;

  /// Timestamp when the status was last retrieved from the portal.
  final DateTime? lastUpdatedAt;

  bool get isFiled =>
      statusCode == GstrFilingStatusCode.filed ||
      statusCode == GstrFilingStatusCode.processed;

  GstrFilingStatus copyWith({
    String? gstin,
    String? period,
    String? returnType,
    GstrFilingStatusCode? statusCode,
    String? arn,
    DateTime? filedAt,
    DateTime? lastUpdatedAt,
  }) {
    return GstrFilingStatus(
      gstin: gstin ?? this.gstin,
      period: period ?? this.period,
      returnType: returnType ?? this.returnType,
      statusCode: statusCode ?? this.statusCode,
      arn: arn ?? this.arn,
      filedAt: filedAt ?? this.filedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstrFilingStatus &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          period == other.period &&
          returnType == other.returnType &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(gstin, period, returnType, statusCode);
}

// ---------------------------------------------------------------------------
// Abstract service interface
// ---------------------------------------------------------------------------

/// Abstract interface for GSTR submission operations.
///
/// Implementations:
/// - [MockGstrSubmissionService] — deterministic in-memory mock.
/// - A real HTTP implementation (future work) that wraps [GstnApiService].
///
/// Filing flow: save → submit → fileWithEvc
abstract class GstrSubmissionService {
  /// Saves a GSTR-1 draft payload to the GSTN portal.
  ///
  /// - [gstin]   — 15-character GSTIN
  /// - [period]  — Tax period in MMYYYY format (e.g. "032024")
  /// - [payload] — GSTR-1 structured data as a map
  Future<GstrSaveResult> saveGstr1(
    String gstin,
    String period,
    Map<String, Object?> payload,
  );

  /// Submits (locks) a previously saved GSTR-1, preventing further edits.
  ///
  /// Must be called after [saveGstr1] succeeds.
  Future<GstrSubmitResult> submitGstr1(String gstin, String period);

  /// Files a submitted GSTR-1 using an EVC (electronic verification code).
  ///
  /// - [otp] — 6-digit OTP received via SMS / email
  ///
  /// Returns an [GstrFileResult] with the ARN on success.
  Future<GstrFileResult> fileGstr1WithEvc(
    String gstin,
    String period,
    String otp,
  );

  /// Retrieves the current filing status for any return type.
  ///
  /// - [returnType] — e.g. "GSTR1", "GSTR3B", "GSTR9"
  Future<GstrFilingStatus> getFilingStatus(
    String gstin,
    String period,
    String returnType,
  );
}

// ---------------------------------------------------------------------------
// Mock implementation
// ---------------------------------------------------------------------------

/// Deterministic in-memory mock implementation of [GstrSubmissionService].
///
/// Behaviour contract:
/// - [saveGstr1]: always succeeds with a generated reference ID.
/// - [submitGstr1]: always succeeds with a submission token.
/// - [fileGstr1WithEvc]: always succeeds with a generated ARN.
/// - [getFilingStatus]: returns [GstrFilingStatusCode.filed] for any input.
///
/// No network calls are made.
class MockGstrSubmissionService implements GstrSubmissionService {
  const MockGstrSubmissionService();

  @override
  Future<GstrSaveResult> saveGstr1(
    String gstin,
    String period,
    Map<String, Object?> payload,
  ) {
    return Future.value(
      GstrSaveResult(
        gstin: gstin,
        period: period,
        returnType: 'GSTR1',
        success: true,
        referenceId: 'MOCK-SAV-$gstin-$period',
      ),
    );
  }

  @override
  Future<GstrSubmitResult> submitGstr1(String gstin, String period) {
    return Future.value(
      GstrSubmitResult(
        gstin: gstin,
        period: period,
        returnType: 'GSTR1',
        success: true,
        submissionToken: 'MOCK-TOK-$gstin-$period',
      ),
    );
  }

  @override
  Future<GstrFileResult> fileGstr1WithEvc(
    String gstin,
    String period,
    String otp,
  ) {
    final arn =
        'AA${gstin.substring(0, 2)}$period${DateTime.now().millisecondsSinceEpoch}';
    return Future.value(
      GstrFileResult(
        gstin: gstin,
        period: period,
        returnType: 'GSTR1',
        success: true,
        arn: arn,
        filedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<GstrFilingStatus> getFilingStatus(
    String gstin,
    String period,
    String returnType,
  ) {
    return Future.value(
      GstrFilingStatus(
        gstin: gstin,
        period: period,
        returnType: returnType,
        statusCode: GstrFilingStatusCode.filed,
        arn: 'MOCK-ARN-$gstin-$period',
        filedAt: DateTime(2024, 8, 20),
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }
}
