import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ecosystem/data/mappers/ecosystem_mapper.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';

void main() {
  group('EcosystemMapper', () {
    // -------------------------------------------------------------------------
    // IntegrationConnector
    // -------------------------------------------------------------------------
    group('connectorFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'conn-001',
          'name': 'GST Network',
          'category': 'government',
          'status': 'connected',
          'description': 'Direct GSTN API integration',
          'last_heartbeat': '2025-09-01T10:00:00.000Z',
          'latency_ms': 120,
          'webhook_url': 'https://api.example.com/webhook',
          'provider': 'NIC',
        };

        final connector = EcosystemMapper.connectorFromJson(json);

        expect(connector.id, 'conn-001');
        expect(connector.name, 'GST Network');
        expect(connector.category, ConnectorCategory.government);
        expect(connector.status, ConnectorStatus.connected);
        expect(connector.description, 'Direct GSTN API integration');
        expect(connector.lastHeartbeat, isNotNull);
        expect(connector.latencyMs, 120);
        expect(connector.webhookUrl, 'https://api.example.com/webhook');
        expect(connector.provider, 'NIC');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'conn-002',
          'name': 'E-Sign',
          'category': 'esign',
          'status': 'disconnected',
          'description': 'Aadhaar-based e-signing',
        };

        final connector = EcosystemMapper.connectorFromJson(json);
        expect(connector.lastHeartbeat, isNull);
        expect(connector.latencyMs, isNull);
        expect(connector.webhookUrl, isNull);
        expect(connector.provider, isNull);
        expect(connector.category, ConnectorCategory.esign);
        expect(connector.status, ConnectorStatus.disconnected);
      });

      test('defaults category to accounting for unknown value', () {
        final json = {
          'id': 'conn-003',
          'name': 'Unknown',
          'category': 'unknownCat',
          'status': 'error',
          'description': '',
        };

        final connector = EcosystemMapper.connectorFromJson(json);
        expect(connector.category, ConnectorCategory.accounting);
        expect(connector.status, ConnectorStatus.error);
      });

      test('handles all ConnectorCategory values', () {
        for (final cat in ConnectorCategory.values) {
          final json = {
            'id': 'conn-cat-${cat.name}',
            'name': cat.name,
            'category': cat.name,
            'status': 'disconnected',
            'description': '',
          };
          final connector = EcosystemMapper.connectorFromJson(json);
          expect(connector.category, cat);
        }
      });

      test('handles all ConnectorStatus values', () {
        for (final status in ConnectorStatus.values) {
          final json = {
            'id': 'conn-status-${status.name}',
            'name': '',
            'category': 'accounting',
            'status': status.name,
            'description': '',
          };
          final connector = EcosystemMapper.connectorFromJson(json);
          expect(connector.status, status);
        }
      });
    });

    group('connectorToJson', () {
      test('includes all fields and round-trips correctly', () {
        const connector = IntegrationConnector(
          id: 'conn-json-001',
          name: 'Payment Gateway',
          category: ConnectorCategory.payment,
          status: ConnectorStatus.beta,
          description: 'Razorpay integration',
          latencyMs: 85,
          webhookUrl: 'https://webhook.example.com',
          provider: 'Razorpay',
        );

        final json = EcosystemMapper.connectorToJson(connector);

        expect(json['id'], 'conn-json-001');
        expect(json['name'], 'Payment Gateway');
        expect(json['category'], 'payment');
        expect(json['status'], 'beta');
        expect(json['description'], 'Razorpay integration');
        expect(json['latency_ms'], 85);
        expect(json['webhook_url'], 'https://webhook.example.com');
        expect(json['provider'], 'Razorpay');
        expect(json['last_heartbeat'], isNull);
        expect(json['installed_at'], isNull);

        final restored = EcosystemMapper.connectorFromJson(json);
        expect(restored.id, connector.id);
        expect(restored.category, connector.category);
        expect(restored.status, connector.status);
        expect(restored.latencyMs, connector.latencyMs);
      });
    });

    // -------------------------------------------------------------------------
    // MarketplaceApp
    // -------------------------------------------------------------------------
    group('appFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'app-001',
          'name': 'Greytip HR',
          'vendor': 'Greytip Software',
          'category': 'hr',
          'install_status': 'installed',
          'description': 'HR and payroll platform',
          'rating': 4.5,
          'review_count': 320,
          'is_free': false,
          'price_per_month': 999.0,
          'installed_at': '2025-06-01T00:00:00.000Z',
          'icon_color': 0xFF4CAF50,
        };

        final app = EcosystemMapper.appFromJson(json);

        expect(app.id, 'app-001');
        expect(app.name, 'Greytip HR');
        expect(app.vendor, 'Greytip Software');
        expect(app.category, AppCategory.hr);
        expect(app.installStatus, AppInstallStatus.installed);
        expect(app.rating, 4.5);
        expect(app.reviewCount, 320);
        expect(app.isFree, false);
        expect(app.pricePerMonth, 999.0);
        expect(app.installedAt, isNotNull);
        expect(app.iconColor, isNotNull);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'app-002',
          'name': 'Free Valuation Tool',
          'vendor': 'Vendor X',
          'category': 'valuation',
          'install_status': 'available',
          'description': '',
          'rating': 3.8,
          'review_count': 45,
          'is_free': true,
        };

        final app = EcosystemMapper.appFromJson(json);
        expect(app.pricePerMonth, isNull);
        expect(app.installedAt, isNull);
        expect(app.iconColor, isNull);
        expect(app.isFree, true);
        expect(app.category, AppCategory.valuation);
      });

      test('defaults install_status to available for unknown value', () {
        final json = {
          'id': 'app-003',
          'name': '',
          'vendor': '',
          'category': 'legal',
          'install_status': 'unknownStatus',
          'description': '',
          'rating': 0.0,
          'review_count': 0,
          'is_free': true,
        };

        final app = EcosystemMapper.appFromJson(json);
        expect(app.installStatus, AppInstallStatus.available);
      });

      test('handles all AppCategory values', () {
        for (final cat in AppCategory.values) {
          final json = {
            'id': 'app-cat-${cat.name}',
            'name': cat.name,
            'vendor': '',
            'category': cat.name,
            'install_status': 'available',
            'description': '',
            'rating': 0.0,
            'review_count': 0,
            'is_free': true,
          };
          final app = EcosystemMapper.appFromJson(json);
          expect(app.category, cat);
        }
      });
    });

    group('appToJson', () {
      test('includes all fields and round-trips correctly', () {
        const app = MarketplaceApp(
          id: 'app-json-001',
          name: 'LegalDesk',
          vendor: 'LegalDesk Inc.',
          category: AppCategory.legal,
          installStatus: AppInstallStatus.pending,
          description: 'Legal document drafting',
          rating: 4.2,
          reviewCount: 150,
          isFree: false,
          pricePerMonth: 1499.0,
        );

        final json = EcosystemMapper.appToJson(app);

        expect(json['id'], 'app-json-001');
        expect(json['name'], 'LegalDesk');
        expect(json['vendor'], 'LegalDesk Inc.');
        expect(json['category'], 'legal');
        expect(json['install_status'], 'pending');
        expect(json['rating'], 4.2);
        expect(json['review_count'], 150);
        expect(json['is_free'], false);
        expect(json['price_per_month'], 1499.0);
        expect(json['installed_at'], isNull);
        expect(json['icon_color'], isNull);

        final restored = EcosystemMapper.appFromJson(json);
        expect(restored.id, app.id);
        expect(restored.category, app.category);
        expect(restored.installStatus, app.installStatus);
        expect(restored.rating, app.rating);
      });
    });
  });
}
