import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/vda/domain/models/vda_record.dart';

class VdaRecordMapper {
  const VdaRecordMapper._();

  // ---------------------------------------------------------------------------
  // JSON (from Supabase) → VdaRecord domain model
  // ---------------------------------------------------------------------------

  static VdaRecord fromJson(Map<String, dynamic> json) {
    return VdaRecord(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      assetType: json['asset_type'] as String,
      buyPrice: (json['buy_price'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (json['sell_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      gainLoss: (json['gain_loss'] as num?)?.toDouble() ?? 0.0,
      tdsDeducted: (json['tds_deducted'] as num?)?.toDouble() ?? 0.0,
      exchange: json['exchange'] as String?,
      assessmentYear: json['assessment_year'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // VdaRecord domain model → JSON (for Supabase insert/update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(VdaRecord record) {
    return {
      'id': record.id,
      'client_id': record.clientId,
      'transaction_date': record.transactionDate.toIso8601String(),
      'asset_type': record.assetType,
      'buy_price': record.buyPrice,
      'sell_price': record.sellPrice,
      'quantity': record.quantity,
      'gain_loss': record.gainLoss,
      'tds_deducted': record.tdsDeducted,
      'exchange': record.exchange,
      'assessment_year': record.assessmentYear,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → VdaRecord domain model
  // ---------------------------------------------------------------------------

  static VdaRecord fromRow(VdaRecordRow row) {
    return VdaRecord(
      id: row.id,
      clientId: row.clientId,
      transactionDate: DateTime.parse(row.transactionDate),
      assetType: row.assetType,
      buyPrice: row.buyPrice,
      sellPrice: row.sellPrice,
      quantity: row.quantity,
      gainLoss: row.gainLoss,
      tdsDeducted: row.tdsDeducted,
      exchange: row.exchange,
      assessmentYear: row.assessmentYear,
    );
  }

  // ---------------------------------------------------------------------------
  // VdaRecord → Drift companion (for insert/update)
  // ---------------------------------------------------------------------------

  static VdaRecordsTableCompanion toCompanion(VdaRecord record) {
    return VdaRecordsTableCompanion(
      id: Value(record.id),
      clientId: Value(record.clientId),
      transactionDate: Value(record.transactionDate.toIso8601String()),
      assetType: Value(record.assetType),
      buyPrice: Value(record.buyPrice),
      sellPrice: Value(record.sellPrice),
      quantity: Value(record.quantity),
      gainLoss: Value(record.gainLoss),
      tdsDeducted: Value(record.tdsDeducted),
      exchange: Value(record.exchange),
      assessmentYear: Value(record.assessmentYear),
      isDirty: const Value(true),
    );
  }
}
