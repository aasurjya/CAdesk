import 'dart:math';

import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_token.dart';
import 'package:ca_app/features/gstn_api/domain/repositories/gstn_repository.dart';

/// In-memory mock implementation of [GstnRepository].
///
/// Returns deterministic fake data suitable for unit tests and local
/// development without requiring live GSTN API credentials.
class MockGstnRepository implements GstnRepository {
  static const int _tokenLifetimeSeconds = 6 * 3600; // 6 hours
  static const int _gstnLength = 15;

  final Random _random = Random(42); // fixed seed for determinism

  // ---------------------------------------------------------------------------
  // GstnRepository interface
  // ---------------------------------------------------------------------------

  @override
  Future<GstnVerificationResult> verifyGstin(String gstin) async {
    if (gstin.length != _gstnLength) {
      return _invalidVerificationResult(gstin);
    }
    return _activeVerificationResult(gstin);
  }

  @override
  Future<GstnFilingStatus> saveReturn(
    String gstin,
    String returnType,
    String period,
    String jsonPayload,
  ) async {
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.saved,
      arn: _generateArn(gstin, period),
    );
  }

  @override
  Future<GstnFilingStatus> submitReturn(
    String gstin,
    String returnType,
    String period,
  ) async {
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.submitted,
      arn: _generateArn(gstin, period),
    );
  }

  @override
  Future<GstnFilingStatus> fileReturn(
    String gstin,
    String returnType,
    String period,
    String otp,
  ) async {
    final now = DateTime.now();
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.filed,
      arn: _generateArn(gstin, period),
      filedAt: now,
    );
  }

  @override
  Future<GstnFilingStatus> getFilingStatus(
    String gstin,
    String returnType,
    String period,
  ) async {
    return GstnFilingStatus(
      gstin: gstin,
      returnType: _parseReturnType(returnType),
      period: period,
      status: GstnReturnStatus.filed,
      arn: _generateArn(gstin, period),
      filedAt: DateTime(2024, 3, 11, 10, 30),
    );
  }

  @override
  Future<Gstr2bFetchResult> fetchGstr2b(String gstin, String period) async {
    return Gstr2bFetchResult(
      gstin: gstin,
      period: period,
      status: Gstr2bStatus.generated,
      totalIgstCredit: 500000,
      totalCgstCredit: 250000,
      totalSgstCredit: 250000,
      entryCount: 25,
      generatedAt: DateTime(2024, 3, 10, 14, 0),
    );
  }

  @override
  Future<GstnToken> getToken(String gstin, String username, String otp) async {
    return GstnToken(
      accessToken: _generateAccessToken(gstin),
      tokenType: 'Bearer',
      expiresIn: _tokenLifetimeSeconds,
      issuedAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  GstnVerificationResult _activeVerificationResult(String gstin) {
    final stateCode = gstin.substring(0, 2);
    return GstnVerificationResult(
      gstin: gstin,
      legalName: 'ABC Private Limited',
      tradeName: 'ABC Traders',
      registrationDate: DateTime(2017, 7, 1),
      status: GstnRegistrationStatus.active,
      stateCode: stateCode,
      constitutionType: 'Private Limited Company',
      returnFilingFrequency: ReturnFilingFrequency.monthly,
    );
  }

  GstnVerificationResult _invalidVerificationResult(String gstin) {
    return GstnVerificationResult(
      gstin: gstin,
      legalName: 'Unknown',
      registrationDate: DateTime(2000),
      status: GstnRegistrationStatus.cancelled,
      stateCode: '00',
      constitutionType: 'Unknown',
      returnFilingFrequency: ReturnFilingFrequency.monthly,
    );
  }

  /// Parses a return type string (case-insensitive) to [GstnReturnType].
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

  /// Generates an ARN in the format: AA + 2-digit state + 8-digit date + 7-digit seq.
  ///
  /// Example: "AA2903210365234"
  String _generateArn(String gstin, String period) {
    final stateCode = gstin.length >= 2 ? gstin.substring(0, 2) : '00';
    // Use period as part of deterministic date portion (DDMMYYYY)
    final mm = period.length >= 2 ? period.substring(0, 2) : '01';
    final yyyy = period.length >= 6 ? period.substring(2, 6) : '2024';
    final datePart = '01$mm$yyyy'; // 8 chars: DD + MM + YYYY
    final seqPart = _random.nextInt(9999999).toString().padLeft(7, '0');
    return 'AA$stateCode$datePart$seqPart';
  }

  /// Generates a pseudo-random access token string for a given GSTIN.
  String _generateAccessToken(String gstin) {
    final seed = gstin.codeUnits.fold(0, (a, b) => a + b);
    final rng = Random(seed);
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(64, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
