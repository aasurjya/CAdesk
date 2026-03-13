import 'package:flutter/foundation.dart';
import 'package:ca_app/features/nri_tax/domain/models/foreign_asset_item.dart';

/// Immutable model representing a taxpayer's Schedule FA (Foreign Assets)
/// declaration as required in the Income Tax Return for residents who hold
/// foreign assets.
///
/// All monetary values are in **paise** (1/100 of Indian Rupee).
@immutable
class ForeignAssetDeclaration {
  const ForeignAssetDeclaration({
    required this.pan,
    required this.financialYear,
    required this.assets,
    required this.totalForeignAssetValue,
    required this.requiresScheduleFA,
    required this.requiresFbar,
  });

  /// PAN of the taxpayer.
  final String pan;

  /// Financial year — e.g. 2024 means FY 2023-24.
  final int financialYear;

  /// List of foreign assets held during the year.
  final List<ForeignAssetItem> assets;

  /// Total closing value of all foreign assets in paise.
  final int totalForeignAssetValue;

  /// True when the taxpayer is a resident and total foreign assets > ₹5 lakh,
  /// triggering mandatory Schedule FA disclosure.
  final bool requiresScheduleFA;

  /// Foreign Bank Account Report (FBAR) — not applicable in the Indian
  /// context; always false.
  final bool requiresFbar;

  ForeignAssetDeclaration copyWith({
    String? pan,
    int? financialYear,
    List<ForeignAssetItem>? assets,
    int? totalForeignAssetValue,
    bool? requiresScheduleFA,
    bool? requiresFbar,
  }) {
    return ForeignAssetDeclaration(
      pan: pan ?? this.pan,
      financialYear: financialYear ?? this.financialYear,
      assets: assets ?? this.assets,
      totalForeignAssetValue:
          totalForeignAssetValue ?? this.totalForeignAssetValue,
      requiresScheduleFA: requiresScheduleFA ?? this.requiresScheduleFA,
      requiresFbar: requiresFbar ?? this.requiresFbar,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForeignAssetDeclaration &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          financialYear == other.financialYear &&
          totalForeignAssetValue == other.totalForeignAssetValue &&
          requiresScheduleFA == other.requiresScheduleFA &&
          requiresFbar == other.requiresFbar &&
          _listEquals(assets, other.assets);

  bool _listEquals(List<ForeignAssetItem> a, List<ForeignAssetItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    pan,
    financialYear,
    Object.hashAll(assets),
    totalForeignAssetValue,
    requiresScheduleFA,
    requiresFbar,
  );

  @override
  String toString() =>
      'ForeignAssetDeclaration(pan: $pan, fy: $financialYear, '
      'assets: ${assets.length}, total: $totalForeignAssetValue paise)';
}
