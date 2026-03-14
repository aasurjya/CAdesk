/// The channel through which a one-time password is delivered.
enum OtpChannel {
  sms('SMS'),
  aadhaarOtp('Aadhaar OTP'),
  totp('Authenticator App'),
  email('Email');

  const OtpChannel(this.label);

  /// Human-readable label for display in the OTP dialog.
  final String label;
}
