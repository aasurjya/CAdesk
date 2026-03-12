/// Immutable model for FC-GPR (Foreign Currency - Gross Provisional Return).
///
/// FC-GPR must be filed with RBI within 30 days of allotment of shares/
/// compulsorily convertible instruments to foreign investors.
///
/// Filing deadline: 30 days from date of allotment (FEMA Regulation 9(1)(A)).
/// Failure to file within deadline attracts penalty under FEMA.
class FcGpr {
  FcGpr({
    required this.entityName,
    required this.cin,
    required this.fipbRouteApproval,
    required this.dateOfReceipt,
    required this.sharesAllotted,
    required this.faceValuePaise,
    required this.issuePricePaise,
    required this.premiumAmountPaise,
    required this.totalInflowPaise,
    required this.foreignInvestorCountry,
  });

  final String entityName;

  /// Corporate Identification Number (CIN) of the Indian entity.
  final String cin;

  /// Whether FIPB (Foreign Investment Promotion Board) route approval was obtained.
  /// FIPB has been abolished; approval now from competent authority.
  final bool fipbRouteApproval;

  /// Date of receipt of inward remittance.
  final DateTime dateOfReceipt;

  /// Number of equity shares/instruments allotted.
  final int sharesAllotted;

  /// Face value per share in paise.
  final int faceValuePaise;

  /// Issue price per share in paise (must be >= FMV for equity).
  final int issuePricePaise;

  /// Share premium per share in paise (issue price minus face value).
  final int premiumAmountPaise;

  /// Total foreign currency inflow in paise.
  final int totalInflowPaise;

  /// ISO 3166-1 alpha-3 country code of the foreign investor (e.g. 'USA', 'GBR').
  final String foreignInvestorCountry;

  FcGpr copyWith({
    String? entityName,
    String? cin,
    bool? fipbRouteApproval,
    DateTime? dateOfReceipt,
    int? sharesAllotted,
    int? faceValuePaise,
    int? issuePricePaise,
    int? premiumAmountPaise,
    int? totalInflowPaise,
    String? foreignInvestorCountry,
  }) {
    return FcGpr(
      entityName: entityName ?? this.entityName,
      cin: cin ?? this.cin,
      fipbRouteApproval: fipbRouteApproval ?? this.fipbRouteApproval,
      dateOfReceipt: dateOfReceipt ?? this.dateOfReceipt,
      sharesAllotted: sharesAllotted ?? this.sharesAllotted,
      faceValuePaise: faceValuePaise ?? this.faceValuePaise,
      issuePricePaise: issuePricePaise ?? this.issuePricePaise,
      premiumAmountPaise: premiumAmountPaise ?? this.premiumAmountPaise,
      totalInflowPaise: totalInflowPaise ?? this.totalInflowPaise,
      foreignInvestorCountry:
          foreignInvestorCountry ?? this.foreignInvestorCountry,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FcGpr &&
        other.entityName == entityName &&
        other.cin == cin &&
        other.fipbRouteApproval == fipbRouteApproval &&
        other.dateOfReceipt == dateOfReceipt &&
        other.sharesAllotted == sharesAllotted &&
        other.faceValuePaise == faceValuePaise &&
        other.issuePricePaise == issuePricePaise &&
        other.premiumAmountPaise == premiumAmountPaise &&
        other.totalInflowPaise == totalInflowPaise &&
        other.foreignInvestorCountry == foreignInvestorCountry;
  }

  @override
  int get hashCode => Object.hash(
    entityName,
    cin,
    fipbRouteApproval,
    dateOfReceipt,
    sharesAllotted,
    faceValuePaise,
    issuePricePaise,
    premiumAmountPaise,
    totalInflowPaise,
    foreignInvestorCountry,
  );
}
