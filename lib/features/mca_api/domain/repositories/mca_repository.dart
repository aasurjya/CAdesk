import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';

/// Abstract repository defining MCA portal API operations.
///
/// All implementations must be stateless and must not perform mutations.
/// Throws [ArgumentError] on invalid input (malformed CIN/DIN).
/// Throws [StateError] when a lookup target is not found.
abstract class McaRepository {
  /// Looks up a company by its 21-character CIN.
  ///
  /// Throws [ArgumentError] if [cin] does not match the required format:
  /// `[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}`
  Future<McaCompanyLookup> lookupByCin(String cin);

  /// Searches for a company by its registered name.
  ///
  /// Throws [ArgumentError] if [name] is empty.
  Future<McaCompanyLookup> searchByName(String name);

  /// Looks up a director by their 8-digit Director Identification Number.
  ///
  /// Throws [ArgumentError] if [din] is not exactly 8 numeric digits.
  Future<McaDirectorLookup> lookupDirector(String din);

  /// Retrieves the current status of a filed e-Form by its SRN.
  Future<McaEFormStatus> getFormStatus(String srn);

  /// Returns the complete filing history for a company identified by [cin].
  ///
  /// Throws [ArgumentError] if [cin] does not match the required format.
  Future<McaFilingHistory> getFilingHistory(String cin);

  /// Prefills and submits an MCA e-Form for the given [cin] and [formType].
  ///
  /// [prefillData] maps MCA portal field names to their string values.
  /// Returns a [McaEFormStatus] with [McaEFormStatusValue.pending] status
  /// and a freshly generated SRN.
  ///
  /// Throws [ArgumentError] if [cin] is invalid.
  Future<McaEFormStatus> prefillAndSubmitForm(
    String cin,
    String formType,
    Map<String, String> prefillData,
  );
}
