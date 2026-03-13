// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Legal entity type of the client.
enum ClientType { individual, huf, firm, company, trust }

/// Income tax regime chosen by the client.
enum TaxRegime { old, newRegime }

/// Age group bucket for the individual client.
enum AgeGroup { under30, thirties, forties, fifties, above60 }

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Immutable financial profile of a client used by the opportunity scanner.
///
/// All monetary amounts are expressed in **paise** (1 ₹ = 100 paise).
class ClientProfile {
  const ClientProfile({
    required this.pan,
    required this.name,
    required this.clientType,
    required this.annualIncome,
    required this.taxRegime,
    required this.currentDeductions,
    required this.currentTaxPaid,
    required this.hasGstRegistration,
    required this.hasTdsDeductions,
    required this.hasCapitalGains,
    required this.hasForeignAssets,
    required this.hasBusinessIncome,
    required this.ageGroup,
  });

  /// 10-character PAN (e.g. ABCDE1234F).
  final String pan;

  /// Client's full name.
  final String name;

  /// Entity type.
  final ClientType clientType;

  /// Gross annual income in paise.
  final int annualIncome;

  /// Tax regime in effect for the current financial year.
  final TaxRegime taxRegime;

  /// Total deductions already claimed in paise (e.g. 80C, 80D invested so far).
  final int currentDeductions;

  /// Total tax already paid (TDS + advance tax) in paise.
  final int currentTaxPaid;

  /// Whether the client is registered under GST.
  final bool hasGstRegistration;

  /// Whether TDS has been deducted from client's income.
  final bool hasTdsDeductions;

  /// Whether the client has capital gains / losses this year.
  final bool hasCapitalGains;

  /// Whether the client holds foreign assets (Schedule FA / FA disclosure).
  final bool hasForeignAssets;

  /// Whether the client has income from business or profession.
  final bool hasBusinessIncome;

  /// Age group — used for senior citizen benefits (80TTB, higher 80D limit).
  final AgeGroup ageGroup;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  ClientProfile copyWith({
    String? pan,
    String? name,
    ClientType? clientType,
    int? annualIncome,
    TaxRegime? taxRegime,
    int? currentDeductions,
    int? currentTaxPaid,
    bool? hasGstRegistration,
    bool? hasTdsDeductions,
    bool? hasCapitalGains,
    bool? hasForeignAssets,
    bool? hasBusinessIncome,
    AgeGroup? ageGroup,
  }) {
    return ClientProfile(
      pan: pan ?? this.pan,
      name: name ?? this.name,
      clientType: clientType ?? this.clientType,
      annualIncome: annualIncome ?? this.annualIncome,
      taxRegime: taxRegime ?? this.taxRegime,
      currentDeductions: currentDeductions ?? this.currentDeductions,
      currentTaxPaid: currentTaxPaid ?? this.currentTaxPaid,
      hasGstRegistration: hasGstRegistration ?? this.hasGstRegistration,
      hasTdsDeductions: hasTdsDeductions ?? this.hasTdsDeductions,
      hasCapitalGains: hasCapitalGains ?? this.hasCapitalGains,
      hasForeignAssets: hasForeignAssets ?? this.hasForeignAssets,
      hasBusinessIncome: hasBusinessIncome ?? this.hasBusinessIncome,
      ageGroup: ageGroup ?? this.ageGroup,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientProfile &&
          runtimeType == other.runtimeType &&
          pan == other.pan;

  @override
  int get hashCode => pan.hashCode;
}
