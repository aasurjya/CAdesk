/// Immutable model for a TDS challan verification record from TRACES/OLTAS.
class ChallanStatus {
  const ChallanStatus({
    required this.bsrCode,
    required this.challanDate,
    required this.challanSerial,
    required this.amountPaise,
    required this.section,
    required this.isVerified,
    this.cinNumber,
  });

  /// BSR code of the bank branch where challan was deposited.
  final String bsrCode;

  /// Date of challan deposit.
  final DateTime challanDate;

  /// Challan serial number.
  final String challanSerial;

  /// Challan amount in paise.
  final int amountPaise;

  /// Section under which TDS was deposited (e.g., '194A', '192').
  final String section;

  /// Whether the challan has been verified in OLTAS.
  final bool isVerified;

  /// CIN (Challan Identification Number) assigned after verification.
  final String? cinNumber;

  ChallanStatus copyWith({
    String? bsrCode,
    DateTime? challanDate,
    String? challanSerial,
    int? amountPaise,
    String? section,
    bool? isVerified,
    String? cinNumber,
  }) {
    return ChallanStatus(
      bsrCode: bsrCode ?? this.bsrCode,
      challanDate: challanDate ?? this.challanDate,
      challanSerial: challanSerial ?? this.challanSerial,
      amountPaise: amountPaise ?? this.amountPaise,
      section: section ?? this.section,
      isVerified: isVerified ?? this.isVerified,
      cinNumber: cinNumber ?? this.cinNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallanStatus &&
        other.bsrCode == bsrCode &&
        other.challanDate == challanDate &&
        other.challanSerial == challanSerial &&
        other.amountPaise == amountPaise &&
        other.section == section &&
        other.isVerified == isVerified &&
        other.cinNumber == cinNumber;
  }

  @override
  int get hashCode => Object.hash(
    bsrCode,
    challanDate,
    challanSerial,
    amountPaise,
    section,
    isVerified,
    cinNumber,
  );
}
