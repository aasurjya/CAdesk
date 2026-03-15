import 'dart:convert';

import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';
import 'package:ca_app/features/traces/data/mock_traces_repository.dart';
import 'package:ca_app/features/traces/data/repositories/traces_repository_impl.dart';
import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';
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

PortalCredential _makeCredential({bool expired = false}) => PortalCredential(
  id: 'cred-traces-1',
  portalType: PortalType.traces,
  username: 'ABCDE1234F',
  grantToken: 'TRACES_SESSION_TOKEN',
  expiresAt: expired
      ? DateTime.now().subtract(const Duration(hours: 1))
      : DateTime.now().add(const Duration(hours: 6)),
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

/// Builds a [TracesRepositoryImpl] whose service calls hit [dio].
TracesRepositoryImpl _liveRepo(
  _FakeCredentialRepository credRepo,
  Dio dio,
) {
  return TracesRepositoryImpl(
    dio: dio,
    credentialRepository: credRepo,
    useRealService: true,
  );
}

/// Builds a [TracesRepositoryImpl] in dev/mock mode.
TracesRepositoryImpl _devRepo(_FakeCredentialRepository credRepo) {
  return TracesRepositoryImpl(
    dio: Dio(),
    credentialRepository: credRepo,
    useRealService: false,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── MockTracesRepository (regression: ensure existing mock tests still pass) ──

  group('MockTracesRepository', () {
    late MockTracesRepository repo;

    setUp(() {
      repo = MockTracesRepository();
    });

    group('verifyPan', () {
      test('returns valid for well-formed PAN', () async {
        final result = await repo.verifyPan('ABCDE1234F');
        expect(result.status, PanStatus.valid);
        expect(result.pan, 'ABCDE1234F');
      });

      test('returns invalid for malformed PAN', () async {
        final result = await repo.verifyPan('INVALID_PAN');
        expect(result.status, PanStatus.invalid);
      });
    });

    group('getChallanStatus', () {
      test('returns matched status with consumed == deposited', () async {
        final date = DateTime(2025, 7, 7);
        final result = await repo.getChallanStatus(
          '0001234',
          date,
          '00001',
          'MUMR12345A',
        );
        expect(result.status, ChallanBookingStatus.matched);
        expect(result.consumedAmount, result.depositedAmount);
        expect(result.balanceAmount, 0);
      });
    });

    group('requestForm16', () {
      test('returns available status', () async {
        final result = await repo.requestForm16(
          'MUMR12345A',
          'ABCDE1234F',
          2025,
        );
        expect(result.tan, 'MUMR12345A');
        expect(result.pan, 'ABCDE1234F');
        expect(result.financialYear, 2025);
      });
    });

    group('requestBulkForm16', () {
      test('returns one result per PAN', () async {
        final pans = ['ABCDE1234F', 'FGHIJ5678K', 'LMNOP9012L'];
        final results = await repo.requestBulkForm16('MUMR12345A', 2025, pans);
        expect(results, hasLength(3));
        for (var i = 0; i < pans.length; i++) {
          expect(results[i].pan, pans[i]);
        }
      });
    });

    group('getJustificationReport', () {
      test('returns empty report for Q1', () async {
        final result = await repo.getJustificationReport('MUMR12345A', 2025, 1);
        expect(result.tan, 'MUMR12345A');
        expect(result.quarter, TdsQuarter.q1);
        expect(result.shortDeductions, isEmpty);
      });
    });

    group('getAllChallans', () {
      test('returns list of challans', () async {
        final result = await repo.getAllChallans('MUMR12345A', 2025);
        expect(result, isNotEmpty);
        for (final c in result) {
          expect(c.tan, 'MUMR12345A');
        }
      });
    });
  });

  // ── TracesRepositoryImpl — mock fallback (useRealService: false) ──

  group('TracesRepositoryImpl (mock fallback)', () {
    late _FakeCredentialRepository credRepo;

    setUp(() {
      credRepo = _FakeCredentialRepository(credential: _makeCredential());
    });

    test('verifyPan delegates to mock for valid PAN', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.verifyPan('ABCDE1234F');
      expect(result.status, PanStatus.valid);
      expect(result.pan, 'ABCDE1234F');
    });

    test('verifyPan throws ArgumentError for short PAN regardless of flag',
        () async {
      final repo = _devRepo(credRepo);
      expect(() => repo.verifyPan('SHORT'), throwsArgumentError);
    });

    test('getChallanStatus delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final date = DateTime(2025, 7, 7);
      final result = await repo.getChallanStatus(
        '0001234',
        date,
        '00001',
        'MUMR12345A',
      );
      expect(result.status, ChallanBookingStatus.matched);
    });

    test('requestForm16 delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.requestForm16('MUMR12345A', 'ABCDE1234F', 2025);
      expect(result.status, Form16RequestStatus.available);
    });

    test('requestBulkForm16 delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final pans = ['ABCDE1234F', 'FGHIJ5678K'];
      final results = await repo.requestBulkForm16('MUMR12345A', 2025, pans);
      expect(results, hasLength(2));
    });

    test('getJustificationReport delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.getJustificationReport('MUMR12345A', 2025, 2);
      expect(result.quarter, TdsQuarter.q2);
      expect(result.shortDeductions, isEmpty);
    });

    test('getAllChallans delegates to mock', () async {
      final repo = _devRepo(credRepo);
      final result = await repo.getAllChallans('MUMR12345A', 2025);
      expect(result, isNotEmpty);
    });
  });

  // ── TracesRepositoryImpl — live service (useRealService: true) ──

  group('TracesRepositoryImpl (live service)', () {
    // ── verifyPan ──

    group('verifyPan', () {
      test('calls service and maps valid PAN status', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'panStatus': 'E',
          'name': 'John Doe',
          'aadhaarLinked': true,
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.verifyPan('ABCDE1234F');

        expect(result.pan, 'ABCDE1234F');
        expect(result.status, PanStatus.valid);
        expect(result.name, 'John Doe');
        expect(result.aadhaarLinked, isTrue);
      });

      test('calls service and maps inactive PAN status', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({'panStatus': 'A', 'name': 'Jane Doe'});
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.verifyPan('ABCDE1234F');

        expect(result.status, PanStatus.inactive);
      });

      test('calls service and maps deleted PAN status', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({'panStatus': 'X', 'name': ''});
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.verifyPan('ABCDE1234F');

        expect(result.status, PanStatus.deleted);
      });

      test('throws ArgumentError for PAN shorter than 10 chars', () {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final repo = _liveRepo(credRepo, Dio());
        expect(() => repo.verifyPan('SHORT'), throwsArgumentError);
      });

      test('re-throws PortalAuthException when session expired', () {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(expired: true),
        );
        final repo = TracesRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );
        expect(
          () => repo.verifyPan('ABCDE1234F'),
          throwsA(isA<PortalAuthException>()),
        );
      });

      test('re-throws PortalAuthException when no credential', () {
        final credRepo = _FakeCredentialRepository();
        final repo = TracesRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );
        expect(
          () => repo.verifyPan('ABCDE1234F'),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── getChallanStatus ──

    group('getChallanStatus', () {
      test('calls service and parses matched challan', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'bookingStatus': 'F',
          'section': '192',
          'depositedAmount': 50000,
          'consumedAmount': 50000,
        });
        final repo = _liveRepo(credRepo, dio);
        final date = DateTime(2025, 7, 7);

        final result = await repo.getChallanStatus(
          '0001234',
          date,
          '00001',
          'MUMR12345A',
        );

        expect(result.status, ChallanBookingStatus.matched);
        expect(result.depositedAmount, 50000);
        expect(result.consumedAmount, 50000);
        expect(result.balanceAmount, 0);
        expect(result.section, '192');
      });

      test('maps unmatched status correctly', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'bookingStatus': 'U',
          'section': '194C',
          'depositedAmount': 75000,
          'consumedAmount': 0,
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.getChallanStatus(
          '0001234',
          DateTime(2025, 7, 7),
          '00002',
          'MUMR12345A',
        );

        expect(result.status, ChallanBookingStatus.unmatched);
        expect(result.balanceAmount, 75000);
      });

      test('re-throws PortalAuthException when no credential', () {
        final credRepo = _FakeCredentialRepository();
        final repo = TracesRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );
        expect(
          () => repo.getChallanStatus(
            '0001234',
            DateTime.now(),
            '00001',
            'MUMR12345A',
          ),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── requestForm16 ──

    group('requestForm16', () {
      test('calls service and returns available request', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'requestId': 'REQ-001',
          'tan': 'MUMR12345A',
          'pan': 'ABCDE1234F',
          'requestStatus': 'A',
          'downloadUrl': 'https://traces.gov.in/download/REQ-001',
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.requestForm16('MUMR12345A', 'ABCDE1234F', 2025);

        expect(result.requestId, 'REQ-001');
        expect(result.status, Form16RequestStatus.available);
        expect(result.downloadUrl, isNotNull);
        expect(result.financialYear, 2025);
      });

      test('returns processing status when TRACES is generating file', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'requestId': 'REQ-002',
          'requestStatus': 'P',
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.requestForm16('MUMR12345A', 'ABCDE1234F', 2025);

        expect(result.status, Form16RequestStatus.processing);
        expect(result.downloadUrl, isNull);
      });

      test('re-throws PortalAuthException when no credential', () {
        final credRepo = _FakeCredentialRepository();
        final repo = TracesRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );
        expect(
          () => repo.requestForm16('MUMR12345A', 'ABCDE1234F', 2025),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── requestBulkForm16 ──

    group('requestBulkForm16', () {
      test('calls service and returns list of requests', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'requests': [
            {'requestId': 'BULK-001', 'pan': 'ABCDE1234F', 'requestStatus': 'P'},
            {'requestId': 'BULK-002', 'pan': 'FGHIJ5678K', 'requestStatus': 'P'},
          ],
        });
        final repo = _liveRepo(credRepo, dio);

        final results = await repo.requestBulkForm16(
          'MUMR12345A',
          2025,
          ['ABCDE1234F', 'FGHIJ5678K'],
        );

        expect(results, hasLength(2));
        expect(results[0].requestId, 'BULK-001');
        expect(results[1].requestId, 'BULK-002');
      });

      test('returns empty list when service returns no requests', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({'requests': []});
        final repo = _liveRepo(credRepo, dio);

        final results = await repo.requestBulkForm16('MUMR12345A', 2025, []);

        expect(results, isEmpty);
      });

      test('re-throws PortalAuthException when session expired', () {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(expired: true),
        );
        final repo = TracesRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );
        expect(
          () => repo.requestBulkForm16('MUMR12345A', 2025, ['ABCDE1234F']),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── getJustificationReport ──

    group('getJustificationReport', () {
      test('calls service and parses report with short deductions', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'shortDeductions': [
            {
              'pan': 'ABCDE1234F',
              'section': '194C',
              'amountPaid': 100000,
              'tdsDeducted': 500,
              'tdsRequired': 2000,
              'shortfall': 1500,
            },
          ],
          'lateDeductions': [],
          'totalShortfall': 1500,
          'totalInterestDemand': 225,
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.getJustificationReport(
          'MUMR12345A',
          2025,
          2,
        );

        expect(result.tan, 'MUMR12345A');
        expect(result.quarter, TdsQuarter.q2);
        expect(result.shortDeductions, hasLength(1));
        expect(result.shortDeductions.first.pan, 'ABCDE1234F');
        expect(result.shortDeductions.first.shortfall, 1500);
        expect(result.totalShortfall, 1500);
        expect(result.totalInterestDemand, 225);
      });

      test('returns empty report when no defaults', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'shortDeductions': [],
          'lateDeductions': [],
          'totalShortfall': 0,
          'totalInterestDemand': 0,
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.getJustificationReport(
          'MUMR12345A',
          2025,
          1,
        );

        expect(result.shortDeductions, isEmpty);
        expect(result.lateDeductions, isEmpty);
        expect(result.totalShortfall, 0);
      });

      test('re-throws PortalAuthException when no credential', () {
        final credRepo = _FakeCredentialRepository();
        final repo = TracesRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );
        expect(
          () => repo.getJustificationReport('MUMR12345A', 2025, 1),
          throwsA(isA<PortalAuthException>()),
        );
      });
    });

    // ── getAllChallans ──

    group('getAllChallans', () {
      test('calls service and returns list of challan statuses', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({
          'challans': [
            {
              'bsrCode': '0004058',
              'challanDate': '07/07/2025',
              'challanSerial': '00125',
              'tan': 'MUMR12345A',
              'section': '192',
              'depositedAmount': 8500000,
              'consumedAmount': 8500000,
              'bookingStatus': 'F',
            },
            {
              'bsrCode': '0004058',
              'challanDate': '07/10/2025',
              'challanSerial': '00189',
              'tan': 'MUMR12345A',
              'section': '194A',
              'depositedAmount': 4500000,
              'consumedAmount': 0,
              'bookingStatus': 'U',
            },
          ],
        });
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.getAllChallans('MUMR12345A', 2025);

        expect(result, hasLength(2));
        expect(result[0].status, ChallanBookingStatus.matched);
        expect(result[0].section, '192');
        expect(result[1].status, ChallanBookingStatus.unmatched);
      });

      test('returns empty list when no challans', () async {
        final credRepo = _FakeCredentialRepository(
          credential: _makeCredential(),
        );
        final dio = _mockDio({'challans': []});
        final repo = _liveRepo(credRepo, dio);

        final result = await repo.getAllChallans('MUMR12345A', 2025);

        expect(result, isEmpty);
      });

      test('re-throws PortalAuthException when no credential', () {
        final credRepo = _FakeCredentialRepository();
        final repo = TracesRepositoryImpl(
          dio: Dio(),
          credentialRepository: credRepo,
          useRealService: true,
        );
        expect(
          () => repo.getAllChallans('MUMR12345A', 2025),
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
        final dioWithRateLimit = Dio();
        dioWithRateLimit.httpClientAdapter = _MockHttpAdapter(
          body: {'message': 'Too Many Requests'},
          statusCode: 429,
        );
        final repo = _liveRepo(credRepo, dioWithRateLimit);

        expect(
          () => repo.verifyPan('ABCDE1234F'),
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
          () => repo.verifyPan('ABCDE1234F'),
          throwsA(isA<PortalUnavailableException>()),
        );
      });
    });
  });
}
