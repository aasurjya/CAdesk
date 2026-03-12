/// Second-factor authentication method.
enum MfaMethod {
  /// Time-based One-Time Password (authenticator app).
  totp,

  /// SMS one-time code.
  sms,

  /// Email one-time code.
  email,
}

/// Immutable snapshot of a user's MFA enrollment state.
class MfaSetup {
  const MfaSetup({
    required this.userId,
    required this.method,
    required this.secret,
    required this.backupCodes,
    required this.isVerified,
    required this.setupAt,
  });

  final String userId;
  final MfaMethod method;

  /// TOTP secret (base32 encoded). Masked in UI after initial display.
  final String secret;

  /// One-time backup codes (shown once at setup).
  final List<String> backupCodes;

  final bool isVerified;
  final DateTime setupAt;

  MfaSetup copyWith({
    String? userId,
    MfaMethod? method,
    String? secret,
    List<String>? backupCodes,
    bool? isVerified,
    DateTime? setupAt,
  }) {
    return MfaSetup(
      userId: userId ?? this.userId,
      method: method ?? this.method,
      secret: secret ?? this.secret,
      backupCodes: backupCodes ?? this.backupCodes,
      isVerified: isVerified ?? this.isVerified,
      setupAt: setupAt ?? this.setupAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MfaSetup &&
        other.userId == userId &&
        other.method == method;
  }

  @override
  int get hashCode => Object.hash(userId, method);

  @override
  String toString() =>
      'MfaSetup(userId: $userId, method: $method, isVerified: $isVerified)';
}
