import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';
import 'package:flutter/foundation.dart';

/// Immutable aggregate model for data parsed from a GSTR-2B JSON download.
///
/// All credit amounts are stored in **paise** (1 rupee = 100 paise).
@immutable
class Gstr2bData {
  const Gstr2bData({
    required this.gstin,
    required this.returnPeriod,
    required this.b2bEntries,
    required this.totalIgstCredit,
    required this.totalCgstCredit,
    required this.totalSgstCredit,
  });

  /// GSTIN of the recipient taxpayer.
  final String gstin;

  /// Return period in "MMYYYY" format (e.g. "012024" for January 2024).
  final String returnPeriod;

  /// B2B invoice entries from the GSTR-2B document.
  final List<Gstr2bEntry> b2bEntries;

  /// Total IGST ITC available across all entries, in paise.
  final int totalIgstCredit;

  /// Total CGST ITC available across all entries, in paise.
  final int totalCgstCredit;

  /// Total SGST ITC available across all entries, in paise.
  final int totalSgstCredit;

  /// Combined ITC credit (IGST + CGST + SGST), in paise.
  int get totalItcCredit => totalIgstCredit + totalCgstCredit + totalSgstCredit;

  Gstr2bData copyWith({
    String? gstin,
    String? returnPeriod,
    List<Gstr2bEntry>? b2bEntries,
    int? totalIgstCredit,
    int? totalCgstCredit,
    int? totalSgstCredit,
  }) {
    return Gstr2bData(
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      b2bEntries: b2bEntries ?? this.b2bEntries,
      totalIgstCredit: totalIgstCredit ?? this.totalIgstCredit,
      totalCgstCredit: totalCgstCredit ?? this.totalCgstCredit,
      totalSgstCredit: totalSgstCredit ?? this.totalSgstCredit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr2bData &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          returnPeriod == other.returnPeriod &&
          totalIgstCredit == other.totalIgstCredit &&
          totalCgstCredit == other.totalCgstCredit &&
          totalSgstCredit == other.totalSgstCredit;

  @override
  int get hashCode => Object.hash(
    gstin,
    returnPeriod,
    totalIgstCredit,
    totalCgstCredit,
    totalSgstCredit,
  );

  @override
  String toString() =>
      'Gstr2bData(gstin: $gstin, period: $returnPeriod, '
      'b2bEntries: ${b2bEntries.length}, totalItc: $totalItcCredit)';
}
