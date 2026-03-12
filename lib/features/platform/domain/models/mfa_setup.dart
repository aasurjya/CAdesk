// ignore_for_file: public_member_api_docs

/// Supported MFA methods.
enum MfaMethod { totp, sms, email }

/// Immutable record of an MFA setup for a user.
final class MfaSetup {
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
  final String secret;
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

  /// Equality is based on [userId] and [method].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MfaSetup &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          method == other.method;

  @override
  int get hashCode => Object.hash(userId, method);

  @override
  String toString() =>
      'MfaSetup(userId: $userId, method: $method, isVerified: $isVerified)';
}
