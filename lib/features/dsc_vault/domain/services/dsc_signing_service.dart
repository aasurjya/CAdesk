import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Result models
// ---------------------------------------------------------------------------

/// Result of a DSC signing operation.
@immutable
class DscSignResult {
  const DscSignResult({
    required this.success,
    required this.signature,
    this.certificateThumbprint,
    this.signedAt,
    this.errorMessage,
  });

  final bool success;

  /// Raw signature bytes (DER-encoded CMS/PKCS#7 SignedData).
  /// Empty list when [success] is false.
  final List<int> signature;

  /// SHA-1 thumbprint of the certificate used for signing.
  final String? certificateThumbprint;

  /// Timestamp when the signing operation completed.
  final DateTime? signedAt;

  /// Error description when [success] is false.
  final String? errorMessage;

  DscSignResult copyWith({
    bool? success,
    List<int>? signature,
    String? certificateThumbprint,
    DateTime? signedAt,
    String? errorMessage,
  }) {
    return DscSignResult(
      success: success ?? this.success,
      signature: signature ?? this.signature,
      certificateThumbprint:
          certificateThumbprint ?? this.certificateThumbprint,
      signedAt: signedAt ?? this.signedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DscSignResult &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          certificateThumbprint == other.certificateThumbprint;

  @override
  int get hashCode => Object.hash(success, certificateThumbprint);
}

/// Information about a DSC certificate retrieved from a hardware token.
@immutable
class DscCertificateInfo {
  const DscCertificateInfo({
    required this.thumbprint,
    required this.subjectName,
    required this.issuerName,
    required this.validFrom,
    required this.validTo,
    required this.serialNumber,
    required this.keyUsage,
    required this.isValid,
  });

  /// SHA-1 thumbprint (hex string, uppercase, 40 chars).
  final String thumbprint;

  /// Distinguished Name of the certificate holder.
  final String subjectName;

  /// Distinguished Name of the Certifying Authority.
  final String issuerName;

  final DateTime validFrom;
  final DateTime validTo;

  /// Certificate serial number (hex string).
  final String serialNumber;

  /// Comma-separated key usage flags (e.g. "Digital Signature, Non-Repudiation").
  final String keyUsage;

  /// False if the certificate is expired or revoked.
  final bool isValid;

  bool get isExpired => DateTime.now().isAfter(validTo);

  int get daysToExpiry => validTo.difference(DateTime.now()).inDays;

  DscCertificateInfo copyWith({
    String? thumbprint,
    String? subjectName,
    String? issuerName,
    DateTime? validFrom,
    DateTime? validTo,
    String? serialNumber,
    String? keyUsage,
    bool? isValid,
  }) {
    return DscCertificateInfo(
      thumbprint: thumbprint ?? this.thumbprint,
      subjectName: subjectName ?? this.subjectName,
      issuerName: issuerName ?? this.issuerName,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      serialNumber: serialNumber ?? this.serialNumber,
      keyUsage: keyUsage ?? this.keyUsage,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DscCertificateInfo &&
          runtimeType == other.runtimeType &&
          thumbprint == other.thumbprint;

  @override
  int get hashCode => thumbprint.hashCode;
}

// ---------------------------------------------------------------------------
// Abstract service interface
// ---------------------------------------------------------------------------

/// Abstract interface for DSC (Digital Signature Certificate) signing
/// operations, bridged to the native platform layer via a platform channel.
///
/// Implementations:
/// - [MockDscSigningService] — deterministic in-memory mock for tests / dev.
/// - A real platform-channel implementation (future work) that communicates
///   with the USB DSC token (Windows) or Keychain/Smart Card (macOS).
///
/// All methods throw [DscSigningException] on errors, including:
/// - Token not connected
/// - PIN incorrect
/// - Certificate expired or revoked
abstract class DscSigningService {
  /// Signs [data] using the certificate identified by [certificateThumbprint].
  ///
  /// - [data]                   — Raw bytes to sign
  /// - [certificateThumbprint]  — SHA-1 thumbprint of the signing certificate
  ///
  /// Returns a [DscSignResult] containing the DER-encoded CMS signature.
  Future<DscSignResult> signData(List<int> data, String certificateThumbprint);

  /// Verifies a [signature] against [data] using the certificate identified
  /// by [thumbprint].
  ///
  /// Returns true when the signature is cryptographically valid.
  Future<bool> verifySignature(
    List<int> data,
    List<int> signature,
    String thumbprint,
  );

  /// Retrieves certificate metadata from the hardware token without signing.
  ///
  /// - [thumbprint] — SHA-1 thumbprint of the target certificate
  ///
  /// Returns a [DscCertificateInfo] with validity and subject details.
  Future<DscCertificateInfo> getCertificateInfo(String thumbprint);
}

// ---------------------------------------------------------------------------
// Exception type
// ---------------------------------------------------------------------------

/// Exception thrown by [DscSigningService] when signing fails.
class DscSigningException implements Exception {
  const DscSigningException({
    required this.message,
    required this.code,
    this.cause,
  });

  final String message;

  /// Machine-readable code (e.g. "TOKEN_NOT_FOUND", "PIN_INCORRECT",
  /// "CERT_EXPIRED", "SIGNING_FAILED").
  final String code;

  final Object? cause;

  @override
  String toString() =>
      'DscSigningException[$code]: $message'
      '${cause != null ? ' — $cause' : ''}';
}

// ---------------------------------------------------------------------------
// Mock implementation
// ---------------------------------------------------------------------------

/// Deterministic in-memory mock implementation of [DscSigningService].
///
/// Behaviour contract:
/// - [signData]: always succeeds with a 4-byte placeholder signature.
/// - [verifySignature]: returns true when [signature] is exactly the
///   placeholder produced by [signData].
/// - [getCertificateInfo]: returns synthetic certificate info valid for
///   5 years from a fixed epoch.
///
/// No platform channel or network calls are made.
class MockDscSigningService implements DscSigningService {
  const MockDscSigningService();

  /// Placeholder signature bytes returned by [signData].
  static const List<int> _mockSignature = [0x30, 0x03, 0x02, 0x01];

  @override
  Future<DscSignResult> signData(List<int> data, String certificateThumbprint) {
    return Future.value(
      DscSignResult(
        success: true,
        signature: List<int>.unmodifiable(_mockSignature),
        certificateThumbprint: certificateThumbprint,
        signedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<bool> verifySignature(
    List<int> data,
    List<int> signature,
    String thumbprint,
  ) {
    // Verify the mock signature byte sequence.
    if (signature.length != _mockSignature.length) return Future.value(false);
    for (var i = 0; i < _mockSignature.length; i++) {
      if (signature[i] != _mockSignature[i]) return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Future<DscCertificateInfo> getCertificateInfo(String thumbprint) {
    final now = DateTime.now();
    return Future.value(
      DscCertificateInfo(
        thumbprint: thumbprint,
        subjectName: 'CN=Mock Certificate Holder, O=Mock CA Pvt Ltd, C=IN',
        issuerName: 'CN=Mock CA Sub-CA, O=Mock CA, C=IN',
        validFrom: DateTime(now.year - 1, 1, 1),
        validTo: DateTime(now.year + 4, 12, 31),
        serialNumber: 'DEADBEEF01234567',
        keyUsage: 'Digital Signature, Non-Repudiation',
        isValid: true,
      ),
    );
  }
}
