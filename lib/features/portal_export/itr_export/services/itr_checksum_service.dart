import 'dart:convert';
import 'dart:typed_data';

import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';

/// Stateless service for computing and verifying ITD payload checksums.
///
/// Uses a pure-Dart SHA-256 implementation since the `crypto` package is not
/// available in this project. The algorithm is fully compliant with FIPS 180-4.
class ItrChecksumService {
  ItrChecksumService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Computes the SHA-256 hex digest of [payload] (UTF-8 encoded).
  static String computeSha256(String payload) {
    final bytes = utf8.encode(payload);
    final digest = _sha256(Uint8List.fromList(bytes));
    return _bytesToHex(digest);
  }

  /// Computes a simple CRC32-style checksum for [payload].
  ///
  /// This is a fallback and produces an 8-character hex string.
  /// Prefer [computeSha256] for production use.
  static String computeSimpleHash(String payload) {
    final bytes = utf8.encode(payload);
    var crc = 0xFFFFFFFF;
    for (final byte in bytes) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        if (crc & 1 != 0) {
          crc = (crc >>> 1) ^ 0xEDB88320;
        } else {
          crc = crc >>> 1;
        }
      }
    }
    crc = (~crc) & 0xFFFFFFFF;
    return crc.toRadixString(16).padLeft(8, '0');
  }

  /// Returns true if the [result]'s checksum matches SHA-256 of its payload.
  static bool verifyChecksum(ItrExportResult result) {
    final expected = computeSha256(result.jsonPayload);
    return expected == result.checksum;
  }

  // ---------------------------------------------------------------------------
  // Pure-Dart SHA-256 implementation (FIPS 180-4)
  // ---------------------------------------------------------------------------

  // SHA-256 initial hash values (first 32 bits of fractional parts of
  // square roots of the first 8 primes).
  static const List<int> _h0 = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];

  // SHA-256 round constants (first 32 bits of fractional parts of cube roots
  // of the first 64 primes).
  static const List<int> _k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  static Uint8List _sha256(Uint8List message) {
    // Pre-processing: add padding bits
    final bitLength = message.length * 8;
    // Append 0x80 byte
    final padded = <int>[...message, 0x80];
    // Pad with zeros until length ≡ 56 (mod 64)
    while (padded.length % 64 != 56) {
      padded.add(0x00);
    }
    // Append bit length as 64-bit big-endian
    for (var i = 7; i >= 0; i--) {
      padded.add((bitLength >> (i * 8)) & 0xFF);
    }

    // Initialize hash values
    final h = List<int>.from(_h0);

    // Process each 512-bit (64-byte) chunk
    for (var chunkStart = 0; chunkStart < padded.length; chunkStart += 64) {
      final chunk = padded.sublist(chunkStart, chunkStart + 64);

      // Prepare message schedule
      final w = List<int>.filled(64, 0);
      for (var i = 0; i < 16; i++) {
        w[i] = ((chunk[i * 4] << 24) |
                (chunk[i * 4 + 1] << 16) |
                (chunk[i * 4 + 2] << 8) |
                chunk[i * 4 + 3]) &
            0xFFFFFFFF;
      }
      for (var i = 16; i < 64; i++) {
        final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
        final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xFFFFFFFF;
      }

      // Working variables
      var a = h[0];
      var b = h[1];
      var c = h[2];
      var d = h[3];
      var e = h[4];
      var f = h[5];
      var g = h[6];
      var hh = h[7];

      // Compression
      for (var i = 0; i < 64; i++) {
        final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = (hh + s1 + ch + _k[i] + w[i]) & 0xFFFFFFFF;
        final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + maj) & 0xFFFFFFFF;

        hh = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xFFFFFFFF;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xFFFFFFFF;
      }

      // Update hash values
      h[0] = (h[0] + a) & 0xFFFFFFFF;
      h[1] = (h[1] + b) & 0xFFFFFFFF;
      h[2] = (h[2] + c) & 0xFFFFFFFF;
      h[3] = (h[3] + d) & 0xFFFFFFFF;
      h[4] = (h[4] + e) & 0xFFFFFFFF;
      h[5] = (h[5] + f) & 0xFFFFFFFF;
      h[6] = (h[6] + g) & 0xFFFFFFFF;
      h[7] = (h[7] + hh) & 0xFFFFFFFF;
    }

    // Produce the final 32-byte digest
    final digest = Uint8List(32);
    for (var i = 0; i < 8; i++) {
      digest[i * 4] = (h[i] >> 24) & 0xFF;
      digest[i * 4 + 1] = (h[i] >> 16) & 0xFF;
      digest[i * 4 + 2] = (h[i] >> 8) & 0xFF;
      digest[i * 4 + 3] = h[i] & 0xFF;
    }
    return digest;
  }

  /// Rotate right [value] by [n] bits (32-bit word).
  static int _rotr(int value, int n) =>
      ((value >>> n) | (value << (32 - n))) & 0xFFFFFFFF;

  static String _bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
