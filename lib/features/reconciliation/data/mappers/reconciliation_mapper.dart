import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';

/// Bi-directional mapper between [ReconciliationResult] / [Discrepancy]
/// domain models and their persistence representations (Drift row / JSON map).
class ReconciliationMapper {
  const ReconciliationMapper._();

  // ---------------------------------------------------------------------------
  // ReconciliationResult: JSON (Supabase) ↔ Domain
  // ---------------------------------------------------------------------------

  /// Supabase JSON → [ReconciliationResult] domain model.
  static ReconciliationResult fromJson(Map<String, dynamic> json) {
    return ReconciliationResult(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      reconciliationType: _safeReconType(
        json['reconciliation_type'] as String? ?? 'tds26as',
      ),
      period: json['period'] as String? ?? '',
      totalMatched: (json['total_matched'] as num?)?.toInt() ?? 0,
      totalUnmatched: (json['total_unmatched'] as num?)?.toInt() ?? 0,
      discrepancies: _parseDiscrepanciesJson(json['discrepancies']),
      status: _safeReconStatus(json['status'] as String? ?? 'pending'),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedDate: json['reviewed_date'] != null
          ? DateTime.tryParse(json['reviewed_date'] as String)
          : null,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// [ReconciliationResult] domain model → Supabase JSON.
  static Map<String, dynamic> toJson(ReconciliationResult result) {
    return {
      'id': result.id,
      'client_id': result.clientId,
      'reconciliation_type': result.reconciliationType.name,
      'period': result.period,
      'total_matched': result.totalMatched,
      'total_unmatched': result.totalUnmatched,
      'discrepancies': jsonEncode(
        result.discrepancies.map(_discrepancyToMap).toList(),
      ),
      'status': result.status.name,
      'reviewed_by': result.reviewedBy,
      'reviewed_date': result.reviewedDate?.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // ReconciliationResult: Drift row ↔ Domain
  // ---------------------------------------------------------------------------

  /// Drift [ReconciliationResultsTableData] → [ReconciliationResult] domain model.
  static ReconciliationResult fromRow(ReconciliationResultsTableData row) {
    return ReconciliationResult(
      id: row.id,
      clientId: row.clientId,
      reconciliationType: _safeReconType(
        row.reconciliationType ?? 'tds26as',
      ),
      period: row.period ?? '',
      totalMatched: row.totalMatched ?? 0,
      totalUnmatched: row.totalUnmatched ?? 0,
      discrepancies: _parseDiscrepanciesText(row.discrepancies),
      status: _safeReconStatus(row.status ?? 'pending'),
      reviewedBy: row.reviewedBy,
      reviewedDate: row.reviewedDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// [ReconciliationResult] → Drift [ReconciliationResultsTableCompanion].
  static ReconciliationResultsTableCompanion toCompanion(
    ReconciliationResult result,
  ) {
    return ReconciliationResultsTableCompanion(
      id: Value(result.id),
      clientId: Value(result.clientId),
      reconciliationType: Value(result.reconciliationType.name),
      period: Value(result.period),
      totalMatched: Value(result.totalMatched),
      totalUnmatched: Value(result.totalUnmatched),
      discrepancies: Value(
        jsonEncode(result.discrepancies.map(_discrepancyToMap).toList()),
      ),
      status: Value(result.status.name),
      reviewedBy: Value(result.reviewedBy),
      reviewedDate: Value(result.reviewedDate),
      createdAt: Value(result.createdAt),
      updatedAt: Value(result.updatedAt),
    );
  }

  // ---------------------------------------------------------------------------
  // Discrepancy: Map ↔ Domain
  // ---------------------------------------------------------------------------

  /// JSON map → [Discrepancy] domain model.
  static Discrepancy discrepancyFromMap(Map<String, dynamic> map) {
    return Discrepancy(
      id: map['id'] as String,
      resultId: map['result_id'] as String,
      field: map['field'] as String,
      expectedValue: map['expected_value'] as String,
      actualValue: map['actual_value'] as String,
      source: map['source'] as String,
      resolved: map['resolved'] as bool? ?? false,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _discrepancyToMap(Discrepancy d) {
    return {
      'id': d.id,
      'result_id': d.resultId,
      'field': d.field,
      'expected_value': d.expectedValue,
      'actual_value': d.actualValue,
      'source': d.source,
      'resolved': d.resolved,
    };
  }

  /// Parse discrepancies from a raw JSON value (from Supabase — may be a list).
  static List<Discrepancy> _parseDiscrepanciesJson(dynamic raw) {
    if (raw == null) return const [];
    try {
      List<dynamic> list;
      if (raw is String) {
        list = jsonDecode(raw) as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      } else {
        return const [];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(discrepancyFromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Parse discrepancies from stored TEXT column (Drift — always a JSON string).
  static List<Discrepancy> _parseDiscrepanciesText(String? text) {
    if (text == null || text.isEmpty) return const [];
    try {
      final list = jsonDecode(text) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(discrepancyFromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static ReconciliationType _safeReconType(String name) {
    try {
      return ReconciliationType.values.byName(name);
    } catch (_) {
      return ReconciliationType.tds26as;
    }
  }

  static ReconciliationStatus _safeReconStatus(String name) {
    try {
      return ReconciliationStatus.values.byName(name);
    } catch (_) {
      return ReconciliationStatus.pending;
    }
  }
}
