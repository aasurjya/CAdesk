import 'package:ca_app/features/e_verification/domain/models/evc_request.dart';

/// Mock API client for UIDAI e-Sign gateway integration.
///
/// In production this would make authenticated HTTPS calls to the
/// UIDAI ASP (Application Service Provider) endpoint.  This mock
/// returns successful verification after a simulated network delay.
class ESignApiClient {
  ESignApiClient._();

  /// Singleton instance.
  static final ESignApiClient instance = ESignApiClient._();

  /// In-memory store mapping PAN → last issued [EvcRequest].
  final Map<String, EvcRequest> _requestStore = {};

  // ── requestESign ──────────────────────────────────────────────────────

  /// Initiates an Aadhaar e-Sign request for [aadhaarNumber].
  ///
  /// [documentHash] is the SHA-256 hex digest of the document to be signed.
  ///
  /// Returns an [EvcRequest] in [EvcStatus.otpSent] state with a masked
  /// mobile and mock OTP for testing.
  Future<EvcRequest> requestESign(
    String documentHash,
    String aadhaarNumber,
  ) async {
    // Simulate network latency.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final pan = _derivePanFromAadhaar(aadhaarNumber);
    final request = EvcRequest(
      pan: pan,
      mobile: _maskMobile(aadhaarNumber),
      email: 'es***@uidai.gov.in',
      evcMethod: EvcMethod.aadhaarOtp,
      otp: '123456',
      otpExpiry: DateTime.now().add(const Duration(minutes: 15)),
      status: EvcStatus.otpSent,
    );

    _requestStore[pan] = request;
    return request;
  }

  // ── checkESignStatus ──────────────────────────────────────────────────

  /// Checks the status of a previously initiated e-Sign request.
  ///
  /// [requestId] here is the PAN used to look up the stored request.
  ///
  /// Returns:
  ///   - [EvcStatus.verified] if the request exists in the store.
  ///   - [EvcStatus.failed] for unknown request identifiers.
  Future<EvcRequest> checkESignStatus(String requestId) async {
    // Simulate network latency.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final stored = _requestStore[requestId];
    if (stored != null) {
      return stored.copyWith(status: EvcStatus.verified);
    }

    return EvcRequest(
      pan: requestId,
      mobile: 'XXXXXX0000',
      email: 'unknown@example.com',
      evcMethod: EvcMethod.aadhaarOtp,
      status: EvcStatus.failed,
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────

  /// Derives a deterministic mock PAN from an Aadhaar number.
  ///
  /// This is purely for mock/test purposes — no real Aadhaar-PAN
  /// linking is performed here.
  static String _derivePanFromAadhaar(String aadhaarNumber) {
    // Use last 6 digits to build a mock PAN: AAAAA<last6>
    final tail = aadhaarNumber.length >= 6
        ? aadhaarNumber.substring(aadhaarNumber.length - 6)
        : aadhaarNumber.padLeft(6, '0');
    return 'AAAAA${tail}Z';
  }

  static String _maskMobile(String aadhaarNumber) {
    // Show last 4 digits of Aadhaar as mock mobile tail.
    final tail = aadhaarNumber.length >= 4
        ? aadhaarNumber.substring(aadhaarNumber.length - 4)
        : aadhaarNumber;
    return 'XXXXXX$tail';
  }
}
