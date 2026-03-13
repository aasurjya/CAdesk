import 'package:flutter/material.dart';

/// Immutable model representing a persisted VDA (Virtual Digital Asset /
/// Crypto) transaction record for data-layer purposes.
///
/// This covers Schedule VDA reporting and TDS u/s 194S tracking.
/// Distinct from the computation-focused [VdaTransaction] model.
@immutable
class VdaRecord {
  const VdaRecord({
    required this.id,
    required this.clientId,
    required this.transactionDate,
    required this.assetType,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.gainLoss,
    required this.tdsDeducted,
    required this.assessmentYear,
    this.exchange,
  });

  final String id;
  final String clientId;

  final DateTime transactionDate;

  /// Type of VDA (e.g. "Bitcoin", "Ethereum", "NFT", "Token").
  final String assetType;

  /// Purchase price per unit in INR.
  final double buyPrice;

  /// Sale price per unit in INR.
  final double sellPrice;

  /// Quantity of units transacted.
  final double quantity;

  /// Net gain (positive) or loss (negative) in INR.
  final double gainLoss;

  /// TDS deducted u/s 194S in INR.
  final double tdsDeducted;

  /// Name of the exchange / platform used.
  final String? exchange;

  /// Assessment year in "YYYY-YY" format, e.g. "2024-25".
  final String assessmentYear;

  VdaRecord copyWith({
    String? id,
    String? clientId,
    DateTime? transactionDate,
    String? assetType,
    double? buyPrice,
    double? sellPrice,
    double? quantity,
    double? gainLoss,
    double? tdsDeducted,
    String? exchange,
    String? assessmentYear,
  }) {
    return VdaRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      transactionDate: transactionDate ?? this.transactionDate,
      assetType: assetType ?? this.assetType,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
      gainLoss: gainLoss ?? this.gainLoss,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      exchange: exchange ?? this.exchange,
      assessmentYear: assessmentYear ?? this.assessmentYear,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VdaRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          transactionDate == other.transactionDate &&
          assetType == other.assetType &&
          buyPrice == other.buyPrice &&
          sellPrice == other.sellPrice &&
          quantity == other.quantity &&
          gainLoss == other.gainLoss &&
          tdsDeducted == other.tdsDeducted &&
          exchange == other.exchange &&
          assessmentYear == other.assessmentYear;

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    transactionDate,
    assetType,
    buyPrice,
    sellPrice,
    quantity,
    gainLoss,
    tdsDeducted,
    exchange,
    assessmentYear,
  );

  @override
  String toString() =>
      'VdaRecord(id: $id, clientId: $clientId, '
      'asset: $assetType, gainLoss: $gainLoss, '
      'ay: $assessmentYear)';
}
