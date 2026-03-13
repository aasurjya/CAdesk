import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_transaction.dart';

class TpTransactionMapper {
  const TpTransactionMapper._();

  // ---------------------------------------------------------------------------
  // JSON (from Supabase) → TpTransaction domain model
  // ---------------------------------------------------------------------------

  static TpTransaction fromJson(Map<String, dynamic> json) {
    return TpTransaction(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      assessmentYear: json['assessment_year'] as String,
      relatedParty: json['related_party'] as String,
      transactionType: json['transaction_type'] as String,
      transactionValue:
          (json['transaction_value'] as num?)?.toDouble() ?? 0.0,
      tpMethod: _safeTpMethod(json['tp_method'] as String? ?? 'tnmm'),
      documentationDue: _parseDate(json['documentation_due'] as String?),
      status: _safeStatus(json['status'] as String? ?? 'draft'),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TpTransaction domain model → JSON (for Supabase insert/update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(TpTransaction tx) {
    return {
      'id': tx.id,
      'client_id': tx.clientId,
      'assessment_year': tx.assessmentYear,
      'related_party': tx.relatedParty,
      'transaction_type': tx.transactionType,
      'transaction_value': tx.transactionValue,
      'tp_method': tx.tpMethod.name,
      'documentation_due': tx.documentationDue?.toIso8601String(),
      'status': tx.status.name,
      'created_at': tx.createdAt.toIso8601String(),
      'updated_at': tx.updatedAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → TpTransaction domain model
  // ---------------------------------------------------------------------------

  static TpTransaction fromRow(TpTransactionRow row) {
    return TpTransaction(
      id: row.id,
      clientId: row.clientId,
      assessmentYear: row.assessmentYear,
      relatedParty: row.relatedParty,
      transactionType: row.transactionType,
      transactionValue: row.transactionValue,
      tpMethod: _safeTpMethod(row.tpMethod),
      documentationDue: row.documentationDue != null
          ? DateTime.tryParse(row.documentationDue!)
          : null,
      status: _safeStatus(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // TpTransaction → Drift companion (for insert/update)
  // ---------------------------------------------------------------------------

  static TpTransactionsTableCompanion toCompanion(TpTransaction tx) {
    return TpTransactionsTableCompanion(
      id: Value(tx.id),
      clientId: Value(tx.clientId),
      assessmentYear: Value(tx.assessmentYear),
      relatedParty: Value(tx.relatedParty),
      transactionType: Value(tx.transactionType),
      transactionValue: Value(tx.transactionValue),
      tpMethod: Value(tx.tpMethod.name),
      documentationDue: Value(tx.documentationDue?.toIso8601String()),
      status: Value(tx.status.name),
      createdAt: Value(tx.createdAt),
      updatedAt: Value(tx.updatedAt),
      isDirty: const Value(true),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static TpMethod _safeTpMethod(String name) {
    try {
      return TpMethod.values.byName(name);
    } catch (_) {
      return TpMethod.tnmm;
    }
  }

  static TpStatus _safeStatus(String name) {
    try {
      return TpStatus.values.byName(name);
    } catch (_) {
      return TpStatus.draft;
    }
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }
}
