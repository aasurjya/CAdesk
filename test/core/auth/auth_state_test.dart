import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/auth/auth_state.dart';

// ---------------------------------------------------------------------------
// Minimal User stub — avoids importing supabase_flutter in tests
// ---------------------------------------------------------------------------

void main() {
  group('AuthState sealed class', () {
    group('AuthUnauthenticated', () {
      test('is a valid AuthState instance', () {
        const state = AuthUnauthenticated();
        expect(state, isA<AuthState>());
        expect(state, isA<AuthUnauthenticated>());
      });

      test('toString returns expected string', () {
        const state = AuthUnauthenticated();
        expect(state.toString(), 'AuthUnauthenticated()');
      });

      test('const equality holds', () {
        const a = AuthUnauthenticated();
        const b = AuthUnauthenticated();
        expect(a, equals(b));
      });
    });

    group('AuthLoading', () {
      test('is a valid AuthState instance', () {
        const state = AuthLoading();
        expect(state, isA<AuthState>());
        expect(state, isA<AuthLoading>());
      });

      test('toString returns expected string', () {
        const state = AuthLoading();
        expect(state.toString(), 'AuthLoading()');
      });

      test('const equality holds', () {
        const a = AuthLoading();
        const b = AuthLoading();
        expect(a, equals(b));
      });
    });

    group('Pattern matching coverage', () {
      test('exhaustive switch over sealed subtypes compiles and works', () {
        const states = <AuthState>[AuthUnauthenticated(), AuthLoading()];

        for (final state in states) {
          final label = switch (state) {
            AuthAuthenticated() => 'authenticated',
            AuthUnauthenticated() => 'unauthenticated',
            AuthLoading() => 'loading',
          };
          expect(label, isNotEmpty);
        }
      });
    });
  });

  group('SyncStatus isOnline', () {
    // Validate that the sealed hierarchy is complete by checking all
    // non-AuthAuthenticated states can be instantiated and used.
    test('AuthUnauthenticated does not require user object', () {
      const state = AuthUnauthenticated();
      expect(state, isNotNull);
    });

    test('AuthLoading does not require any fields', () {
      const state = AuthLoading();
      expect(state, isNotNull);
    });
  });
}
