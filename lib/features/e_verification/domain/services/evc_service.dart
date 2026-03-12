import 'dart:convert';

import 'package:ca_app/features/e_verification/domain/models/evc_request.dart';
import 'package:crypto/crypto.dart';

/// Stateless service for EVC (Electronic Verification Code) generation
/// and OTP-based e-verification flows.
///
/// All methods return new immutable instances — no state is mutated.
class EvcService {
  EvcService._();

  // ── EVC initiation ────────────────────────────────────────────────────

  /// Creates a new [EvcRequest] in [EvcStatus.pending] state.
  ///
  /// [pan] is the taxpayer's PAN. [method] selects the verification channel.
  static EvcRequest initiateEvc(String pan, EvcMethod method) {
    return EvcRequest(
      pan: pan,
      mobile: _maskMobile('XXXXXXXXXX'),
      email: 'te***@gmail.com',
      evcMethod: method,
      status: EvcStatus.pending,
    );
  }

  // ── OTP generation ────────────────────────────────────────────────────

  /// Generates an OTP for [request] and returns the updated request.
  ///
  /// In test/mock mode the OTP is always `"123456"`.
  /// The expiry is set to now + 15 minutes.
  static EvcRequest generateOtp(EvcRequest request) {
    final expiry = DateTime.now().add(const Duration(minutes: 15));
    return request.copyWith(
      otp: _testOtp,
      otpExpiry: expiry,
      status: EvcStatus.otpSent,
    );
  }

  // ── OTP verification ──────────────────────────────────────────────────

  /// Verifies [enteredOtp] against [request].
  ///
  /// Returns:
  ///   - [EvcStatus.verified] on match (and not expired).
  ///   - [EvcStatus.failed] on mismatch or expiry.
  static EvcRequest verifyOtp(EvcRequest request, String enteredOtp) {
    if (isOtpExpired(request)) {
      return request.copyWith(status: EvcStatus.failed);
    }
    if (request.otp == enteredOtp) {
      return request.copyWith(status: EvcStatus.verified);
    }
    return request.copyWith(status: EvcStatus.failed);
  }

  // ── Expiry check ──────────────────────────────────────────────────────

  /// Returns `true` when [request]'s OTP has expired.
  ///
  /// Returns `false` when no expiry has been set (OTP not yet generated).
  static bool isOtpExpired(EvcRequest request) {
    final expiry = request.otpExpiry;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  // ── EVC code generation ───────────────────────────────────────────────

  /// Generates a 10-character alphanumeric EVC code for [pan].
  ///
  /// The code is derived deterministically from the PAN using SHA-256,
  /// ensuring the same PAN always yields the same code in a session.
  /// Real EVC codes are issued by the ITD backend.
  static String generateEvcCode(String pan) {
    final bytes = utf8.encode(pan);
    final digest = sha256.convert(bytes);
    // Take first 10 hex digits and upper-case them.
    return digest.toString().substring(0, 10).toUpperCase();
  }

  // ── Private helpers ───────────────────────────────────────────────────

  static const String _testOtp = '123456';

  static String _maskMobile(String mobile) {
    if (mobile.length < 4) return mobile;
    return 'XXXXXX${mobile.substring(mobile.length - 4)}';
  }
}
