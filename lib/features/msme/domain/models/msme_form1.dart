import 'package:ca_app/features/msme/domain/models/msme_payment_tracker.dart';

/// Immutable model for MSME Form-1 (Half-Yearly Return).
///
/// All companies having turnover exceeding ₹500 crore and having received
/// goods or services from micro and small enterprises and whose payment
/// to micro and small enterprise suppliers is due and remains unpaid
/// must file this return with MCA half-yearly.
///
/// Periods: April–September (filed by October 31) and
///          October–March (filed by April 30).
class MsmeForm1 {
  const MsmeForm1({required this.period, required this.unpaidEntries});

  /// Half-year period identifier, e.g. 'H1-2024' or 'H2-2024'.
  final String period;

  /// List of MSME payment entries that remain unpaid as of period end.
  final List<MsmePaymentTracker> unpaidEntries;

  MsmeForm1 copyWith({
    String? period,
    List<MsmePaymentTracker>? unpaidEntries,
  }) {
    return MsmeForm1(
      period: period ?? this.period,
      unpaidEntries: unpaidEntries ?? this.unpaidEntries,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MsmeForm1) return false;
    if (other.period != period) return false;
    if (other.unpaidEntries.length != unpaidEntries.length) return false;
    for (var i = 0; i < unpaidEntries.length; i++) {
      if (other.unpaidEntries[i] != unpaidEntries[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(period, Object.hashAll(unpaidEntries));
}
