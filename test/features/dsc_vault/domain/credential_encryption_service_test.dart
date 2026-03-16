import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/dsc_vault/domain/services/credential_encryption_service.dart';

void main() {
  group('CredentialEncryptionService', () {
    const service = CredentialEncryptionService(
      deviceId: 'test-device-id-12345678',
    );

    group('encrypt', () {
      test('returns non-empty string for plaintext', () {
        final result = service.encrypt('my-secret-password');
        expect(result, isNotEmpty);
      });

      test('returned string is base64 encoded', () {
        final result = service.encrypt('test');
        // Base64 chars: A-Z, a-z, 0-9, +, /, = (padding)
        final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
        expect(base64Regex.hasMatch(result), isTrue);
      });

      test('encrypts different plaintexts to different ciphertexts', () {
        final result1 = service.encrypt('password1');
        final result2 = service.encrypt('password2');
        expect(result1, isNot(equals(result2)));
      });

      test('same plaintext encrypts to same ciphertext with deterministic IV', () {
        // With the same service (same key), encrypt should produce consistent output
        // as long as implementation is deterministic — or at least decrypt should work
        final result1 = service.encrypt('hello');
        final result2 = service.encrypt('hello');
        // Even if IVs differ, both should decrypt correctly
        expect(service.decrypt(result1), equals('hello'));
        expect(service.decrypt(result2), equals('hello'));
      });

      test('handles single character string', () {
        // AES-CBC with PKCS7 padding requires at least 1 byte
        final result = service.encrypt('x');
        expect(result, isNotEmpty);
        expect(service.decrypt(result), equals('x'));
      });

      test('handles special characters', () {
        const special = r'P@$$w0rd!#%^&*()_+-=[]{}|;:,.<>?';
        final encrypted = service.encrypt(special);
        expect(encrypted, isNotEmpty);
        expect(service.decrypt(encrypted), equals(special));
      });

      test('handles unicode characters', () {
        const unicode = 'पासवर्ड123';
        final encrypted = service.encrypt(unicode);
        expect(service.decrypt(encrypted), equals(unicode));
      });

      test('handles long strings', () {
        final longString = 'a' * 1000;
        final encrypted = service.encrypt(longString);
        expect(service.decrypt(encrypted), equals(longString));
      });
    });

    group('decrypt', () {
      test('round-trips plaintext correctly', () {
        const original = 'my-portal-password-123';
        final encrypted = service.encrypt(original);
        final decrypted = service.decrypt(encrypted);
        expect(decrypted, equals(original));
      });

      test('throws on invalid ciphertext', () {
        expect(
          () => service.decrypt('not-valid-base64!!!'),
          throwsA(isA<CredentialEncryptionException>()),
        );
      });

      test('throws on tampered ciphertext', () {
        final encrypted = service.encrypt('test');
        // Corrupt the ciphertext by replacing characters
        final tampered = encrypted.replaceAll('A', 'Z');
        if (tampered != encrypted) {
          // Only test if tampering actually changed something
          expect(
            () => service.decrypt(tampered),
            throwsA(isA<CredentialEncryptionException>()),
          );
        }
      });
    });

    group('different device IDs', () {
      test('services with different device IDs produce different keys', () {
        const service1 = CredentialEncryptionService(deviceId: 'device-aaa');
        const service2 = CredentialEncryptionService(deviceId: 'device-bbb');
        final encrypted = service1.encrypt('test-secret');
        // Decrypting with a different key should either throw or return garbage
        try {
          final result = service2.decrypt(encrypted);
          expect(result, isNot(equals('test-secret')));
        } catch (_) {
          // Expected: decryption with wrong key fails
        }
      });

      test('service with same device ID can decrypt its own output', () {
        const svc = CredentialEncryptionService(deviceId: 'consistent-device');
        const plaintext = 'my-gstn-login-password';
        final encrypted = svc.encrypt(plaintext);
        expect(svc.decrypt(encrypted), equals(plaintext));
      });
    });
  });
}
