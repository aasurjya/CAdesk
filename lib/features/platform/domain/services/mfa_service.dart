import 'dart:math';

import 'package:ca_app/features/platform/domain/models/mfa_setup.dart';

/// Stateless singleton providing MFA (Multi-Factor Authentication) operations.
///
/// TOTP generation uses a simplified mock algorithm suitable for testing.
/// Production code should use HMAC-SHA1 per RFC 6238.
class MfaService {
  MfaService._();

  static final MfaService instance = MfaService._();

  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const String _alphanumericChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // TOTP
  // ---------------------------------------------------------------------------

  /// Generates a random 16-character base32 TOTP secret.
  String generateTotpSecret() {
    return List.generate(
      16,
      (_) => _base32Chars[_random.nextInt(_base32Chars.length)],
    ).join();
  }

  /// Generates a 6-digit TOTP code for [secret] at [time].
  ///
  /// Mock algorithm: `(secret.hashCode XOR counter) mod 1_000_000`
  /// where counter = epoch-milliseconds / 30_000.
  String generateTotp(String secret, DateTime time) {
    final counter = time.millisecondsSinceEpoch ~/ 30000;
    final code = (secret.hashCode ^ counter).abs() % 1000000;
    return code.toString().padLeft(6, '0');
  }

  /// Returns true if [code] matches the TOTP for [secret] at [time],
  /// checking [window] adjacent time-steps in each direction.
  bool verifyTotp(
    String secret,
    String code,
    DateTime time, {
    int window = 1,
  }) {
    for (var offset = -window; offset <= window; offset++) {
      final offsetTime = time.add(Duration(seconds: offset * 30));
      if (generateTotp(secret, offsetTime) == code) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Backup codes
  // ---------------------------------------------------------------------------

  /// Generates 10 unique 8-character uppercase alphanumeric backup codes.
  List<String> generateBackupCodes() {
    final codes = <String>{};
    while (codes.length < 10) {
      codes.add(_randomCode(8));
    }
    return codes.toList(growable: false);
  }

  String _randomCode(int length) {
    return List.generate(
      length,
      (_) => _alphanumericChars[_random.nextInt(_alphanumericChars.length)],
    ).join();
  }

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------

  /// Creates and returns an unverified [MfaSetup] for [userId].
  MfaSetup setupMfa(String userId, MfaMethod method) {
    return MfaSetup(
      userId: userId,
      method: method,
      secret: generateTotpSecret(),
      backupCodes: generateBackupCodes(),
      isVerified: false,
      setupAt: DateTime.now(),
    );
  }
}
