import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Exception thrown when encryption or decryption fails.
class CredentialEncryptionException implements Exception {
  const CredentialEncryptionException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'CredentialEncryptionException: $message'
      '${cause != null ? ' (cause: $cause)' : ''}';
}

/// AES-256 encryption service for portal credentials.
///
/// The encryption key is derived deterministically from a device-specific
/// identifier using SHA-256, producing a stable 32-byte key. This is a
/// stateless value-object — construct with a device ID and reuse freely.
///
/// Example:
/// ```dart
/// const service = CredentialEncryptionService(deviceId: deviceId);
/// final cipher = service.encrypt('my-secret');
/// final plain  = service.decrypt(cipher); // 'my-secret'
/// ```
class CredentialEncryptionService {
  const CredentialEncryptionService({required this.deviceId});

  /// A stable device-scoped identifier used to derive the encryption key.
  final String deviceId;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Encrypts [plaintext] using AES-256-CBC and returns a base64 string.
  ///
  /// The output format is `<base64-iv><base64-ciphertext>` concatenated as a
  /// single base64-encoded blob: `base64(iv_bytes + cipher_bytes)`.
  ///
  /// Throws [CredentialEncryptionException] on failure.
  String encrypt(String plaintext) {
    try {
      final key = _deriveKey();
      final iv = enc.IV.fromLength(16); // fixed zero-IV for determinism
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(plaintext, iv: iv);
      // Pack: base64(iv_bytes || cipher_bytes)
      final combined = _combineBytes(iv.bytes, encrypted.bytes);
      return base64.encode(combined);
    } on CredentialEncryptionException {
      rethrow;
    } catch (e) {
      throw CredentialEncryptionException('Encryption failed', cause: e);
    }
  }

  /// Decrypts a base64-encoded ciphertext produced by [encrypt].
  ///
  /// Throws [CredentialEncryptionException] if the input is malformed or
  /// cannot be decrypted with this service's key.
  String decrypt(String ciphertext) {
    try {
      final combined = base64.decode(ciphertext);
      if (combined.length < 16) {
        throw const CredentialEncryptionException(
          'Ciphertext is too short to contain a valid IV',
        );
      }
      final ivBytes = combined.sublist(0, 16);
      final cipherBytes = combined.sublist(16);
      final key = _deriveKey();
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(enc.Encrypted(cipherBytes), iv: iv);
    } on CredentialEncryptionException {
      rethrow;
    } catch (e) {
      throw CredentialEncryptionException('Decryption failed', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Derives a deterministic 32-byte AES-256 key from [deviceId] via SHA-256.
  enc.Key _deriveKey() {
    final bytes = utf8.encode(deviceId);
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Concatenates [iv] and [cipher] into a single byte list.
  List<int> _combineBytes(List<int> iv, List<int> cipher) {
    return [...iv, ...cipher];
  }
}
