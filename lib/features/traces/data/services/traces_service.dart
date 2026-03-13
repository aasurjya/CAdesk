import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';
import 'package:ca_app/features/traces/domain/models/ais_data.dart';
import 'package:ca_app/features/traces/domain/models/form16_certificate.dart';
import 'package:ca_app/features/traces/domain/models/form26as_data.dart';

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
      body: {
        'pan': pan.toUpperCase(),
        'assessmentYear': assessmentYear,
      },
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
        message: _extractMessage(e.response?.data) ??
            'TRACES authentication failed. Please re-login.',
        statusCode: status,
      );
    }

    if (status == 429) {
      final retryAfter = _parseRetryAfter(e.response?.headers);
      throw PortalRateLimitException(
        portal: _kPortal,
        message: _extractMessage(e.response?.data) ??
            'TRACES rate limit exceeded.',
        retryAfterSeconds: retryAfter,
      );
    }

    throw PortalUnavailableException(
      portal: _kPortal,
      message: _extractMessage(e.response?.data) ??
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
        message: 'TRACES session has expired or no credentials configured. '
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
