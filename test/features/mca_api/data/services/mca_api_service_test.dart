import 'dart:convert';

import 'package:ca_app/features/mca_api/data/services/mca_api_service.dart';
import 'package:ca_app/features/mca_api/domain/models/charge_record.dart';
import 'package:ca_app/features/mca_api/domain/models/company_details.dart';
import 'package:ca_app/features/mca_api/domain/models/company_search_result.dart';
import 'package:ca_app/features/mca_api/domain/models/din_details.dart';
import 'package:ca_app/features/mca_api/domain/models/director_details.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_record.dart';
import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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

const String _kValidCin = 'L17110MH1973PLC019786';
const String _kInvalidCin = 'INVALID';
const String _kValidDin = '00000009';
const String _kInvalidDin = '1234567'; // 7 digits

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Validation — ArgumentError on bad CIN / DIN
  // -------------------------------------------------------------------------
  group('McaApiService — input validation', () {
    late _FakeCredentialRepository repo;

    setUp(
      () => repo = _FakeCredentialRepository(credential: _makeCredential()),
    );

    test('searchCompany throws ArgumentError for empty query', () {
      expect(
        () => McaApiService.searchCompany(
          '',
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });

    test('searchCompany throws ArgumentError for whitespace-only query', () {
      expect(
        () => McaApiService.searchCompany(
          '   ',
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });

    test('getCompanyDetails throws ArgumentError for invalid CIN', () {
      expect(
        () => McaApiService.getCompanyDetails(
          _kInvalidCin,
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });

    test('getFilingHistory throws ArgumentError for invalid CIN', () {
      expect(
        () => McaApiService.getFilingHistory(
          _kInvalidCin,
          2024,
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });

    test('checkDin throws ArgumentError for 7-digit DIN', () {
      expect(
        () => McaApiService.checkDin(
          _kInvalidDin,
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });

    test('checkDin throws ArgumentError for DIN with letters', () {
      expect(
        () => McaApiService.checkDin(
          '1234567A',
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });

    test('getCharges throws ArgumentError for invalid CIN', () {
      expect(
        () => McaApiService.getCharges(
          _kInvalidCin,
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });

    test('searchDirector throws ArgumentError for invalid DIN', () {
      expect(
        () => McaApiService.searchDirector(
          _kInvalidDin,
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsArgumentError,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Missing credentials → PortalAuthException
  // -------------------------------------------------------------------------
  group('McaApiService — missing credentials', () {
    late _FakeCredentialRepository emptyRepo;

    setUp(() => emptyRepo = _FakeCredentialRepository());

    test('searchCompany throws PortalAuthException when no credential', () {
      expect(
        () => McaApiService.searchCompany(
          'Tata',
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getCompanyDetails throws PortalAuthException when no credential', () {
      expect(
        () => McaApiService.getCompanyDetails(
          _kValidCin,
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getFilingHistory throws PortalAuthException when no credential', () {
      expect(
        () => McaApiService.getFilingHistory(
          _kValidCin,
          2024,
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('checkDin throws PortalAuthException when no credential', () {
      expect(
        () => McaApiService.checkDin(
          _kValidDin,
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getCharges throws PortalAuthException when no credential', () {
      expect(
        () => McaApiService.getCharges(
          _kValidCin,
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('searchDirector throws PortalAuthException when no credential', () {
      expect(
        () => McaApiService.searchDirector(
          _kValidDin,
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // CompanySearchResult model
  // -------------------------------------------------------------------------
  group('CompanySearchResult model', () {
    test('copyWith only changes specified field', () {
      final original = CompanySearchResult(
        cin: _kValidCin,
        name: 'Tata Motors Ltd',
        status: McaCompanyStatus.active,
        incorporationDate: DateTime(1973, 11, 10),
        roc: 'RoC-Mumbai',
      );
      final copy = original.copyWith(name: 'Renamed Corp');
      expect(copy.name, 'Renamed Corp');
      expect(copy.cin, _kValidCin);
      expect(identical(original, copy), isFalse);
    });

    test('equality on same values', () {
      final a = CompanySearchResult(
        cin: _kValidCin,
        name: 'Tata Motors Ltd',
        status: McaCompanyStatus.active,
        incorporationDate: DateTime(1973, 11, 10),
        roc: 'RoC-Mumbai',
      );
      final b = CompanySearchResult(
        cin: _kValidCin,
        name: 'Tata Motors Ltd',
        status: McaCompanyStatus.active,
        incorporationDate: DateTime(1973, 11, 10),
        roc: 'RoC-Mumbai',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // -------------------------------------------------------------------------
  // CompanyDetails model
  // -------------------------------------------------------------------------
  group('CompanyDetails model', () {
    test('copyWith only changes directors', () {
      final original = CompanyDetails(
        cin: _kValidCin,
        name: 'ABC Ltd',
        registeredAddress: '1 MG Road',
        authorizedCapital: 100000000,
        paidUpCapital: 50000000,
        directors: const [],
        status: McaCompanyStatus.active,
        incorporationDate: DateTime(2000, 1, 1),
        roc: 'RoC-Mumbai',
      );
      final newDir = Director(din: '00000001', name: 'John', designation: 'MD');
      final copy = original.copyWith(directors: [newDir]);
      expect(copy.directors, hasLength(1));
      expect(original.directors, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // DinDetails model
  // -------------------------------------------------------------------------
  group('DinDetails model', () {
    test('copyWith preserves unchanged fields', () {
      final original = DinDetails(
        din: _kValidDin,
        name: 'Ram Kumar',
        nationality: 'Indian',
        status: McaDirectorStatus.approved,
        dob: DateTime(1970, 5, 15),
      );
      final copy = original.copyWith(name: 'Ram Kumar Singh');
      expect(copy.name, 'Ram Kumar Singh');
      expect(copy.din, _kValidDin);
      expect(copy.dob, original.dob);
    });

    test('equality on same values', () {
      final a = DinDetails(
        din: _kValidDin,
        name: 'Ram Kumar',
        nationality: 'Indian',
        status: McaDirectorStatus.approved,
      );
      final b = DinDetails(
        din: _kValidDin,
        name: 'Ram Kumar',
        nationality: 'Indian',
        status: McaDirectorStatus.approved,
      );
      expect(a, equals(b));
    });
  });

  // -------------------------------------------------------------------------
  // ChargeRecord model
  // -------------------------------------------------------------------------
  group('ChargeRecord model', () {
    test('isSatisfied is true for satisfied status', () {
      final charge = ChargeRecord(
        chargeId: 'CHG001',
        holderName: 'HDFC Bank',
        amount: 100000000,
        dateOfCreation: DateTime(2020, 1, 1),
        status: ChargeStatus.satisfied,
      );
      expect(charge.isSatisfied, isTrue);
    });

    test('isSatisfied is true for modifiedSatisfied status', () {
      final charge = ChargeRecord(
        chargeId: 'CHG002',
        holderName: 'SBI',
        amount: 50000000,
        dateOfCreation: DateTime(2019, 6, 1),
        status: ChargeStatus.modifiedSatisfied,
      );
      expect(charge.isSatisfied, isTrue);
    });

    test('isSatisfied is false for open status', () {
      final charge = ChargeRecord(
        chargeId: 'CHG003',
        holderName: 'ICICI Bank',
        amount: 75000000,
        dateOfCreation: DateTime(2022, 3, 15),
        status: ChargeStatus.open,
      );
      expect(charge.isSatisfied, isFalse);
    });

    test('copyWith dateOfSatisfaction', () {
      final charge = ChargeRecord(
        chargeId: 'CHG001',
        holderName: 'HDFC Bank',
        amount: 100000000,
        dateOfCreation: DateTime(2020, 1, 1),
        status: ChargeStatus.open,
      );
      final satisfied = charge.copyWith(
        status: ChargeStatus.satisfied,
        dateOfSatisfaction: DateTime(2024, 3, 31),
      );
      expect(satisfied.isSatisfied, isTrue);
      expect(satisfied.dateOfSatisfaction, DateTime(2024, 3, 31));
    });

    test('equality on same values', () {
      final a = ChargeRecord(
        chargeId: 'CHG001',
        holderName: 'HDFC Bank',
        amount: 100000000,
        dateOfCreation: DateTime(2020, 1, 1),
        status: ChargeStatus.open,
      );
      final b = ChargeRecord(
        chargeId: 'CHG001',
        holderName: 'HDFC Bank',
        amount: 100000000,
        dateOfCreation: DateTime(2020, 1, 1),
        status: ChargeStatus.open,
      );
      expect(a, equals(b));
    });
  });

  // -------------------------------------------------------------------------
  // DirectorDetails model
  // -------------------------------------------------------------------------
  group('DirectorDetails model', () {
    test('copyWith associatedCompanies is immutable copy', () {
      final original = DirectorDetails(
        din: _kValidDin,
        name: 'John Doe',
        nationality: 'Indian',
        status: McaDirectorStatus.approved,
        associatedCompanies: const [_kValidCin],
      );
      final copy = original.copyWith(
        associatedCompanies: [_kValidCin, 'L12345AB2000PLC000001'],
      );
      expect(copy.associatedCompanies, hasLength(2));
      expect(original.associatedCompanies, hasLength(1));
    });

    test('equality on same values', () {
      final a = DirectorDetails(
        din: _kValidDin,
        name: 'John Doe',
        nationality: 'Indian',
        status: McaDirectorStatus.approved,
        associatedCompanies: const [],
      );
      final b = DirectorDetails(
        din: _kValidDin,
        name: 'John Doe',
        nationality: 'Indian',
        status: McaDirectorStatus.approved,
        associatedCompanies: const [],
      );
      expect(a, equals(b));
    });
  });

  // -------------------------------------------------------------------------
  // McaApiService.searchCompany — HTTP happy path
  // -------------------------------------------------------------------------
  group('McaApiService.searchCompany — HTTP', () {
    test('parses list of company search results', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'companyData': [
          {
            'cin': _kValidCin,
            'company_name': 'Tata Motors Limited',
            'company_status': 'Active',
            'date_of_incorporation': '10/11/1973',
            'roc_code': 'RoC-Mumbai',
          },
        ],
      });

      final results = await McaApiService.searchCompany(
        'Tata',
        dio: dio,
        credentialRepository: repo,
      );

      expect(results, hasLength(1));
      expect(results.first.cin, _kValidCin);
      expect(results.first.name, 'Tata Motors Limited');
      expect(results.first.status, McaCompanyStatus.active);
      expect(results.first.incorporationDate, DateTime(1973, 11, 10));
    });

    test('returns empty list when no results', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({'companyData': []});

      final results = await McaApiService.searchCompany(
        'Nonexistent Corp XYZ',
        dio: dio,
        credentialRepository: repo,
      );

      expect(results, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // McaApiService.getCompanyDetails — HTTP happy path
  // -------------------------------------------------------------------------
  group('McaApiService.getCompanyDetails — HTTP', () {
    test('parses full company details with directors', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'cin': _kValidCin,
        'company_name': 'Tata Motors Limited',
        'registered_address': 'Bombay House, 24 Homi Mody Street',
        'authorized_capital': 6400000000,
        'paid_up_capital': 3400000000,
        'company_status': 'Active',
        'date_of_incorporation': '10/11/1973',
        'roc_code': 'RoC-Mumbai',
        'directors': [
          {
            'din': '00000001',
            'director_name': 'N Chandrasekaran',
            'designation': 'Chairman',
            'date_of_appointment': '12/01/2017',
          },
        ],
      });

      final details = await McaApiService.getCompanyDetails(
        _kValidCin,
        dio: dio,
        credentialRepository: repo,
      );

      expect(details.cin, _kValidCin);
      expect(details.name, 'Tata Motors Limited');
      expect(details.directors, hasLength(1));
      expect(details.directors.first.din, '00000001');
      expect(details.directors.first.designation, 'Chairman');
      expect(details.authorizedCapital, 6400000000);
    });
  });

  // -------------------------------------------------------------------------
  // McaApiService.getFilingHistory — HTTP happy path
  // -------------------------------------------------------------------------
  group('McaApiService.getFilingHistory — HTTP', () {
    test('parses filing history records', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
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
      });

      final records = await McaApiService.getFilingHistory(
        _kValidCin,
        2023,
        dio: dio,
        credentialRepository: repo,
      );

      expect(records, hasLength(1));
      expect(records.first.srn, 'A12345678');
      expect(records.first.formType, 'MGT-7');
      expect(records.first.feesPaid, 60000);
    });

    test('returns empty list when no filing history', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({'filingHistory': []});

      final records = await McaApiService.getFilingHistory(
        _kValidCin,
        0,
        dio: dio,
        credentialRepository: repo,
      );

      expect(records, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // McaApiService.checkDin — HTTP happy path
  // -------------------------------------------------------------------------
  group('McaApiService.checkDin — HTTP', () {
    test('parses DIN details correctly', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'din': _kValidDin,
        'director_name': 'Ram Kumar',
        'nationality': 'Indian',
        'din_status': 'Approved',
        'dob': '15/05/1970',
      });

      final details = await McaApiService.checkDin(
        _kValidDin,
        dio: dio,
        credentialRepository: repo,
      );

      expect(details.din, _kValidDin);
      expect(details.name, 'Ram Kumar');
      expect(details.status, McaDirectorStatus.approved);
      expect(details.dob, DateTime(1970, 5, 15));
    });
  });

  // -------------------------------------------------------------------------
  // McaApiService.getCharges — HTTP happy path
  // -------------------------------------------------------------------------
  group('McaApiService.getCharges — HTTP', () {
    test('parses charge records', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'charges': [
          {
            'charge_id': 'CHG001',
            'charge_holder_name': 'HDFC Bank',
            'amount': 500000000,
            'date_of_creation': '01/04/2020',
            'status': 'Open',
            'assets_description': 'Plant and machinery',
          },
        ],
      });

      final charges = await McaApiService.getCharges(
        _kValidCin,
        dio: dio,
        credentialRepository: repo,
      );

      expect(charges, hasLength(1));
      expect(charges.first.chargeId, 'CHG001');
      expect(charges.first.holderName, 'HDFC Bank');
      expect(charges.first.isSatisfied, isFalse);
      expect(charges.first.assets, 'Plant and machinery');
    });
  });

  // -------------------------------------------------------------------------
  // McaApiService.searchDirector — HTTP happy path
  // -------------------------------------------------------------------------
  group('McaApiService.searchDirector — HTTP', () {
    test('parses director details with associated companies', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'din': _kValidDin,
        'director_name': 'John Doe',
        'nationality': 'Indian',
        'din_status': 'Approved',
        'associated_companies': [_kValidCin],
        'father_name': 'James Doe',
      });

      final details = await McaApiService.searchDirector(
        _kValidDin,
        dio: dio,
        credentialRepository: repo,
      );

      expect(details.din, _kValidDin);
      expect(details.associatedCompanies, contains(_kValidCin));
      expect(details.fatherName, 'James Doe');
      expect(details.status, McaDirectorStatus.approved);
    });
  });

  // -------------------------------------------------------------------------
  // McaFilingRecord model
  // -------------------------------------------------------------------------
  group('McaFilingRecord model', () {
    test('copyWith updates specified fields', () {
      final record = McaFilingRecord(
        srn: 'A12345678',
        formType: 'MGT-7',
        filedAt: DateTime(2023, 9, 30),
        status: 'Approved',
        documentDescription: 'Annual Return',
        feesPaid: 60000,
      );
      final updated = record.copyWith(status: 'Rejected');
      expect(updated.status, 'Rejected');
      expect(updated.srn, 'A12345678');
    });
  });
}
