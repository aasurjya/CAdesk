import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

/// Converts between [VdaTransaction] / [VdaSummary] and JSON maps.
class CryptoVdaMapper {
  const CryptoVdaMapper._();

  static VdaTransaction transactionFromJson(Map<String, dynamic> json) {
    return VdaTransaction(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      assetType: VdaAssetType.values.firstWhere(
        (e) => e.name == (json['asset_type'] as String? ?? 'crypto'),
        orElse: () => VdaAssetType.crypto,
      ),
      assetName: json['asset_name'] as String,
      transactionType: VdaTransactionType.values.firstWhere(
        (e) => e.name == (json['transaction_type'] as String? ?? 'buy'),
        orElse: () => VdaTransactionType.buy,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      buyPrice: (json['buy_price'] as num).toDouble(),
      sellPrice: (json['sell_price'] as num).toDouble(),
      gainLoss: (json['gain_loss'] as num).toDouble(),
      taxAt30Percent: (json['tax_at_30_percent'] as num).toDouble(),
      tdsUnder194S: (json['tds_under_194s'] as num).toDouble(),
      exchange: json['exchange'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      remarks: json['remarks'] as String?,
    );
  }

  static Map<String, dynamic> transactionToJson(VdaTransaction tx) {
    return {
      'id': tx.id,
      'client_id': tx.clientId,
      'client_name': tx.clientName,
      'asset_type': tx.assetType.name,
      'asset_name': tx.assetName,
      'transaction_type': tx.transactionType.name,
      'quantity': tx.quantity,
      'buy_price': tx.buyPrice,
      'sell_price': tx.sellPrice,
      'gain_loss': tx.gainLoss,
      'tax_at_30_percent': tx.taxAt30Percent,
      'tds_under_194s': tx.tdsUnder194S,
      'exchange': tx.exchange,
      'transaction_date': tx.transactionDate.toIso8601String(),
      'remarks': tx.remarks,
    };
  }

  static VdaSummary summaryFromJson(Map<String, dynamic> json) {
    return VdaSummary(
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      assessmentYear: json['assessment_year'] as String,
      totalTransactions: (json['total_transactions'] as num).toInt(),
      totalGains: (json['total_gains'] as num).toDouble(),
      totalLosses: (json['total_losses'] as num).toDouble(),
      netTaxableGain: (json['net_taxable_gain'] as num).toDouble(),
      taxLiability: (json['tax_liability'] as num).toDouble(),
      tdsCollected: (json['tds_collected'] as num).toDouble(),
      tdsShortfall: (json['tds_shortfall'] as num).toDouble(),
      hasLossRestrictionViolation:
          json['has_loss_restriction_violation'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> summaryToJson(VdaSummary summary) {
    return {
      'client_id': summary.clientId,
      'client_name': summary.clientName,
      'assessment_year': summary.assessmentYear,
      'total_transactions': summary.totalTransactions,
      'total_gains': summary.totalGains,
      'total_losses': summary.totalLosses,
      'net_taxable_gain': summary.netTaxableGain,
      'tax_liability': summary.taxLiability,
      'tds_collected': summary.tdsCollected,
      'tds_shortfall': summary.tdsShortfall,
      'has_loss_restriction_violation': summary.hasLossRestrictionViolation,
    };
  }
}
