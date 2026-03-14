import 'package:ca_app/features/llp_compliance/domain/models/llp_entity.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';

/// Abstract contract for LLP compliance data operations.
///
/// Covers LLP entity management and compliance filings.
abstract class LlpComplianceRepository {
  // -------------------------------------------------------------------------
  // LLPEntity operations
  // -------------------------------------------------------------------------

  /// Retrieve all LLP entities.
  Future<List<LLPEntity>> getEntities();

  /// Retrieve a single entity by [id]. Returns null if not found.
  Future<LLPEntity?> getEntityById(String id);

  /// Search entities by [query] (matched against LLP name and LLPIN).
  Future<List<LLPEntity>> searchEntities(String query);

  /// Insert a new [LLPEntity] and return its ID.
  Future<String> insertEntity(LLPEntity entity);

  /// Update an existing [LLPEntity]. Returns true on success.
  Future<bool> updateEntity(LLPEntity entity);

  /// Delete the entity identified by [id]. Returns true on success.
  Future<bool> deleteEntity(String id);

  // -------------------------------------------------------------------------
  // LLPFiling operations
  // -------------------------------------------------------------------------

  /// Retrieve all LLP filings.
  Future<List<LLPFiling>> getFilings();

  /// Retrieve filings for a specific LLP [llpId].
  Future<List<LLPFiling>> getFilingsByEntity(String llpId);

  /// Retrieve filings filtered by [status].
  Future<List<LLPFiling>> getFilingsByStatus(LLPFilingStatus status);

  /// Insert a new [LLPFiling] and return its ID.
  Future<String> insertFiling(LLPFiling filing);

  /// Update an existing [LLPFiling]. Returns true on success.
  Future<bool> updateFiling(LLPFiling filing);

  /// Delete the filing identified by [id]. Returns true on success.
  Future<bool> deleteFiling(String id);
}
