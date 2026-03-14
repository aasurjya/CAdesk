import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';
import 'package:ca_app/features/mca_api/domain/repositories/mca_repository.dart';

/// CIN validation pattern: [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}
final _cinRegex = RegExp(r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$');

/// DIN validation pattern: exactly 8 numeric digits.
final _dinRegex = RegExp(r'^[0-9]{8}$');

/// Real implementation of [McaRepository].
///
/// Makes HTTP calls to the MCA portal API.
/// Full wiring to [McaApiService] is deferred until the portal integration phase.
class McaApiRepositoryImpl implements McaRepository {
  const McaApiRepositoryImpl();

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

  @override
  Future<McaCompanyLookup> lookupByCin(String cin) async {
    _assertValidCin(cin);
    // TODO(portal): delegate to McaApiService HTTP call
    throw UnimplementedError('lookupByCin requires portal integration');
  }

  @override
  Future<McaCompanyLookup> searchByName(String name) async {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Search term must not be empty');
    }
    // TODO(portal): delegate to McaApiService HTTP call
    throw UnimplementedError('searchByName requires portal integration');
  }

  @override
  Future<McaDirectorLookup> lookupDirector(String din) async {
    _assertValidDin(din);
    // TODO(portal): delegate to McaApiService HTTP call
    throw UnimplementedError('lookupDirector requires portal integration');
  }

  @override
  Future<McaEFormStatus> getFormStatus(String srn) async {
    // TODO(portal): delegate to McaApiService HTTP call
    throw UnimplementedError('getFormStatus requires portal integration');
  }

  @override
  Future<McaFilingHistory> getFilingHistory(String cin) async {
    _assertValidCin(cin);
    // TODO(portal): delegate to McaApiService HTTP call
    return McaFilingHistory(cin: cin, filings: const []);
  }

  @override
  Future<McaEFormStatus> prefillAndSubmitForm(
    String cin,
    String formType,
    Map<String, String> prefillData,
  ) async {
    _assertValidCin(cin);
    // TODO(portal): delegate to McaApiService HTTP call
    throw UnimplementedError(
      'prefillAndSubmitForm requires portal integration',
    );
  }
}
