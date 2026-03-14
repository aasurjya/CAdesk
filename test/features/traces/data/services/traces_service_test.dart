import 'dart:convert';

import 'package:ca_app/features/portal_connector/domain/exceptions/portal_exceptions.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';
import 'package:ca_app/features/traces/data/services/traces_service.dart';
import 'package:ca_app/features/traces/domain/models/ais_data.dart';
import 'package:ca_app/features/traces/domain/models/form16_certificate.dart';
import 'package:ca_app/features/traces/domain/models/form26as_data.dart';
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Form26asData model
  // -------------------------------------------------------------------------
  group('Form26asData model', () {
    test('totalTds sums all TDS entries', () {
      final data = Form26asData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        tdsEntries: [
          TdsEntry26as(
            deductorName: 'Employer A',
            deductorTan: 'AAAA00001A',
            section: '192',
            amountPaid: 5000000,
            taxDeducted: 100000,
            depositDate: DateTime(2024, 3, 15),
          ),
          TdsEntry26as(
            deductorName: 'Bank B',
            deductorTan: 'BBBB00002B',
            section: '194A',
            amountPaid: 100000,
            taxDeducted: 10000,
            depositDate: DateTime(2024, 3, 20),
          ),
        ],
        advanceTax: 50000,
        selfAssessment: 0,
      );
      expect(data.totalTds, 110000);
    });

    test('totalTds is 0 for empty entries', () {
      const data = Form26asData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        tdsEntries: [],
        advanceTax: 0,
        selfAssessment: 0,
      );
      expect(data.totalTds, 0);
    });

    test('copyWith creates new instance', () {
      const original = Form26asData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        tdsEntries: [],
        advanceTax: 0,
        selfAssessment: 0,
      );
      final copy = original.copyWith(advanceTax: 25000);
      expect(copy.advanceTax, 25000);
      expect(original.advanceTax, 0);
      expect(identical(original, copy), isFalse);
    });

    test('equality on same values', () {
      const a = Form26asData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        tdsEntries: [],
        advanceTax: 10000,
        selfAssessment: 5000,
      );
      const b = Form26asData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        tdsEntries: [],
        advanceTax: 10000,
        selfAssessment: 5000,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // -------------------------------------------------------------------------
  // TdsEntry26as model
  // -------------------------------------------------------------------------
  group('TdsEntry26as model', () {
    test('copyWith preserves unchanged fields', () {
      final entry = TdsEntry26as(
        deductorName: 'Employer',
        deductorTan: 'AAAA00001A',
        section: '192',
        amountPaid: 5000000,
        taxDeducted: 100000,
        depositDate: DateTime(2024, 3, 15),
      );
      final copy = entry.copyWith(section: '194C');
      expect(copy.section, '194C');
      expect(copy.deductorName, 'Employer');
    });

    test('equality on same values', () {
      final a = TdsEntry26as(
        deductorName: 'Employer',
        deductorTan: 'AAAA00001A',
        section: '192',
        amountPaid: 5000000,
        taxDeducted: 100000,
        depositDate: DateTime(2024, 3, 15),
      );
      final b = TdsEntry26as(
        deductorName: 'Employer',
        deductorTan: 'AAAA00001A',
        section: '192',
        amountPaid: 5000000,
        taxDeducted: 100000,
        depositDate: DateTime(2024, 3, 15),
      );
      expect(a, equals(b));
    });
  });

  // -------------------------------------------------------------------------
  // AisData model
  // -------------------------------------------------------------------------
  group('AisData model', () {
    test('totalIncome sums all income entries', () {
      final data = AisData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        incomeDetails: [
          const AisIncome(
            sourceType: 'Salary',
            sourceName: 'Employer A',
            amount: 80000000,
            taxDeducted: 10000000,
          ),
          const AisIncome(
            sourceType: 'Interest',
            sourceName: 'Bank B',
            amount: 5000000,
            taxDeducted: 500000,
          ),
        ],
      );
      expect(data.totalIncome, 85000000);
    });

    test('totalIncome is 0 for empty list', () {
      const data = AisData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        incomeDetails: [],
      );
      expect(data.totalIncome, 0);
    });

    test('copyWith returns new instance', () {
      const original = AisData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        incomeDetails: [],
      );
      final copy = original.copyWith(assessmentYear: '2025-26');
      expect(copy.assessmentYear, '2025-26');
      expect(original.assessmentYear, '2024-25');
    });

    test('equality on same pan and assessmentYear', () {
      const a = AisData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        incomeDetails: [],
      );
      const b = AisData(
        pan: 'ABCDE1234F',
        assessmentYear: '2024-25',
        incomeDetails: [],
      );
      expect(a, equals(b));
    });
  });

  // -------------------------------------------------------------------------
  // Form16Certificate model
  // -------------------------------------------------------------------------
  group('Form16Certificate model', () {
    test('copyWith only changes specified fields', () {
      const cert = Form16Certificate(
        employerTan: 'AAAA00001A',
        employeePan: 'ABCDE1234F',
        financialYear: 2024,
        grossSalary: 80000000,
        tdsDeducted: 10000000,
      );
      final copy = cert.copyWith(grossSalary: 90000000);
      expect(copy.grossSalary, 90000000);
      expect(copy.tdsDeducted, 10000000);
    });

    test('equality on same values', () {
      const a = Form16Certificate(
        employerTan: 'AAAA00001A',
        employeePan: 'ABCDE1234F',
        financialYear: 2024,
        grossSalary: 80000000,
        tdsDeducted: 10000000,
        quarter: 4,
      );
      const b = Form16Certificate(
        employerTan: 'AAAA00001A',
        employeePan: 'ABCDE1234F',
        financialYear: 2024,
        grossSalary: 80000000,
        tdsDeducted: 10000000,
        quarter: 4,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // -------------------------------------------------------------------------
  // TdsCertificate model
  // -------------------------------------------------------------------------
  group('TdsCertificate model', () {
    test('equality on same values', () {
      const a = TdsCertificate(
        tan: 'AAAA00001A',
        deducteePan: 'ABCDE1234F',
        section: '194C',
        period: 'Q1FY2024',
        amountPaid: 100000,
        taxDeducted: 10000,
      );
      const b = TdsCertificate(
        tan: 'AAAA00001A',
        deducteePan: 'ABCDE1234F',
        section: '194C',
        period: 'Q1FY2024',
        amountPaid: 100000,
        taxDeducted: 10000,
      );
      expect(a, equals(b));
    });

    test('copyWith changes certificateNumber', () {
      const cert = TdsCertificate(
        tan: 'AAAA00001A',
        deducteePan: 'ABCDE1234F',
        section: '194J',
        period: 'Q2FY2024',
        amountPaid: 200000,
        taxDeducted: 20000,
      );
      final copy = cert.copyWith(certificateNumber: 'CERT-001');
      expect(copy.certificateNumber, 'CERT-001');
      expect(cert.certificateNumber, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // TracesService — missing / expired credentials
  // -------------------------------------------------------------------------
  group('TracesService — credential errors', () {
    test('downloadForm26as throws when no credential', () async {
      final repo = _FakeCredentialRepository();
      expect(
        () => TracesService.downloadForm26as(
          'ABCDE1234F',
          '2024-25',
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('downloadAis throws when session expired', () async {
      final repo = _FakeCredentialRepository(
        credential: _makeCredential(expired: true),
      );
      expect(
        () => TracesService.downloadAis(
          'ABCDE1234F',
          '2024-25',
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getForm16 throws when no credential', () async {
      final repo = _FakeCredentialRepository();
      expect(
        () => TracesService.getForm16(
          'AAAA00001A',
          1,
          2024,
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });

    test('getTdsCertificates throws when no credential', () async {
      final repo = _FakeCredentialRepository();
      expect(
        () => TracesService.getTdsCertificates(
          'AAAA00001A',
          'Q1FY2024',
          dio: Dio(),
          credentialRepository: repo,
        ),
        throwsA(isA<PortalAuthException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // TracesService.checkLoginStatus
  // -------------------------------------------------------------------------
  group('TracesService.checkLoginStatus', () {
    test('returns false when no credential stored', () async {
      final repo = _FakeCredentialRepository();
      final result = await TracesService.checkLoginStatus(
        dio: Dio(),
        credentialRepository: repo,
      );
      expect(result, isFalse);
    });

    test('returns false when credential is expired', () async {
      final repo = _FakeCredentialRepository(
        credential: _makeCredential(expired: true),
      );
      final result = await TracesService.checkLoginStatus(
        dio: Dio(),
        credentialRepository: repo,
      );
      expect(result, isFalse);
    });

    test('returns true when session check succeeds', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({'status': 'OK'}, statusCode: 200);
      final result = await TracesService.checkLoginStatus(
        dio: dio,
        credentialRepository: repo,
      );
      expect(result, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // TracesService — Form 26AS HTTP happy path
  // -------------------------------------------------------------------------
  group('TracesService.downloadForm26as — HTTP', () {
    test('parses Form 26AS with two TDS entries', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'Part_A': [
          {
            'deductorName': 'Employer XYZ',
            'deductorTAN': 'MUMB12345A',
            'section': '192',
            'amountPaid': 6000000,
            'taxDeducted': 800000,
            'depositDate': '15/03/2024',
          },
          {
            'deductorName': 'HDFC Bank',
            'deductorTAN': 'HDFC00001B',
            'section': '194A',
            'amountPaid': 200000,
            'taxDeducted': 20000,
            'depositDate': '20/03/2024',
          },
        ],
        'Part_C_advanceTax': 100000,
        'Part_C_selfAssessment': 50000,
      });

      final result = await TracesService.downloadForm26as(
        'ABCDE1234F',
        '2024-25',
        dio: dio,
        credentialRepository: repo,
      );

      expect(result.pan, 'ABCDE1234F');
      expect(result.assessmentYear, '2024-25');
      expect(result.tdsEntries, hasLength(2));
      expect(result.tdsEntries.first.deductorName, 'Employer XYZ');
      expect(result.tdsEntries.first.taxDeducted, 800000);
      expect(result.advanceTax, 100000);
      expect(result.selfAssessment, 50000);
      expect(result.totalTds, 820000);
    });

    test('parses empty Part_A list', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'Part_A': [],
        'Part_C_advanceTax': 0,
        'Part_C_selfAssessment': 0,
      });

      final result = await TracesService.downloadForm26as(
        'XYZAB5678Z',
        '2023-24',
        dio: dio,
        credentialRepository: repo,
      );

      expect(result.tdsEntries, isEmpty);
      expect(result.totalTds, 0);
    });
  });

  // -------------------------------------------------------------------------
  // TracesService — AIS HTTP happy path
  // -------------------------------------------------------------------------
  group('TracesService.downloadAis — HTTP', () {
    test('parses AIS with one income entry', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'incomeDetails': [
          {
            'sourceType': 'Salary',
            'sourceName': 'ABC Corp',
            'amount': 90000000,
            'taxDeducted': 12000000,
          },
        ],
      });

      final result = await TracesService.downloadAis(
        'ABCDE1234F',
        '2024-25',
        dio: dio,
        credentialRepository: repo,
      );

      expect(result.pan, 'ABCDE1234F');
      expect(result.incomeDetails, hasLength(1));
      expect(result.incomeDetails.first.sourceType, 'Salary');
      expect(result.totalIncome, 90000000);
    });
  });

  // -------------------------------------------------------------------------
  // TracesService — Form 16 HTTP happy path
  // -------------------------------------------------------------------------
  group('TracesService.getForm16 — HTTP', () {
    test('parses Form 16 certificates list', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({
        'certificates': [
          {
            'tan': 'AAAA00001A',
            'pan': 'ABCDE1234F',
            'grossSalary': 80000000,
            'tdsDeducted': 10000000,
            'certificateNumber': 'CERT-20240001',
          },
        ],
      });

      final certs = await TracesService.getForm16(
        'AAAA00001A',
        4,
        2024,
        dio: dio,
        credentialRepository: repo,
      );

      expect(certs, hasLength(1));
      expect(certs.first.employeePan, 'ABCDE1234F');
      expect(certs.first.certificateNumber, 'CERT-20240001');
      expect(certs.first.financialYear, 2024);
      expect(certs.first.quarter, 4);
    });

    test('returns empty list when no certificates', () async {
      final repo = _FakeCredentialRepository(credential: _makeCredential());
      final dio = _mockDio({'certificates': []});

      final certs = await TracesService.getForm16(
        'AAAA00001A',
        1,
        2024,
        dio: dio,
        credentialRepository: repo,
      );

      expect(certs, isEmpty);
    });
  });
}
