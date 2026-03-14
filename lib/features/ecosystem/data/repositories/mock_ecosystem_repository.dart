import 'package:flutter/material.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';
import 'package:ca_app/features/ecosystem/domain/repositories/ecosystem_repository.dart';

/// In-memory mock implementation of [EcosystemRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockEcosystemRepository implements EcosystemRepository {
  static const List<IntegrationConnector> _seedConnectors = [
    IntegrationConnector(
      id: 'conn-001',
      name: 'Income Tax Portal (ITD)',
      category: ConnectorCategory.government,
      status: ConnectorStatus.connected,
      description:
          'Direct integration with the Income Tax Department portal for ITR filing and refund tracking.',
      latencyMs: 320,
      provider: 'ITD',
    ),
    IntegrationConnector(
      id: 'conn-002',
      name: 'GST Portal (GSTN)',
      category: ConnectorCategory.government,
      status: ConnectorStatus.connected,
      description:
          'Real-time GSTIN validation and GSTR filing via NIC/GSTN APIs.',
      latencyMs: 480,
      provider: 'GSTN',
    ),
    IntegrationConnector(
      id: 'conn-003',
      name: 'Razorpay Gateway',
      category: ConnectorCategory.payment,
      status: ConnectorStatus.beta,
      description:
          'Accept client fee payments via Razorpay UPI, cards, and net banking.',
      provider: 'Razorpay',
    ),
  ];

  static final List<MarketplaceApp> _seedApps = [
    MarketplaceApp(
      id: 'app-001',
      name: 'ValuTrack Pro',
      vendor: 'Valuemotion Technologies',
      category: AppCategory.valuation,
      installStatus: AppInstallStatus.installed,
      description:
          'Business valuation using DCF, comparative, and asset-based methods.',
      rating: 4.6,
      reviewCount: 234,
      isFree: false,
      pricePerMonth: 2999,
      installedAt: DateTime(2025, 11, 1),
      iconColor: const Color(0xFF1565C0),
    ),
    MarketplaceApp(
      id: 'app-002',
      name: 'PayMaster HRMS',
      vendor: 'PayMaster Solutions',
      category: AppCategory.payroll,
      installStatus: AppInstallStatus.available,
      description: 'Integrated HR & payroll management with PF/ESI compliance.',
      rating: 4.3,
      reviewCount: 188,
      isFree: false,
      pricePerMonth: 1499,
      iconColor: const Color(0xFF2E7D32),
    ),
    MarketplaceApp(
      id: 'app-003',
      name: 'LegalDesk Drafting',
      vendor: 'LegalDesk India',
      category: AppCategory.legal,
      installStatus: AppInstallStatus.installed,
      description:
          'AI-assisted legal document drafting — MoA, AoA, agreements.',
      rating: 4.1,
      reviewCount: 95,
      isFree: true,
      installedAt: DateTime(2026, 1, 15),
      iconColor: const Color(0xFF6A1B9A),
    ),
  ];

  final List<IntegrationConnector> _connectors = List.of(_seedConnectors);
  final List<MarketplaceApp> _apps = List.of(_seedApps);

  @override
  Future<String> insertConnector(IntegrationConnector connector) async {
    _connectors.add(connector);
    return connector.id;
  }

  @override
  Future<List<IntegrationConnector>> getAllConnectors() async =>
      List.unmodifiable(_connectors);

  @override
  Future<List<IntegrationConnector>> getConnectorsByStatus(
    ConnectorStatus status,
  ) async =>
      List.unmodifiable(_connectors.where((c) => c.status == status).toList());

  @override
  Future<List<IntegrationConnector>> getConnectorsByCategory(
    ConnectorCategory category,
  ) async => List.unmodifiable(
    _connectors.where((c) => c.category == category).toList(),
  );

  @override
  Future<bool> updateConnector(IntegrationConnector connector) async {
    final idx = _connectors.indexWhere((c) => c.id == connector.id);
    if (idx == -1) return false;
    final updated = List<IntegrationConnector>.of(_connectors)
      ..[idx] = connector;
    _connectors
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteConnector(String id) async {
    final before = _connectors.length;
    _connectors.removeWhere((c) => c.id == id);
    return _connectors.length < before;
  }

  @override
  Future<String> insertMarketplaceApp(MarketplaceApp app) async {
    _apps.add(app);
    return app.id;
  }

  @override
  Future<List<MarketplaceApp>> getAllMarketplaceApps() async =>
      List.unmodifiable(_apps);

  @override
  Future<List<MarketplaceApp>> getMarketplaceAppsByStatus(
    AppInstallStatus installStatus,
  ) async => List.unmodifiable(
    _apps.where((a) => a.installStatus == installStatus).toList(),
  );

  @override
  Future<List<MarketplaceApp>> getMarketplaceAppsByCategory(
    AppCategory category,
  ) async =>
      List.unmodifiable(_apps.where((a) => a.category == category).toList());

  @override
  Future<bool> updateMarketplaceApp(MarketplaceApp app) async {
    final idx = _apps.indexWhere((a) => a.id == app.id);
    if (idx == -1) return false;
    final updated = List<MarketplaceApp>.of(_apps)..[idx] = app;
    _apps
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteMarketplaceApp(String id) async {
    final before = _apps.length;
    _apps.removeWhere((a) => a.id == id);
    return _apps.length < before;
  }
}
