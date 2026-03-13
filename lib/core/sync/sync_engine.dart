import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/sync/sync_status_provider.dart';
import 'package:ca_app/core/sync/conflict_resolver.dart';

/// Sync engine: watches connectivity, processes sync queue when online.
/// Phase 1: skeleton — database integration wired in Phase 2.
class SyncEngine extends AsyncNotifier<void> {
  // ignore: unused_field — will be used in Phase 2 when DB integration is wired
  final ConflictResolver _resolver = const ConflictResolver();

  @override
  Future<void> build() async {
    // Watch connectivity changes
    ref.listen(_connectivityStreamProvider, (previous, next) {
      next.whenData((result) {
        final isOnline = result != ConnectivityResult.none;
        if (isOnline) {
          _onCameOnline();
        } else {
          ref.read(syncStatusProvider.notifier).setOffline();
        }
      });
    });
  }

  Future<void> _onCameOnline() async {
    final notifier = ref.read(syncStatusProvider.notifier);
    notifier.setSyncing();
    try {
      // Phase 1: verify Supabase connection
      await Supabase.instance.client
          .from('feature_flags')
          .select('id')
          .limit(1);
      notifier.setSynced();
    } catch (e) {
      notifier.setError('Sync failed: $e');
    }
  }

  Future<void> triggerSync() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_onCameOnline);
  }
}

// Internal connectivity stream provider
final _connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.firstOrNull ?? ConnectivityResult.none,
  );
});

final syncEngineProvider = AsyncNotifierProvider<SyncEngine, void>(
  SyncEngine.new,
);
