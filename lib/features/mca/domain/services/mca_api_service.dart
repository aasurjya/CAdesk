import 'package:flutter/foundation.dart';

import 'package:ca_app/features/mca/domain/models/company.dart';

// ---------------------------------------------------------------------------
// Result models
// ---------------------------------------------------------------------------

/// Full master data for a company as prefilled from the MCA portal.
@immutable
class CompanyMasterData {
  const CompanyMasterData({
    required this.cin,
    required this.companyName,
    required this.incorporationDate,
    required this.registeredAddress,
    required this.rocJurisdiction,
    required this.category,
    required this.status,
    required this.paidUpCapital,
    required this.authorisedCapital,
    required this.directors,
  });

  final String cin;
  final String companyName;
  final DateTime incorporationDate;
  final String registeredAddress;
  final String rocJurisdiction;
  final CompanyCategory category;
  final CompanyStatus status;

  /// Paid-up capital in Indian Rupees.
  final double paidUpCapital;

  /// Authorised capital in Indian Rupees.
  final double authorisedCapital;

  final List<Director> directors;

  CompanyMasterData copyWith({
    String? cin,
    String? companyName,
    DateTime? incorporationDate,
    String? registeredAddress,
    String? rocJurisdiction,
    CompanyCategory? category,
    CompanyStatus? status,
    double? paidUpCapital,
    double? authorisedCapital,
    List<Director>? directors,
  }) {
    return CompanyMasterData(
      cin: cin ?? this.cin,
      companyName: companyName ?? this.companyName,
      incorporationDate: incorporationDate ?? this.incorporationDate,
      registeredAddress: registeredAddress ?? this.registeredAddress,
      rocJurisdiction: rocJurisdiction ?? this.rocJurisdiction,
      category: category ?? this.category,
      status: status ?? this.status,
      paidUpCapital: paidUpCapital ?? this.paidUpCapital,
      authorisedCapital: authorisedCapital ?? this.authorisedCapital,
      directors: directors ?? this.directors,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyMasterData &&
          runtimeType == other.runtimeType &&
          cin == other.cin;

  @override
  int get hashCode => cin.hashCode;
}

/// Result of uploading an MCA e-form.
@immutable
class McaUploadResult {
  const McaUploadResult({
    required this.formType,
    required this.success,
    this.srn,
    this.uploadedAt,
    this.errorMessage,
  });

  final String formType;
  final bool success;

  /// Service Request Number assigned by MCA on successful upload.
  final String? srn;

  /// Timestamp when the upload was acknowledged by the MCA portal.
  final DateTime? uploadedAt;

  final String? errorMessage;

  McaUploadResult copyWith({
    String? formType,
    bool? success,
    String? srn,
    DateTime? uploadedAt,
    String? errorMessage,
  }) {
    return McaUploadResult(
      formType: formType ?? this.formType,
      success: success ?? this.success,
      srn: srn ?? this.srn,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McaUploadResult &&
          runtimeType == other.runtimeType &&
          formType == other.formType &&
          success == other.success &&
          srn == other.srn;

  @override
  int get hashCode => Object.hash(formType, success, srn);
}

/// Processing status of an SRN (Service Request Number) on MCA.
enum McaSrnStatusCode {
  pending(label: 'Pending', code: 'PEN'),
  underProcessing(label: 'Under Processing', code: 'UPR'),
  approved(label: 'Approved', code: 'APR'),
  rejected(label: 'Rejected', code: 'REJ'),
  resubmissionRequired(label: 'Resubmission Required', code: 'RSB');

  const McaSrnStatusCode({required this.label, required this.code});

  final String label;
  final String code;

  static McaSrnStatusCode fromCode(String code) {
    switch (code.toUpperCase().trim()) {
      case 'UPR':
        return McaSrnStatusCode.underProcessing;
      case 'APR':
        return McaSrnStatusCode.approved;
      case 'REJ':
        return McaSrnStatusCode.rejected;
      case 'RSB':
        return McaSrnStatusCode.resubmissionRequired;
      default:
        return McaSrnStatusCode.pending;
    }
  }
}

/// Status details for a previously submitted MCA SRN.
@immutable
class McaSrnStatus {
  const McaSrnStatus({
    required this.srn,
    required this.formType,
    required this.statusCode,
    this.remarks,
    this.processedAt,
    this.lastCheckedAt,
  });

  final String srn;
  final String formType;
  final McaSrnStatusCode statusCode;

  /// Remarks from MCA when [statusCode] is rejected or resubmission required.
  final String? remarks;

  /// Timestamp when MCA completed processing.
  final DateTime? processedAt;

  /// Timestamp of the last status poll.
  final DateTime? lastCheckedAt;

  bool get isTerminal =>
      statusCode == McaSrnStatusCode.approved ||
      statusCode == McaSrnStatusCode.rejected;

  McaSrnStatus copyWith({
    String? srn,
    String? formType,
    McaSrnStatusCode? statusCode,
    String? remarks,
    DateTime? processedAt,
    DateTime? lastCheckedAt,
  }) {
    return McaSrnStatus(
      srn: srn ?? this.srn,
      formType: formType ?? this.formType,
      statusCode: statusCode ?? this.statusCode,
      remarks: remarks ?? this.remarks,
      processedAt: processedAt ?? this.processedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McaSrnStatus &&
          runtimeType == other.runtimeType &&
          srn == other.srn &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(srn, statusCode);
}

// ---------------------------------------------------------------------------
// Abstract service interface
// ---------------------------------------------------------------------------

/// Abstract interface for MCA portal API integration.
///
/// Implementations:
/// - [MockMcaApiService] — deterministic in-memory mock for tests / dev.
/// - A real HTTP implementation (future work) calling the MCA v3 API.
///
/// All methods throw [McaApiException] on portal errors.
abstract class McaApiService {
  /// Prefills company master data from the MCA portal using a CIN.
  ///
  /// - [cin] — Corporate Identification Number (21 characters)
  ///
  /// Returns [CompanyMasterData] with all available fields populated.
  Future<CompanyMasterData> prefillForm(String cin);

  /// Uploads an MCA e-form to the portal.
  ///
  /// - [formType] — e.g. "MGT-7", "AOC-4", "DIR-3 KYC"
  /// - [data]     — Form data as a structured map
  ///
  /// Returns [McaUploadResult] with the SRN on success.
  Future<McaUploadResult> uploadEForm(
    String formType,
    Map<String, Object?> data,
  );

  /// Retrieves the current processing status of an SRN.
  ///
  /// - [srn] — Service Request Number returned by [uploadEForm]
  Future<McaSrnStatus> getSrnStatus(String srn);
}

// ---------------------------------------------------------------------------
// Exception type
// ---------------------------------------------------------------------------

/// Exception thrown by [McaApiService] implementations when the MCA portal
/// returns an error or a request cannot be completed.
class McaApiException implements Exception {
  const McaApiException({required this.message, this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() =>
      'McaApiException: $message'
      '${statusCode != null ? ' (HTTP $statusCode)' : ''}'
      '${cause != null ? ' — $cause' : ''}';
}

// ---------------------------------------------------------------------------
// Mock implementation
// ---------------------------------------------------------------------------

/// Deterministic in-memory mock implementation of [McaApiService].
///
/// Behaviour contract:
/// - [prefillForm]: returns synthetic master data for any valid CIN.
/// - [uploadEForm]: always succeeds with a generated SRN.
/// - [getSrnStatus]: always returns [McaSrnStatusCode.approved].
///
/// No network calls are made.
class MockMcaApiService implements McaApiService {
  const MockMcaApiService();

  @override
  Future<CompanyMasterData> prefillForm(String cin) {
    return Future.value(
      CompanyMasterData(
        cin: cin,
        companyName: 'Mock Company Pvt Ltd',
        incorporationDate: DateTime(2018, 4, 1),
        registeredAddress: '123 Mock Street, Mumbai, Maharashtra 400001',
        rocJurisdiction: 'ROC Mumbai',
        category: CompanyCategory.privateLimited,
        status: CompanyStatus.active,
        paidUpCapital: 1000000.0,
        authorisedCapital: 10000000.0,
        directors: [
          Director(
            din: '00000001',
            name: 'Mock Director One',
            designation: 'Managing Director',
            appointmentDate: DateTime(2018, 4, 1),
          ),
          Director(
            din: '00000002',
            name: 'Mock Director Two',
            designation: 'Director',
            appointmentDate: DateTime(2018, 4, 1),
          ),
        ],
      ),
    );
  }

  @override
  Future<McaUploadResult> uploadEForm(
    String formType,
    Map<String, Object?> data,
  ) {
    final srn =
        'MOCK${formType.replaceAll('-', '')}${DateTime.now().millisecondsSinceEpoch}';
    return Future.value(
      McaUploadResult(
        formType: formType,
        success: true,
        srn: srn,
        uploadedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<McaSrnStatus> getSrnStatus(String srn) {
    return Future.value(
      McaSrnStatus(
        srn: srn,
        formType: _inferFormType(srn),
        statusCode: McaSrnStatusCode.approved,
        processedAt: DateTime.now(),
        lastCheckedAt: DateTime.now(),
      ),
    );
  }

  /// Infers the form type from a mock SRN for convenience.
  String _inferFormType(String srn) {
    if (srn.contains('MGT7')) return 'MGT-7';
    if (srn.contains('AOC4')) return 'AOC-4';
    return 'UNKNOWN';
  }
}
