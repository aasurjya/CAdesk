import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/portal_connector/data/providers/portal_connector_repository_providers.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

// ---------------------------------------------------------------------------
// Portal connection status
// ---------------------------------------------------------------------------

/// Connection state for a single government portal.
enum PortalConnectionStatus { connected, disconnected, error }

/// Immutable snapshot of a portal's connection state.
class PortalConnectionInfo {
  const PortalConnectionInfo({
    required this.portal,
    required this.status,
    required this.hasCredentials,
    this.lastSyncAt,
    this.errorMessage,
  });

  final Portal portal;
  final PortalConnectionStatus status;
  final bool hasCredentials;
  final DateTime? lastSyncAt;
  final String? errorMessage;

  PortalConnectionInfo copyWith({
    Portal? portal,
    PortalConnectionStatus? status,
    bool? hasCredentials,
    DateTime? lastSyncAt,
    String? errorMessage,
  }) {
    return PortalConnectionInfo(
      portal: portal ?? this.portal,
      status: status ?? this.status,
      hasCredentials: hasCredentials ?? this.hasCredentials,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Sync frequency options for portal data refresh.
enum SyncFrequency {
  manual('Manual'),
  hourly('Every Hour'),
  daily('Daily'),
  weekly('Weekly');

  const SyncFrequency(this.label);

  final String label;
}

/// Immutable configuration for a single portal.
class PortalConfig {
  const PortalConfig({
    required this.portal,
    this.username = '',
    this.apiKey = '',
    this.hasPassword = false,
    this.syncFrequency = SyncFrequency.daily,
  });

  final Portal portal;
  final String username;
  final String apiKey;
  final bool hasPassword;
  final SyncFrequency syncFrequency;

  PortalConfig copyWith({
    Portal? portal,
    String? username,
    String? apiKey,
    bool? hasPassword,
    SyncFrequency? syncFrequency,
  }) {
    return PortalConfig(
      portal: portal ?? this.portal,
      username: username ?? this.username,
      apiKey: apiKey ?? this.apiKey,
      hasPassword: hasPassword ?? this.hasPassword,
      syncFrequency: syncFrequency ?? this.syncFrequency,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All 5 portal connections with their current status.
final portalConnectionsProvider =
    NotifierProvider<PortalConnectionsNotifier, List<PortalConnectionInfo>>(
      PortalConnectionsNotifier.new,
    );

class PortalConnectionsNotifier extends Notifier<List<PortalConnectionInfo>> {
  @override
  List<PortalConnectionInfo> build() {
    // Watch the repository to ensure connectivity; connection state is managed
    // locally in this notifier since it represents live UI state (not persisted).
    ref.watch(portalCredentialRepositoryProvider);
    return const [
      PortalConnectionInfo(
        portal: Portal.itd,
        status: PortalConnectionStatus.connected,
        hasCredentials: true,
        lastSyncAt: null,
      ),
      PortalConnectionInfo(
        portal: Portal.gstn,
        status: PortalConnectionStatus.connected,
        hasCredentials: true,
        lastSyncAt: null,
      ),
      PortalConnectionInfo(
        portal: Portal.traces,
        status: PortalConnectionStatus.disconnected,
        hasCredentials: false,
      ),
      PortalConnectionInfo(
        portal: Portal.mca,
        status: PortalConnectionStatus.error,
        hasCredentials: true,
        errorMessage: 'Session expired',
      ),
      PortalConnectionInfo(
        portal: Portal.epfo,
        status: PortalConnectionStatus.disconnected,
        hasCredentials: false,
      ),
    ];
  }

  /// Simulate testing a portal connection.
  Future<void> testConnection(Portal portal) async {
    final index = state.indexWhere((c) => c.portal == portal);
    if (index == -1) return;

    // Mark as connecting (keep current status while testing)
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final current = state[index];
    final updated = current.hasCredentials
        ? current.copyWith(
            status: PortalConnectionStatus.connected,
            lastSyncAt: DateTime.now(),
            errorMessage: null,
          )
        : current.copyWith(
            status: PortalConnectionStatus.error,
            errorMessage: 'No credentials configured',
          );

    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index) updated else state[i],
    ];
  }

  /// Update connection info after config changes.
  void updateConnection(PortalConnectionInfo info) {
    state = [
      for (final c in state)
        if (c.portal == info.portal) info else c,
    ];
  }
}

/// Per-portal configuration (credentials, sync frequency).
final portalConfigProvider =
    NotifierProvider<PortalConfigNotifier, Map<Portal, PortalConfig>>(
      PortalConfigNotifier.new,
    );

class PortalConfigNotifier extends Notifier<Map<Portal, PortalConfig>> {
  @override
  Map<Portal, PortalConfig> build() {
    return {for (final p in Portal.values) p: PortalConfig(portal: p)};
  }

  void updateConfig(Portal portal, PortalConfig config) {
    state = {...state, portal: config};
  }
}

/// Currently selected portal for configuration screen.
final selectedPortalProvider = NotifierProvider<SelectedPortalNotifier, Portal>(
  SelectedPortalNotifier.new,
);

class SelectedPortalNotifier extends Notifier<Portal> {
  @override
  Portal build() => Portal.itd;

  void select(Portal portal) => state = portal;
}

/// Count of connected portals.
final connectedPortalCountProvider = Provider<int>((ref) {
  final connections = ref.watch(portalConnectionsProvider);
  return connections
      .where((c) => c.status == PortalConnectionStatus.connected)
      .length;
});

/// Overall sync health: true if all credentialed portals are connected.
final allPortalsHealthyProvider = Provider<bool>((ref) {
  final connections = ref.watch(portalConnectionsProvider);
  final credentialed = connections.where((c) => c.hasCredentials);
  if (credentialed.isEmpty) return false;
  return credentialed.every(
    (c) => c.status == PortalConnectionStatus.connected,
  );
});
