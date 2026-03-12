import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_record.dart';

/// CIN: [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}
final _cinRegex = RegExp(r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$');

/// DIN: exactly 8 numeric digits.
final _dinRegex = RegExp(r'^[0-9]{8}$');

/// Stateless parser that converts MCA portal JSON responses into domain models.
///
/// All methods throw [FormatException] when required JSON fields are missing
/// or cannot be parsed.
class McaResponseParser {
  const McaResponseParser();

  // -------------------------------------------------------------------------
  // Validation
  // -------------------------------------------------------------------------

  /// Returns true when [cin] matches the MCA CIN format.
  bool validateCin(String cin) => _cinRegex.hasMatch(cin);

  /// Returns true when [din] is exactly 8 numeric digits.
  bool validateDin(String din) => _dinRegex.hasMatch(din);

  // -------------------------------------------------------------------------
  // Parsers
  // -------------------------------------------------------------------------

  /// Parses a company lookup JSON response from the MCA portal.
  ///
  /// Expected structure:
  /// ```json
  /// {"status": "1", "data": { ... }}
  /// ```
  McaCompanyLookup parseCompanyLookup(Map<String, dynamic> json) {
    final data = _requireData(json);
    final cin = _requireString(data, 'cin');
    final companyName = _requireString(data, 'company_name');
    final statusStr = _requireString(data, 'company_status');
    final dateStr = _requireString(data, 'date_of_incorporation');
    final authorizedCapital = _requireInt(data, 'authorized_capital');
    final paidUpCapital = _requireInt(data, 'paid_up_capital');
    final roc = _requireString(data, 'roc_code');
    final state = _requireString(data, 'state');
    final address = _requireString(data, 'registered_office_address');
    final category = _requireString(data, 'company_category');
    final subCategory = _requireString(data, 'company_sub_category');

    return McaCompanyLookup(
      cin: cin,
      companyName: companyName,
      registeredOfficeAddress: address,
      state: state,
      dateOfIncorporation: _parseDdMmYyyy(dateStr),
      status: _parseCompanyStatus(statusStr),
      authorizedCapital: authorizedCapital,
      paidUpCapital: paidUpCapital,
      companyCategory: category,
      companySubCategory: subCategory,
      roc: roc,
    );
  }

  /// Parses a director lookup JSON response from the MCA portal.
  McaDirectorLookup parseDirectorLookup(Map<String, dynamic> json) {
    final data = _requireData(json);
    final din = _requireString(data, 'din');
    final name = _requireString(data, 'name');
    final statusStr = _requireString(data, 'status');
    final nationality = _requireString(data, 'nationality');

    final dobStr = data['date_of_birth'] as String?;
    final fatherName = data['father_name'] as String?;
    final rawCompanies = data['associated_companies'];
    final associatedCompanies = rawCompanies is List
        ? rawCompanies.cast<String>()
        : const <String>[];

    return McaDirectorLookup(
      din: din,
      directorName: name,
      dateOfBirth: dobStr != null ? _parseDdMmYyyy(dobStr) : null,
      fatherName: fatherName,
      nationality: nationality,
      status: _parseDirectorStatus(statusStr),
      associatedCompanies: List<String>.unmodifiable(associatedCompanies),
    );
  }

  /// Parses an e-Form status JSON response from the MCA portal.
  McaEFormStatus parseFormStatus(Map<String, dynamic> json) {
    final data = _requireData(json);
    final srn = _requireString(data, 'srn');
    final formType = _requireString(data, 'form_type');
    final cin = _requireString(data, 'cin');
    final filedAtStr = _requireString(data, 'filed_at');
    final statusStr = _requireString(data, 'status');

    final approvalDateStr = data['approval_date'] as String?;
    final remarks = data['remarks'] as String?;

    return McaEFormStatus(
      srn: srn,
      formType: formType,
      cin: cin,
      filedAt: DateTime.parse(filedAtStr),
      status: _parseEFormStatus(statusStr),
      approvalDate:
          approvalDateStr != null ? DateTime.parse(approvalDateStr) : null,
      remarks: remarks,
    );
  }

  /// Parses a filing history JSON response from the MCA portal.
  McaFilingHistory parseFilingHistory(Map<String, dynamic> json) {
    final data = _requireData(json);
    final cin = _requireString(data, 'cin');
    final rawFilings = data['filings'];
    if (rawFilings == null) {
      throw FormatException('Missing required field: filings');
    }
    final filings = (rawFilings as List<dynamic>)
        .map((item) => _parseFilingRecord(item as Map<String, dynamic>))
        .toList(growable: false);

    return McaFilingHistory(cin: cin, filings: filings);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Map<String, dynamic> _requireData(Map<String, dynamic> json) {
    final data = json['data'];
    if (data == null || data is! Map<String, dynamic>) {
      throw const FormatException(
        'MCA response missing required "data" object',
      );
    }
    return data;
  }

  String _requireString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) {
      throw FormatException('Missing required field: $key');
    }
    if (value is! String) {
      throw FormatException('Expected String for field $key, got ${value.runtimeType}');
    }
    return value;
  }

  int _requireInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) {
      throw FormatException('Missing required field: $key');
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException(
      'Expected int for field $key, got ${value.runtimeType}',
    );
  }

  /// Parses a date string in DD/MM/YYYY format.
  DateTime _parseDdMmYyyy(String date) {
    final parts = date.split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date format "$date". Expected DD/MM/YYYY');
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      throw FormatException('Non-numeric date parts in "$date"');
    }
    return DateTime(year, month, day);
  }

  McaCompanyStatus _parseCompanyStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'active':
        return McaCompanyStatus.active;
      case 'dormant':
        return McaCompanyStatus.dormant;
      case 'strike off':
      case 'striked off':
      case 'struck off':
        return McaCompanyStatus.strikedOff;
      case 'under liquidation':
        return McaCompanyStatus.underLiquidation;
      case 'amalgamated':
        return McaCompanyStatus.amalgamated;
      default:
        return McaCompanyStatus.active;
    }
  }

  McaDirectorStatus _parseDirectorStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'approved':
        return McaDirectorStatus.approved;
      case 'disqualified':
        return McaDirectorStatus.disqualified;
      case 'deactivated':
        return McaDirectorStatus.deactivated;
      default:
        return McaDirectorStatus.approved;
    }
  }

  McaEFormStatusValue _parseEFormStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return McaEFormStatusValue.pending;
      case 'under processing':
        return McaEFormStatusValue.underProcessing;
      case 'approved':
        return McaEFormStatusValue.approved;
      case 'rejected':
        return McaEFormStatusValue.rejected;
      case 'resubmission required':
        return McaEFormStatusValue.resubmissionRequired;
      default:
        return McaEFormStatusValue.pending;
    }
  }

  McaFilingRecord _parseFilingRecord(Map<String, dynamic> map) {
    final srn = _requireString(map, 'srn');
    final formType = _requireString(map, 'form_type');
    final filedAtStr = _requireString(map, 'filed_at');
    final status = _requireString(map, 'status');
    final description = _requireString(map, 'document_description');
    final feesPaid = _requireInt(map, 'fees_paid');

    return McaFilingRecord(
      srn: srn,
      formType: formType,
      filedAt: DateTime.parse(filedAtStr),
      status: status,
      documentDescription: description,
      feesPaid: feesPaid,
    );
  }
}
