import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/auth/auth_state.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/auth/supabase_auth_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';

/// Creates a [ProviderContainer] with optional overrides for testing.
///
/// The caller must call [ProviderContainer.dispose] in tearDown:
/// ```dart
/// late ProviderContainer container;
/// setUp(() => container = createTestContainer());
/// tearDown(() => container.dispose());
/// ```
ProviderContainer createTestContainer({List<dynamic> overrides = const []}) {
  return ProviderContainer(overrides: overrides.cast());
}

/// Returns a [ProviderContainer] pre-configured with an in-memory database
/// and common overrides for offline/unit testing.
///
/// Includes:
/// - [appDatabaseProvider] -> in-memory Drift database
/// - [authProvider] -> unauthenticated state
/// - [featureFlagProvider] -> empty flags (all disabled)
/// - [currentFirmIdProvider] -> empty string
///
/// Additional [overrides] are appended after the defaults, so callers can
/// selectively replace any of the above.
///
/// The caller must call [ProviderContainer.dispose] in tearDown.
/// The in-memory database is closed via [appDatabaseProvider]'s built-in
/// `ref.onDispose` handler.
ProviderContainer createTestContainerWithDefaults({
  List<dynamic> overrides = const [],
}) {
  final db = AppDatabase(executor: NativeDatabase.memory());

  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      authProvider.overrideWith(_UnauthenticatedAuthNotifier.new),
      featureFlagProvider.overrideWith(_EmptyFeatureFlagNotifier.new),
      currentFirmIdProvider.overrideWithValue(''),
      ...overrides.cast(),
    ],
  );
}

/// Convenience: creates an [authProvider] override that returns
/// unauthenticated state. Use in a `ProviderContainer(overrides: [...])`.
dynamic overrideAuthUnauthenticated() {
  return authProvider.overrideWith(_UnauthenticatedAuthNotifier.new);
}

/// Convenience: override [currentFirmIdProvider] with a given firm ID.
dynamic overrideFirmId(String firmId) {
  return currentFirmIdProvider.overrideWithValue(firmId);
}

/// Convenience: override [featureFlagProvider] with specific flags enabled.
dynamic overrideFeatureFlags(Map<String, bool> flags) {
  return featureFlagProvider.overrideWith(
    () => _CustomFeatureFlagNotifier(flags),
  );
}

/// Convenience: override [appDatabaseProvider] with an in-memory database.
/// Returns a tuple of (override, database) so tests can interact with the
/// database directly and close it in tearDown.
(dynamic, AppDatabase) overrideDatabase() {
  final db = AppDatabase(executor: NativeDatabase.memory());
  return (appDatabaseProvider.overrideWithValue(db), db);
}

// ---------------------------------------------------------------------------
// Private notifier stubs
// ---------------------------------------------------------------------------

class _UnauthenticatedAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthUnauthenticated();
}

class _EmptyFeatureFlagNotifier extends FeatureFlagNotifier {
  @override
  Future<FeatureFlags> build() async => FeatureFlags.empty;
}

class _CustomFeatureFlagNotifier extends FeatureFlagNotifier {
  _CustomFeatureFlagNotifier(this._flags);

  final Map<String, bool> _flags;

  @override
  Future<FeatureFlags> build() async => FeatureFlags(_flags);
}
