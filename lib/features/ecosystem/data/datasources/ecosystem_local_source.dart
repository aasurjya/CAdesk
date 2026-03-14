import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';

/// Local (SQLite via Drift) data source for ecosystem connectors and apps.
///
/// Note: full DAO wiring is deferred until the ecosystem tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class EcosystemLocalSource {
  const EcosystemLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertConnector(IntegrationConnector c) async => c.id;

  Future<List<IntegrationConnector>> getAllConnectors() async => const [];

  Future<bool> updateConnector(IntegrationConnector c) async => false;

  Future<bool> deleteConnector(String id) async => false;

  Future<String> insertMarketplaceApp(MarketplaceApp app) async => app.id;

  Future<List<MarketplaceApp>> getAllMarketplaceApps() async => const [];

  Future<bool> updateMarketplaceApp(MarketplaceApp app) async => false;

  Future<bool> deleteMarketplaceApp(String id) async => false;
}
