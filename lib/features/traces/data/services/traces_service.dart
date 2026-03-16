import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';
import 'package:ca_app/features/traces/domain/models/ais_data.dart';
import 'package:ca_app/features/traces/domain/models/form16_certificate.dart';
import 'package:ca_app/features/traces/domain/models/form26as_data.dart';
import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';

// ---------------------------------------------------------------------------
// Base-URL constant — overridable via --dart-define.
// ---------------------------------------------------------------------------

const String _kTracesBaseUrl = String.fromEnvironment(
  'TRACES_API_BASE_URL',
  defaultValue: 'https://www.tdscpc.gov.in',
);

const String _kPortal = 'TRACES';

/// Service providing TRACES portal API integration.
///
/// Credentials are resolved from [PortalCredentialRepository] at call time.
/// All methods accept an injected [Dio] instance for testability.
class TracesService {
  TracesService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Download Form 26AS for the given [pan] and [assessmentYear].
  ///
  /// [assessmentYear] format: "YYYY-YY" (e.g. "2024-25").
  ///
  /// Throws [PortalAuthException] on 401/403.
  /// Throws [PortalRateLimitException] on 429.
  /// Throws [PortalUnavailableException] on 5xx or network failure.
  static Future<Form26asData> downloadForm26as(
    String pan,
    String assessmentYear, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/eStatement/26AS-Form-Download',
      sessionCookie: creds,
      body: {
        'pan': pan.toUpperCase(),
        'assessmentYear': assessmentYear,
        'type': 'C',
      },
    );
    return _parseForm26as(
      _decodeBody(response.data),
      pan: pan,
      assessmentYear: assessmentYear,
    );
  }

  /// Download AIS (Annual Information Statement) for [pan] and [assessmentYear].
  static Future<AisData> downloadAis(
    String pan,
    String assessmentYear, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/ais/downloadAIS',
      sessionCookie: creds,
      body: {'pan': pan.toUpperCase(), 'assessmentYear': assessmentYear},
    );
    return _parseAis(
      _decodeBody(response.data),
      pan: pan,
      assessmentYear: assessmentYear,
    );
  }

  /// Download Form 16 certificates for a deductor [tan], [quarter] (1-4),
  /// and [financialYear] (e.g. 2024 for FY 2024-25).
  static Future<List<Form16Certificate>> getForm16(
    String tan,
    int quarter,
    int financialYear, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/form16/download',
      sessionCookie: creds,
      body: {
        'tan': tan.toUpperCase(),
        'quarter': quarter,
        'financialYear': financialYear,
      },
    );
    final body = _decodeBody(response.data);
    final list = body['certificates'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => _parseForm16Certificate(
            e,
            tan: tan,
            financialYear: financialYear,
            quarter: quarter,
          ),
        )
        .toList(growable: false);
  }

  /// Download TDS certificates (Form 16A) for [tan] and [period].
  ///
  /// [period] is a string identifying the quarter, e.g. "Q1FY2024".
  static Future<List<TdsCertificate>> getTdsCertificates(
    String tan,
    String period, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/form16A/download',
      sessionCookie: creds,
      body: {'tan': tan.toUpperCase(), 'period': period},
    );
    final body = _decodeBody(response.data);
    final list = body['certificates'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => _parseTdsCertificate(e, tan: tan, period: period))
        .toList(growable: false);
  }

  /// Check whether the current session is still active (logged in).
  ///
  /// Returns `true` when a valid credential with an unexpired token exists.
  static Future<bool> checkLoginStatus({
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final credential = await credentialRepository.getCredential(
      PortalType.traces,
    );
    if (credential == null) return false;
    if (!credential.isTokenValid) return false;

    try {
      await _get(
        dio: dio,
        path: '/app/login/check',
        sessionCookie: credential.grantToken ?? '',
      );
      return true;
    } on PortalAuthException {
      return false;
    } on PortalUnavailableException {
      return false;
    }
  }

  /// Authenticate against TRACES using the stored [credential].
  ///
  /// Returns `true` on success.
  /// Throws [PortalAuthException] on bad credentials.
  static Future<bool> login(
    PortalCredential credential, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    try {
      final response = await _post(
        dio: dio,
        path: '/app/login',
        sessionCookie: null,
        body: {
          'userId': credential.username ?? '',
          'password': credential.encryptedPassword ?? '',
        },
      );
      final decoded = _decodeBody(response.data);
      final statusStr = decoded['status'] as String?;
      final success = statusStr == 'SUCCESS' || response.statusCode == 200;
      return success;
    } on DioException catch (e) {
      _throwPortalException(e);
    }
  }

  /// Verify a PAN with the TRACES / ITD API.
  ///
  /// Throws [PortalAuthException] on 401/403.
  /// Throws [PortalRateLimitException] on 429.
  /// Throws [PortalUnavailableException] on 5xx or network failure.
  static Future<TracesPanVerification> verifyPan(
    String pan, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/pan/verify',
      sessionCookie: creds,
      body: {'pan': pan.toUpperCase()},
    );
    return _parsePanVerification(_decodeBody(response.data), pan: pan);
  }

  /// Fetch the booking / matching status of a specific TDS challan.
  ///
  /// [bsrCode] — 7-digit BSR code of the bank branch.
  /// [date]    — Date the challan was deposited.
  /// [serial]  — 5-digit challan serial number.
  /// [tan]     — TAN of the deductor.
  static Future<TracesChallanStatus> getChallanStatus(
    String bsrCode,
    DateTime date,
    String serial,
    String tan, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/challan/status',
      sessionCookie: creds,
      body: {
        'bsrCode': bsrCode,
        'date': _formatDate(date),
        'serial': serial,
        'tan': tan.toUpperCase(),
      },
    );
    return _parseChallanStatus(
      _decodeBody(response.data),
      bsrCode: bsrCode,
      date: date,
      serial: serial,
      tan: tan,
    );
  }

  /// Submit a Form 16 / 16A download request for a single deductee.
  ///
  /// [tan]           — TAN of the deductor.
  /// [pan]           — PAN of the deductee.
  /// [financialYear] — Financial year (e.g. 2024 for FY 2024-25).
  static Future<TracesForm16Request> requestForm16(
    String tan,
    String pan,
    int financialYear, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/form16/request',
      sessionCookie: creds,
      body: {
        'tan': tan.toUpperCase(),
        'pan': pan.toUpperCase(),
        'financialYear': financialYear,
      },
    );
    return _parseForm16Request(
      _decodeBody(response.data),
      tan: tan,
      pan: pan,
      financialYear: financialYear,
    );
  }

  /// Submit a bulk Form 16 download request covering multiple deductees.
  ///
  /// TRACES allows up to 50 PANs per request.
  static Future<List<TracesForm16Request>> requestBulkForm16(
    String tan,
    int financialYear,
    List<String> pans, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/form16/bulkRequest',
      sessionCookie: creds,
      body: {
        'tan': tan.toUpperCase(),
        'financialYear': financialYear,
        'pans': pans.map((p) => p.toUpperCase()).toList(),
      },
    );
    final body = _decodeBody(response.data);
    final list = body['requests'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => _parseForm16Request(
            e,
            tan: tan,
            pan: e['pan'] as String? ?? '',
            financialYear: financialYear,
          ),
        )
        .toList(growable: false);
  }

  /// Fetch the justification report for a TAN / quarter.
  ///
  /// [tan]           — TAN of the deductor.
  /// [financialYear] — Financial year.
  /// [quarter]       — Quarter number: 1 = Q1 (Apr-Jun), …, 4 = Q4 (Jan-Mar).
  static Future<TracesJustificationReport> getJustificationReport(
    String tan,
    int financialYear,
    int quarter, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/justificationReport/download',
      sessionCookie: creds,
      body: {
        'tan': tan.toUpperCase(),
        'financialYear': financialYear,
        'quarter': quarter,
      },
    );
    return _parseJustificationReport(
      _decodeBody(response.data),
      tan: tan,
      financialYear: financialYear,
      quarter: quarter,
    );
  }

  /// Fetch all challans deposited by [tan] in the given [financialYear].
  static Future<List<TracesChallanStatus>> getAllChallans(
    String tan,
    int financialYear, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final creds = await _resolveCredentials(credentialRepository);
    final response = await _post(
      dio: dio,
      path: '/app/challan/list',
      sessionCookie: creds,
      body: {'tan': tan.toUpperCase(), 'financialYear': financialYear},
    );
    final body = _decodeBody(response.data);
    final list = body['challans'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => _parseChallanFromList(e, tan: tan))
        .toList(growable: false);
  }

  // -------------------------------------------------------------------------
  // Private helpers — HTTP
  // -------------------------------------------------------------------------

  static Future<Response<dynamic>> _get({
    required Dio dio,
    required String path,
    required String sessionCookie,
  }) async {
    try {
      return await dio.get<dynamic>(
        '$_kTracesBaseUrl$path',
        options: Options(
          headers: {if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie},
        ),
      );
    } on DioException catch (e) {
      _throwPortalException(e);
    }
  }

  static Future<Response<dynamic>> _post({
    required Dio dio,
    required String path,
    required String? sessionCookie,
    required Map<String, dynamic> body,
  }) async {
    try {
      return await dio.post<dynamic>(
        '$_kTracesBaseUrl$path',
        data: body,
        options: Options(
          headers: {
            if (sessionCookie != null && sessionCookie.isNotEmpty)
              'Cookie': sessionCookie,
          },
        ),
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
        message:
            _extractMessage(e.response?.data) ??
            'TRACES authentication failed. Please re-login.',
        statusCode: status,
      );
    }

    if (status == 429) {
      final retryAfter = _parseRetryAfter(e.response?.headers);
      throw PortalRateLimitException(
        portal: _kPortal,
        message:
            _extractMessage(e.response?.data) ?? 'TRACES rate limit exceeded.',
        retryAfterSeconds: retryAfter,
      );
    }

    throw PortalUnavailableException(
      portal: _kPortal,
      message:
          _extractMessage(e.response?.data) ??
          e.message ??
          'TRACES portal is currently unavailable.',
      statusCode: status,
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers — credentials
  // -------------------------------------------------------------------------

  static Future<String> _resolveCredentials(
    PortalCredentialRepository repo,
  ) async {
    final credential = await repo.getCredential(PortalType.traces);
    if (credential == null || !credential.isTokenValid) {
      throw const PortalAuthException(
        portal: _kPortal,
        message:
            'TRACES session has expired or no credentials configured. '
            'Please log in via Settings → Portal Connectors → TRACES.',
      );
    }
    return credential.grantToken ?? '';
  }

  // -------------------------------------------------------------------------
  // Private helpers — parsing
  // -------------------------------------------------------------------------

  static Form26asData _parseForm26as(
    Map<String, dynamic> data, {
    required String pan,
    required String assessmentYear,
  }) {
    final entries = (data['Part_A'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseTdsEntry)
        .toList(growable: false);

    return Form26asData(
      pan: pan.toUpperCase(),
      assessmentYear: assessmentYear,
      tdsEntries: entries,
      advanceTax: _parsePaise(data['Part_C_advanceTax']),
      selfAssessment: _parsePaise(data['Part_C_selfAssessment']),
    );
  }

  static TdsEntry26as _parseTdsEntry(Map<String, dynamic> e) {
    return TdsEntry26as(
      deductorName: e['deductorName'] as String? ?? '',
      deductorTan: e['deductorTAN'] as String? ?? '',
      section: e['section'] as String? ?? '',
      amountPaid: _parsePaise(e['amountPaid']),
      taxDeducted: _parsePaise(e['taxDeducted']),
      depositDate: _parseDate(e['depositDate'] as String?),
    );
  }

  static AisData _parseAis(
    Map<String, dynamic> data, {
    required String pan,
    required String assessmentYear,
  }) {
    final incomes = (data['incomeDetails'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseAisIncome)
        .toList(growable: false);

    return AisData(
      pan: pan.toUpperCase(),
      assessmentYear: assessmentYear,
      incomeDetails: incomes,
    );
  }

  static AisIncome _parseAisIncome(Map<String, dynamic> e) {
    return AisIncome(
      sourceType: e['sourceType'] as String? ?? '',
      sourceName: e['sourceName'] as String? ?? '',
      amount: _parsePaise(e['amount']),
      taxDeducted: _parsePaise(e['taxDeducted']),
    );
  }

  static Form16Certificate _parseForm16Certificate(
    Map<String, dynamic> e, {
    required String tan,
    required int financialYear,
    required int quarter,
  }) {
    return Form16Certificate(
      employerTan: e['tan'] as String? ?? tan,
      employeePan: e['pan'] as String? ?? '',
      financialYear: financialYear,
      grossSalary: _parsePaise(e['grossSalary']),
      tdsDeducted: _parsePaise(e['tdsDeducted']),
      certificateNumber: e['certificateNumber'] as String?,
      quarter: quarter,
    );
  }

  static TdsCertificate _parseTdsCertificate(
    Map<String, dynamic> e, {
    required String tan,
    required String period,
  }) {
    return TdsCertificate(
      tan: e['tan'] as String? ?? tan,
      deducteePan: e['pan'] as String? ?? '',
      section: e['section'] as String? ?? '',
      period: period,
      amountPaid: _parsePaise(e['amountPaid']),
      taxDeducted: _parsePaise(e['taxDeducted']),
      certificateNumber: e['certificateNumber'] as String?,
    );
  }

  static TracesPanVerification _parsePanVerification(
    Map<String, dynamic> data, {
    required String pan,
  }) {
    final statusCode = (data['panStatus'] as String? ?? 'I').toUpperCase();
    final PanStatus status;
    switch (statusCode) {
      case 'E':
        status = PanStatus.valid;
        break;
      case 'A':
        status = PanStatus.inactive;
        break;
      case 'X':
        status = PanStatus.deleted;
        break;
      default:
        status = PanStatus.invalid;
    }
    return TracesPanVerification(
      pan: pan.toUpperCase(),
      name: data['name'] as String? ?? '',
      status: status,
      aadhaarLinked: (data['aadhaarLinked'] as bool?) ?? false,
      dateOfBirth: data['dateOfBirth'] as String?,
      verifiedAt: DateTime.now(),
    );
  }

  static TracesChallanStatus _parseChallanStatus(
    Map<String, dynamic> data, {
    required String bsrCode,
    required DateTime date,
    required String serial,
    required String tan,
  }) {
    final statusCode = (data['bookingStatus'] as String? ?? 'U').toUpperCase();
    final ChallanBookingStatus status;
    switch (statusCode) {
      case 'F':
        status = ChallanBookingStatus.matched;
        break;
      case 'B':
        status = ChallanBookingStatus.bookingConfirmed;
        break;
      case 'O':
        status = ChallanBookingStatus.overBooked;
        break;
      default:
        status = ChallanBookingStatus.unmatched;
    }
    final deposited = _parsePaise(data['depositedAmount']);
    final consumed = _parsePaise(data['consumedAmount']);
    return TracesChallanStatus(
      bsrCode: bsrCode,
      challanDate: date,
      challanSerial: serial,
      tan: tan.toUpperCase(),
      section: data['section'] as String? ?? '',
      depositedAmount: deposited,
      status: status,
      consumedAmount: consumed,
      balanceAmount: deposited - consumed,
    );
  }

  static TracesChallanStatus _parseChallanFromList(
    Map<String, dynamic> data, {
    required String tan,
  }) {
    final statusCode = (data['bookingStatus'] as String? ?? 'U').toUpperCase();
    final ChallanBookingStatus status;
    switch (statusCode) {
      case 'F':
        status = ChallanBookingStatus.matched;
        break;
      case 'B':
        status = ChallanBookingStatus.bookingConfirmed;
        break;
      case 'O':
        status = ChallanBookingStatus.overBooked;
        break;
      default:
        status = ChallanBookingStatus.unmatched;
    }
    final deposited = _parsePaise(data['depositedAmount']);
    final consumed = _parsePaise(data['consumedAmount']);
    return TracesChallanStatus(
      bsrCode: data['bsrCode'] as String? ?? '',
      challanDate: _parseDate(data['challanDate'] as String?),
      challanSerial: data['challanSerial'] as String? ?? '',
      tan: data['tan'] as String? ?? tan.toUpperCase(),
      section: data['section'] as String? ?? '',
      depositedAmount: deposited,
      status: status,
      consumedAmount: consumed,
      balanceAmount: deposited - consumed,
    );
  }

  static TracesForm16Request _parseForm16Request(
    Map<String, dynamic> data, {
    required String tan,
    required String pan,
    required int financialYear,
  }) {
    final statusCode = (data['requestStatus'] as String? ?? 'P').toUpperCase();
    final Form16RequestStatus status;
    switch (statusCode) {
      case 'A':
        status = Form16RequestStatus.available;
        break;
      case 'P':
        status = Form16RequestStatus.processing;
        break;
      case 'D':
        status = Form16RequestStatus.downloaded;
        break;
      case 'F':
        status = Form16RequestStatus.failed;
        break;
      default:
        status = Form16RequestStatus.submitted;
    }
    return TracesForm16Request(
      requestId: data['requestId'] as String? ?? '$tan-$pan-$financialYear',
      tan: data['tan'] as String? ?? tan.toUpperCase(),
      pan: data['pan'] as String? ?? pan.toUpperCase(),
      financialYear: financialYear,
      requestType: Form16RequestType.form16,
      status: status,
      downloadUrl: data['downloadUrl'] as String?,
      requestedAt: DateTime.now(),
    );
  }

  static TracesJustificationReport _parseJustificationReport(
    Map<String, dynamic> data, {
    required String tan,
    required int financialYear,
    required int quarter,
  }) {
    final tdsQuarter = TdsQuarter.values[(quarter - 1).clamp(0, 3)];
    final shortList = (data['shortDeductions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseShortDeduction)
        .toList(growable: false);
    final lateList = (data['lateDeductions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseLateDeduction)
        .toList(growable: false);
    return TracesJustificationReport(
      tan: tan.toUpperCase(),
      financialYear: financialYear,
      quarter: tdsQuarter,
      shortDeductions: shortList,
      lateDeductions: lateList,
      totalShortfall: _parsePaise(data['totalShortfall']),
      totalInterestDemand: _parsePaise(data['totalInterestDemand']),
    );
  }

  static ShortDeductionEntry _parseShortDeduction(Map<String, dynamic> data) {
    return ShortDeductionEntry(
      pan: data['pan'] as String? ?? '',
      section: data['section'] as String? ?? '',
      amountPaid: _parsePaise(data['amountPaid']),
      tdsDeducted: _parsePaise(data['tdsDeducted']),
      tdsRequired: _parsePaise(data['tdsRequired']),
      shortfall: _parsePaise(data['shortfall']),
    );
  }

  static LateDeductionEntry _parseLateDeduction(Map<String, dynamic> data) {
    return LateDeductionEntry(
      pan: data['pan'] as String? ?? '',
      section: data['section'] as String? ?? '',
      dueDate: data['dueDate'] as String? ?? '',
      depositedDate: data['depositedDate'] as String? ?? '',
      daysLate: (data['daysLate'] as num?)?.toInt() ?? 0,
      interest: _parsePaise(data['interest']),
    );
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
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
