import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:ca_app/features/mca_api/domain/models/charge_record.dart';
import 'package:ca_app/features/mca_api/domain/models/company_details.dart';
import 'package:ca_app/features/mca_api/domain/models/company_search_result.dart';
import 'package:ca_app/features/mca_api/domain/models/din_details.dart';
import 'package:ca_app/features/mca_api/domain/models/director_details.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_record.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

// ---------------------------------------------------------------------------
// Base-URL constant — overridable via --dart-define.
// ---------------------------------------------------------------------------

const String _kMcaBaseUrl = String.fromEnvironment(
  'MCA_API_BASE_URL',
  defaultValue: 'https://api.mca.gov.in',
);

const String _kPortal = 'MCA';

/// CIN format: [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}
final RegExp _kCinPattern = RegExp(
  r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$',
);

/// DIN format: exactly 8 numeric digits.
final RegExp _kDinPattern = RegExp(r'^[0-9]{8}$');

/// Service providing MCA (Ministry of Corporate Affairs) API integration.
///
/// All methods are static and accept an injected [Dio] for testability.
/// Credentials are resolved from [PortalCredentialRepository] at call time.
class McaApiService {
  McaApiService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Search for companies by [query] (name substring or CIN prefix).
  ///
  /// Returns up to 20 results from the MCA master data.
  ///
  /// Throws [PortalAuthException] on 401/403.
  /// Throws [PortalRateLimitException] on 429.
  /// Throws [PortalUnavailableException] on 5xx or network failure.
  static Future<List<CompanySearchResult>> searchCompany(
    String query, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    if (query.trim().isEmpty) {
      throw ArgumentError.value(query, 'query', 'Search query must not be empty.');
    }
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/MCA21/mds/efiling/getCompanyMasterDataForGovt',
      apiKey: apiKey,
      queryParameters: {
        'company_name': query,
        'type': 'search',
      },
    );
    final body = _decodeBody(response.data);
    final list = body['companyData'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_parseCompanySearchResult)
        .toList(growable: false);
  }

  /// Fetch full company details by CIN.
  ///
  /// Throws [ArgumentError] when [cin] does not match the CIN format.
  static Future<CompanyDetails> getCompanyDetails(
    String cin, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    _validateCin(cin);
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/MCA21/mds/efiling/getCompanyMasterDataForGovt',
      apiKey: apiKey,
      queryParameters: {'company_cin': cin.toUpperCase(), 'type': 'details'},
    );
    return _parseCompanyDetails(_decodeBody(response.data));
  }

  /// Retrieve the filing history for a company identified by [cin].
  ///
  /// [year] is the financial year (e.g. 2024 for FY 2024-25); pass 0 for all.
  static Future<List<McaFilingRecord>> getFilingHistory(
    String cin,
    int year, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    _validateCin(cin);
    final apiKey = await _resolveApiKey(credentialRepository);
    final queryParams = <String, dynamic>{'cin': cin.toUpperCase()};
    if (year > 0) queryParams['year'] = year;

    final response = await _get(
      dio: dio,
      path: '/MCA21/mds/efiling/getFilingHistory',
      apiKey: apiKey,
      queryParameters: queryParams,
    );
    final body = _decodeBody(response.data);
    final list = body['filingHistory'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_parseFilingRecord)
        .toList(growable: false);
  }

  /// Verify a DIN and return director status.
  ///
  /// Throws [ArgumentError] when [din] is not exactly 8 numeric digits.
  static Future<DinDetails> checkDin(
    String din, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    _validateDin(din);
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/MCA21/mds/efiling/getDINMasterData',
      apiKey: apiKey,
      queryParameters: {'din': din},
    );
    return _parseDinDetails(_decodeBody(response.data));
  }

  /// Retrieve all charges registered against [cin].
  static Future<List<ChargeRecord>> getCharges(
    String cin, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    _validateCin(cin);
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/MCA21/mds/efiling/getCharges',
      apiKey: apiKey,
      queryParameters: {'cin': cin.toUpperCase()},
    );
    final body = _decodeBody(response.data);
    final list = body['charges'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_parseChargeRecord)
        .toList(growable: false);
  }

  /// Search for a director by DIN and return full profile.
  ///
  /// Throws [ArgumentError] when [din] is not exactly 8 numeric digits.
  static Future<DirectorDetails> searchDirector(
    String din, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    _validateDin(din);
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/MCA21/mds/efiling/getDirectorMasterData',
      apiKey: apiKey,
      queryParameters: {'din': din},
    );
    return _parseDirectorDetails(_decodeBody(response.data));
  }

  // -------------------------------------------------------------------------
  // Private helpers — HTTP
  // -------------------------------------------------------------------------

  static Future<Response<dynamic>> _get({
    required Dio dio,
    required String path,
    required String apiKey,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get<dynamic>(
        '$_kMcaBaseUrl$path',
        queryParameters: queryParameters,
        options: Options(headers: {'x-api-key': apiKey}),
      );
    } on DioException catch (e) {
      _throwPortalException(e);
    }
  }

  static Never _throwPortalException(DioException e) {
    final status = e.response?.statusCode;

    if (status == 401 || status == 403) {
      throw PortalAuthException(
        portal: _kPortal,
        message: _extractMessage(e.response?.data) ??
            'MCA API authentication failed. Check your API key.',
        statusCode: status,
      );
    }

    if (status == 429) {
      final retryAfter = _parseRetryAfter(e.response?.headers);
      throw PortalRateLimitException(
        portal: _kPortal,
        message: _extractMessage(e.response?.data) ??
            'MCA API rate limit exceeded.',
        retryAfterSeconds: retryAfter,
      );
    }

    throw PortalUnavailableException(
      portal: _kPortal,
      message: _extractMessage(e.response?.data) ??
          e.message ??
          'MCA portal is currently unavailable.',
      statusCode: status,
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers — credentials
  // -------------------------------------------------------------------------

  static Future<String> _resolveApiKey(
    PortalCredentialRepository repo,
  ) async {
    final credential = await repo.getCredential(PortalType.mca);
    final token = credential?.grantToken ?? credential?.encryptedPassword;
    if (token == null || token.isEmpty) {
      throw const PortalAuthException(
        portal: _kPortal,
        message: 'No MCA API key configured. Please add credentials in '
            'Settings → Portal Connectors → MCA.',
      );
    }
    return token;
  }

  // -------------------------------------------------------------------------
  // Private helpers — validation
  // -------------------------------------------------------------------------

  static void _validateCin(String cin) {
    if (!_kCinPattern.hasMatch(cin.toUpperCase())) {
      throw ArgumentError.value(
        cin,
        'cin',
        'Invalid CIN format. Expected [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}.',
      );
    }
  }

  static void _validateDin(String din) {
    if (!_kDinPattern.hasMatch(din)) {
      throw ArgumentError.value(
        din,
        'din',
        'Invalid DIN format. Expected exactly 8 numeric digits.',
      );
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers — parsing
  // -------------------------------------------------------------------------

  static CompanySearchResult _parseCompanySearchResult(
    Map<String, dynamic> data,
  ) {
    return CompanySearchResult(
      cin: data['cin'] as String? ?? '',
      name: data['company_name'] as String? ?? '',
      status: _parseCompanyStatus(data['company_status'] as String?),
      incorporationDate:
          _parseDate(data['date_of_incorporation'] as String?),
      roc: data['roc_code'] as String? ?? '',
    );
  }

  static CompanyDetails _parseCompanyDetails(Map<String, dynamic> data) {
    final directorList = (data['directors'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseDirector)
        .toList(growable: false);

    return CompanyDetails(
      cin: data['cin'] as String? ?? '',
      name: data['company_name'] as String? ?? '',
      registeredAddress:
          data['registered_address'] as String? ?? '',
      authorizedCapital: _parsePaise(data['authorized_capital']),
      paidUpCapital: _parsePaise(data['paid_up_capital']),
      directors: directorList,
      status: _parseCompanyStatus(data['company_status'] as String?),
      incorporationDate:
          _parseDate(data['date_of_incorporation'] as String?),
      roc: data['roc_code'] as String? ?? '',
    );
  }

  static Director _parseDirector(Map<String, dynamic> data) {
    return Director(
      din: data['din'] as String? ?? '',
      name: data['director_name'] as String? ?? '',
      designation: data['designation'] as String? ?? '',
      appointmentDate:
          _parseDateOpt(data['date_of_appointment'] as String?),
    );
  }

  static McaFilingRecord _parseFilingRecord(Map<String, dynamic> data) {
    return McaFilingRecord(
      srn: data['srn'] as String? ?? '',
      formType: data['form_type'] as String? ?? '',
      filedAt: _parseDate(data['date_of_filing'] as String?),
      status: data['status'] as String? ?? '',
      documentDescription:
          data['document_description'] as String? ?? '',
      feesPaid: _parsePaise(data['fees_paid']),
    );
  }

  static DinDetails _parseDinDetails(Map<String, dynamic> data) {
    return DinDetails(
      din: data['din'] as String? ?? '',
      name: data['director_name'] as String? ?? '',
      nationality: data['nationality'] as String? ?? '',
      status: _parseDirectorStatus(data['din_status'] as String?),
      dob: _parseDateOpt(data['dob'] as String?),
    );
  }

  static ChargeRecord _parseChargeRecord(Map<String, dynamic> data) {
    return ChargeRecord(
      chargeId: data['charge_id'] as String? ?? '',
      holderName: data['charge_holder_name'] as String? ?? '',
      amount: _parsePaise(data['amount']),
      dateOfCreation: _parseDate(data['date_of_creation'] as String?),
      status: _parseChargeStatus(data['status'] as String?),
      dateOfSatisfaction:
          _parseDateOpt(data['date_of_satisfaction'] as String?),
      assets: data['assets_description'] as String?,
    );
  }

  static DirectorDetails _parseDirectorDetails(Map<String, dynamic> data) {
    final companies = (data['associated_companies'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false);

    return DirectorDetails(
      din: data['din'] as String? ?? '',
      name: data['director_name'] as String? ?? '',
      nationality: data['nationality'] as String? ?? '',
      status: _parseDirectorStatus(data['din_status'] as String?),
      associatedCompanies: companies,
      dob: _parseDateOpt(data['dob'] as String?),
      fatherName: data['father_name'] as String?,
      address: data['address'] as String?,
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers — enum parsers
  // -------------------------------------------------------------------------

  static McaCompanyStatus _parseCompanyStatus(String? raw) {
    switch ((raw ?? '').toUpperCase().replaceAll(' ', '_')) {
      case 'ACTIVE':
        return McaCompanyStatus.active;
      case 'DORMANT':
        return McaCompanyStatus.dormant;
      case 'STRIKE_OFF':
      case 'STRUCK_OFF':
        return McaCompanyStatus.strikedOff;
      case 'UNDER_LIQUIDATION':
        return McaCompanyStatus.underLiquidation;
      case 'AMALGAMATED':
        return McaCompanyStatus.amalgamated;
      default:
        return McaCompanyStatus.active;
    }
  }

  static McaDirectorStatus _parseDirectorStatus(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'DISQUALIFIED':
        return McaDirectorStatus.disqualified;
      case 'DEACTIVATED':
        return McaDirectorStatus.deactivated;
      default:
        return McaDirectorStatus.approved;
    }
  }

  static ChargeStatus _parseChargeStatus(String? raw) {
    switch ((raw ?? '').toUpperCase().replaceAll(' ', '_')) {
      case 'SATISFIED':
        return ChargeStatus.satisfied;
      case 'MODIFIED_SATISFIED':
        return ChargeStatus.modifiedSatisfied;
      default:
        return ChargeStatus.open;
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers — utilities
  // -------------------------------------------------------------------------

  /// Decodes [data] to [Map<String, dynamic>] whether Dio has already decoded
  /// it as a Map or returned it as a raw JSON String.
  static Map<String, dynamic> _decodeBody(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return const {};
  }

  static int _parsePaise(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime(2000);
    try {
      // MCA dates are typically DD/MM/YYYY
      final parts = raw.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime(2000);
    }
  }

  static DateTime? _parseDateOpt(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return _parseDate(raw);
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          final msg = decoded['message'];
          if (msg is String && msg.isNotEmpty) return msg;
        }
      } catch (_) {
        return data.isNotEmpty ? data : null;
      }
    }
    return null;
  }

  static int? _parseRetryAfter(Headers? headers) {
    final value = headers?.value('Retry-After');
    if (value == null) return null;
    return int.tryParse(value);
  }
}
