import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits a [ConnectivityResult] whenever the device's network status changes.
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.firstOrNull ?? ConnectivityResult.none,
  );
});

/// Returns `true` when the device has any active network connection.
/// Defaults to `true` until the first connectivity event is received so the
/// app does not incorrectly block network calls on startup.
final isOnlineProvider = Provider<bool>((ref) {
  final result = ref.watch(connectivityStreamProvider).asData?.value;
  if (result == null) return true;
  return result != ConnectivityResult.none;
});
