import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sync status enum.
enum SyncStatus {
  synced,
  syncing,
  offline,
  error;

  bool get isOnline => this != SyncStatus.offline;
}

/// Immutable sync state.
class SyncState {
  const SyncState({
    required this.status,
    this.pendingCount = 0,
    this.lastSyncedAt,
    this.errorMessage,
  });

  static const SyncState initial = SyncState(status: SyncStatus.synced);

  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SyncStatusNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState.initial;

  void setSyncing() => state = state.copyWith(status: SyncStatus.syncing);

  void setSynced({int pendingCount = 0}) => state = state.copyWith(
    status: SyncStatus.synced,
    pendingCount: pendingCount,
    lastSyncedAt: DateTime.now(),
    errorMessage: null,
  );

  void setOffline() => state = state.copyWith(status: SyncStatus.offline);

  void setError(String message) =>
      state = state.copyWith(status: SyncStatus.error, errorMessage: message);

  void setPendingCount(int count) =>
      state = state.copyWith(pendingCount: count);
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncState>(
  SyncStatusNotifier.new,
);
