import 'package:ca_app/features/ecosystem/data/datasources/ecosystem_local_source.dart';
import 'package:ca_app/features/ecosystem/data/datasources/ecosystem_remote_source.dart';
import 'package:ca_app/features/ecosystem/data/mappers/ecosystem_mapper.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';
import 'package:ca_app/features/ecosystem/domain/repositories/ecosystem_repository.dart';

/// Real implementation of [EcosystemRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class EcosystemRepositoryImpl implements EcosystemRepository {
  const EcosystemRepositoryImpl({required this.remote, required this.local});

  final EcosystemRemoteSource remote;
  final EcosystemLocalSource local;

  @override
  Future<String> insertConnector(IntegrationConnector connector) async {
    try {
      final json = await remote.insertConnector(
        EcosystemMapper.connectorToJson(connector),
      );
      final created = EcosystemMapper.connectorFromJson(json);
      await local.insertConnector(created);
      return created.id;
    } catch (_) {
      return local.insertConnector(connector);
    }
  }

  @override
  Future<List<IntegrationConnector>> getAllConnectors() async {
    try {
      final jsonList = await remote.fetchAllConnectors();
      final connectors = jsonList
          .map(EcosystemMapper.connectorFromJson)
          .toList();
      for (final c in connectors) {
        await local.insertConnector(c);
      }
      return List.unmodifiable(connectors);
    } catch (_) {
      return local.getAllConnectors();
    }
  }

  @override
  Future<List<IntegrationConnector>> getConnectorsByStatus(
    ConnectorStatus status,
  ) async {
    try {
      final all = await getAllConnectors();
      return List.unmodifiable(all.where((c) => c.status == status).toList());
    } catch (_) {
      final all = await local.getAllConnectors();
      return List.unmodifiable(all.where((c) => c.status == status).toList());
    }
  }

  @override
  Future<List<IntegrationConnector>> getConnectorsByCategory(
    ConnectorCategory category,
  ) async {
    try {
      final all = await getAllConnectors();
      return List.unmodifiable(
        all.where((c) => c.category == category).toList(),
      );
    } catch (_) {
      final all = await local.getAllConnectors();
      return List.unmodifiable(
        all.where((c) => c.category == category).toList(),
      );
    }
  }

  @override
  Future<bool> updateConnector(IntegrationConnector connector) async {
    try {
      await remote.updateConnector(
        connector.id,
        EcosystemMapper.connectorToJson(connector),
      );
      await local.updateConnector(connector);
      return true;
    } catch (_) {
      return local.updateConnector(connector);
    }
  }

  @override
  Future<bool> deleteConnector(String id) async {
    try {
      await remote.deleteConnector(id);
      await local.deleteConnector(id);
      return true;
    } catch (_) {
      return local.deleteConnector(id);
    }
  }

  @override
  Future<String> insertMarketplaceApp(MarketplaceApp app) async {
    try {
      final json = await remote.insertMarketplaceApp(
        EcosystemMapper.appToJson(app),
      );
      final created = EcosystemMapper.appFromJson(json);
      await local.insertMarketplaceApp(created);
      return created.id;
    } catch (_) {
      return local.insertMarketplaceApp(app);
    }
  }

  @override
  Future<List<MarketplaceApp>> getAllMarketplaceApps() async {
    try {
      final jsonList = await remote.fetchAllMarketplaceApps();
      final apps = jsonList.map(EcosystemMapper.appFromJson).toList();
      for (final a in apps) {
        await local.insertMarketplaceApp(a);
      }
      return List.unmodifiable(apps);
    } catch (_) {
      return local.getAllMarketplaceApps();
    }
  }

  @override
  Future<List<MarketplaceApp>> getMarketplaceAppsByStatus(
    AppInstallStatus installStatus,
  ) async {
    try {
      final all = await getAllMarketplaceApps();
      return List.unmodifiable(
        all.where((a) => a.installStatus == installStatus).toList(),
      );
    } catch (_) {
      final all = await local.getAllMarketplaceApps();
      return List.unmodifiable(
        all.where((a) => a.installStatus == installStatus).toList(),
      );
    }
  }

  @override
  Future<List<MarketplaceApp>> getMarketplaceAppsByCategory(
    AppCategory category,
  ) async {
    try {
      final all = await getAllMarketplaceApps();
      return List.unmodifiable(
        all.where((a) => a.category == category).toList(),
      );
    } catch (_) {
      final all = await local.getAllMarketplaceApps();
      return List.unmodifiable(
        all.where((a) => a.category == category).toList(),
      );
    }
  }

  @override
  Future<bool> updateMarketplaceApp(MarketplaceApp app) async {
    try {
      await remote.updateMarketplaceApp(app.id, EcosystemMapper.appToJson(app));
      await local.updateMarketplaceApp(app);
      return true;
    } catch (_) {
      return local.updateMarketplaceApp(app);
    }
  }

  @override
  Future<bool> deleteMarketplaceApp(String id) async {
    try {
      await remote.deleteMarketplaceApp(id);
      await local.deleteMarketplaceApp(id);
      return true;
    } catch (_) {
      return local.deleteMarketplaceApp(id);
    }
  }
}
