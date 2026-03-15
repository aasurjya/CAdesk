import 'dart:convert';

import 'package:ca_app/features/gstn_api/data/mock_gstn_repository.dart';
import 'package:ca_app/features/gstn_api/data/repositories/gstn_api_repository_impl.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
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
  Future<bool> updateSyncStatus(PortalType _, String status) async => true;
}

PortalCredential _makeCredential({String token = 'test-api-key'}) =>
    PortalCredential(
      id: 'cred-gstn-1',
      portalType: PortalType.gstn,
      grantToken: token,
      expiresAt: DateTime.now().add(const Duration(hours: 6)),
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

/// Builds a [GstnApiRepositoryImpl] whose service calls hit [adapter].
GstnApiRepositoryImpl _liveRepo(
  _FakeCredentialRepository credRepo,
  Dio dio,
) {
  return GstnApiRepositoryImpl(
    dio: dio,
    credentialRepository: credRepo,
    useRealService: true,
  );
}

/// Builds a [GstnApiRepositoryImpl] that falls back to the mock.
GstnApiRepositoryImpl _devRepo(_FakeCredentialRepository credRepo) {
  return GstnApiRepositoryImpl(
    dio: Dio(),
    credentialRepository: credRepo,
    useRealService: false,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── MockGstnRepository (regression: ensure existing mock tests still pass) ──

  group('MockGstnRepository', () {
    late MockGstnRepository repo;

    setUp(() {
      repo = MockGstnRepository();
    });

    group('verifyGstin', () {
      test('returns active result for 15-char GSTIN', () async {
        final result = await repo.verifyGstin('29ABCDE1234F1Z5');
        expect(result.status, GstnRegistrationStatus.active);
        expect(result.gstin, '29ABCDE1234F1Z5');
      });

      test('returns cancelled for invalid length', () async {
        final result = await repo.verifyGstin('INVALID');
        expect(result.status, GstnRegistrationStatus.cancelled);
      });
    });

    group('saveReturn', () {
      test('returns saved status', () async {
        final result = await repo.saveReturn(
          '29ABCDE1234F1Z5',
          'GSTR1',
          '032024',
          '{}',
        );
        expect(result.status, GstnReturnStatus.saved);
        expect(result.returnType, GstnReturnType.gstr1);
      });
    });

    group('submitReturn', () {
      test('returns submitted status', () async {
        final result = await repo.submitReturn(
          '29ABCDE1234F1Z5',
          'GSTR3B',
          '032024',
        );
        expect(result.status, GstnReturnStatus.submitted);
        expect(result.returnType, GstnReturnType.gstr3b);
      });
    });

    group('fileReturn', () {
      test('returns filed status with filedAt', () async {
        final result = await repo.fileReturn(
          '29ABCDE1234F1Z5',
          'GSTR1',
          '032024',
          '123456',
        );
        expect(result.status, GstnReturnStatus.filed);
        expect(result.filedAt, isNotNull);
      });
    });

    group('getFilingStatus', () {
      test('returns filing status', () async {
        final result = await repo.getFilingStatus(
          '29ABCDE1234F1Z5',
          'GSTR1',
          '032024',
        );
        expect(result.gstin, '29ABCDE1234F1Z5');
        expect(result.period, '032024');
      });
    });

    group('fetchGstr2b', () {
      test('returns result with entry count', () async {
        final result = await repo.fetchGstr2b('29ABCDE1234F1Z5', '032024');
        expect(result.status, Gstr2bStatus.generated);
        expect(result.entryCount, greaterThan(0));
      });
    });

    group('getToken', () {
      test('returns token with Bearer type', () async {
        final result = await repo.getToken(
          '29ABCDE1234F1Z5',
          'user@test.com',
          '123456',
        );
        expect(result.tokenType, 'Bearer');
        expect(result.accessToken, isNotEmpty);
      });
    });
  });

  // ── GstnApiRepositoryImpl — mock fallback (useRealService: false) ──

  group('GstnApiRepositoryImpl (mock fallback)', () {
    late _FakeCredentialRepository credRepo;

    setUp(() {
      credRepo = _FakeCredentialRepository(credential: _makeCredential());
    });

    test('verifyGstin delegates to mock, returns active for 15-char GSTIN',
        () async {
      final repo = _devRepo(credRepo);
      final result = await repo.verifyGstin('29ABCDE1234F1Z5');
      expect(result.status, GstnRegistrationStatus.active);
      expect(result.gstin, '29ABCDE1234F1Z5');
    });

    test('verifyGstin delegates to mock, returns cancelled for invalid GSTIN',
        () async {
      final repo = _devRepo(credRepo);
      final result = await repo.verifyGstin('INVALID');
      expect(result.status, GstnRegistrationStatus.cancelled);
    });

    test('saveReturn delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.saveReturn(
        '29ABCDE1234F1Z5',
        'GSTR1',
        '032024',
        '{}',
      );
      expect(result.status, GstnReturnStatus.saved);
    });

    test('submitReturn delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.submitReturn(
        '29ABCDE1234F1Z5',
        'GSTR3B',
        '032024',
      );
      expect(result.status, GstnReturnStatus.submitted);
    });

    test('fileReturn delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.fileReturn(
        '29ABCDE1234F1Z5',
        'GSTR1',
        '032024',
        '654321',
      );
      expect(result.status, GstnReturnStatus.filed);
      expect(result.filedAt, isNotNull);
    });

    test('getFilingStatus delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.getFilingStatus(
        '29ABCDE1234F1Z5',
        'GSTR1',
        '032024',
      );
      expect(result.gstin, '29ABCDE1234F1Z5');
      expect(result.period, '032024');
    });

    test('fetchGstr2b delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.fetchGstr2b('29ABCDE1234F1Z5', '032024');
      expect(result.status, Gstr2bStatus.generated);
      expect(result.entryCount, greaterThan(0));
    });

    test('getToken delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.getToken(
        '29ABCDE1234F1Z5',
        'user@test.com',
        '123456',
      );
      expect(result.tokenType, 'Bearer');
      expect(result.accessToken, isNotEmpty);
    });
  });

  // ── GstnApiRepositoryImpl — live service (useRealService: true) ──

  group('GstnApiRepositoryImpl (live service)', () {
    // ── verifyGstin ──

    group('verifyGstin', () {
      test('calls GstnApiService.searchGstin and maps result', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'taxpayerInfo': {
            'gstin': '29AABCU9603R1ZX',
            'lgnm': 'ABC Private Limited',
            'tradeNam': 'ABC Traders',
            'pradr': {'bno': '123', 'loc': 'Bangalore', 'stcd': 'Karnataka'},
            'rgdt': '01/07/2017',
            'sts': 'Active',
            'stjCd': '29',
            'ctb': 'Private Limited Company',
            'rstk': 'M',
          },
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.verifyGstin('29AABCU9603R1ZX');

        expect(result.gstin, '29AABCU9603R1ZX');
        expect(result.legalName, 'ABC Private Limited');
        expect(result.tradeName, 'ABC Traders');
        expect(result.status, GstnRegistrationStatus.active);
        expect(result.stateCode, '29');
        expect(result.registrationDate, DateTime(2017, 7, 1));
      });

      test('re-throws PortalAuthException when credentials missing', () {
        final credRepo = _FakeCredentialRepository(); // no credential
        final repo = GstnApiRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );

        expect(
          () => repo.verifyGstin('29AABCU9603R1ZX'),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── getFilingStatus ──

    group('getFilingStatus', () {
      test('calls service and returns parsed filing status', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'filing': {
            'status': 'FIL',
            'arn': 'AA29010320241234567',
            'dof': '11/03/2024',
          },
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.getFilingStatus(
          '29AABCU9603R1ZX',
          'GSTR1',
          '032024',
        );

        expect(result.status, GstnReturnStatus.filed);
        expect(result.arn, 'AA29010320241234567');
        expect(result.filedAt, DateTime(2024, 3, 11));
      });

      test('re-throws PortalAuthException when credentials missing', () {
        final credRepo = _FakeCredentialRepository();
        final repo = GstnApiRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );

        expect(
          () => repo.getFilingStatus('29AABCU9603R1ZX', 'GSTR1', '032024'),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── saveReturn ──

    group('saveReturn', () {
      test('calls service and returns saved status', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({'status': 'SAV', 'arn': null});
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.saveReturn(
          '29AABCU9603R1ZX',
          'GSTR1',
          '032024',
          '{}',
        );

        expect(result.status, GstnReturnStatus.saved);
        expect(result.gstin, '29AABCU9603R1ZX');
      });

      test('re-throws PortalAuthException when credentials missing', () {
        final credRepo = _FakeCredentialRepository();
        final repo = GstnApiRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );

        expect(
          () => repo.saveReturn('29AABCU9603R1ZX', 'GSTR1', '032024', '{}'),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── submitReturn ──

    group('submitReturn', () {
      test('calls service and returns submitted status', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({'status': 'SUB'});
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.submitReturn(
          '29AABCU9603R1ZX',
          'GSTR3B',
          '032024',
        );

        expect(result.status, GstnReturnStatus.submitted);
        expect(result.returnType, GstnReturnType.gstr3b);
      });
    });

    // ── fileReturn ──

    group('fileReturn', () {
      test('calls service and returns filed status with ARN', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'status': 'FIL',
          'arn': 'AA29010320241234567',
          'dof': '11/03/2024',
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.fileReturn(
          '29AABCU9603R1ZX',
          'GSTR1',
          '032024',
          '123456',
        );

        expect(result.status, GstnReturnStatus.filed);
        expect(result.arn, 'AA29010320241234567');
      });

      test('re-throws PortalAuthException when credentials missing', () {
        final credRepo = _FakeCredentialRepository();
        final repo = GstnApiRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );

        expect(
          () => repo.fileReturn(
            '29AABCU9603R1ZX',
            'GSTR1',
            '032024',
            '123456',
          ),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── fetchGstr2b ──

    group('fetchGstr2b', () {
      test('calls service and parses result', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'data': {
            'docSts': 'GN',
            'genDt': '10/03/2024',
            'docSummary': {
              'igst': 500000,
              'cgst': 250000,
              'sgst': 250000,
              'entryCnt': 25,
            },
          },
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.fetchGstr2b('29AABCU9603R1ZX', '032024');

        expect(result.status, Gstr2bStatus.generated);
        expect(result.totalIgstCredit, 500000);
        expect(result.totalCgstCredit, 250000);
        expect(result.totalSgstCredit, 250000);
        expect(result.entryCount, 25);
        expect(result.totalCredit, 1000000);
        expect(result.generatedAt, DateTime(2024, 3, 10));
      });

      test('maps NG status to notGenerated', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({'data': {'docSts': 'NG', 'docSummary': {}}});
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.fetchGstr2b('29AABCU9603R1ZX', '032024');

        expect(result.status, Gstr2bStatus.notGenerated);
        expect(result.entryCount, 0);
      });

      test('re-throws PortalAuthException when credentials missing', () {
        final credRepo = _FakeCredentialRepository();
        final repo = GstnApiRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );

        expect(
          () => repo.fetchGstr2b('29AABCU9603R1ZX', '032024'),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── getToken ──

    group('getToken', () {
      test('calls service and returns access token', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'authToken': {
            'authtoken': 'eyJhbGciOiJSUzI1NiJ9.test',
            'tokenType': 'Bearer',
            'expiry': 21600,
          },
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.getToken(
          '29AABCU9603R1ZX',
          'user@test.com',
          '654321',
        );

        expect(result.accessToken, 'eyJhbGciOiJSUzI1NiJ9.test');
        expect(result.tokenType, 'Bearer');
        expect(result.expiresIn, 21600);
        expect(result.isExpired, isFalse);
      });

      test('re-throws PortalAuthException when credentials missing', () {
        final credRepo = _FakeCredentialRepository();
        final repo = GstnApiRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );

        expect(
          () => repo.getToken('29AABCU9603R1ZX', 'user@test.com', '654321'),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── Portal exception propagation ──

    group('portal exception propagation', () {
      test('re-throws PortalRateLimitException from service', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        // 429 response triggers PortalRateLimitException in the service
        final dioWithRateLimit = Dio();
        dioWithRateLimit.httpClientAdapter = _MockHttpAdapter(
          body: {'message': 'Too Many Requests'},
          statusCode: 429,
        );
        final repo = _liveRepo(credRepo, dioWithRateLimit);

        expect(
          () => repo.getFilingStatus('29AABCU9603R1ZX', 'GSTR1', '032024'),
          throwsA(isA<PortalRateLimitException>()),
        );
      });

      test('re-throws PortalUnavailableException on 503', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dioWith503 = Dio();
        dioWith503.httpClientAdapter = _MockHttpAdapter(
          body: {'message': 'Service Unavailable'},
          statusCode: 503,
        );
        final repo = _liveRepo(credRepo, dioWith503);

        expect(
          () => repo.getFilingStatus('29AABCU9603R1ZX', 'GSTR1', '032024'),
          throwsA(isA<PortalUnavailableException>()),
        );
      });
    });
  });
}
