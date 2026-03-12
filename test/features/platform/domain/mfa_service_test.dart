import 'package:ca_app/features/platform/domain/models/mfa_setup.dart';
import 'package:ca_app/features/platform/domain/services/mfa_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = MfaService.instance;

  group('MfaService.generateTotpSecret', () {
    test('returns a 16-character base32 string', () {
      final secret = service.generateTotpSecret();
      expect(secret.length, 16);
      expect(RegExp(r'^[A-Z2-7]+$').hasMatch(secret), isTrue);
    });

    test('generates unique secrets on each call', () {
      final s1 = service.generateTotpSecret();
      final s2 = service.generateTotpSecret();
      // Extremely unlikely to be equal with 16-char random strings
      expect(s1, isNot(equals(s2)));
    });
  });

  group('MfaService.generateTotp', () {
    test('returns a 6-digit string', () {
      final code = service.generateTotp('ABCDEFGHIJKLMNOP', DateTime.now());
      expect(code.length, 6);
      expect(RegExp(r'^\d{6}$').hasMatch(code), isTrue);
    });

    test('returns same code for times within the same 30-second window', () {
      final t1 = DateTime(2025, 1, 1, 12, 0, 5);
      final t2 = DateTime(2025, 1, 1, 12, 0, 28);
      final code1 = service.generateTotp('TESTSECRETABCDEF', t1);
      final code2 = service.generateTotp('TESTSECRETABCDEF', t2);
      expect(code1, equals(code2));
    });

    test('returns different code for different 30-second windows', () {
      final t1 = DateTime(2025, 1, 1, 12, 0, 0);
      final t2 = DateTime(2025, 1, 1, 12, 0, 30);
      final code1 = service.generateTotp('TESTSECRETABCDEF', t1);
      final code2 = service.generateTotp('TESTSECRETABCDEF', t2);
      expect(code1, isNot(equals(code2)));
    });
  });

  group('MfaService.verifyTotp', () {
    test('verifies correct code for current window', () {
      const secret = 'MYSECRETHIJKLMNO';
      final now = DateTime(2025, 6, 15, 10, 30, 10);
      final code = service.generateTotp(secret, now);

      expect(service.verifyTotp(secret, code, now), isTrue);
    });

    test('verifies code from adjacent window (window=1)', () {
      const secret = 'MYSECRETHIJKLMNO';
      final now = DateTime(2025, 6, 15, 10, 30, 10);
      final prevWindow = now.subtract(const Duration(seconds: 30));
      final code = service.generateTotp(secret, prevWindow);

      expect(service.verifyTotp(secret, code, now, window: 1), isTrue);
    });

    test('rejects code from window outside tolerance', () {
      const secret = 'MYSECRETHIJKLMNO';
      final now = DateTime(2025, 6, 15, 10, 30, 10);
      final farPast = now.subtract(const Duration(seconds: 90));
      final code = service.generateTotp(secret, farPast);

      expect(service.verifyTotp(secret, code, now, window: 1), isFalse);
    });

    test('rejects incorrect code', () {
      const secret = 'MYSECRETHIJKLMNO';
      final now = DateTime(2025, 6, 15, 10, 30, 10);
      expect(service.verifyTotp(secret, '000000', now), isFalse);
    });
  });

  group('MfaService.generateBackupCodes', () {
    test('returns exactly 10 backup codes', () {
      final codes = service.generateBackupCodes();
      expect(codes, hasLength(10));
    });

    test('each code is 8 alphanumeric characters', () {
      final codes = service.generateBackupCodes();
      for (final code in codes) {
        expect(code.length, 8);
        expect(RegExp(r'^[A-Z0-9]+$').hasMatch(code), isTrue);
      }
    });

    test('all codes are unique', () {
      final codes = service.generateBackupCodes();
      expect(codes.toSet().length, 10);
    });
  });

  group('MfaService.setupMfa', () {
    test('returns MfaSetup with correct userId and method', () {
      final setup = service.setupMfa('user-42', MfaMethod.totp);

      expect(setup.userId, 'user-42');
      expect(setup.method, MfaMethod.totp);
    });

    test('returned setup has unverified status initially', () {
      final setup = service.setupMfa('user-42', MfaMethod.totp);
      expect(setup.isVerified, isFalse);
    });

    test('returned setup has 10 backup codes', () {
      final setup = service.setupMfa('user-42', MfaMethod.totp);
      expect(setup.backupCodes, hasLength(10));
    });

    test('secret is non-empty 16-character string', () {
      final setup = service.setupMfa('user-42', MfaMethod.totp);
      expect(setup.secret.length, 16);
    });

    test('setupAt is close to now', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final setup = service.setupMfa('user-42', MfaMethod.sms);
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(
        setup.setupAt.isAfter(before) && setup.setupAt.isBefore(after),
        isTrue,
      );
    });
  });

  group('MfaSetup immutability', () {
    test('copyWith creates new instance with updated fields', () {
      final setup = MfaSetup(
        userId: 'u1',
        method: MfaMethod.totp,
        secret: 'ABCDEFGHIJKLMNOP',
        backupCodes: const ['12345678'],
        isVerified: false,
        setupAt: DateTime(2025, 1, 1),
      );

      final verified = setup.copyWith(isVerified: true);
      expect(verified.isVerified, isTrue);
      expect(verified.userId, 'u1');
      expect(identical(setup, verified), isFalse);
    });

    test('operator == based on userId and method', () {
      final a = MfaSetup(
        userId: 'u1',
        method: MfaMethod.totp,
        secret: 'AAAAAAAAAAAAAAAA',
        backupCodes: const [],
        isVerified: false,
        setupAt: DateTime(2025, 1, 1),
      );
      final b = MfaSetup(
        userId: 'u1',
        method: MfaMethod.totp,
        secret: 'BBBBBBBBBBBBBBBB',
        backupCodes: const [],
        isVerified: true,
        setupAt: DateTime(2025, 6, 1),
      );
      expect(a, equals(b));
    });
  });
}
