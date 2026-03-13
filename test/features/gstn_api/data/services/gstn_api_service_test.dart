import 'dart:convert';

import 'package:ca_app/features/gstn_api/data/services/gstn_api_service.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstin_details.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gst_notice.dart';
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
      id: 'cred-1',
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
  dio.httpClientAdapter =
      _MockHttpAdapter(body: body, statusCode: statusCode);
  return dio;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // validateGstin — pure function, no HTTP
  // -------------------------------------------------------------------------
  group('GstnApiService.validateGstin', () {
    test('known valid GSTIN 29AABCU9603R1ZJ passes', () {
      // 29AABCU9603R1ZJ has a valid check character computed by the GSTN
      // modulus-36 Luhn-style algorithm (checksum J for 29AABCU9603R1Z).
      expect(GstnApiService.validateGstin('29AABCU9603R1ZJ'), isTrue);
    });

    test('wrong length (14 chars) returns false', () {
      expect(GstnApiService.validateGstin('29AABCU9603R1Z'), isFalse);
    });

    test('wrong length (16 chars) returns false', () {
      expect(GstnApiService.validateGstin('29AABCU9603R1ZXX'), isFalse);
    });

    test('empty string returns false', () {
      expect(GstnApiService.validateGstin(''), isFalse);
    });

    test('all zeros returns false', () {
      expect(GstnApiService.validateGstin('000000000000000'), isFalse);
    });

    test('lowercase input returns false', () {
      expect(GstnApiService.validateGstin('29aabcu9603r1zx'), isFalse);
    });

    test('special characters return false', () {
      expect(GstnApiService.validateGstin('29AABC!9603R1ZX'), isFalse);
    });

    test('missing Z in 14th position returns false', () {
      // Replace the mandatory Z at position 13 (0-indexed) with A.
      expect(GstnApiService.validateGstin('29AABCU9603R1AX'), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // GstinDetails model — immutability
  // -------------------------------------------------------------------------
  group('GstinDetails model', () {
    GstinDetails makeDetails() => GstinDetails(
          gstin: '29AABCU9603R1ZX',
          legalName: 'ABC Ltd',
          tradeName: 'ABC',
          address: '123 Street, Bangalore',
          registrationDate: DateTime(2017, 7, 1),
          status: GstnRegistrationStatus.active,
          stateCode: '29',
          constitutionType: 'Private Limited Company',
          returnFilingFrequency: ReturnFilingFrequency.monthly,
        );

    test('copyWith legalName creates new instance, original unchanged', () {
      final original = makeDetails();
      final copy = original.copyWith(legalName: 'XYZ Ltd');
      expect(copy.legalName, 'XYZ Ltd');
      expect(original.legalName, 'ABC Ltd');
      expect(identical(original, copy), isFalse);
    });

    test('copyWith with no changes reproduces equal value', () {
      final original = makeDetails();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('equality holds for identical field values', () {
      expect(makeDetails(), equals(makeDetails()));
      expect(makeDetails().hashCode, equals(makeDetails().hashCode));
    });
  });

  // -------------------------------------------------------------------------
  // GstNotice model
  // -------------------------------------------------------------------------
  group('GstNotice model', () {
    test('isPending is true for open status', () {
      final n = GstNotice(
        noticeId: 'N001',
        type: 'GSTR-3A',
        issuedDate: DateTime(2024, 1, 10),
        dueDate: DateTime(2024, 2, 10),
        description: 'Non-filing',
        status: GstNoticeStatus.open,
      );
      expect(n.isPending, isTrue);
    });

    test('isPending is true for pendingHearing', () {
      final n = GstNotice(
        noticeId: 'N002',
        type: 'ASMT-10',
        issuedDate: DateTime(2024, 1, 10),
        dueDate: DateTime(2024, 2, 10),
        description: 'Scrutiny',
        status: GstNoticeStatus.pendingHearing,
      );
      expect(n.isPending, isTrue);
    });

    test('isPending is false for closed', () {
      final n = GstNotice(
        noticeId: 'N003',
        type: 'GSTR-3A',
        issuedDate: DateTime(2024, 1, 10),
        dueDate: DateTime(2024, 2, 10),
        description: 'Closed',
        status: GstNoticeStatus.closed,
      );
      expect(n.isPending, isFalse);
    });

    test('isPending is false for replied', () {
      final n = GstNotice(
        noticeId: 'N004',
        type: 'REG-03',
        issuedDate: DateTime(2024, 1, 10),
        dueDate: DateTime(2024, 2, 10),
        description: 'Replied',
        status: GstNoticeStatus.replied,
      );
      expect(n.isPending, isFalse);
    });

    test('copyWith status only changes status', () {
      final original = GstNotice(
        noticeId: 'N001',
        type: 'GSTR-3A',
        issuedDate: DateTime(2024, 1, 10),
        dueDate: DateTime(2024, 2, 10),
        description: 'Test',
        status: GstNoticeStatus.open,
      );
      final copy = original.copyWith(status: GstNoticeStatus.replied);
      expect(copy.noticeId, original.noticeId);
      expect(copy.status, GstNoticeStatus.replied);
    });

    test('equality holds on same-value instances', () {
      final a = GstNotice(
        noticeId: 'N001',
        type: 'GSTR-3A',
        issuedDate: DateTime(2024, 1, 10),
        dueDate: DateTime(2024, 2, 10),
        description: 'Test',
        status: GstNoticeStatus.open,
      );
      final b = GstNotice(
        noticeId: 'N001',
        type: 'GSTR-3A',
        issuedDate: DateTime(2024, 1, 10),
        dueDate: DateTime(2024, 2, 10),
        description: 'Test',
        status: GstNoticeStatus.open,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // -------------------------------------------------------------------------
  // PortalAuthException — missing credentials
  // -------------------------------------------------------------------------
  group('GstnApiService — missing credentials throw PortalAuthException', () {
    late _FakeCredentialRepository emptyRepo;

    setUp(() => emptyRepo = _FakeCredentialRepository());

    test('searchGstin throws when no credential stored', () {
      expect(
        () => GstnApiService.searchGstin(
          '29AABCU9603R1ZX',
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getFilingStatus throws when no credential stored', () {
      expect(
        () => GstnApiService.getFilingStatus(
          '29AABCU9603R1ZX',
          'GSTR1',
          '032024',
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getGstr1Status throws when no credential stored', () {
      expect(
        () => GstnApiService.getGstr1Status(
          '29AABCU9603R1ZX',
          '032024',
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getGstr3bStatus throws when no credential stored', () {
      expect(
        () => GstnApiService.getGstr3bStatus(
          '29AABCU9603R1ZX',
          '032024',
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getNotices throws when no credential stored', () {
      expect(
        () => GstnApiService.getNotices(
          '29AABCU9603R1ZX',
          dio: Dio(),
          credentialRepository: emptyRepo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // PortalExceptions — toString
  // -------------------------------------------------------------------------
  group('PortalException.toString', () {
    test('PortalAuthException contains portal and message', () {
      const ex = PortalAuthException(
        portal: 'GSTN',
        message: 'bad key',
        statusCode: 401,
      );
      expect(ex.toString(), contains('GSTN'));
      expect(ex.toString(), contains('bad key'));
      expect(ex.toString(), contains('401'));
    });

    test('PortalAuthException without statusCode omits HTTP part', () {
      const ex = PortalAuthException(portal: 'GSTN', message: 'no creds');
      expect(ex.toString(), isNot(contains('HTTP')));
    });

    test('PortalRateLimitException includes retryAfter', () {
      const ex = PortalRateLimitException(
        portal: 'GSTN',
        message: 'too many',
        retryAfterSeconds: 60,
      );
      expect(ex.toString(), contains('60'));
    });

    test('PortalRateLimitException without retryAfter omits retry part', () {
      const ex = PortalRateLimitException(
        portal: 'GSTN',
        message: 'too many',
      );
      expect(ex.toString(), isNot(contains('retry after')));
    });

    test('PortalUnavailableException contains message', () {
      const ex = PortalUnavailableException(
        portal: 'GSTN',
        message: 'server down',
      );
      expect(ex.toString(), contains('server down'));
    });
  });

  // -------------------------------------------------------------------------
  // GstnFilingStatus model
  // -------------------------------------------------------------------------
  group('GstnFilingStatus model', () {
    test('copyWith returns new instance with updated status', () {
      const original = GstnFilingStatus(
        gstin: '29AABCU9603R1ZX',
        returnType: GstnReturnType.gstr1,
        period: '032024',
        status: GstnReturnStatus.filed,
        arn: 'AA29010320241234567',
      );
      final updated = original.copyWith(status: GstnReturnStatus.processed);
      expect(updated.status, GstnReturnStatus.processed);
      expect(updated.arn, original.arn);
      expect(identical(original, updated), isFalse);
    });

    test('equality on same values', () {
      const a = GstnFilingStatus(
        gstin: '29AABCU9603R1ZX',
        returnType: GstnReturnType.gstr3b,
        period: '032024',
        status: GstnReturnStatus.notFiled,
      );
      const b = GstnFilingStatus(
        gstin: '29AABCU9603R1ZX',
        returnType: GstnReturnType.gstr3b,
        period: '032024',
        status: GstnReturnStatus.notFiled,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // -------------------------------------------------------------------------
  // searchGstin — HTTP happy path
  // -------------------------------------------------------------------------
  group('GstnApiService.searchGstin — HTTP responses', () {
    test('parses taxpayer info from success response', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
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

      final result = await GstnApiService.searchGstin(
        '29AABCU9603R1ZX',
        dio: dio,
        credentialRepository: repo,
      );

      expect(result.gstin, '29AABCU9603R1ZX');
      expect(result.legalName, 'ABC Private Limited');
      expect(result.tradeName, 'ABC Traders');
      expect(result.status, GstnRegistrationStatus.active);
      expect(result.returnFilingFrequency, ReturnFilingFrequency.monthly);
      expect(result.registrationDate, DateTime(2017, 7, 1));
    });

    test('quarterly filer sets returnFilingFrequency to quarterly', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'taxpayerInfo': {
          'gstin': '29AABCU9603R1ZX',
          'lgnm': 'Small Trader',
          'tradeNam': '',
          'pradr': {},
          'rgdt': '01/04/2020',
          'sts': 'Active',
          'stjCd': '29',
          'ctb': 'Proprietorship',
          'rstk': 'Q',
        },
      });

      final result = await GstnApiService.searchGstin(
        '29AABCU9603R1ZX',
        dio: dio,
        credentialRepository: repo,
      );

      expect(result.returnFilingFrequency, ReturnFilingFrequency.quarterly);
    });
  });

  // -------------------------------------------------------------------------
  // getNotices — HTTP happy path
  // -------------------------------------------------------------------------
  group('GstnApiService.getNotices — HTTP responses', () {
    test('parses empty notices list', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({'notices': []});

      final notices = await GstnApiService.getNotices(
        '29AABCU9603R1ZX',
        dio: dio,
        credentialRepository: repo,
      );
      expect(notices, isEmpty);
    });

    test('parses one notice correctly', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'notices': [
          {
            'noticeId': 'N2024001',
            'noticeType': 'GSTR-3A',
            'issuedDate': '10/01/2024',
            'dueDate': '10/02/2024',
            'description': 'Non-filing of GSTR-3B',
            'status': 'OPEN',
          },
        ],
      });

      final notices = await GstnApiService.getNotices(
        '29AABCU9603R1ZX',
        dio: dio,
        credentialRepository: repo,
      );

      expect(notices, hasLength(1));
      expect(notices.first.noticeId, 'N2024001');
      expect(notices.first.type, 'GSTR-3A');
      expect(notices.first.status, GstNoticeStatus.open);
      expect(notices.first.dueDate, DateTime(2024, 2, 10));
    });
  });
}
