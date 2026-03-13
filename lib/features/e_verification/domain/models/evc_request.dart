/// EVC generation method as supported by the Income Tax Department.
enum EvcMethod {
  netBanking('Net Banking'),
  demat('Demat Account'),
  aadhaarOtp('Aadhaar OTP'),
  bankAtm('Bank ATM'),
  prevalidatedBank('Pre-validated Bank Account');

  const EvcMethod(this.label);

  final String label;
}

/// Lifecycle status of an EVC request.
enum EvcStatus {
  pending('Pending'),
  otpSent('OTP Sent'),
  verified('Verified'),
  expired('Expired'),
  failed('Failed');

  const EvcStatus(this.label);

  final String label;
}

/// Immutable model representing an Electronic Verification Code request.
class EvcRequest {
  const EvcRequest({
    required this.pan,
    required this.mobile,
    required this.email,
    required this.evcMethod,
    required this.status,
    this.otp,
    this.otpExpiry,
  });

  /// PAN of the taxpayer initiating e-verification.
  final String pan;

  /// Masked mobile number (e.g. "XXXXXX7890").
  final String mobile;

  /// Masked email address (e.g. "te***@gmail.com").
  final String email;

  final EvcMethod evcMethod;

  /// 6-digit OTP. Null until generated.
  final String? otp;

  /// Expiry timestamp for the OTP (now + 15 min). Null until OTP generated.
  final DateTime? otpExpiry;

  final EvcStatus status;

  // ── copyWith ──────────────────────────────────────────────────────────

  EvcRequest copyWith({
    String? pan,
    String? mobile,
    String? email,
    EvcMethod? evcMethod,
    String? otp,
    DateTime? otpExpiry,
    EvcStatus? status,
  }) {
    return EvcRequest(
      pan: pan ?? this.pan,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      evcMethod: evcMethod ?? this.evcMethod,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      status: status ?? this.status,
    );
  }

  // ── Equality ─────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EvcRequest) return false;
    return other.pan == pan &&
        other.mobile == mobile &&
        other.email == email &&
        other.evcMethod == evcMethod &&
        other.otp == otp &&
        other.otpExpiry == otpExpiry &&
        other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(pan, mobile, email, evcMethod, otp, otpExpiry, status);
}
