import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_connector/data/providers/portal_connector_providers.dart';
import 'package:ca_app/features/portal_connector/data/providers/portal_connector_repository_providers.dart';
import 'package:ca_app/features/portal_connector/data/repositories/mock_portal_connector_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      portalCredentialRepositoryProvider.overrideWithValue(
        MockPortalCredentialRepository(),
      ),
    ],
  );
}

void main() {
  group('PortalConnectionsNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('initial state has 5 portal connections', () {
      final connections = container.read(portalConnectionsProvider);
      expect(connections.length, 5);
    });

    test('all connections have portal values', () {
      final connections = container.read(portalConnectionsProvider);
      expect(connections.every((c) => Portal.values.contains(c.portal)), isTrue);
    });

    test('ITD portal is initially connected', () {
      final connections = container.read(portalConnectionsProvider);
      final itd = connections.firstWhere((c) => c.portal == Portal.itd);
      expect(itd.status, PortalConnectionStatus.connected);
    });

    test('TRACES portal is initially disconnected', () {
      final connections = container.read(portalConnectionsProvider);
      final traces = connections.firstWhere((c) => c.portal == Portal.traces);
      expect(traces.status, PortalConnectionStatus.disconnected);
    });

    test('updateConnection changes connection info', () {
      final updated = PortalConnectionInfo(
        portal: Portal.traces,
        status: PortalConnectionStatus.connected,
        hasCredentials: true,
      );
      container
          .read(portalConnectionsProvider.notifier)
          .updateConnection(updated);
      final traces = container
          .read(portalConnectionsProvider)
          .firstWhere((c) => c.portal == Portal.traces);
      expect(traces.status, PortalConnectionStatus.connected);
    });
  });

  group('PortalConfigNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('initial config has entry for every portal', () {
      final config = container.read(portalConfigProvider);
      for (final portal in Portal.values) {
        expect(config.containsKey(portal), isTrue);
      }
    });

    test('updateConfig changes portal config', () {
      final newConfig = PortalConfig(
        portal: Portal.gstn,
        username: 'testuser@gstn.gov.in',
        hasPassword: true,
        syncFrequency: SyncFrequency.hourly,
      );
      container
          .read(portalConfigProvider.notifier)
          .updateConfig(Portal.gstn, newConfig);
      final updated = container.read(portalConfigProvider)[Portal.gstn];
      expect(updated?.username, 'testuser@gstn.gov.in');
      expect(updated?.syncFrequency, SyncFrequency.hourly);
    });
  });

  group('SelectedPortalNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('initial selected portal is ITD', () {
      expect(container.read(selectedPortalProvider), Portal.itd);
    });

    test('can select GSTN', () {
      container.read(selectedPortalProvider.notifier).select(Portal.gstn);
      expect(container.read(selectedPortalProvider), Portal.gstn);
    });

    test('can select MCA', () {
      container.read(selectedPortalProvider.notifier).select(Portal.mca);
      expect(container.read(selectedPortalProvider), Portal.mca);
    });
  });

  group('connectedPortalCountProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('count is non-negative', () {
      final count = container.read(connectedPortalCountProvider);
      expect(count, greaterThanOrEqualTo(0));
    });

    test('initial count is 2 (ITD + GSTN connected)', () {
      final count = container.read(connectedPortalCountProvider);
      expect(count, 2);
    });
  });

  group('allPortalsHealthyProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('initial health is false (MCA has error)', () {
      final healthy = container.read(allPortalsHealthyProvider);
      expect(healthy, isFalse);
    });
  });
}
