// ignore_for_file: public_member_api_docs

import 'package:ca_app/features/platform/domain/models/permission.dart';

/// Represents an authenticated user within the CA firm application.
final class AppUser {
  const AppUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.firmId,
    required this.mfaEnabled,
    required this.isActive,
    required this.createdAt,
  });

  final String userId;
  final String email;
  final String name;
  final UserRole role;
  final String firmId;
  final bool mfaEnabled;
  final bool isActive;
  final DateTime createdAt;

  /// Convenience: set of permission codes derived from [role].
  ///
  /// Returns an empty set when the user is inactive.
  Set<String> get permissions {
    if (!isActive) return const {};
    return kRolePermissions[role] ?? const {};
  }

  AppUser copyWith({
    String? userId,
    String? email,
    String? name,
    UserRole? role,
    String? firmId,
    bool? mfaEnabled,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      firmId: firmId ?? this.firmId,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'AppUser(userId: $userId, email: $email, role: $role, isActive: $isActive)';
}
