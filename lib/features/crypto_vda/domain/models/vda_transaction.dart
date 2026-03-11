import 'package:flutter/material.dart';

/// Type of virtual digital asset.
enum VdaAssetType {
  crypto(label: 'Cryptocurrency', icon: Icons.currency_bitcoin_rounded),
  nft(label: 'NFT', icon: Icons.image_rounded),
  token(label: 'Utility Token', icon: Icons.token_rounded),
  stablecoin(label: 'Stablecoin', icon: Icons.account_balance_rounded);

  const VdaAssetType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Type of VDA transaction under Section 115BBH.
enum VdaTransactionType {
  buy(label: 'Buy', color: Color(0xFF1565C0)),
  sell(label: 'Sell', color: Color(0xFFE65100)),
  transfer(label: 'Transfer', color: Color(0xFF6A1B9A)),
  mining(label: 'Mining', color: Color(0xFF2E7D32)),
  staking(label: 'Staking', color: Color(0xFF00838F)),
  airdrop(label: 'Airdrop', color: Color(0xFFD4890E));

  const VdaTransactionType({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Immutable model representing a single VDA transaction
/// under Section 115BBH / 194S of the Income Tax Act.
@immutable
class VdaTransaction {
  const VdaTransaction({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.assetType,
    required this.assetName,
    required this.transactionType,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    required this.gainLoss,
    required this.taxAt30Percent,
    required this.tdsUnder194S,
    required this.exchange,
    required this.transactionDate,
    this.remarks,
  });

  final String id;
  final String clientId;
  final String clientName;
  final VdaAssetType assetType;
  final String assetName;
  final VdaTransactionType transactionType;
  final double quantity;
  final double buyPrice;
  final double sellPrice;
  final double gainLoss;
  final double taxAt30Percent;
  final double tdsUnder194S;
  final String exchange;
  final DateTime transactionDate;
  final String? remarks;

  /// Returns a new [VdaTransaction] with the given fields replaced.
  VdaTransaction copyWith({
    String? id,
    String? clientId,
    String? clientName,
    VdaAssetType? assetType,
    String? assetName,
    VdaTransactionType? transactionType,
    double? quantity,
    double? buyPrice,
    double? sellPrice,
    double? gainLoss,
    double? taxAt30Percent,
    double? tdsUnder194S,
    String? exchange,
    DateTime? transactionDate,
    String? remarks,
  }) {
    return VdaTransaction(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      assetType: assetType ?? this.assetType,
      assetName: assetName ?? this.assetName,
      transactionType: transactionType ?? this.transactionType,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      gainLoss: gainLoss ?? this.gainLoss,
      taxAt30Percent: taxAt30Percent ?? this.taxAt30Percent,
      tdsUnder194S: tdsUnder194S ?? this.tdsUnder194S,
      exchange: exchange ?? this.exchange,
      transactionDate: transactionDate ?? this.transactionDate,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VdaTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          assetType == other.assetType &&
          assetName == other.assetName &&
          transactionType == other.transactionType &&
          quantity == other.quantity &&
          buyPrice == other.buyPrice &&
          sellPrice == other.sellPrice &&
          gainLoss == other.gainLoss &&
          taxAt30Percent == other.taxAt30Percent &&
          tdsUnder194S == other.tdsUnder194S &&
          exchange == other.exchange &&
          transactionDate == other.transactionDate;

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    assetType,
    assetName,
    transactionType,
    quantity,
    buyPrice,
    sellPrice,
    gainLoss,
    taxAt30Percent,
    tdsUnder194S,
    exchange,
    transactionDate,
  );

  @override
  String toString() =>
      'VdaTransaction(id: $id, asset: $assetName, '
      'type: ${transactionType.label}, gain/loss: $gainLoss)';
}
