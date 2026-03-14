import 'package:ca_app/features/xbrl/domain/models/xbrl_filing.dart';

/// Abstract contract for XBRL data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class XbrlRepository {
  /// Retrieve all XBRL filings.
  Future<List<XbrlFiling>> getAllFilings();

  /// Retrieve filings for a given [companyId].
  Future<List<XbrlFiling>> getFilingsByCompany(String companyId);

  /// Retrieve a single filing by [id]. Returns null if not found.
  Future<XbrlFiling?> getFilingById(String id);

  /// Insert a new [XbrlFiling]. Returns its ID.
  Future<String> insertFiling(XbrlFiling filing);

  /// Update an existing [XbrlFiling]. Returns true on success.
  Future<bool> updateFiling(XbrlFiling filing);

  /// Delete a filing by [id]. Returns true on success.
  Future<bool> deleteFiling(String id);
}
