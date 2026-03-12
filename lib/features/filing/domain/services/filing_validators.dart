/// Pure validation functions for common Indian tax/identity fields.
///
/// All validators return `null` on success or an error message string on failure.
/// They are stateless and can be used in both form fields and batch validation.
class FilingValidators {
  FilingValidators._();

  // ---------------------------------------------------------------------------
  // PAN — Permanent Account Number
  // Format: AAAAA9999A (5 alpha + 4 digits + 1 alpha)
  // 4th char indicates entity type: P=Individual, C=Company, H=HUF, etc.
  // ---------------------------------------------------------------------------

  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  /// Valid PAN entity type codes (4th character).
  static const _validPanTypes = {
    'A', // Association of Persons (AOP)
    'B', // Body of Individuals (BOI)
    'C', // Company
    'F', // Firm
    'G', // Government
    'H', // HUF (Hindu Undivided Family)
    'L', // Local Authority
    'J', // Artificial Juridical Person
    'P', // Individual (Person)
    'T', // Trust (AOP)
  };

  static String? validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN is required';
    }
    final pan = value.trim().toUpperCase();
    if (pan.length != 10) return 'PAN must be exactly 10 characters';
    if (!_panRegex.hasMatch(pan)) {
      return 'Invalid PAN format (expected: ABCDE1234F)';
    }
    if (!_validPanTypes.contains(pan[3])) {
      return 'Invalid PAN entity type: ${pan[3]}';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Aadhaar — 12-digit UID with Verhoeff checksum
  // ---------------------------------------------------------------------------

  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length != 12) return 'Aadhaar must be 12 digits';
    if (!RegExp(r'^\d{12}$').hasMatch(cleaned)) {
      return 'Aadhaar must contain only digits';
    }
    if (!_verhoeffCheck(cleaned)) return 'Invalid Aadhaar checksum';
    return null;
  }

  // ---------------------------------------------------------------------------
  // IFSC — Indian Financial System Code
  // Format: 4 alpha + 0 + 6 alphanumeric (e.g. SBIN0001234)
  // ---------------------------------------------------------------------------

  static final _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  static String? validateIfsc(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final ifsc = value.trim().toUpperCase();
    if (ifsc.length != 11) return 'IFSC must be 11 characters';
    if (!_ifscRegex.hasMatch(ifsc)) {
      return 'Invalid IFSC format (expected: SBIN0001234)';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Mobile — Indian mobile number (10 digits starting 6-9)
  // ---------------------------------------------------------------------------

  static final _mobileRegex = RegExp(r'^[6-9]\d{9}$');

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final mobile = value.trim().replaceAll(RegExp(r'[\s\-+]'), '');
    // Strip +91 or 0 prefix
    final normalized = mobile.startsWith('91') && mobile.length == 12
        ? mobile.substring(2)
        : mobile.startsWith('0') && mobile.length == 11
        ? mobile.substring(1)
        : mobile;
    if (!_mobileRegex.hasMatch(normalized)) {
      return 'Invalid mobile number (10 digits starting 6-9)';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!_emailRegex.hasMatch(value.trim())) return 'Invalid email address';
    return null;
  }

  // ---------------------------------------------------------------------------
  // TAN — Tax Deduction Account Number
  // Format: 4 alpha + 5 digits + 1 alpha (e.g. MUMR12345A)
  // ---------------------------------------------------------------------------

  static final _tanRegex = RegExp(r'^[A-Z]{4}\d{5}[A-Z]$');

  static String? validateTan(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final tan = value.trim().toUpperCase();
    if (tan.length != 10) return 'TAN must be 10 characters';
    if (!_tanRegex.hasMatch(tan)) {
      return 'Invalid TAN format (expected: MUMR12345A)';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Pincode — Indian postal code (6 digits, first digit 1-9)
  // ---------------------------------------------------------------------------

  static final _pincodeRegex = RegExp(r'^[1-9]\d{5}$');

  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final pincode = value.trim();
    if (!_pincodeRegex.hasMatch(pincode)) {
      return 'Invalid pincode (6 digits, first digit 1-9)';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Verhoeff checksum algorithm for Aadhaar validation
  // ---------------------------------------------------------------------------

  static const _verhoeffD = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
  ];

  static const _verhoeffP = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];

  static bool _verhoeffCheck(String number) {
    int c = 0;
    final digits = number.split('').reversed.toList();
    for (int i = 0; i < digits.length; i++) {
      final digit = int.parse(digits[i]);
      c = _verhoeffD[c][_verhoeffP[i % 8][digit]];
    }
    return c == 0;
  }
}
