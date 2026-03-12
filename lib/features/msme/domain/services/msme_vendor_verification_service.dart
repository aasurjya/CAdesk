/// Result of verifying an MSME vendor's registration status.
class MsmeVerificationResult {
  const MsmeVerificationResult({
    required this.udyamNumber,
    required this.isVerified,
    required this.category,
    required this.enterpriseName,
  });

  final String udyamNumber;

  /// Whether the Udyam registration number is valid and active.
  final bool isVerified;

  /// MSME category returned by the verification API.
  final String category;
  final String enterpriseName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MsmeVerificationResult &&
        other.udyamNumber == udyamNumber &&
        other.isVerified == isVerified &&
        other.category == category &&
        other.enterpriseName == enterpriseName;
  }

  @override
  int get hashCode =>
      Object.hash(udyamNumber, isVerified, category, enterpriseName);
}

/// Service for verifying MSME vendor registration via Udyam portal.
///
/// Returns a mock response in the current implementation.
/// In production this would call the Udyam verification API.
class MsmeVendorVerificationService {
  MsmeVendorVerificationService._();

  static final MsmeVendorVerificationService instance =
      MsmeVendorVerificationService._();

  /// Verifies the MSME status for the given [udyamNumber].
  ///
  /// Returns a [MsmeVerificationResult] indicating verification status.
  /// Currently returns a mock response; real implementation would call
  /// the Udyam Registration Portal API.
  Future<MsmeVerificationResult> verifyMsmeStatus(String udyamNumber) async {
    // Mock implementation — production would call Udyam API
    if (udyamNumber.isEmpty) {
      return MsmeVerificationResult(
        udyamNumber: udyamNumber,
        isVerified: false,
        category: '',
        enterpriseName: '',
      );
    }
    return MsmeVerificationResult(
      udyamNumber: udyamNumber,
      isVerified: true,
      category: 'MICRO',
      enterpriseName: 'Mock Enterprise',
    );
  }
}
