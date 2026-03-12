/// Methods available for e-verification of ITR after filing.
enum VerificationMethod {
  evcNetBanking(
    label: 'EVC via Net Banking',
    description: 'Generate EVC through your net banking portal',
  ),
  evcBankAccount(
    label: 'EVC via Bank Account',
    description: 'Generate EVC using pre-validated bank account',
  ),
  aadhaarOtp(
    label: 'Aadhaar OTP',
    description: 'Verify using OTP sent to Aadhaar-linked mobile',
  ),
  dsc(
    label: 'Digital Signature (DSC)',
    description: 'Sign and submit using registered DSC',
  );

  const VerificationMethod({required this.label, required this.description});

  final String label;
  final String description;
}
