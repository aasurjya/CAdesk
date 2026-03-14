import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:ca_app/features/gstn_api/domain/models/gstin_details.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gst_notice.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

// ---------------------------------------------------------------------------
// Base-URL constant — overridable via --dart-define for dev/staging/prod.
// ---------------------------------------------------------------------------

const String _kGstnBaseUrl = String.fromEnvironment(
  'GSTN_API_BASE_URL',
  defaultValue: 'https://api.gstn.gov.in',
);

const String _kPortal = 'GSTN';

/// GSTN checksum weights used in the Luhn-style checksum algorithm.
const List<int> _kChecksumWeights = [
  1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, // 14 weights for chars 1-14
];

const String _kCharset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// Service providing GSTN portal API integration.
///
/// All methods are static and accept a [Dio] client so they can be tested
/// by injecting a mock/stub client. Credentials are resolved from the
/// [PortalCredentialRepository] at call time — no state is held here.
class GstnApiService {
  GstnApiService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Search for a GSTIN and return full taxpayer details.
  ///
  /// Throws [PortalAuthException] on 401/403.
  /// Throws [PortalRateLimitException] on 429.
  /// Throws [PortalUnavailableException] on 5xx / network errors.
  static Future<GstinDetails> searchGstin(
    String gstin, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/taxpayerapi/v2.0/search/$gstin',
      apiKey: apiKey,
    );
    return _parseGstinDetails(_decodeBody(response.data));
  }

  /// Get the filing status of a specific return for a GSTIN / period.
  static Future<GstnFilingStatus> getFilingStatus(
    String gstin,
    String returnType,
    String period, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/returns/v2.0/returns/statu',
      apiKey: apiKey,
      queryParameters: {
        'gstin': gstin,
        'ret_period': period,
        'rtntype': returnType.toUpperCase(),
      },
    );
    return _parseFilingStatus(
      _decodeBody(response.data),
      gstin: gstin,
      returnType: returnType,
      period: period,
    );
  }

  /// Get the GSTR-1 filing status for a GSTIN and period.
  static Future<GstnFilingStatus> getGstr1Status(
    String gstin,
    String period, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) {
    return getFilingStatus(
      gstin,
      'GSTR1',
      period,
      dio: dio,
      credentialRepository: credentialRepository,
    );
  }

  /// Get the GSTR-3B filing status for a GSTIN and period.
  static Future<GstnFilingStatus> getGstr3bStatus(
    String gstin,
    String period, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) {
    return getFilingStatus(
      gstin,
      'GSTR3B',
      period,
      dio: dio,
      credentialRepository: credentialRepository,
    );
  }

  /// Validate a GSTIN: format check first, then GSTN checksum.
  ///
  /// Returns `true` only if the GSTIN is syntactically valid AND passes the
  /// official check-character algorithm.
  static bool validateGstin(String gstin) {
    if (!_isValidGstinFormat(gstin)) return false;
    return _isChecksumValid(gstin);
  }

  /// Retrieve all notices issued to a GSTIN.
  static Future<List<GstNotice>> getNotices(
    String gstin, {
    required Dio dio,
    required PortalCredentialRepository credentialRepository,
  }) async {
    final apiKey = await _resolveApiKey(credentialRepository);
    final response = await _get(
      dio: dio,
      path: '/notices/v1.0/notices',
      apiKey: apiKey,
      queryParameters: {'gstin': gstin},
    );
    final body = _decodeBody(response.data);
    final list = body['notices'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_parseNotice)
        .toList(growable: false);
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
        '$_kGstnBaseUrl$path',
        queryParameters: queryParameters,
        options: Options(headers: {'gstin-apikey': apiKey}),
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
            'Authentication failed. Check your GSTN API key.',
        statusCode: status,
      );
    }

    if (status == 429) {
      final retryAfter = _parseRetryAfter(e.response?.headers);
      throw PortalRateLimitException(
        portal: _kPortal,
        message:
            _extractMessage(e.response?.data) ??
            'GSTN API rate limit exceeded.',
        retryAfterSeconds: retryAfter,
      );
    }

    // 5xx or connectivity issues
    throw PortalUnavailableException(
      portal: _kPortal,
      message:
          _extractMessage(e.response?.data) ??
          e.message ??
          'GSTN portal is currently unavailable.',
      statusCode: status,
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers — credentials
  // -------------------------------------------------------------------------

  static Future<String> _resolveApiKey(PortalCredentialRepository repo) async {
    final credential = await repo.getCredential(PortalType.gstn);
    final token = credential?.grantToken ?? credential?.encryptedPassword;
    if (token == null || token.isEmpty) {
      throw const PortalAuthException(
        portal: _kPortal,
        message:
            'No GSTN API key configured. Please add credentials in '
            'Settings → Portal Connectors → GSTN.',
      );
    }
    return token;
  }

  // -------------------------------------------------------------------------
  // Private helpers — parsing
  // -------------------------------------------------------------------------

  static GstinDetails _parseGstinDetails(Map<String, dynamic> data) {
    final taxpayer = (data['taxpayerInfo'] as Map<String, dynamic>?) ?? data;
    final freq = (taxpayer['rstk'] as String? ?? 'M').toUpperCase();
    return GstinDetails(
      gstin: taxpayer['gstin'] as String? ?? '',
      legalName: taxpayer['lgnm'] as String? ?? '',
      tradeName: taxpayer['tradeNam'] as String? ?? '',
      address: _buildAddress(taxpayer['pradr'] as Map<String, dynamic>?),
      registrationDate: _parseDate(taxpayer['rgdt'] as String?),
      status: _parseRegistrationStatus(taxpayer['sts'] as String?),
      stateCode: taxpayer['stjCd'] as String? ?? '',
      constitutionType: taxpayer['ctb'] as String? ?? '',
      returnFilingFrequency: freq == 'Q'
          ? ReturnFilingFrequency.quarterly
          : ReturnFilingFrequency.monthly,
    );
  }

  static String _buildAddress(Map<String, dynamic>? addr) {
    if (addr == null) return '';
    final parts = <String>[
      addr['bno'] as String? ?? '',
      addr['flno'] as String? ?? '',
      addr['loc'] as String? ?? '',
      addr['dst'] as String? ?? '',
      addr['stcd'] as String? ?? '',
      addr['pncd'] as String? ?? '',
    ].where((s) => s.isNotEmpty).toList();
    return parts.join(', ');
  }

  static GstnRegistrationStatus _parseRegistrationStatus(String? sts) {
    switch ((sts ?? '').toUpperCase()) {
      case 'ACTIVE':
        return GstnRegistrationStatus.active;
      case 'CANCELLED':
        return GstnRegistrationStatus.cancelled;
      default:
        return GstnRegistrationStatus.suspended;
    }
  }

  static GstnFilingStatus _parseFilingStatus(
    Map<String, dynamic> data, {
    required String gstin,
    required String returnType,
    required String period,
  }) {
    final filingData = (data['filing'] as Map<String, dynamic>?) ?? data;
    final statusStr = (filingData['status'] as String? ?? 'NF').toUpperCase();
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: _parseReturnStatus(statusStr),
      arn: filingData['arn'] as String?,
      filedAt: _parseDateOpt(filingData['dof'] as String?),
    );
  }

  static GstnReturnType _parseReturnType(String returnType) {
    switch (returnType.toUpperCase()) {
      case 'GSTR1':
        return GstnReturnType.gstr1;
      case 'GSTR3B':
        return GstnReturnType.gstr3b;
      case 'GSTR9':
        return GstnReturnType.gstr9;
      case 'GSTR9C':
        return GstnReturnType.gstr9c;
      default:
        return GstnReturnType.gstr1;
    }
  }

  static GstnReturnStatus _parseReturnStatus(String status) {
    switch (status) {
      case 'NF':
        return GstnReturnStatus.notFiled;
      case 'SAV':
        return GstnReturnStatus.saved;
      case 'SUB':
        return GstnReturnStatus.submitted;
      case 'CNF':
      case 'FIL':
        return GstnReturnStatus.filed;
      case 'PRO':
        return GstnReturnStatus.processed;
      case 'REJ':
        return GstnReturnStatus.rejected;
      default:
        return GstnReturnStatus.notFiled;
    }
  }

  static GstNotice _parseNotice(Map<String, dynamic> data) {
    return GstNotice(
      noticeId: data['noticeId'] as String? ?? '',
      type: data['noticeType'] as String? ?? '',
      issuedDate: _parseDate(data['issuedDate'] as String?),
      dueDate: _parseDate(data['dueDate'] as String?),
      description: data['description'] as String? ?? '',
      status: _parseNoticeStatus(data['status'] as String?),
    );
  }

  static GstNoticeStatus _parseNoticeStatus(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'REPLIED':
        return GstNoticeStatus.replied;
      case 'CLOSED':
        return GstNoticeStatus.closed;
      case 'PENDING_HEARING':
        return GstNoticeStatus.pendingHearing;
      default:
        return GstNoticeStatus.open;
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers — GSTIN validation
  // -------------------------------------------------------------------------

  /// GSTIN format: [0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}
  static final RegExp _kGstinPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );

  static bool _isValidGstinFormat(String gstin) {
    if (gstin.length != 15) return false;
    return _kGstinPattern.hasMatch(gstin.toUpperCase());
  }

  /// Validates the 15th check character of a GSTIN using the standard
  /// modulus-36 Luhn-style algorithm defined by GSTN.
  static bool _isChecksumValid(String gstin) {
    final upper = gstin.toUpperCase();
    var sum = 0;
    for (var i = 0; i < 14; i++) {
      final charIndex = _kCharset.indexOf(upper[i]);
      if (charIndex < 0) return false;
      final product = charIndex * _kChecksumWeights[i];
      sum += (product ~/ 36) + (product % 36);
    }
    final checkIndex = (36 - (sum % 36)) % 36;
    return _kCharset[checkIndex] == upper[14];
  }

  // -------------------------------------------------------------------------
  // Private helpers — general utilities
  // -------------------------------------------------------------------------

  static DateTime _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime(2000);
    try {
      // GSTN dates are DD/MM/YYYY
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

  /// Decodes [data] to [Map<String, dynamic>] regardless of whether Dio
  /// has already decoded it (Map) or returned it as a JSON String.
  static Map<String, dynamic> _decodeBody(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return const {};
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
