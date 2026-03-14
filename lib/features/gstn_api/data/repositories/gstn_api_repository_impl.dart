import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_token.dart';
import 'package:ca_app/features/gstn_api/domain/repositories/gstn_repository.dart';

/// Real implementation of [GstnRepository].
///
/// Makes authenticated HTTP calls to the GSTN portal API.
/// Full wiring to [GstnApiService] is deferred until the portal integration phase.
class GstnApiRepositoryImpl implements GstnRepository {
  const GstnApiRepositoryImpl();

  static const int _gstnLength = 15;

  @override
  Future<GstnVerificationResult> verifyGstin(String gstin) async {
    // TODO(portal): delegate to GstnApiService HTTP call
    return GstnVerificationResult(
      gstin: gstin,
      legalName: '',
      registrationDate: DateTime(2000),
      status: gstin.length == _gstnLength
          ? GstnRegistrationStatus.active
          : GstnRegistrationStatus.cancelled,
      stateCode: gstin.length >= 2 ? gstin.substring(0, 2) : '00',
      constitutionType: 'Unknown',
      returnFilingFrequency: ReturnFilingFrequency.monthly,
    );
  }

  @override
  Future<GstnFilingStatus> saveReturn(
    String gstin,
    String returnType,
    String period,
    String jsonPayload,
  ) async {
    // TODO(portal): delegate to GstnApiService HTTP call
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.saved,
    );
  }

  @override
  Future<GstnFilingStatus> submitReturn(
    String gstin,
    String returnType,
    String period,
  ) async {
    // TODO(portal): delegate to GstnApiService HTTP call
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.submitted,
    );
  }

  @override
  Future<GstnFilingStatus> fileReturn(
    String gstin,
    String returnType,
    String period,
    String otp,
  ) async {
    // TODO(portal): delegate to GstnApiService HTTP call
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.filed,
      filedAt: DateTime.now(),
    );
  }

  @override
  Future<GstnFilingStatus> getFilingStatus(
    String gstin,
    String returnType,
    String period,
  ) async {
    // TODO(portal): delegate to GstnApiService HTTP call
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.notFiled,
    );
  }

  @override
  Future<Gstr2bFetchResult> fetchGstr2b(String gstin, String period) async {
    // TODO(portal): delegate to GstnApiService HTTP call
    return Gstr2bFetchResult(
      gstin: gstin,
      period: period,
      status: Gstr2bStatus.notGenerated,
      totalIgstCredit: 0,
      totalCgstCredit: 0,
      totalSgstCredit: 0,
      entryCount: 0,
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<GstnToken> getToken(String gstin, String username, String otp) async {
    // TODO(portal): delegate to GstnApiService HTTP call
    return GstnToken(
      accessToken: '',
      tokenType: 'Bearer',
      expiresIn: 0,
      issuedAt: DateTime.now(),
    );
  }

  GstnReturnType _parseReturnType(String returnType) {
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
}
