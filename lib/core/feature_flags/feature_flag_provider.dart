import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'flag_cache.dart';

/// Immutable snapshot of feature flags.
class FeatureFlags {
  const FeatureFlags(this._flags);

  static const FeatureFlags empty = FeatureFlags({});

  final Map<String, bool> _flags;

  bool isEnabled(String flagName) => _flags[flagName] ?? false;

  FeatureFlags copyWithFlag(String name, bool value) {
    return FeatureFlags({..._flags, name: value});
  }
}

/// Notifier that fetches flags from Supabase feature_flags table.
/// Falls back to all-false (use mocks) on any error.
class FeatureFlagNotifier extends AsyncNotifier<FeatureFlags> {
  final FlagCache _cache = FlagCache();

  @override
  Future<FeatureFlags> build() async {
    return _fetchFlags();
  }

  Future<FeatureFlags> _fetchFlags() async {
    if (!_cache.isStale) {
      // Return from cache — reconstruct FeatureFlags from cache
      return _buildFromCache();
    }
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('feature_flags')
          .select('flag_name, is_enabled')
          .or('firm_id.is.null'); // global flags

      final flags = <String, bool>{};
      for (final row in response as List<dynamic>) {
        final name = row['flag_name'] as String?;
        final enabled = row['is_enabled'] as bool? ?? false;
        if (name != null) {
          flags[name] = enabled;
        }
      }
      _cache.update(flags);
      return FeatureFlags(flags);
    } catch (e) {
      // On error, return all-false (safe default — use mocks)
      return FeatureFlags.empty;
    }
  }

  FeatureFlags _buildFromCache() {
    return FeatureFlags(_cache.flags);
  }

  Future<void> refresh() async {
    _cache.invalidate();
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchFlags);
  }

  bool isEnabled(String flagName) {
    return state.asData?.value.isEnabled(flagName) ?? false;
  }
}

final featureFlagProvider =
    AsyncNotifierProvider<FeatureFlagNotifier, FeatureFlags>(
      FeatureFlagNotifier.new,
    );
