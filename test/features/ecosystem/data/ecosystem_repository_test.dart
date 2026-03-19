import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ecosystem/data/repositories/mock_ecosystem_repository.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';

void main() {
  late MockEcosystemRepository repo;

  setUp(() {
    repo = MockEcosystemRepository();
  });

  group('MockEcosystemRepository - IntegrationConnector', () {
    test('getAllConnectors returns non-empty seeded list', () async {
      final connectors = await repo.getAllConnectors();
      expect(connectors, isNotEmpty);
    });

    test('getConnectorsByStatus filters correctly', () async {
      final connectors = await repo.getConnectorsByStatus(
        ConnectorStatus.connected,
      );
      for (final c in connectors) {
        expect(c.status, ConnectorStatus.connected);
      }
    });

    test('getConnectorsByCategory filters correctly', () async {
      final connectors = await repo.getConnectorsByCategory(
        ConnectorCategory.government,
      );
      for (final c in connectors) {
        expect(c.category, ConnectorCategory.government);
      }
    });

    test('insertConnector adds entry and returns id', () async {
      const connector = IntegrationConnector(
        id: 'conn-new-001',
        name: 'Test Connector',
        category: ConnectorCategory.payment,
        status: ConnectorStatus.disconnected,
        description: 'Test payment gateway integration',
      );
      final id = await repo.insertConnector(connector);
      expect(id, 'conn-new-001');

      final all = await repo.getAllConnectors();
      expect(all.any((c) => c.id == 'conn-new-001'), isTrue);
    });

    test('updateConnector returns true on success', () async {
      final all = await repo.getAllConnectors();
      final first = all.first;
      final updated = IntegrationConnector(
        id: first.id,
        name: first.name,
        category: first.category,
        status: ConnectorStatus.error,
        description: first.description,
      );
      final success = await repo.updateConnector(updated);
      expect(success, isTrue);
    });

    test('updateConnector returns false for non-existent id', () async {
      const ghost = IntegrationConnector(
        id: 'non-existent-conn',
        name: 'Ghost',
        category: ConnectorCategory.kyc,
        status: ConnectorStatus.error,
        description: 'N/A',
      );
      final success = await repo.updateConnector(ghost);
      expect(success, isFalse);
    });

    test('deleteConnector removes entry and returns true', () async {
      final all = await repo.getAllConnectors();
      final target = all.first;
      final deleted = await repo.deleteConnector(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllConnectors();
      expect(remaining.any((c) => c.id == target.id), isFalse);
    });

    test('deleteConnector returns false for non-existent id', () async {
      final deleted = await repo.deleteConnector('no-such-id');
      expect(deleted, isFalse);
    });
  });

  group('MockEcosystemRepository - MarketplaceApp', () {
    test('getAllMarketplaceApps returns non-empty seeded list', () async {
      final apps = await repo.getAllMarketplaceApps();
      expect(apps, isNotEmpty);
    });

    test('getMarketplaceAppsByStatus filters correctly', () async {
      final apps = await repo.getMarketplaceAppsByStatus(
        AppInstallStatus.installed,
      );
      for (final a in apps) {
        expect(a.installStatus, AppInstallStatus.installed);
      }
    });

    test('getMarketplaceAppsByCategory filters correctly', () async {
      final apps = await repo.getMarketplaceAppsByCategory(AppCategory.payroll);
      for (final a in apps) {
        expect(a.category, AppCategory.payroll);
      }
    });

    test('insertMarketplaceApp adds entry and returns id', () async {
      const app = MarketplaceApp(
        id: 'app-new-001',
        name: 'New App',
        vendor: 'Test Vendor',
        category: AppCategory.legal,
        installStatus: AppInstallStatus.available,
        description: 'A test app',
        rating: 4.0,
        reviewCount: 50,
        isFree: true,
      );
      final id = await repo.insertMarketplaceApp(app);
      expect(id, 'app-new-001');
    });

    test('updateMarketplaceApp returns true on success', () async {
      final all = await repo.getAllMarketplaceApps();
      final first = all.first;
      final updated = MarketplaceApp(
        id: first.id,
        name: first.name,
        vendor: first.vendor,
        category: first.category,
        installStatus: AppInstallStatus.deprecated,
        description: first.description,
        rating: first.rating,
        reviewCount: first.reviewCount,
        isFree: first.isFree,
      );
      final success = await repo.updateMarketplaceApp(updated);
      expect(success, isTrue);
    });

    test('updateMarketplaceApp returns false for non-existent id', () async {
      const ghost = MarketplaceApp(
        id: 'non-existent-app',
        name: 'Ghost',
        vendor: 'Nobody',
        category: AppCategory.banking,
        installStatus: AppInstallStatus.deprecated,
        description: 'N/A',
        rating: 0,
        reviewCount: 0,
        isFree: true,
      );
      final success = await repo.updateMarketplaceApp(ghost);
      expect(success, isFalse);
    });

    test('deleteMarketplaceApp removes entry and returns true', () async {
      final all = await repo.getAllMarketplaceApps();
      final target = all.first;
      final deleted = await repo.deleteMarketplaceApp(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllMarketplaceApps();
      expect(remaining.any((a) => a.id == target.id), isFalse);
    });

    test('deleteMarketplaceApp returns false for non-existent id', () async {
      final deleted = await repo.deleteMarketplaceApp('no-such-id');
      expect(deleted, isFalse);
    });
  });
}
