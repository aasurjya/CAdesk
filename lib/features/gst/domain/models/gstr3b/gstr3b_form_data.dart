import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';

/// Immutable top-level aggregator for a GSTR-3B return.
///
/// GSTR-3B is a monthly summary return combining outward tax liability
/// and inward ITC claims. It is filed before GSTR-1 and results in
/// the net tax payable or ITC carry-forward for the period.
class Gstr3bFormData {
  const Gstr3bFormData({
    required this.gstin,
    required this.periodMonth,
    required this.periodYear,
    required this.taxLiability,
    required this.itcClaimed,
    required this.exemptSupplies,
  });

  /// GSTIN of the registered taxpayer filing this return.
  final String gstin;

  /// Tax period month (1–12).
  final int periodMonth;

  /// Tax period year.
  final int periodYear;

  /// Table 3.1: Tax on outward + reverse charge inward supplies.
  final Gstr3bTaxLiability taxLiability;

  /// Table 4: Eligible ITC (available, reversed, net).
  final Gstr3bItcClaimed itcClaimed;

  /// Table 3.2: Exempt, nil-rated, and non-GST outward supplies.
  final Gstr3bExemptSupplies exemptSupplies;

  /// Human-readable period label (e.g. 'Jan 2026').
  String get periodLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[periodMonth - 1]} $periodYear';
  }

  /// Net tax payable = total tax liability - net ITC available.
  ///
  /// Positive value means tax due; negative means ITC carry-forward.
  double get netTaxPayable =>
      taxLiability.totalTaxLiability - itcClaimed.netItcAvailable.totalItc;

  Gstr3bFormData copyWith({
    String? gstin,
    int? periodMonth,
    int? periodYear,
    Gstr3bTaxLiability? taxLiability,
    Gstr3bItcClaimed? itcClaimed,
    Gstr3bExemptSupplies? exemptSupplies,
  }) {
    return Gstr3bFormData(
      gstin: gstin ?? this.gstin,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      taxLiability: taxLiability ?? this.taxLiability,
      itcClaimed: itcClaimed ?? this.itcClaimed,
      exemptSupplies: exemptSupplies ?? this.exemptSupplies,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr3bFormData &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          periodMonth == other.periodMonth &&
          periodYear == other.periodYear;

  @override
  int get hashCode => Object.hash(gstin, periodMonth, periodYear);
}
