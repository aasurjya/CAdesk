import 'package:encrypt/encrypt.dart' as encryption;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialEncryptionService {
  static const _secureStorage = FlutterSecureStorage();
  static const _masterKeyId = 'cadesk_master_key';

  /// Encrypt plaintext credential
  /// Returns encrypted string in format "IV:ciphertext"
  static Future<String> encrypt(String plaintext) async {
    try {
      final masterKey = await _getMasterKey();
      final key = encryption.Key.fromUtf8(masterKey);
      final iv = encryption.IV.fromSecureRandom(16);
      final encrypter = encryption.Encrypter(encryption.AES(key));
      final encrypted = encrypter.encrypt(plaintext, iv: iv);

      // Return IV + ciphertext (IV needed for decryption)
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt credential from "IV:ciphertext" format
  static Future<String> decrypt(String encryptedData) async {
    try {
      final masterKey = await _getMasterKey();
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted format: expected "IV:ciphertext"');
      }

      final iv = encryption.IV.fromBase64(parts[0]);
      final key = encryption.Key.fromUtf8(masterKey);
      final encrypter = encryption.Encrypter(encryption.AES(key));
      final plaintext = encrypter.decrypt64(parts[1], iv: iv);

      return plaintext;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Get or generate master key (stored in secure storage)
  /// Generates 32-byte AES key if not already stored
  static Future<String> _getMasterKey() async {
    try {
      var key = await _secureStorage.read(key: _masterKeyId);
      if (key == null) {
        // Generate 32-byte key
        key = encryption.Key.fromSecureRandom(32).base64;
        await _secureStorage.write(key: _masterKeyId, value: key);
      }
      return key;
    } catch (e) {
      throw Exception('Failed to get master key: $e');
    }
  }
}
