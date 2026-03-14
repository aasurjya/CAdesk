import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';

/// Abstract contract for startup compliance data operations.
///
/// Covers startup entities and startup filings.
abstract class StartupComplianceRepository {
  // ---------------------------------------------------------------------------
  // StartupEntity
  // ---------------------------------------------------------------------------

  /// Returns all startup entities.
  Future<List<StartupEntity>> getStartupEntities();

  /// Returns the startup entity for [id], or null if not found.
  Future<StartupEntity?> getStartupEntityById(String id);

  /// Returns all startup entities matching [status].
  Future<List<StartupEntity>> getStartupEntitiesByRecognitionStatus(
    RecognitionStatus status,
  );

  /// Inserts a new [StartupEntity] and returns its ID.
  Future<String> insertStartupEntity(StartupEntity entity);

  /// Updates an existing [StartupEntity]. Returns true on success.
  Future<bool> updateStartupEntity(StartupEntity entity);

  /// Deletes the startup entity identified by [id]. Returns true on success.
  Future<bool> deleteStartupEntity(String id);

  // ---------------------------------------------------------------------------
  // StartupFiling
  // ---------------------------------------------------------------------------

  /// Returns all startup filings.
  Future<List<StartupFiling>> getStartupFilings();

  /// Returns the startup filing for [id], or null if not found.
  Future<StartupFiling?> getStartupFilingById(String id);

  /// Returns all filings for [startupId].
  Future<List<StartupFiling>> getStartupFilingsByStartup(String startupId);

  /// Returns all filings matching [status].
  Future<List<StartupFiling>> getStartupFilingsByStatus(
    StartupFilingStatus status,
  );

  /// Inserts a new [StartupFiling] and returns its ID.
  Future<String> insertStartupFiling(StartupFiling filing);

  /// Updates an existing [StartupFiling]. Returns true on success.
  Future<bool> updateStartupFiling(StartupFiling filing);

  /// Deletes the filing identified by [id]. Returns true on success.
  Future<bool> deleteStartupFiling(String id);
}
