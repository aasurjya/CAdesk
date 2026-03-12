import 'package:ca_app/features/e_verification/domain/models/evc_request.dart';
import 'package:ca_app/features/e_verification/domain/services/e_sign_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── requestESign ──────────────────────────────────────────────────────

  group('ESignApiClient.requestESign', () {
    test('returns EvcRequest with aadhaarOtp method', () async {
      final result = await ESignApiClient.instance.requestESign(
        'deadbeef1234',
        '123456789012',
      );
      expect(result.evcMethod, EvcMethod.aadhaarOtp);
    });

    test('returns EvcRequest with otpSent status', () async {
      final result = await ESignApiClient.instance.requestESign(
        'deadbeef1234',
        '123456789012',
      );
      expect(result.status, EvcStatus.otpSent);
    });

    test('returns non-null otp', () async {
      final result = await ESignApiClient.instance.requestESign(
        'deadbeef1234',
        '123456789012',
      );
      expect(result.otp, isNotNull);
      expect(result.otp, isNotEmpty);
    });

    test('returns non-null otpExpiry', () async {
      final result = await ESignApiClient.instance.requestESign(
        'deadbeef1234',
        '123456789012',
      );
      expect(result.otpExpiry, isNotNull);
    });

    test('returns masked mobile', () async {
      final result = await ESignApiClient.instance.requestESign(
        'deadbeef1234',
        '123456789012',
      );
      expect(result.mobile, isNotEmpty);
    });

    test('different aadhaar numbers return distinct requests', () async {
      final r1 = await ESignApiClient.instance.requestESign(
        'hash1',
        '123456789012',
      );
      final r2 = await ESignApiClient.instance.requestESign(
        'hash2',
        '999888777666',
      );
      // They may share the same mock OTP but should be distinct objects
      expect(identical(r1, r2), isFalse);
    });
  });

  // ── checkESignStatus ──────────────────────────────────────────────────

  group('ESignApiClient.checkESignStatus', () {
    test('known requestId → returns verified status', () async {
      // First create a request to get a valid requestId
      final initial = await ESignApiClient.instance.requestESign(
        'hash-to-check',
        '111222333444',
      );
      final status = await ESignApiClient.instance.checkESignStatus(
        initial.pan,
      );
      expect(status.status, EvcStatus.verified);
    });

    test('returns EvcRequest (not null)', () async {
      final initial = await ESignApiClient.instance.requestESign(
        'some-hash',
        '555666777888',
      );
      final status = await ESignApiClient.instance.checkESignStatus(
        initial.pan,
      );
      expect(status, isA<EvcRequest>());
    });

    test('unknown requestId → returns failed status', () async {
      final status = await ESignApiClient.instance.checkESignStatus(
        'UNKNOWNPAN',
      );
      expect(status.status, EvcStatus.failed);
    });
  });

  // ── Singleton pattern ────────────────────────────────────────────────

  group('ESignApiClient singleton', () {
    test('instance is always the same object', () {
      final a = ESignApiClient.instance;
      final b = ESignApiClient.instance;
      expect(identical(a, b), isTrue);
    });
  });
}
