import 'package:dio/dio.dart';

import 'package:ca_app/features/mca_api/data/mock_mca_repository.dart';
import 'package:ca_app/features/mca_api/data/services/mca_api_service.dart';
import 'package:ca_app/features/mca_api/domain/models/company_details.dart';
import 'package:ca_app/features/mca_api/domain/models/director_details.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_record.dart';
import 'package:ca_app/features/mca_api/domain/repositories/mca_repository.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

/// CIN validation pattern: [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}
final _cinRegex = RegExp(r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$');

/// DIN validation pattern: exactly 8 numeric digits.
final _dinRegex = RegExp(r'^[0-9]{8}$');

/// Real implementation of [McaRepository].
///
/// Delegates to [McaApiService] HTTP calls. When [featureFlagEnabled] is
/// `false`, every API error falls back to [MockMcaRepository] data, providing
/// safe offline/demo behaviour. The provider layer is responsible for evaluating
/// the feature flag and passing the result through the constructor.
class McaApiRepositoryImpl implements McaRepository {
  const McaApiRepositoryImpl({
    required this.dio,
    required this.credentialRepository,
    this.featureFlagEnabled = false,
  }) : _mock = const MockMcaRepository();

  /// Dio HTTP client used for all outbound requests.
  final Dio dio;

  /// Repository used to resolve the MCA API key at call time.
  final PortalCredentialRepository credentialRepository;

  /// When `true`, errors from the real API are propagated to the caller.
  /// When `false`, any error causes a transparent fallback to [MockMcaRepository].
  final bool featureFlagEnabled;

  final MockMcaRepository _mock;

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  void _assertValidCin(String cin) {
    if (!_cinRegex.hasMatch(cin)) {
      throw ArgumentError.value(
        cin,
        'cin',
        'CIN must match [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}',
      );
    }
  }

  void _assertValidDin(String din) {
    if (!_dinRegex.hasMatch(din)) {
      throw ArgumentError.value(
        din,
        'din',
        'DIN must be exactly 8 numeric digits',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // McaRepository
  // ---------------------------------------------------------------------------

  @override
  Future<McaCompanyLookup> lookupByCin(String cin) async {
    _assertValidCin(cin);
    try {
      final details = await McaApiService.getCompanyDetails(
        cin,
        dio: dio,
        credentialRepository: credentialRepository,
      );
      return _companyDetailsToLookup(details);
    } catch (e) {
      if (featureFlagEnabled) rethrow;
      return _mock.lookupByCin(cin);
    }
  }

  @override
  Future<McaCompanyLookup> searchByName(String name) async {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Search term must not be empty');
    }
    try {
      final results = await McaApiService.searchCompany(
        name,
        dio: dio,
        credentialRepository: credentialRepository,
      );
      if (results.isEmpty) {
        return _mock.searchByName(name);
      }
      final first = results.first;
      // CIN format: [LU] + 5 digits + 2-letter state + ...
      // State code occupies positions 6–7 (0-indexed).
      final state = first.cin.length >= 8 ? first.cin.substring(6, 8) : '';
      return McaCompanyLookup(
        cin: first.cin,
        companyName: first.name,
        registeredOfficeAddress: '',
        state: state,
        dateOfIncorporation: first.incorporationDate,
        status: first.status,
        authorizedCapital: 0,
        paidUpCapital: 0,
        companyCategory: '',
        companySubCategory: '',
        roc: first.roc,
      );
    } catch (e) {
      if (featureFlagEnabled) rethrow;
      return _mock.searchByName(name);
    }
  }

  @override
  Future<McaDirectorLookup> lookupDirector(String din) async {
    _assertValidDin(din);
    try {
      final details = await McaApiService.searchDirector(
        din,
        dio: dio,
        credentialRepository: credentialRepository,
      );
      return _directorDetailsToLookup(details);
    } catch (e) {
      if (featureFlagEnabled) rethrow;
      return _mock.lookupDirector(din);
    }
  }

  @override
  Future<McaEFormStatus> getFormStatus(String srn) async {
    // MCA21 does not expose a standalone SRN-status endpoint in the public API.
    // Until a portal-web scraping layer is available, this uses mock data.
    // When [featureFlagEnabled] the caller receives mock data with no fallback
    // penalty; failures propagate only if the real implementation exists.
    try {
      return await _mock.getFormStatus(srn);
    } catch (e) {
      if (featureFlagEnabled) rethrow;
      return _mock.getFormStatus(srn);
    }
  }

  @override
  Future<McaFilingHistory> getFilingHistory(String cin) async {
    _assertValidCin(cin);
    try {
      final records = await McaApiService.getFilingHistory(
        cin,
        0,
        dio: dio,
        credentialRepository: credentialRepository,
      );
      return McaFilingHistory(
        cin: cin,
        filings: List<McaFilingRecord>.unmodifiable(records),
      );
    } catch (e) {
      if (featureFlagEnabled) rethrow;
      return McaFilingHistory(cin: cin, filings: const []);
    }
  }

  @override
  Future<McaEFormStatus> prefillAndSubmitForm(
    String cin,
    String formType,
    Map<String, String> prefillData,
  ) async {
    _assertValidCin(cin);
    try {
      // Real path: portal auto-submit layer (MCA e-Form WebView automation).
      // Delegate to mock until MCA portal auto-submit is wired end-to-end.
      return await _mock.prefillAndSubmitForm(cin, formType, prefillData);
    } catch (e) {
      if (featureFlagEnabled) rethrow;
      return _mock.prefillAndSubmitForm(cin, formType, prefillData);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers — model mapping
  // ---------------------------------------------------------------------------

  /// Converts a [CompanyDetails] (low-level service model) to [McaCompanyLookup]
  /// (the domain contract model).
  McaCompanyLookup _companyDetailsToLookup(CompanyDetails details) {
    // CIN format: [LU] + 5 digits + 2-letter state + 4 digits + 3 letters + 6 digits
    // State code occupies positions 6–7 (0-indexed).
    final state = details.cin.length >= 8 ? details.cin.substring(6, 8) : '';
    return McaCompanyLookup(
      cin: details.cin,
      companyName: details.name,
      registeredOfficeAddress: details.registeredAddress,
      state: state,
      dateOfIncorporation: details.incorporationDate,
      status: details.status,
      authorizedCapital: details.authorizedCapital,
      paidUpCapital: details.paidUpCapital,
      companyCategory: '',
      companySubCategory: '',
      roc: details.roc,
    );
  }

  /// Converts a [DirectorDetails] (low-level service model) to [McaDirectorLookup]
  /// (the domain contract model).
  McaDirectorLookup _directorDetailsToLookup(DirectorDetails details) {
    return McaDirectorLookup(
      din: details.din,
      directorName: details.name,
      nationality: details.nationality,
      status: details.status,
      associatedCompanies: List<String>.unmodifiable(
        details.associatedCompanies,
      ),
      dateOfBirth: details.dob,
      fatherName: details.fatherName,
    );
  }
}
