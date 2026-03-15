import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ecosystem/data/providers/ecosystem_providers.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';

void main() {
  group('Ecosystem Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('integrationConnectorsProvider', () {
      test('returns non-empty list of connectors', () {
        final connectors = container.read(integrationConnectorsProvider);
        expect(connectors, isNotEmpty);
        expect(connectors.length, greaterThanOrEqualTo(8));
      });

      test('list is unmodifiable', () {
        final connectors = container.read(integrationConnectorsProvider);
        expect(
          () => (connectors as dynamic).add(connectors.first),
          throwsA(isA<Error>()),
        );
      });

      test('all entries are IntegrationConnector instances', () {
        final connectors = container.read(integrationConnectorsProvider);
        for (final c in connectors) {
          expect(c, isA<IntegrationConnector>());
        }
      });
    });

    group('marketplaceAppsProvider', () {
      test('returns non-empty list of marketplace apps', () {
        final apps = container.read(marketplaceAppsProvider);
        expect(apps, isNotEmpty);
        expect(apps.length, greaterThanOrEqualTo(4));
      });

      test('all entries are MarketplaceApp instances', () {
        final apps = container.read(marketplaceAppsProvider);
        for (final a in apps) {
          expect(a, isA<MarketplaceApp>());
        }
      });
    });

    group('connectorStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(connectorStatusFilterProvider), isNull);
      });

      test('can be set to connected status', () {
        container
            .read(connectorStatusFilterProvider.notifier)
            .update(ConnectorStatus.connected);
        expect(
          container.read(connectorStatusFilterProvider),
          ConnectorStatus.connected,
        );
      });

      test('can be set to error status', () {
        container
            .read(connectorStatusFilterProvider.notifier)
            .update(ConnectorStatus.error);
        expect(
          container.read(connectorStatusFilterProvider),
          ConnectorStatus.error,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(connectorStatusFilterProvider.notifier)
            .update(ConnectorStatus.beta);
        container.read(connectorStatusFilterProvider.notifier).update(null);
        expect(container.read(connectorStatusFilterProvider), isNull);
      });
    });

    group('filteredConnectorsProvider', () {
      test('returns all connectors when no filter is set', () {
        final all = container.read(integrationConnectorsProvider);
        final filtered = container.read(filteredConnectorsProvider);
        expect(filtered.length, all.length);
      });

      test('filters to connected connectors only', () {
        container
            .read(connectorStatusFilterProvider.notifier)
            .update(ConnectorStatus.connected);
        final filtered = container.read(filteredConnectorsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((c) => c.status == ConnectorStatus.connected),
          isTrue,
        );
      });

      test('filters to error connectors only', () {
        container
            .read(connectorStatusFilterProvider.notifier)
            .update(ConnectorStatus.error);
        final filtered = container.read(filteredConnectorsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((c) => c.status == ConnectorStatus.error),
          isTrue,
        );
      });

      test('filters to disconnected returns correct subset', () {
        container
            .read(connectorStatusFilterProvider.notifier)
            .update(ConnectorStatus.disconnected);
        final filtered = container.read(filteredConnectorsProvider);
        for (final c in filtered) {
          expect(c.status, ConnectorStatus.disconnected);
        }
      });
    });

    group('ecosystemSummaryProvider', () {
      test('totalConnectors matches integrationConnectorsProvider length', () {
        final summary = container.read(ecosystemSummaryProvider);
        expect(
          summary.totalConnectors,
          container.read(integrationConnectorsProvider).length,
        );
      });

      test('connectedConnectors is non-negative', () {
        final summary = container.read(ecosystemSummaryProvider);
        expect(summary.connectedConnectors, greaterThanOrEqualTo(0));
      });

      test('connectedConnectors <= totalConnectors', () {
        final summary = container.read(ecosystemSummaryProvider);
        expect(
          summary.connectedConnectors,
          lessThanOrEqualTo(summary.totalConnectors),
        );
      });

      test('errorConnectors matches count of error connectors', () {
        final summary = container.read(ecosystemSummaryProvider);
        final expected = container
            .read(integrationConnectorsProvider)
            .where((c) => c.status == ConnectorStatus.error)
            .length;
        expect(summary.errorConnectors, expected);
      });

      test('installedApps matches installed count', () {
        final summary = container.read(ecosystemSummaryProvider);
        final expected = container
            .read(marketplaceAppsProvider)
            .where((a) => a.installStatus == AppInstallStatus.installed)
            .length;
        expect(summary.installedApps, expected);
      });
    });
  });
}
