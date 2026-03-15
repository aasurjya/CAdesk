import 'package:dio/dio.dart';

import 'package:ca_app/features/gstn_api/data/mock_gstn_repository.dart';
import 'package:ca_app/features/gstn_api/data/services/gstn_api_service.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_token.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
import 'package:ca_app/features/gstn_api/domain/repositories/gstn_repository.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

/// Live HTTP implementation of [GstnRepository].
///
/// Each method calls the corresponding [GstnApiService] static method and
/// maps its result to the domain type.
///
/// When [useRealService] is `false` (the default for development) every call
/// falls through to [_mock] so the app works without live GSTN credentials.
/// Set `useRealService: true` only when the `gstn_api_real_repo` feature flag
/// is enabled (handled by [GstnApiRepositoryProvider]).
///
/// Portal exceptions ([PortalAuthException], [PortalRateLimitException],
/// [PortalUnavailableException]) are always re-thrown — callers decide whether
/// to show an error or retry.
class GstnApiRepositoryImpl implements GstnRepository {
  const GstnApiRepositoryImpl({
    required this.dio,
    required this.credentialRepository,
    this.useRealService = false,
  });

  final Dio dio;
  final PortalCredentialRepository credentialRepository;

  /// When `true`, every method delegates to [GstnApiService].
  /// When `false`, the mock is used as a fallback.
  final bool useRealService;

  static final MockGstnRepository _mock = MockGstnRepository();

  // -------------------------------------------------------------------------
  // GstnRepository interface
  // -------------------------------------------------------------------------

  @override
  Future<GstnVerificationResult> verifyGstin(String gstin) async {
    if (!useRealService) return _mock.verifyGstin(gstin);
    try {
      final details = await GstnApiService.searchGstin(
        gstin,
        dio: dio,
        credentialRepository: credentialRepository,
      );
      return GstnVerificationResult(
        gstin: details.gstin,
        legalName: details.legalName,
        tradeName: details.tradeName.isNotEmpty ? details.tradeName : null,
        registrationDate: details.registrationDate,
        status: details.status,
        stateCode: details.stateCode,
        constitutionType: details.constitutionType,
        returnFilingFrequency: details.returnFilingFrequency,
      );
    } on PortalAuthException {
      rethrow;
    } on PortalRateLimitException {
      rethrow;
    } on PortalUnavailableException {
      rethrow;
    }
  }

  @override
  Future<GstnFilingStatus> saveReturn(
    String gstin,
    String returnType,
    String period,
    String jsonPayload,
  ) async {
    if (!useRealService) {
      return _mock.saveReturn(gstin, returnType, period, jsonPayload);
    }
    try {
      return await GstnApiService.saveReturn(
        gstin,
        returnType,
        period,
        jsonPayload,
        dio: dio,
        credentialRepository: credentialRepository,
      );
    } on PortalAuthException {
      rethrow;
    } on PortalRateLimitException {
      rethrow;
    } on PortalUnavailableException {
      rethrow;
    }
  }

  @override
  Future<GstnFilingStatus> submitReturn(
    String gstin,
    String returnType,
    String period,
  ) async {
    if (!useRealService) {
      return _mock.submitReturn(gstin, returnType, period);
    }
    try {
      return await GstnApiService.submitReturn(
        gstin,
        returnType,
        period,
        dio: dio,
        credentialRepository: credentialRepository,
      );
    } on PortalAuthException {
      rethrow;
    } on PortalRateLimitException {
      rethrow;
    } on PortalUnavailableException {
      rethrow;
    }
  }

  @override
  Future<GstnFilingStatus> fileReturn(
    String gstin,
    String returnType,
    String period,
    String otp,
  ) async {
    if (!useRealService) {
      return _mock.fileReturn(gstin, returnType, period, otp);
    }
    try {
      return await GstnApiService.fileReturn(
        gstin,
        returnType,
        period,
        otp,
        dio: dio,
        credentialRepository: credentialRepository,
      );
    } on PortalAuthException {
      rethrow;
    } on PortalRateLimitException {
      rethrow;
    } on PortalUnavailableException {
      rethrow;
    }
  }

  @override
  Future<GstnFilingStatus> getFilingStatus(
    String gstin,
    String returnType,
    String period,
  ) async {
    if (!useRealService) {
      return _mock.getFilingStatus(gstin, returnType, period);
    }
    try {
      return await GstnApiService.getFilingStatus(
        gstin,
        returnType,
        period,
        dio: dio,
        credentialRepository: credentialRepository,
      );
    } on PortalAuthException {
      rethrow;
    } on PortalRateLimitException {
      rethrow;
    } on PortalUnavailableException {
      rethrow;
    }
  }

  @override
  Future<Gstr2bFetchResult> fetchGstr2b(String gstin, String period) async {
    if (!useRealService) return _mock.fetchGstr2b(gstin, period);
    try {
      return await GstnApiService.fetchGstr2b(
        gstin,
        period,
        dio: dio,
        credentialRepository: credentialRepository,
      );
    } on PortalAuthException {
      rethrow;
    } on PortalRateLimitException {
      rethrow;
    } on PortalUnavailableException {
      rethrow;
    }
  }

  @override
  Future<GstnToken> getToken(
    String gstin,
    String username,
    String otp,
  ) async {
    if (!useRealService) return _mock.getToken(gstin, username, otp);
    try {
      return await GstnApiService.getToken(
        gstin,
        username,
        otp,
        dio: dio,
        credentialRepository: credentialRepository,
      );
    } on PortalAuthException {
      rethrow;
    } on PortalRateLimitException {
      rethrow;
    } on PortalUnavailableException {
      rethrow;
    }
  }
}
