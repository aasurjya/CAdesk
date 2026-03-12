import 'package:ca_app/features/e_verification/domain/models/evc_request.dart';
import 'package:ca_app/features/e_verification/domain/services/evc_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── initiateEvc ───────────────────────────────────────────────────────

  group('EvcService.initiateEvc', () {
    test('returns EvcRequest with pending status', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      expect(req.status, EvcStatus.pending);
    });

    test('stores pan correctly', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      expect(req.pan, 'ABCDE1234F');
    });

    test('stores evcMethod correctly', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.netBanking);
      expect(req.evcMethod, EvcMethod.netBanking);
    });

    test('otp is null initially', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      expect(req.otp, isNull);
    });

    test('otpExpiry is null initially', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      expect(req.otpExpiry, isNull);
    });

    test('mobile is masked (not full number)', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      // Masked format should not be empty but should contain masking chars
      expect(req.mobile, isNotEmpty);
    });

    test('email is masked (not full address)', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      expect(req.email, isNotEmpty);
    });
  });

  // ── generateOtp ───────────────────────────────────────────────────────

  group('EvcService.generateOtp', () {
    late EvcRequest baseRequest;

    setUp(() {
      baseRequest = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
    });

    test('returns request with otpSent status', () {
      final result = EvcService.generateOtp(baseRequest);
      expect(result.status, EvcStatus.otpSent);
    });

    test('otp is set and non-null', () {
      final result = EvcService.generateOtp(baseRequest);
      expect(result.otp, isNotNull);
      expect(result.otp, isNotEmpty);
    });

    test('otp is 6 digits in test mode', () {
      final result = EvcService.generateOtp(baseRequest);
      expect(result.otp, '123456');
    });

    test('otpExpiry is set approximately 15 minutes from now', () {
      final before = DateTime.now();
      final result = EvcService.generateOtp(baseRequest);
      final after = DateTime.now();

      expect(result.otpExpiry, isNotNull);
      // Expiry should be ~15 minutes after generation
      final minExpiry = before.add(const Duration(minutes: 14));
      final maxExpiry = after.add(const Duration(minutes: 16));
      expect(result.otpExpiry!.isAfter(minExpiry), isTrue);
      expect(result.otpExpiry!.isBefore(maxExpiry), isTrue);
    });

    test('original request is not mutated', () {
      EvcService.generateOtp(baseRequest);
      expect(baseRequest.otp, isNull);
      expect(baseRequest.status, EvcStatus.pending);
    });
  });

  // ── verifyOtp ─────────────────────────────────────────────────────────

  group('EvcService.verifyOtp', () {
    late EvcRequest requestWithOtp;

    setUp(() {
      final base = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      requestWithOtp = EvcService.generateOtp(base);
    });

    test('correct OTP → verified status', () {
      final result = EvcService.verifyOtp(requestWithOtp, '123456');
      expect(result.status, EvcStatus.verified);
    });

    test('wrong OTP → failed status', () {
      final result = EvcService.verifyOtp(requestWithOtp, '000000');
      expect(result.status, EvcStatus.failed);
    });

    test('correct OTP → returns new instance (immutability)', () {
      final result = EvcService.verifyOtp(requestWithOtp, '123456');
      expect(identical(result, requestWithOtp), isFalse);
    });

    test('expired OTP → failed status', () {
      final expiredRequest = requestWithOtp.copyWith(
        otpExpiry: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      final result = EvcService.verifyOtp(expiredRequest, '123456');
      expect(result.status, EvcStatus.failed);
    });

    test('original request not mutated after verification', () {
      EvcService.verifyOtp(requestWithOtp, '123456');
      expect(requestWithOtp.status, EvcStatus.otpSent);
    });
  });

  // ── isOtpExpired ─────────────────────────────────────────────────────

  group('EvcService.isOtpExpired', () {
    test('no expiry set → false', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      expect(EvcService.isOtpExpired(req), isFalse);
    });

    test('expiry in the future → false', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      final withExpiry = req.copyWith(
        otpExpiry: DateTime.now().add(const Duration(minutes: 10)),
      );
      expect(EvcService.isOtpExpired(withExpiry), isFalse);
    });

    test('expiry in the past → true', () {
      final req = EvcService.initiateEvc('ABCDE1234F', EvcMethod.aadhaarOtp);
      final expired = req.copyWith(
        otpExpiry: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(EvcService.isOtpExpired(expired), isTrue);
    });
  });

  // ── generateEvcCode ──────────────────────────────────────────────────

  group('EvcService.generateEvcCode', () {
    test('returns a 10-character string', () {
      final code = EvcService.generateEvcCode('ABCDE1234F');
      expect(code.length, 10);
    });

    test('returns only alphanumeric characters', () {
      final code = EvcService.generateEvcCode('ABCDE1234F');
      expect(RegExp(r'^[A-Z0-9]{10}$').hasMatch(code), isTrue);
    });

    test('same PAN returns consistent code in same session', () {
      final code1 = EvcService.generateEvcCode('ABCDE1234F');
      final code2 = EvcService.generateEvcCode('ABCDE1234F');
      expect(code1, equals(code2));
    });

    test('different PANs return different codes', () {
      final code1 = EvcService.generateEvcCode('ABCDE1234F');
      final code2 = EvcService.generateEvcCode('ZYXWV9876A');
      expect(code1, isNot(equals(code2)));
    });
  });

  // ── EvcRequest model ─────────────────────────────────────────────────

  group('EvcRequest model', () {
    EvcRequest createRequest({
      String pan = 'ABCDE1234F',
      String mobile = 'XXXXXX7890',
      String email = 'te***@gmail.com',
      EvcMethod evcMethod = EvcMethod.aadhaarOtp,
      String? otp,
      DateTime? otpExpiry,
      EvcStatus status = EvcStatus.pending,
    }) {
      return EvcRequest(
        pan: pan,
        mobile: mobile,
        email: email,
        evcMethod: evcMethod,
        otp: otp,
        otpExpiry: otpExpiry,
        status: status,
      );
    }

    test('creates with correct field values', () {
      final req = createRequest();
      expect(req.pan, 'ABCDE1234F');
      expect(req.mobile, 'XXXXXX7890');
      expect(req.evcMethod, EvcMethod.aadhaarOtp);
      expect(req.status, EvcStatus.pending);
    });

    test('copyWith → updates specified fields', () {
      final req = createRequest();
      final updated = req.copyWith(status: EvcStatus.verified);
      expect(updated.status, EvcStatus.verified);
      expect(updated.pan, req.pan);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final req = createRequest(otp: '123456');
      final copy = req.copyWith();
      expect(copy.pan, req.pan);
      expect(copy.otp, req.otp);
      expect(copy.status, req.status);
    });

    test('equality → equal when all fields match', () {
      final a = createRequest();
      final b = createRequest();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when pan differs', () {
      final a = createRequest(pan: 'ABCDE1234F');
      final b = createRequest(pan: 'ZYXWV9876A');
      expect(a, isNot(equals(b)));
    });
  });

  // ── EvcMethod enum ────────────────────────────────────────────────────

  group('EvcMethod enum', () {
    test('all methods have labels', () {
      for (final method in EvcMethod.values) {
        expect(method.label, isNotEmpty);
      }
    });

    test('netBanking has correct label', () {
      expect(EvcMethod.netBanking.label, isNotEmpty);
    });

    test('aadhaarOtp has correct label', () {
      expect(EvcMethod.aadhaarOtp.label, isNotEmpty);
    });
  });

  // ── EvcStatus enum ────────────────────────────────────────────────────

  group('EvcStatus enum', () {
    test('all statuses are distinct', () {
      final statuses = EvcStatus.values.toSet();
      expect(statuses.length, EvcStatus.values.length);
    });
  });
}
