/// Immutable model for personal and contact information in ITR-1 (Sahaj).
class PersonalInfo {
  const PersonalInfo({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.pan,
    required this.aadhaarNumber,
    required this.dateOfBirth,
    required this.email,
    required this.mobile,
    required this.flatDoorBlock,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.employerName,
    required this.employerTan,
    required this.bankAccountNumber,
    required this.bankIfsc,
    required this.bankName,
  });

  factory PersonalInfo.empty() => PersonalInfo(
    firstName: '',
    middleName: '',
    lastName: '',
    pan: '',
    aadhaarNumber: '',
    dateOfBirth: DateTime(1990),
    email: '',
    mobile: '',
    flatDoorBlock: '',
    street: '',
    city: '',
    state: '',
    pincode: '',
    employerName: '',
    employerTan: '',
    bankAccountNumber: '',
    bankIfsc: '',
    bankName: '',
  );

  final String firstName;
  final String middleName;
  final String lastName;
  final String pan;
  final String aadhaarNumber;
  final DateTime dateOfBirth;
  final String email;
  final String mobile;
  final String flatDoorBlock;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String employerName;
  final String employerTan;
  final String bankAccountNumber;
  final String bankIfsc;
  final String bankName;

  /// Full name assembled from name parts.
  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((p) => p.trim().isNotEmpty).toList();
    return parts.join(' ');
  }

  PersonalInfo copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? pan,
    String? aadhaarNumber,
    DateTime? dateOfBirth,
    String? email,
    String? mobile,
    String? flatDoorBlock,
    String? street,
    String? city,
    String? state,
    String? pincode,
    String? employerName,
    String? employerTan,
    String? bankAccountNumber,
    String? bankIfsc,
    String? bankName,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      pan: pan ?? this.pan,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      flatDoorBlock: flatDoorBlock ?? this.flatDoorBlock,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      employerName: employerName ?? this.employerName,
      employerTan: employerTan ?? this.employerTan,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      bankName: bankName ?? this.bankName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalInfo &&
        other.firstName == firstName &&
        other.middleName == middleName &&
        other.lastName == lastName &&
        other.pan == pan &&
        other.aadhaarNumber == aadhaarNumber &&
        other.dateOfBirth == dateOfBirth &&
        other.email == email &&
        other.mobile == mobile &&
        other.flatDoorBlock == flatDoorBlock &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.pincode == pincode &&
        other.employerName == employerName &&
        other.employerTan == employerTan &&
        other.bankAccountNumber == bankAccountNumber &&
        other.bankIfsc == bankIfsc &&
        other.bankName == bankName;
  }

  @override
  int get hashCode => Object.hash(
    firstName,
    middleName,
    lastName,
    pan,
    aadhaarNumber,
    dateOfBirth,
    email,
    mobile,
    flatDoorBlock,
    street,
    city,
    state,
    pincode,
    employerName,
    employerTan,
    bankAccountNumber,
    bankIfsc,
    bankName,
  );
}
