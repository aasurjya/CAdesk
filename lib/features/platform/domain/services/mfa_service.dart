// ignore_for_file: public_member_api_docs

import 'dart:math';
import 'dart:typed_data';

import 'package:ca_app/features/platform/domain/models/mfa_setup.dart';

/// MFA service providing TOTP generation/verification and backup code management.
///
/// Stateless singleton — use [MfaService.instance].
final class MfaService {
  MfaService._();

  static final MfaService instance = MfaService._();

  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const String _alphaNumChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  final Random _rng = Random.secure();

  // ---------------------------------------------------------------------------
  // Secret & code generation
  // ---------------------------------------------------------------------------

  /// Generates a 16-character random Base32 string suitable as a TOTP secret.
  String generateTotpSecret() {
    return List.generate(
      16,
      (_) => _base32Chars[_rng.nextInt(_base32Chars.length)],
    ).join();
  }

  /// Generates a 6-digit TOTP code for [secret] at [atTime].
  ///
  /// Uses standard RFC 6238 TOTP: 30-second step, 6 digits, HMAC-SHA1.
  String generateTotp(String secret, DateTime atTime) {
    final counter = atTime.millisecondsSinceEpoch ~/ 1000 ~/ 30;
    return _hotp(_base32Decode(secret), counter);
  }

  /// Verifies that [code] is valid for [secret] at [atTime].
  ///
  /// Checks [window] steps in each direction (default 0 = current step only).
  bool verifyTotp(
    String secret,
    String code,
    DateTime atTime, {
    int window = 0,
  }) {
    final counter = atTime.millisecondsSinceEpoch ~/ 1000 ~/ 30;
    final keyBytes = _base32Decode(secret);
    for (var delta = -window; delta <= window; delta++) {
      if (_hotp(keyBytes, counter + delta) == code) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Backup codes
  // ---------------------------------------------------------------------------

  /// Generates 10 unique 8-character alphanumeric backup codes.
  List<String> generateBackupCodes() {
    final codes = <String>{};
    while (codes.length < 10) {
      codes.add(
        List.generate(
          8,
          (_) => _alphaNumChars[_rng.nextInt(_alphaNumChars.length)],
        ).join(),
      );
    }
    return codes.toList();
  }

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------

  /// Creates an [MfaSetup] record for [userId] using [method].
  MfaSetup setupMfa(String userId, MfaMethod method) {
    return MfaSetup(
      userId: userId,
      method: method,
      secret: generateTotpSecret(),
      backupCodes: generateBackupCodes(),
      isVerified: false,
      setupAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Private TOTP / HMAC-SHA1 helpers
  // ---------------------------------------------------------------------------

  /// RFC 4226 HOTP: HMAC-SHA1 based one-time password.
  String _hotp(Uint8List key, int counter) {
    final msg = _counterToBytes(counter);
    final mac = _hmacSha1(key, msg);
    final offset = mac[19] & 0x0f;
    final code =
        (((mac[offset] & 0x7f) << 24) |
            ((mac[offset + 1] & 0xff) << 16) |
            ((mac[offset + 2] & 0xff) << 8) |
            (mac[offset + 3] & 0xff)) %
        1000000;
    return code.toString().padLeft(6, '0');
  }

  Uint8List _counterToBytes(int counter) {
    final bytes = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      bytes[i] = c & 0xff;
      c >>= 8;
    }
    return bytes;
  }

  /// Pure-Dart HMAC-SHA1 (no external packages).
  Uint8List _hmacSha1(Uint8List key, Uint8List message) {
    const blockSize = 64;
    var k = key.length > blockSize ? _sha1(key) : key;
    if (k.length < blockSize) {
      final padded = Uint8List(blockSize);
      padded.setRange(0, k.length, k);
      k = padded;
    }

    final ipad = Uint8List(blockSize);
    final opad = Uint8List(blockSize);
    for (var i = 0; i < blockSize; i++) {
      ipad[i] = k[i] ^ 0x36;
      opad[i] = k[i] ^ 0x5c;
    }

    final innerInput = Uint8List(blockSize + message.length);
    innerInput.setRange(0, blockSize, ipad);
    innerInput.setRange(blockSize, blockSize + message.length, message);
    final innerHash = _sha1(innerInput);

    final outerInput = Uint8List(blockSize + 20);
    outerInput.setRange(0, blockSize, opad);
    outerInput.setRange(blockSize, blockSize + 20, innerHash);
    return _sha1(outerInput);
  }

  /// Pure-Dart SHA-1 implementation (RFC 3174).
  Uint8List _sha1(Uint8List data) {
    // Initial hash values.
    var h0 = 0x67452301;
    var h1 = 0xEFCDAB89;
    var h2 = 0x98BADCFE;
    var h3 = 0x10325476;
    var h4 = 0xC3D2E1F0;

    // Pre-processing: padding.
    final originalLength = data.length;
    final bitLength = originalLength * 8;

    // Append bit '1' (0x80 byte) then zeros, then 64-bit big-endian length.
    final padded = <int>[...data, 0x80];
    while ((padded.length % 64) != 56) {
      padded.add(0x00);
    }
    // Append 64-bit big-endian bit length.
    for (var i = 7; i >= 0; i--) {
      padded.add((bitLength >> (i * 8)) & 0xff);
    }

    final bytes = Uint8List.fromList(padded);

    // Process each 512-bit (64-byte) chunk.
    for (var chunkStart = 0; chunkStart < bytes.length; chunkStart += 64) {
      final w = List<int>.filled(80, 0);
      for (var i = 0; i < 16; i++) {
        final base = chunkStart + i * 4;
        w[i] = ((bytes[base] & 0xff) << 24) |
            ((bytes[base + 1] & 0xff) << 16) |
            ((bytes[base + 2] & 0xff) << 8) |
            (bytes[base + 3] & 0xff);
      }
      for (var i = 16; i < 80; i++) {
        w[i] = _rotl32(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);
      }

      var a = h0, b = h1, c = h2, d = h3, e = h4;

      for (var i = 0; i < 80; i++) {
        int f, k;
        if (i < 20) {
          f = (b & c) | (~b & d);
          k = 0x5A827999;
        } else if (i < 40) {
          f = b ^ c ^ d;
          k = 0x6ED9EBA1;
        } else if (i < 60) {
          f = (b & c) | (b & d) | (c & d);
          k = 0x8F1BBCDC;
        } else {
          f = b ^ c ^ d;
          k = 0xCA62C1D6;
        }
        final temp = (_rotl32(a, 5) + f + e + k + w[i]) & 0xFFFFFFFF;
        e = d;
        d = c;
        c = _rotl32(b, 30);
        b = a;
        a = temp;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
    }

    final result = Uint8List(20);
    _writeUint32BE(result, 0, h0);
    _writeUint32BE(result, 4, h1);
    _writeUint32BE(result, 8, h2);
    _writeUint32BE(result, 12, h3);
    _writeUint32BE(result, 16, h4);
    return result;
  }

  int _rotl32(int value, int shift) {
    return ((value << shift) | (value >> (32 - shift))) & 0xFFFFFFFF;
  }

  void _writeUint32BE(Uint8List bytes, int offset, int value) {
    bytes[offset] = (value >> 24) & 0xff;
    bytes[offset + 1] = (value >> 16) & 0xff;
    bytes[offset + 2] = (value >> 8) & 0xff;
    bytes[offset + 3] = value & 0xff;
  }

  /// Decodes a Base32-encoded string to bytes.
  Uint8List _base32Decode(String input) {
    final chars = input.toUpperCase().replaceAll('=', '');
    final bits = StringBuffer();
    for (final ch in chars.split('')) {
      final idx = _base32Chars.indexOf(ch);
      if (idx < 0) continue;
      bits.write(idx.toRadixString(2).padLeft(5, '0'));
    }
    final bitStr = bits.toString();
    final byteCount = bitStr.length ~/ 8;
    final result = Uint8List(byteCount);
    for (var i = 0; i < byteCount; i++) {
      result[i] = int.parse(bitStr.substring(i * 8, i * 8 + 8), radix: 2);
    }
    return result;
  }
}
