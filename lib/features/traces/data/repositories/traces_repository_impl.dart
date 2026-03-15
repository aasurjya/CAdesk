import 'package:dio/dio.dart';

import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';
import 'package:ca_app/features/traces/data/mock_traces_repository.dart';
import 'package:ca_app/features/traces/data/services/traces_service.dart';
import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';
import 'package:ca_app/features/traces/domain/repositories/traces_repository.dart';

/// Live HTTP implementation of [TracesRepository].
///
/// Each method calls the corresponding [TracesService] static method.
///
/// When [useRealService] is `false` (the default for development) every call
/// falls through to [_mock] so the app works without live TRACES credentials.
/// Set `useRealService: true` only when the `traces_real_repo` feature flag
/// is enabled (handled by [tracesRepositoryProvider]).
///
/// Portal exceptions ([PortalAuthException], [PortalRateLimitException],
/// [PortalUnavailableException]) are always re-thrown — callers decide whether
/// to show an error or retry.
class TracesRepositoryImpl implements TracesRepository {
  const TracesRepositoryImpl({
    required this.dio,
    required this.credentialRepository,
    this.useRealService = false,
  });

  final Dio dio;
  final PortalCredentialRepository credentialRepository;

  /// When `true`, every method delegates to [TracesService].
  /// When `false`, the mock is used as a fallback.
  final bool useRealService;

  static final MockTracesRepository _mock = MockTracesRepository();

  // -------------------------------------------------------------------------
  // TracesRepository interface
  // -------------------------------------------------------------------------

  @override
  Future<TracesPanVerification> verifyPan(String pan) async {
    if (pan.length != 10) {
      throw ArgumentError.value(
        pan,
        'pan',
        'PAN must be exactly 10 characters',
      );
    }
    if (!useRealService) return _mock.verifyPan(pan);
    try {
      return await TracesService.verifyPan(
        pan,
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
  Future<TracesChallanStatus> getChallanStatus(
    String bsrCode,
    DateTime date,
    String serial,
    String tan,
  ) async {
    if (!useRealService) {
      return _mock.getChallanStatus(bsrCode, date, serial, tan);
    }
    try {
      return await TracesService.getChallanStatus(
        bsrCode,
        date,
        serial,
        tan,
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
  Future<TracesForm16Request> requestForm16(
    String tan,
    String pan,
    int financialYear,
  ) async {
    if (!useRealService) {
      return _mock.requestForm16(tan, pan, financialYear);
    }
    try {
      return await TracesService.requestForm16(
        tan,
        pan,
        financialYear,
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
  Future<List<TracesForm16Request>> requestBulkForm16(
    String tan,
    int financialYear,
    List<String> pans,
  ) async {
    if (!useRealService) {
      return _mock.requestBulkForm16(tan, financialYear, pans);
    }
    try {
      return await TracesService.requestBulkForm16(
        tan,
        financialYear,
        pans,
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
  Future<TracesJustificationReport> getJustificationReport(
    String tan,
    int financialYear,
    int quarter,
  ) async {
    if (!useRealService) {
      return _mock.getJustificationReport(tan, financialYear, quarter);
    }
    try {
      return await TracesService.getJustificationReport(
        tan,
        financialYear,
        quarter,
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
  Future<List<TracesChallanStatus>> getAllChallans(
    String tan,
    int financialYear,
  ) async {
    if (!useRealService) {
      return _mock.getAllChallans(tan, financialYear);
    }
    try {
      return await TracesService.getAllChallans(
        tan,
        financialYear,
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
