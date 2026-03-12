import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:flutter/foundation.dart';

/// Immutable grouping of a challan and its associated deductee records.
@immutable
class FvuChallanWithDeductees {
  const FvuChallanWithDeductees({
    required this.challan,
    required this.deductees,
  });

  /// The CD (challan detail) record.
  final FvuChallanRecord challan;

  /// The DD (deductee detail) records under this challan.
  final List<FvuDeducteeRecord> deductees;

  FvuChallanWithDeductees copyWith({
    FvuChallanRecord? challan,
    List<FvuDeducteeRecord>? deductees,
  }) {
    return FvuChallanWithDeductees(
      challan: challan ?? this.challan,
      deductees: deductees ?? this.deductees,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FvuChallanWithDeductees &&
          runtimeType == other.runtimeType &&
          challan == other.challan &&
          _listEquals(deductees, other.deductees);

  @override
  int get hashCode => Object.hash(challan, Object.hashAll(deductees));

  @override
  String toString() =>
      'FvuChallanWithDeductees(challan: $challan, '
      'deductees: ${deductees.length})';
}

/// Immutable model representing the complete structure of an FVU file.
///
/// Consists of a batch header (BH), one or more challan groups (CD + DD),
/// and an implied trailer (BT) computed from the data.
@immutable
class FvuFileStructure {
  const FvuFileStructure({required this.batchHeader, required this.challans});

  /// Batch header (BH) record with deductor info and totals.
  final FvuBatchHeader batchHeader;

  /// Ordered list of challan groups, each with associated deductee records.
  final List<FvuChallanWithDeductees> challans;

  // ---------------------------------------------------------------------------
  // Computed
  // ---------------------------------------------------------------------------

  /// Total number of challan records.
  int get totalChallanCount => challans.length;

  /// Total number of deductee records across all challans.
  int get totalDeducteeCount =>
      challans.fold(0, (sum, c) => sum + c.deductees.length);

  /// Sum of all TDS amounts across all deductee records.
  double get totalTaxDeducted => challans.fold(
    0.0,
    (sum, c) => sum + c.deductees.fold(0.0, (s, d) => s + d.tdsAmount),
  );

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  FvuFileStructure copyWith({
    FvuBatchHeader? batchHeader,
    List<FvuChallanWithDeductees>? challans,
  }) {
    return FvuFileStructure(
      batchHeader: batchHeader ?? this.batchHeader,
      challans: challans ?? this.challans,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FvuFileStructure &&
          runtimeType == other.runtimeType &&
          batchHeader == other.batchHeader &&
          _listEquals(challans, other.challans);

  @override
  int get hashCode => Object.hash(batchHeader, Object.hashAll(challans));

  @override
  String toString() =>
      'FvuFileStructure(tan: ${batchHeader.tan}, '
      'challans: $totalChallanCount, deductees: $totalDeducteeCount)';
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
