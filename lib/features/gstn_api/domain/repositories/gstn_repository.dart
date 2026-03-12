import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_token.dart';

/// Abstract interface for GSTN portal operations.
///
/// Domain-layer business logic depends on this interface only.
/// Concrete implementations (mock, live HTTP) live in the data layer.
abstract class GstnRepository {
  /// Verify a GSTIN and return registration details.
  ///
  /// [gstin] must be a 15-character GST Identification Number.
  Future<GstnVerificationResult> verifyGstin(String gstin);

  /// Save a draft return payload to the GSTN portal.
  ///
  /// [returnType] is the string name of the return (e.g. "GSTR1").
  /// [period] is in MMYYYY format.
  /// [jsonPayload] is the serialised return data as a JSON string.
  Future<GstnFilingStatus> saveReturn(
    String gstin,
    String returnType,
    String period,
    String jsonPayload,
  );

  /// Submit a previously saved return, locking it for filing.
  Future<GstnFilingStatus> submitReturn(
    String gstin,
    String returnType,
    String period,
  );

  /// File a submitted return using an EVC/DSC OTP.
  ///
  /// On success the return receives an ARN and status becomes filed.
  Future<GstnFilingStatus> fileReturn(
    String gstin,
    String returnType,
    String period,
    String otp,
  );

  /// Retrieve the current filing status of a return.
  Future<GstnFilingStatus> getFilingStatus(
    String gstin,
    String returnType,
    String period,
  );

  /// Fetch the auto-drafted GSTR-2B ITC statement for a period.
  Future<Gstr2bFetchResult> fetchGstr2b(String gstin, String period);

  /// Obtain an access token for the given GSTIN credentials.
  ///
  /// [otp] is the EVC (electronic verification code) received via SMS.
  Future<GstnToken> getToken(String gstin, String username, String otp);
}
