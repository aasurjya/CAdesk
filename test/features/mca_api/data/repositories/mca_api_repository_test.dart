import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/mca_api/data/mock_mca_repository.dart';
import 'package:ca_app/features/mca_api/data/repositories/mca_api_repository_impl.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_record.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

// ---------------------------------------------------------------------------
// Fakes & helpers
// ---------------------------------------------------------------------------

class _FakeCredentialRepository implements PortalCredentialRepository {
  _FakeCredentialRepository({this.credential});
  final PortalCredential? credential;

  @override
  Future<PortalCredential?> getCredential(PortalType _) async => credential;

  @override
  Future<String> storeCredential(PortalCredential c) async => c.id;

  @override
  Future<bool> updateCredential(PortalCredential c) async => true;

  @override
  Future<bool> deleteCredential(PortalType _) async => true;

  @override
  Future<String?> getSyncStatus(PortalType _) async => null;

  @override
  Future<bool> updateSyncStatus(PortalType _, String s) async => true;
}

PortalCredential _makeCredential() => const PortalCredential(
  id: 'cred-mca-1',
  portalType: PortalType.mca,
  grantToken: 'test-mca-api-key',
);

class _MockHttpAdapter implements HttpClientAdapter {
  _MockHttpAdapter({required this.body, this.statusCode = 200});
  final Map<String, dynamic> body;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = utf8.encode(jsonEncode(body));
    return ResponseBody.fromBytes(bytes, statusCode);
  }

  @override
  void close({bool force = false}) {}
}

Dio _mockDio(Map<String, dynamic> body, {int statusCode = 200}) {
  final dio = Dio();
  dio.httpClientAdapter = _MockHttpAdapter(body: body, statusCode: statusCode);
  return dio;
}

McaApiRepositoryImpl _makeRepo({
  required Map<String, dynamic> responseBody,
  int statusCode = 200,
  bool flagEnabled = false,
  PortalCredential? credential,
}) {
  return McaApiRepositoryImpl(
    dio: _mockDio(responseBody, statusCode: statusCode),
    credentialRepository: _FakeCredentialRepository(
      credential: credential ?? _makeCredential(),
    ),
    featureFlagEnabled: flagEnabled,
  );
}

const String _kValidCin = 'L17110MH1973PLC019786';
const String _kValidDin = '00000009';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // MockMcaRepository — comprehensive contract tests
  // -------------------------------------------------------------------------
  group('MockMcaRepository', () {
    late MockMcaRepository repo;

    setUp(() {
      repo = const MockMcaRepository();
    });

    const validDin = '00001001';

    group('lookupByCin', () {
      test('returns company for valid CIN', () async {
        final result = await repo.lookupByCin(_kValidCin);
        expect(result.cin, _kValidCin);
        expect(result.status, McaCompanyStatus.active);
      });

      test('throws ArgumentError for invalid CIN', () async {
        expect(() => repo.lookupByCin('INVALID'), throwsArgumentError);
      });
    });

    group('searchByName', () {
      test('returns result for non-empty name', () async {
        final result = await repo.searchByName('Reliance');
        expect(result.companyName, isNotEmpty);
      });

      test('throws ArgumentError for empty name', () async {
        expect(() => repo.searchByName(''), throwsArgumentError);
      });
    });

    group('lookupDirector', () {
      test('returns director for valid DIN', () async {
        final result = await repo.lookupDirector(validDin);
        expect(result.din, validDin);
        expect(result.status, McaDirectorStatus.approved);
      });

      test('throws ArgumentError for invalid DIN', () async {
        expect(() => repo.lookupDirector('BADDIN'), throwsArgumentError);
      });
    });

    group('getFormStatus', () {
      test('returns approved status for valid SRN', () async {
        final result = await repo.getFormStatus('A12345678');
        expect(result.status, McaEFormStatusValue.approved);
      });
    });

    group('getFilingHistory', () {
      test('returns history with filings for valid CIN', () async {
        final result = await repo.getFilingHistory(_kValidCin);
        expect(result.cin, _kValidCin);
        expect(result.filings, isNotEmpty);
      });

      test('throws ArgumentError for invalid CIN', () async {
        expect(() => repo.getFilingHistory('INVALID'), throwsArgumentError);
      });
    });

    group('prefillAndSubmitForm', () {
      test('returns pending status with generated SRN', () async {
        final result = await repo.prefillAndSubmitForm(_kValidCin, 'MGT-7', {
          'key': 'value',
        });
        expect(result.status, McaEFormStatusValue.pending);
        expect(result.srn, isNotEmpty);
        expect(result.cin, _kValidCin);
        expect(result.formType, 'MGT-7');
      });

      test('throws ArgumentError for invalid CIN', () async {
        expect(
          () => repo.prefillAndSubmitForm('INVALID', 'MGT-7', {}),
          throwsArgumentError,
        );
      });
    });
  });

  // -------------------------------------------------------------------------
  // McaApiRepositoryImpl — input validation (ArgumentErrors propagate
  // regardless of flag state because validation happens before the HTTP call)
  // -------------------------------------------------------------------------
  group('McaApiRepositoryImpl — input validation', () {
    test('lookupByCin throws ArgumentError for invalid CIN', () {
      final repo = _makeRepo(responseBody: {});
      expect(() => repo.lookupByCin('INVALID'), throwsArgumentError);
    });

    test('lookupByCin throws ArgumentError for empty string', () {
      final repo = _makeRepo(responseBody: {});
      expect(() => repo.lookupByCin(''), throwsArgumentError);
    });

    test('searchByName throws ArgumentError for empty string', () {
      final repo = _makeRepo(responseBody: {});
      expect(() => repo.searchByName(''), throwsArgumentError);
    });

    test('lookupDirector throws ArgumentError for 7-digit DIN', () {
      final repo = _makeRepo(responseBody: {});
      expect(() => repo.lookupDirector('1234567'), throwsArgumentError);
    });

    test('lookupDirector throws ArgumentError for alpha DIN', () {
      final repo = _makeRepo(responseBody: {});
      expect(() => repo.lookupDirector('ABCDEFGH'), throwsArgumentError);
    });

    test('getFilingHistory throws ArgumentError for invalid CIN', () {
      final repo = _makeRepo(responseBody: {});
      expect(() => repo.getFilingHistory('BAD'), throwsArgumentError);
    });

    test('prefillAndSubmitForm throws ArgumentError for invalid CIN', () {
      final repo = _makeRepo(responseBody: {});
      expect(
        () => repo.prefillAndSubmitForm('BAD', 'MGT-7', {}),
        throwsArgumentError,
      );
    });
  });

  // -------------------------------------------------------------------------
  // McaApiRepositoryImpl — flag OFF (fallback to mock)
  // -------------------------------------------------------------------------
  group('McaApiRepositoryImpl — flag disabled falls back to mock', () {
    // When flag is off, ANY error (network, auth, etc.) silently falls back.

    test('lookupByCin falls back to mock when no credentials', () async {
      final repo = McaApiRepositoryImpl(
        dio: Dio(),
        credentialRepository: _FakeCredentialRepository(), // no credential
        featureFlagEnabled: false,
      );
      // Should not throw — falls back to mock data.
      final result = await repo.lookupByCin(_kValidCin);
      expect(result.cin, _kValidCin);
      expect(result.status, McaCompanyStatus.active);
    });

    test('searchByName falls back to mock when no credentials', () async {
      final repo = McaApiRepositoryImpl(
        dio: Dio(),
        credentialRepository: _FakeCredentialRepository(),
        featureFlagEnabled: false,
      );
      final result = await repo.searchByName('Tata');
      expect(result.companyName, isNotEmpty);
    });

    test('lookupDirector falls back to mock when no credentials', () async {
      final repo = McaApiRepositoryImpl(
        dio: Dio(),
        credentialRepository: _FakeCredentialRepository(),
        featureFlagEnabled: false,
      );
      final result = await repo.lookupDirector(_kValidDin);
      expect(result.din, _kValidDin);
      expect(result.status, McaDirectorStatus.approved);
    });

    test('getFilingHistory returns empty list on error (flag off)', () async {
      final repo = McaApiRepositoryImpl(
        dio: Dio(),
        credentialRepository: _FakeCredentialRepository(),
        featureFlagEnabled: false,
      );
      final result = await repo.getFilingHistory(_kValidCin);
      expect(result.cin, _kValidCin);
      expect(result.filings, isEmpty);
    });

    test('getFormStatus returns mock result (flag off)', () async {
      final repo = _makeRepo(responseBody: {}, flagEnabled: false);
      final result = await repo.getFormStatus('A12345678');
      expect(result.status, McaEFormStatusValue.approved);
    });

    test('prefillAndSubmitForm returns pending mock result (flag off)', () async {
      final repo = _makeRepo(responseBody: {}, flagEnabled: false);
      final result = await repo.prefillAndSubmitForm(
        _kValidCin,
        'MGT-7',
        {'field': 'value'},
      );
      expect(result.status, McaEFormStatusValue.pending);
      expect(result.srn, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // McaApiRepositoryImpl — flag ON, happy HTTP paths
  // -------------------------------------------------------------------------
  group('McaApiRepositoryImpl — flag enabled, HTTP success paths', () {
    test('lookupByCin maps CompanyDetails to McaCompanyLookup', () async {
      final repo = _makeRepo(
        responseBody: {
          'cin': _kValidCin,
          'company_name': 'Tata Motors Limited',
          'registered_address': 'Bombay House, Mumbai',
          'authorized_capital': 6400000000,
          'paid_up_capital': 3400000000,
          'company_status': 'Active',
          'date_of_incorporation': '10/11/1973',
          'roc_code': 'RoC-Mumbai',
          'directors': <Map<String, dynamic>>[],
        },
        flagEnabled: true,
      );

      final result = await repo.lookupByCin(_kValidCin);
      expect(result.cin, _kValidCin);
      expect(result.companyName, 'Tata Motors Limited');
      expect(result.registeredOfficeAddress, 'Bombay House, Mumbai');
      expect(result.authorizedCapital, 6400000000);
      expect(result.paidUpCapital, 3400000000);
      expect(result.roc, 'RoC-Mumbai');
      expect(result.status, McaCompanyStatus.active);
      // CIN: L17110MH1973PLC019786 → state at positions 6–7 = 'MH'.
      expect(result.state, 'MH');
    });

    test('searchByName maps first CompanySearchResult to McaCompanyLookup', () async {
      final repo = _makeRepo(
        responseBody: {
          'companyData': [
            {
              'cin': _kValidCin,
              'company_name': 'Tata Motors Limited',
              'company_status': 'Active',
              'date_of_incorporation': '10/11/1973',
              'roc_code': 'RoC-Mumbai',
            },
          ],
        },
        flagEnabled: true,
      );

      final result = await repo.searchByName('Tata');
      expect(result.cin, _kValidCin);
      expect(result.companyName, 'Tata Motors Limited');
      expect(result.state, 'MH');
      expect(result.status, McaCompanyStatus.active);
    });

    test('searchByName falls back to mock when results list is empty', () async {
      final repo = _makeRepo(
        responseBody: {'companyData': <dynamic>[]},
        flagEnabled: true,
      );
      // No results → mock fallback is always acceptable data.
      final result = await repo.searchByName('Nonexistent XYZ Corp');
      expect(result.companyName, isNotEmpty);
    });

    test('lookupDirector maps DirectorDetails to McaDirectorLookup', () async {
      final repo = _makeRepo(
        responseBody: {
          'din': _kValidDin,
          'director_name': 'Ram Kumar',
          'nationality': 'Indian',
          'din_status': 'Approved',
          'associated_companies': [_kValidCin],
          'father_name': 'Shyam Kumar',
          'dob': '15/05/1970',
        },
        flagEnabled: true,
      );

      final result = await repo.lookupDirector(_kValidDin);
      expect(result.din, _kValidDin);
      expect(result.directorName, 'Ram Kumar');
      expect(result.nationality, 'Indian');
      expect(result.status, McaDirectorStatus.approved);
      expect(result.associatedCompanies, contains(_kValidCin));
      expect(result.fatherName, 'Shyam Kumar');
      expect(result.dateOfBirth, DateTime(1970, 5, 15));
    });

    test('getFilingHistory maps McaFilingRecord list', () async {
      final repo = _makeRepo(
        responseBody: {
          'filingHistory': [
            {
              'srn': 'A12345678',
              'form_type': 'MGT-7',
              'date_of_filing': '30/09/2023',
              'status': 'Approved',
              'document_description': 'Annual Return',
              'fees_paid': 60000,
            },
          ],
        },
        flagEnabled: true,
      );

      final result = await repo.getFilingHistory(_kValidCin);
      expect(result.cin, _kValidCin);
      expect(result.filings, hasLength(1));
      expect(result.filings.first.srn, 'A12345678');
      expect(result.filings.first.formType, 'MGT-7');
      expect(result.filings.first.feesPaid, 60000);
    });

    test('getFilingHistory returns empty filing list when API returns none', () async {
      final repo = _makeRepo(
        responseBody: {'filingHistory': <dynamic>[]},
        flagEnabled: true,
      );
      final result = await repo.getFilingHistory(_kValidCin);
      expect(result.filings, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // McaApiRepositoryImpl — flag ON, HTTP error paths
  // -------------------------------------------------------------------------
  group('McaApiRepositoryImpl — flag enabled, HTTP error propagation', () {
    test('lookupByCin propagates PortalAuthException (401) when flag on', () {
      final repo = _makeRepo(
        responseBody: {'message': 'Unauthorized'},
        statusCode: 401,
        flagEnabled: true,
      );
      expect(
        () => repo.lookupByCin(_kValidCin),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('lookupByCin propagates PortalRateLimitException (429) when flag on', () {
      final repo = _makeRepo(
        responseBody: {'message': 'Too many requests'},
        statusCode: 429,
        flagEnabled: true,
      );
      expect(
        () => repo.lookupByCin(_kValidCin),
        throwsA(isA<PortalRateLimitException>()),
      );
    });

    test(
      'lookupByCin propagates PortalUnavailableException (500) when flag on',
      () {
        final repo = _makeRepo(
          responseBody: {'message': 'Internal Server Error'},
          statusCode: 500,
          flagEnabled: true,
        );
        expect(
          () => repo.lookupByCin(_kValidCin),
          throwsA(isA<PortalUnavailableException>()),
        );
      },
    );

    test(
      'searchByName propagates PortalAuthException (403) when flag on',
      () {
        final repo = _makeRepo(
          responseBody: {'message': 'Forbidden'},
          statusCode: 403,
          flagEnabled: true,
        );
        expect(
          () => repo.searchByName('Tata'),
          throwsA(isA<PortalAuthException>()),
        );
      },
    );

    test(
      'lookupDirector propagates PortalUnavailableException (503) when flag on',
      () {
        final repo = _makeRepo(
          responseBody: {'message': 'Service unavailable'},
          statusCode: 503,
          flagEnabled: true,
        );
        expect(
          () => repo.lookupDirector(_kValidDin),
          throwsA(isA<PortalUnavailableException>()),
        );
      },
    );

    test(
      'getFilingHistory propagates PortalAuthException (401) when flag on',
      () {
        final repo = _makeRepo(
          responseBody: {'message': 'Unauthorized'},
          statusCode: 401,
          flagEnabled: true,
        );
        expect(
          () => repo.getFilingHistory(_kValidCin),
          throwsA(isA<PortalAuthException>()),
        );
      },
    );

    test(
      'lookupByCin falls back to mock on 401 when flag off',
      () async {
        final repo = _makeRepo(
          responseBody: {'message': 'Unauthorized'},
          statusCode: 401,
          flagEnabled: false,
        );
        // Should not throw — falls back to mock.
        final result = await repo.lookupByCin(_kValidCin);
        expect(result.cin, _kValidCin);
      },
    );
  });

  // -------------------------------------------------------------------------
  // McaApiRepositoryImpl — immutability of returned collections
  // -------------------------------------------------------------------------
  group('McaApiRepositoryImpl — immutability', () {
    test('getFilingHistory returns unmodifiable filings list', () async {
      final repo = _makeRepo(
        responseBody: {
          'filingHistory': [
            {
              'srn': 'A00000001',
              'form_type': 'AOC-4',
              'date_of_filing': '15/10/2023',
              'status': 'Approved',
              'document_description': 'Financial Statements',
              'fees_paid': 20000,
            },
          ],
        },
        flagEnabled: true,
      );
      final history = await repo.getFilingHistory(_kValidCin);
      // Verify the list is unmodifiable by casting to List and attempting add.
      // Use a typed dummy value to avoid a TypeError masking UnsupportedError.
      final dummy = McaFilingRecord(
        srn: 'X',
        formType: 'X',
        filedAt: DateTime(2000),
        status: 'X',
        documentDescription: 'X',
        feesPaid: 0,
      );
      expect(
        () => (history.filings as List).add(dummy),
        throwsUnsupportedError,
      );
    });

    test('lookupDirector returns unmodifiable associatedCompanies list', () async {
      final repo = _makeRepo(
        responseBody: {
          'din': _kValidDin,
          'director_name': 'Test Director',
          'nationality': 'Indian',
          'din_status': 'Approved',
          'associated_companies': [_kValidCin],
        },
        flagEnabled: true,
      );
      final result = await repo.lookupDirector(_kValidDin);
      expect(
        () => (result.associatedCompanies as List).add('extra'),
        throwsUnsupportedError,
      );
    });
  });
}
