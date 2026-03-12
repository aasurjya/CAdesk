import 'package:flutter/foundation.dart';

/// Type of foreign asset as per Schedule FA of ITR-2.
enum ForeignAssetType {
  /// Bank account in a foreign country (Schedule FA-A1).
  bankAccount('Bank Account'),

  /// Equity shares or debt interest in a foreign entity (Schedule FA-A2).
  equityShares('Equity Shares'),

  /// Immovable property situated outside India (Schedule FA-A3).
  immovableProperty('Immovable Property'),

  /// Any other capital asset outside India (Schedule FA-A4).
  otherCapitalAsset('Other Capital Asset'),

  /// Financial interest in any entity outside India (Schedule FA-B).
  financialInterest('Financial Interest'),

  /// Any account (other than bank account) outside India (Schedule FA-C).
  otherAccount('Other Account'),

  /// Any trust outside India in which the assessee is a trustee/beneficiary
  /// (Schedule FA-D).
  foreignTrust('Foreign Trust');

  const ForeignAssetType(this.label);

  /// Display label for the asset type.
  final String label;
}

/// Immutable model for a single foreign asset entry in Schedule FA.
///
/// Schedule FA is mandatory for residents (ordinarily resident) who hold
/// any asset outside India or have signing authority in any account
/// located outside India.
class ForeignAsset {
  const ForeignAsset({
    required this.countryCode,
    required this.countryName,
    required this.assetType,
    required this.description,
    required this.valueInForeignCurrency,
    required this.exchangeRate,
    required this.acquisitionDate,
    required this.incomeDerived,
    required this.incomeOffered,
  });

  /// ISO 3166-1 alpha-2 country code (e.g., 'US', 'GB', 'SG').
  final String countryCode;

  /// Full name of the country where the asset is located.
  final String countryName;

  /// Type of foreign asset per Schedule FA categorisation.
  final ForeignAssetType assetType;

  /// Description of the specific asset (e.g., account number, property address).
  final String description;

  /// Peak value / closing balance in the foreign currency.
  final double valueInForeignCurrency;

  /// RBI reference exchange rate (foreign currency to INR) as on closing date.
  final double exchangeRate;

  /// Date of acquisition (ISO-8601 date string, e.g. '2020-06-01').
  final String acquisitionDate;

  /// Income derived from the foreign asset during the year (in INR).
  final double incomeDerived;

  /// Income offered to tax in India (in INR).
  final double incomeOffered;

  /// Asset value converted to Indian Rupees using [exchangeRate].
  double get valueInINR => valueInForeignCurrency * exchangeRate;

  ForeignAsset copyWith({
    String? countryCode,
    String? countryName,
    ForeignAssetType? assetType,
    String? description,
    double? valueInForeignCurrency,
    double? exchangeRate,
    String? acquisitionDate,
    double? incomeDerived,
    double? incomeOffered,
  }) {
    return ForeignAsset(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      assetType: assetType ?? this.assetType,
      description: description ?? this.description,
      valueInForeignCurrency:
          valueInForeignCurrency ?? this.valueInForeignCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      incomeDerived: incomeDerived ?? this.incomeDerived,
      incomeOffered: incomeOffered ?? this.incomeOffered,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForeignAsset &&
        other.countryCode == countryCode &&
        other.countryName == countryName &&
        other.assetType == assetType &&
        other.description == description &&
        other.valueInForeignCurrency == valueInForeignCurrency &&
        other.exchangeRate == exchangeRate &&
        other.acquisitionDate == acquisitionDate &&
        other.incomeDerived == incomeDerived &&
        other.incomeOffered == incomeOffered;
  }

  @override
  int get hashCode => Object.hash(
    countryCode,
    countryName,
    assetType,
    description,
    valueInForeignCurrency,
    exchangeRate,
    acquisitionDate,
    incomeDerived,
    incomeOffered,
  );
}

/// Immutable aggregate model for Schedule FA (Foreign Assets).
///
/// Required for resident assessees (ordinarily resident) who hold
/// foreign assets or have signing authority outside India.
class ForeignAssetSchedule {
  const ForeignAssetSchedule({required this.assets});

  /// All foreign asset entries.
  final List<ForeignAsset> assets;

  /// Total aggregate value of all foreign assets in INR.
  double get totalValueInINR =>
      assets.fold(0.0, (sum, a) => sum + a.valueInINR);

  /// Total income derived from all foreign assets during the year.
  double get totalIncomeDerived =>
      assets.fold(0.0, (sum, a) => sum + a.incomeDerived);

  /// Total income offered to tax in India from foreign assets.
  double get totalIncomeOffered =>
      assets.fold(0.0, (sum, a) => sum + a.incomeOffered);

  ForeignAssetSchedule copyWith({List<ForeignAsset>? assets}) {
    return ForeignAssetSchedule(assets: assets ?? this.assets);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForeignAssetSchedule && listEquals(other.assets, assets);
  }

  @override
  int get hashCode => Object.hashAll(assets);
}
