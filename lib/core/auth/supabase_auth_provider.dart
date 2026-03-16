import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState; // avoid clash with our sealed AuthState

import 'package:ca_app/core/auth/auth_state.dart';

/// Returns the appropriate auth redirect URL for the current platform.
/// On web, uses the browser's base URI (includes /CAdesk/ path).
/// On native, uses the deep-link scheme.
String _authRedirectUrl() {
  if (kIsWeb) {
    return Uri.base.toString();
  }
  return 'io.cadeskhq.app://auth';
}

/// Provides the Supabase auth client for easy access in other providers.
final _supabaseAuthProvider = Provider<GoTrueClient>(
  (ref) => Supabase.instance.client.auth,
);

/// Notifier that manages authentication state by listening to Supabase's
/// auth state change stream. Exposes [signIn] and [signOut] methods.
class AuthNotifier extends AsyncNotifier<AuthState> {
  // Typed as dynamic because the stream emits gotrue's AuthState which we
  // hide to avoid a name clash with our own sealed AuthState class.
  StreamSubscription<dynamic>? _authSubscription;

  @override
  Future<AuthState> build() async {
    final auth = ref.read(_supabaseAuthProvider);

    // Subscribe to Supabase auth state changes and map to our sealed AuthState.
    _authSubscription?.cancel();
    _authSubscription = auth.onAuthStateChange.listen(
      (supabaseAuthState) {
        final mapped = _deriveStateFromSession(supabaseAuthState.session);
        state = AsyncData(mapped);
      },
      onError: (Object error, StackTrace stack) =>
          state = AsyncError(error, stack),
    );

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Derive initial state from the current session.
    return _deriveStateFromSession(auth.currentSession);
  }

  /// Signs in with email and password. Throws [AuthException] on failure.
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final auth = ref.read(_supabaseAuthProvider);
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AsyncData(_deriveStateFromSession(response.session));
    } on AuthException {
      rethrow;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  /// Signs up with email, password and display name.
  /// Throws [AuthException] on failure.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    try {
      final auth = ref.read(_supabaseAuthProvider);
      final response = await auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _authRedirectUrl(),
        data: {'display_name': displayName},
      );
      state = AsyncData(_deriveStateFromSession(response.session));
    } on AuthException {
      rethrow;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  /// Sends a password-reset email. Throws [AuthException] on failure.
  Future<void> resetPassword(String email) async {
    try {
      final auth = ref.read(_supabaseAuthProvider);
      await auth.resetPasswordForEmail(
        email,
        redirectTo: _authRedirectUrl(),
      );
    } on AuthException {
      rethrow;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  /// Signs out the current user. Throws on failure.
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final auth = ref.read(_supabaseAuthProvider);
      await auth.signOut();
      state = const AsyncData(AuthUnauthenticated());
    } on AuthException {
      rethrow;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  AuthState _deriveStateFromSession(Session? session) {
    if (session == null) return const AuthUnauthenticated();

    final user = session.user;
    // firmId and role are stored in user metadata by the Supabase edge function
    // that creates the profile. Default role is 'staff' when not yet set.
    final metadata = user.userMetadata ?? {};
    final firmId = metadata['firm_id'] as String?;
    final role = (metadata['role'] as String?) ?? 'staff';

    return AuthAuthenticated(user: user, firmId: firmId, role: role);
  }
}

/// Global provider for [AuthNotifier]. Use [authProvider] to watch or read
/// authentication state throughout the app.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
