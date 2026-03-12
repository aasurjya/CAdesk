<<<<<<< HEAD
// ignore_for_file: public_member_api_docs

/// Supported MFA methods.
enum MfaMethod { totp, sms, email }

/// Immutable record of an MFA setup for a user.
final class MfaSetup {
=======
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
>>>>>>> worktree-agent-ad3dc1f5
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
<<<<<<< HEAD
  final String secret;
  final List<String> backupCodes;
=======

  /// TOTP secret (base32 encoded). Masked in UI after initial display.
  final String secret;

  /// One-time backup codes (shown once at setup).
  final List<String> backupCodes;

>>>>>>> worktree-agent-ad3dc1f5
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

<<<<<<< HEAD
  /// Equality is based on [userId] and [method].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MfaSetup &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          method == other.method;
=======
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MfaSetup &&
        other.userId == userId &&
        other.method == method;
  }
>>>>>>> worktree-agent-ad3dc1f5

  @override
  int get hashCode => Object.hash(userId, method);

  @override
  String toString() =>
      'MfaSetup(userId: $userId, method: $method, isVerified: $isVerified)';
}
