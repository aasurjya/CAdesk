import 'package:supabase_flutter/supabase_flutter.dart';

/// Sealed class representing all possible authentication states in CADesk.
sealed class AuthState {
  const AuthState();
}

/// The user is authenticated. Contains the Supabase [User], an optional
/// [firmId] (the CA firm the user belongs to), and the user's [role].
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    required this.role,
    this.firmId,
  });

  final User user;
  final String? firmId;
  final String role;

  @override
  String toString() =>
      'AuthAuthenticated(userId: ${user.id}, firmId: $firmId, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated &&
          runtimeType == other.runtimeType &&
          user.id == other.user.id &&
          firmId == other.firmId &&
          role == other.role;

  @override
  int get hashCode => Object.hash(user.id, firmId, role);
}

/// The user is not authenticated.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  String toString() => 'AuthUnauthenticated()';
}

/// Authentication state is being determined (e.g. on app startup).
final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  String toString() => 'AuthLoading()';
}
