/// Booking / matching status of a TDS challan on the TRACES portal.
///
/// - [matched]          — Challan fully matched to TDS returns (code "F")
/// - [unmatched]        — Challan deposited but not yet matched (code "U")
/// - [bookingConfirmed] — Booking confirmed by bank / CPC-TDS (code "B")
/// - [overBooked]       — Claims exceed the deposited amount (code "O")
enum ChallanBookingStatus { matched, unmatched, bookingConfirmed, overBooked }

/// Immutable snapshot of a TDS challan as returned by the TRACES API.
///
/// All monetary amounts are in **paise** (1/100 of a rupee) to avoid
/// floating-point rounding errors.
class TracesChallanStatus {
  const TracesChallanStatus({
    required this.bsrCode,
    required this.challanDate,
    required this.challanSerial,
    required this.tan,
    required this.section,
    required this.depositedAmount,
    required this.status,
    required this.consumedAmount,
    required this.balanceAmount,
  });

  /// 7-digit BSR code of the receiving bank branch.
  final String bsrCode;

  /// Date the challan was deposited with the bank.
  final DateTime challanDate;

  /// 5-digit serial number assigned by the bank.
  final String challanSerial;

  /// TAN of the deductor who deposited the challan.
  final String tan;

  /// Income-tax section under which TDS was deducted (e.g. "192", "194C").
  final String section;

  /// Total amount deposited in the challan, in paise.
  final int depositedAmount;

  /// Current booking / matching status.
  final ChallanBookingStatus status;

  /// Amount already consumed / claimed against this challan, in paise.
  final int consumedAmount;

  /// Remaining balance (depositedAmount − consumedAmount), in paise.
  final int balanceAmount;

  /// Returns a new [TracesChallanStatus] with selected fields replaced.
  TracesChallanStatus copyWith({
    String? bsrCode,
    DateTime? challanDate,
    String? challanSerial,
    String? tan,
    String? section,
    int? depositedAmount,
    ChallanBookingStatus? status,
    int? consumedAmount,
    int? balanceAmount,
  }) {
    return TracesChallanStatus(
      bsrCode: bsrCode ?? this.bsrCode,
      challanDate: challanDate ?? this.challanDate,
      challanSerial: challanSerial ?? this.challanSerial,
      tan: tan ?? this.tan,
      section: section ?? this.section,
      depositedAmount: depositedAmount ?? this.depositedAmount,
      status: status ?? this.status,
      consumedAmount: consumedAmount ?? this.consumedAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TracesChallanStatus &&
        other.bsrCode == bsrCode &&
        other.challanDate == challanDate &&
        other.challanSerial == challanSerial &&
        other.tan == tan &&
        other.section == section &&
        other.depositedAmount == depositedAmount &&
        other.status == status &&
        other.consumedAmount == consumedAmount &&
        other.balanceAmount == balanceAmount;
  }

  @override
  int get hashCode => Object.hash(
        bsrCode,
        challanDate,
        challanSerial,
        tan,
        section,
        depositedAmount,
        status,
        consumedAmount,
        balanceAmount,
      );
}
