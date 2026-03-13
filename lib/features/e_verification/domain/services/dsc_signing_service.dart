import 'dart:convert';

import 'package:ca_app/features/e_verification/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';
import 'package:crypto/crypto.dart';

/// Stateless service for DSC token detection, document signing, and
/// signature verification.
///
/// Production note: [detectAvailableTokens] returns mock test certificates.
/// In a production build the method would invoke a platform channel to
/// communicate with the native DSC bridge (e.g. ePass2003, WD Pro tokens).
class DscSigningService {
  DscSigningService._();

  // ── Token detection ───────────────────────────────────────────────────

  /// Returns available DSC certificates.
  ///
  /// In this domain-layer mock, a single test certificate is returned.
  /// Production implementations call a platform channel / native bridge.
  static List<DscCertificate> detectAvailableTokens() {
    final now = DateTime.now();
    return [
      DscCertificate(
        tokenId: 'token-test-001',
        subjectName: 'CN=Test User, O=Test Org, C=IN',
        issuer: 'CN=Test CA, O=eMudhra, C=IN',
        serialNumber: 'TEST001',
        validFrom: now.subtract(const Duration(days: 1)),
        validTo: now.add(const Duration(days: 730)), // ~2 years
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      ),
    ];
  }

  // ── Request creation ──────────────────────────────────────────────────

  /// Creates a new [SigningRequest] in [SigningStatus.pending] state.
  ///
  /// [documentHash] must be the SHA-256 hex digest of the document bytes.
  static SigningRequest createSigningRequest(
    String documentHash,
    DocumentType type,
    String signerPan,
  ) {
    final requestId = _generateRequestId(documentHash, signerPan);
    return SigningRequest(
      requestId: requestId,
      documentHash: documentHash,
      documentType: type,
      signerPan: signerPan,
      signerName: '',
      status: SigningStatus.pending,
    );
  }

  // ── Signing ────────────────────────────────────────────────────────────

  /// Signs [request] using [cert].
  ///
  /// Returns an updated [SigningRequest] with:
  ///   - [SigningStatus.signed] and a base-64 mock signature on success.
  ///   - [SigningStatus.failed] if the token is not valid.
  ///
  /// The original [request] is never mutated.
  static SigningRequest signDocument(
    SigningRequest request,
    DscCertificate cert,
  ) {
    if (!isTokenValid(cert)) {
      return request.copyWith(status: SigningStatus.failed);
    }

    final signature = _computeMockSignature(
      request.documentHash,
      cert.serialNumber,
    );

    return request.copyWith(
      status: SigningStatus.signed,
      signature: signature,
      signedAt: DateTime.now(),
    );
  }

  // ── Verification ──────────────────────────────────────────────────────

  /// Verifies the signature on [request] against [cert].
  ///
  /// Returns `true` only if:
  ///   - [request] has a non-null [SigningRequest.signature].
  ///   - The recomputed mock signature matches the stored one.
  static bool verifySignature(SigningRequest request, DscCertificate cert) {
    final sig = request.signature;
    if (sig == null || sig.isEmpty) return false;

    final expected = _computeMockSignature(
      request.documentHash,
      cert.serialNumber,
    );
    return sig == expected;
  }

  // ── Token validation ──────────────────────────────────────────────────

  /// Returns `true` when [cert] is not expired and contains
  /// the `digitalSignature` key-usage flag.
  static bool isTokenValid(DscCertificate cert) {
    if (cert.isExpired) return false;
    return cert.keyUsage.contains('digitalSignature');
  }

  // ── Private helpers ───────────────────────────────────────────────────

  /// Generates a unique, deterministic request id from document hash + PAN
  /// combined with a timestamp component for uniqueness across calls.
  static String _generateRequestId(String documentHash, String signerPan) {
    final seed =
        '$documentHash-$signerPan-${DateTime.now().microsecondsSinceEpoch}';
    final bytes = utf8.encode(seed);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  /// Mock signing: base64( sha256(documentHash + certSerialNumber) ).
  ///
  /// This is deterministic and sufficient for testing all signing flows.
  /// Real production signing uses PKCS#7/CMS with the hardware token.
  static String _computeMockSignature(
    String documentHash,
    String serialNumber,
  ) {
    final input = utf8.encode('$documentHash$serialNumber');
    final digest = sha256.convert(input);
    return base64.encode(digest.bytes);
  }
}
