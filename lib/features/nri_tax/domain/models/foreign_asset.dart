import 'package:flutter/material.dart';

enum ForeignAssetType {
  bankAccount('Bank Account', Icons.account_balance_rounded),
  property('Property', Icons.home_rounded),
  equity('Equity / Stocks', Icons.show_chart_rounded),
  bonds('Bonds / Debentures', Icons.receipt_long_rounded),
  retirementFund('Retirement Fund', Icons.savings_rounded),
  otherAsset('Other Asset', Icons.category_rounded);

  const ForeignAssetType(this.label, this.icon);
  final String label;
  final IconData icon;
}

class ForeignAsset {
  const ForeignAsset({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.assetType,
    required this.country,
    required this.valueInr,
    required this.scheduleFARequired,
    required this.reportedInItr,
    this.incomeFromAsset,
  });

  final String id;
  final String clientId;
  final String clientName;
  final ForeignAssetType assetType;
  final String country;
  final double valueInr;
  final double? incomeFromAsset;
  final bool scheduleFARequired;
  final bool reportedInItr;

  /// Returns true when the asset value exceeds ₹5 lakh.
  bool get isHighValue => valueInr > 500000;

  String get formattedValue {
    if (valueInr >= 10000000) {
      return '₹${(valueInr / 10000000).toStringAsFixed(2)} Cr';
    } else if (valueInr >= 100000) {
      return '₹${(valueInr / 100000).toStringAsFixed(2)} L';
    }
    return '₹${valueInr.toStringAsFixed(0)}';
  }

  ForeignAsset copyWith({
    String? id,
    String? clientId,
    String? clientName,
    ForeignAssetType? assetType,
    String? country,
    double? valueInr,
    double? incomeFromAsset,
    bool? scheduleFARequired,
    bool? reportedInItr,
  }) {
    return ForeignAsset(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      assetType: assetType ?? this.assetType,
      country: country ?? this.country,
      valueInr: valueInr ?? this.valueInr,
      incomeFromAsset: incomeFromAsset ?? this.incomeFromAsset,
      scheduleFARequired: scheduleFARequired ?? this.scheduleFARequired,
      reportedInItr: reportedInItr ?? this.reportedInItr,
    );
  }
}
