import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';

/// Abstract contract for ecosystem/integration data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class EcosystemRepository {
  /// Insert a new [IntegrationConnector] and return its generated ID.
  Future<String> insertConnector(IntegrationConnector connector);

  /// Retrieve all integration connectors.
  Future<List<IntegrationConnector>> getAllConnectors();

  /// Retrieve connectors filtered by [status].
  Future<List<IntegrationConnector>> getConnectorsByStatus(
    ConnectorStatus status,
  );

  /// Retrieve connectors filtered by [category].
  Future<List<IntegrationConnector>> getConnectorsByCategory(
    ConnectorCategory category,
  );

  /// Update an existing [IntegrationConnector]. Returns true on success.
  Future<bool> updateConnector(IntegrationConnector connector);

  /// Delete the connector identified by [id]. Returns true on success.
  Future<bool> deleteConnector(String id);

  /// Insert a new [MarketplaceApp] and return its generated ID.
  Future<String> insertMarketplaceApp(MarketplaceApp app);

  /// Retrieve all marketplace apps.
  Future<List<MarketplaceApp>> getAllMarketplaceApps();

  /// Retrieve marketplace apps filtered by [installStatus].
  Future<List<MarketplaceApp>> getMarketplaceAppsByStatus(
    AppInstallStatus installStatus,
  );

  /// Retrieve marketplace apps filtered by [category].
  Future<List<MarketplaceApp>> getMarketplaceAppsByCategory(
    AppCategory category,
  );

  /// Update an existing [MarketplaceApp]. Returns true on success.
  Future<bool> updateMarketplaceApp(MarketplaceApp app);

  /// Delete the marketplace app identified by [id]. Returns true on success.
  Future<bool> deleteMarketplaceApp(String id);
}
