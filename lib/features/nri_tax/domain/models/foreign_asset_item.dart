import 'package:flutter/foundation.dart';

/// Category of a foreign asset for Schedule FA reporting.
enum ForeignAssetCategory {
  bankAccount('Bank Account'),
  equity('Equity / Stocks'),
  debt('Debt Instruments'),
  immovableProperty('Immovable Property'),
  insurance('Insurance Policy'),
  other('Other Asset');

  const ForeignAssetCategory(this.label);
  final String label;
}

/// Immutable model representing a single foreign asset held by an NRI/resident
/// taxpayer, for Schedule FA disclosure in the Income Tax Return.
///
/// All monetary values are in **paise** (1/100 of Indian Rupee).
///
/// Note: This is separate from the existing [ForeignAsset] model in the same
/// feature, which serves the presentation layer with INR double values and
/// UI metadata. [ForeignAssetItem] is the domain-layer model with strict
/// integer paise amounts.
@immutable
class ForeignAssetItem {
  const ForeignAssetItem({
    required this.assetType,
    required this.country,
    required this.institution,
    required this.accountNumber,
    required this.peakValue,
    required this.closingValue,
    required this.incomeAccrued,
  });

  /// Category of the foreign asset.
  final ForeignAssetCategory assetType;

  /// ISO alpha-2 country code where the asset is held (e.g. "US", "GB").
  final String country;

  /// Name of the financial institution or custodian.
  final String institution;

  /// Account / security number — must be masked (e.g. "****1234").
  final String accountNumber;

  /// Maximum value of the asset during the financial year, in paise.
  final int peakValue;

  /// Closing balance / value at year-end, in paise.
  final int closingValue;

  /// Income accrued from this asset during the year, in paise.
  final int incomeAccrued;

  ForeignAssetItem copyWith({
    ForeignAssetCategory? assetType,
    String? country,
    String? institution,
    String? accountNumber,
    int? peakValue,
    int? closingValue,
    int? incomeAccrued,
  }) {
    return ForeignAssetItem(
      assetType: assetType ?? this.assetType,
      country: country ?? this.country,
      institution: institution ?? this.institution,
      accountNumber: accountNumber ?? this.accountNumber,
      peakValue: peakValue ?? this.peakValue,
      closingValue: closingValue ?? this.closingValue,
      incomeAccrued: incomeAccrued ?? this.incomeAccrued,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForeignAssetItem &&
          runtimeType == other.runtimeType &&
          assetType == other.assetType &&
          country == other.country &&
          institution == other.institution &&
          accountNumber == other.accountNumber &&
          peakValue == other.peakValue &&
          closingValue == other.closingValue &&
          incomeAccrued == other.incomeAccrued;

  @override
  int get hashCode => Object.hash(
        assetType,
        country,
        institution,
        accountNumber,
        peakValue,
        closingValue,
        incomeAccrued,
      );

  @override
  String toString() =>
      'ForeignAssetItem(type: ${assetType.label}, country: $country, '
      'closing: $closingValue paise)';
}
