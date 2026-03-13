import 'dart:convert';

import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:typed_data';

// We use the Dart SDK's built-in crypto via dart:convert + dart:typed_data.
// SHA-256 is available through the `crypto` package; however since the project
// does not declare it as a dependency, we implement a minimal SHA-256 wrapper
// using dart:convert's latin1 encoding and the platform's native crypto.
//
// Implementation uses package:crypto when available, otherwise falls back to
// a pure-Dart SHA-256.  To keep dependencies minimal we inline a thin wrapper
// that calls [_sha256Hex].

/// Stateless service that generates Invoice Reference Numbers (IRN) and QR
/// data strings per the NIC/IRP e-invoice specification.
///
/// IRN = SHA-256 hex of (sellerGstin + docType + docNumber + docDate).
/// QR data = JSON string with key invoice fields for the printed QR code.
class IrnGenerator {
  IrnGenerator._();

  /// Generates a 64-character hex IRN for the given invoice parameters.
  ///
  /// The IRN is computed as SHA-256 of the concatenation:
  /// `sellerGstin + docType + docNumber + docDate`
  /// where [docDate] should be in DD/MM/YYYY format.
  static String generateIrn({
    required String sellerGstin,
    required String docType,
    required String docNumber,
    required String docDate,
  }) {
    final input = '$sellerGstin$docType$docNumber$docDate';
    return _sha256Hex(input);
  }

  /// Builds the QR code data JSON string per NIC IRP spec.
  ///
  /// Returns a compact JSON string containing the fields that the IRP
  /// includes in the signed QR code payload (seller GSTIN, buyer GSTIN,
  /// doc number, doc date, doc type, total invoice value, IRN, and ack
  /// number placeholder).
  static String generateQrData(EInvoiceRequest req, String irn) {
    final docDateStr = _formatDate(req.docDtls.dt);
    final qrMap = {
      'SellerGstin': req.sellerDtls.gstin,
      'BuyerGstin': req.buyerDtls.gstin,
      'DocNo': req.docDtls.no,
      'DocDate': docDateStr,
      'DocType': req.docDtls.typ,
      'TotInvVal': req.valDtls.totInvVal,
      'Irn': irn,
      'AckNo': '',
      'AckDate': '',
    };
    return jsonEncode(qrMap);
  }

  // ── Private helpers ───────────────────────────────────────────────────

  /// Returns the NIC API date format DD/MM/YYYY for [date].
  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// Computes SHA-256 of [input] (UTF-8 encoded) and returns lower-case hex.
  ///
  /// Uses a pure-Dart implementation to avoid external package dependencies.
  static String _sha256Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = _sha256(Uint8List.fromList(bytes));
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // ── Pure-Dart SHA-256 ─────────────────────────────────────────────────
  // Based on FIPS 180-4. No external dependencies.

  static const List<int> _k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, //
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

  static Uint8List _sha256(Uint8List data) {
    // Initial hash values (first 32 bits of fractional parts of square roots).
    var h0 = 0x6a09e667;
    var h1 = 0xbb67ae85;
    var h2 = 0x3c6ef372;
    var h3 = 0xa54ff53a;
    var h4 = 0x510e527f;
    var h5 = 0x9b05688c;
    var h6 = 0x1f83d9ab;
    var h7 = 0x5be0cd19;

    // Pre-processing: add padding bits.
    final msgLen = data.length;
    final bitLen = msgLen * 8;

    // Determine padded length: original + 1 byte (0x80) + zeros + 8 bytes len.
    var paddedLen = msgLen + 1;
    while (paddedLen % 64 != 56) {
      paddedLen++;
    }
    paddedLen += 8;

    final padded = Uint8List(paddedLen);
    padded.setRange(0, msgLen, data);
    padded[msgLen] = 0x80;
    // Append bit length as 64-bit big-endian.
    for (var i = 0; i < 8; i++) {
      padded[paddedLen - 8 + i] = (bitLen >> (56 - i * 8)) & 0xff;
    }

    // Process each 512-bit (64-byte) chunk.
    for (var chunkStart = 0; chunkStart < paddedLen; chunkStart += 64) {
      final w = List<int>.filled(64, 0);
      for (var i = 0; i < 16; i++) {
        w[i] =
            (padded[chunkStart + i * 4] << 24) |
            (padded[chunkStart + i * 4 + 1] << 16) |
            (padded[chunkStart + i * 4 + 2] << 8) |
            padded[chunkStart + i * 4 + 3];
      }
      for (var i = 16; i < 64; i++) {
        final s0 =
            _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ _shr(w[i - 15], 3);
        final s1 =
            _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ _shr(w[i - 2], 10);
        w[i] = _mask32(w[i - 16] + s0 + w[i - 7] + s1);
      }

      var a = h0, b = h1, c = h2, d = h3;
      var e = h4, f = h5, g = h6, h = h7;

      for (var i = 0; i < 64; i++) {
        final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ (~e & g);
        final temp1 = _mask32(h + s1 + ch + _k[i] + w[i]);
        final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = _mask32(s0 + maj);

        h = g;
        g = f;
        f = e;
        e = _mask32(d + temp1);
        d = c;
        c = b;
        b = a;
        a = _mask32(temp1 + temp2);
      }

      h0 = _mask32(h0 + a);
      h1 = _mask32(h1 + b);
      h2 = _mask32(h2 + c);
      h3 = _mask32(h3 + d);
      h4 = _mask32(h4 + e);
      h5 = _mask32(h5 + f);
      h6 = _mask32(h6 + g);
      h7 = _mask32(h7 + h);
    }

    // Produce the final 32-byte digest.
    final digest = Uint8List(32);
    void writeWord(int offset, int word) {
      digest[offset] = (word >> 24) & 0xff;
      digest[offset + 1] = (word >> 16) & 0xff;
      digest[offset + 2] = (word >> 8) & 0xff;
      digest[offset + 3] = word & 0xff;
    }

    writeWord(0, h0);
    writeWord(4, h1);
    writeWord(8, h2);
    writeWord(12, h3);
    writeWord(16, h4);
    writeWord(20, h5);
    writeWord(24, h6);
    writeWord(28, h7);
    return digest;
  }

  /// Right-rotate 32-bit integer [n] by [s] positions.
  static int _rotr(int n, int s) => _mask32(((n >>> s) | (n << (32 - s))));

  /// Logical right shift, masking to 32 bits.
  static int _shr(int n, int s) => _mask32(n >>> s);

  /// Mask value to lower 32 bits.
  static int _mask32(int n) => n & 0xFFFFFFFF;
}
