/// Registration/operational status of a company on the MCA portal.
enum McaCompanyStatus {
  active,
  dormant,
  strikedOff,
  underLiquidation,
  amalgamated,
}

/// Immutable result of a CIN or name lookup on the MCA portal.
///
/// All monetary values (authorizedCapital, paidUpCapital) are in paise.
class McaCompanyLookup {
  const McaCompanyLookup({
    required this.cin,
    required this.companyName,
    required this.registeredOfficeAddress,
    required this.state,
    required this.dateOfIncorporation,
    required this.status,
    required this.authorizedCapital,
    required this.paidUpCapital,
    required this.companyCategory,
    required this.companySubCategory,
    required this.roc,
  });

  /// 21-character Corporate Identification Number.
  /// Format: [LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}
  final String cin;

  final String companyName;
  final String registeredOfficeAddress;

  /// Two-letter state code (e.g. "MH", "DL", "KA").
  final String state;

  final DateTime dateOfIncorporation;
  final McaCompanyStatus status;

  /// Authorized share capital in paise.
  final int authorizedCapital;

  /// Paid-up share capital in paise.
  final int paidUpCapital;

  /// e.g. "Company limited by Shares"
  final String companyCategory;

  /// e.g. "Indian Non-Government Company"
  final String companySubCategory;

  /// Registrar of Companies office (e.g. "RoC-Mumbai").
  final String roc;

  McaCompanyLookup copyWith({
    String? cin,
    String? companyName,
    String? registeredOfficeAddress,
    String? state,
    DateTime? dateOfIncorporation,
    McaCompanyStatus? status,
    int? authorizedCapital,
    int? paidUpCapital,
    String? companyCategory,
    String? companySubCategory,
    String? roc,
  }) {
    return McaCompanyLookup(
      cin: cin ?? this.cin,
      companyName: companyName ?? this.companyName,
      registeredOfficeAddress:
          registeredOfficeAddress ?? this.registeredOfficeAddress,
      state: state ?? this.state,
      dateOfIncorporation: dateOfIncorporation ?? this.dateOfIncorporation,
      status: status ?? this.status,
      authorizedCapital: authorizedCapital ?? this.authorizedCapital,
      paidUpCapital: paidUpCapital ?? this.paidUpCapital,
      companyCategory: companyCategory ?? this.companyCategory,
      companySubCategory: companySubCategory ?? this.companySubCategory,
      roc: roc ?? this.roc,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McaCompanyLookup &&
        other.cin == cin &&
        other.companyName == companyName &&
        other.registeredOfficeAddress == registeredOfficeAddress &&
        other.state == state &&
        other.dateOfIncorporation == dateOfIncorporation &&
        other.status == status &&
        other.authorizedCapital == authorizedCapital &&
        other.paidUpCapital == paidUpCapital &&
        other.companyCategory == companyCategory &&
        other.companySubCategory == companySubCategory &&
        other.roc == roc;
  }

  @override
  int get hashCode => Object.hash(
    cin,
    companyName,
    registeredOfficeAddress,
    state,
    dateOfIncorporation,
    status,
    authorizedCapital,
    paidUpCapital,
    companyCategory,
    companySubCategory,
    roc,
  );
}
