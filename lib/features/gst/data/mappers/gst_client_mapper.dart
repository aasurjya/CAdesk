import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';

class GstClientMapper {
  const GstClientMapper._();

  // JSON (from Supabase) → GstClient domain model
  static GstClient fromJson(Map<String, dynamic> json) {
    return GstClient(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      tradeName: json['trade_name'] as String?,
      gstin: json['gstin'] as String,
      pan: json['pan'] as String,
      registrationType: _safeRegistrationType(
        json['registration_type'] as String? ?? 'regular',
      ),
      state: json['state'] as String,
      stateCode: json['state_code'] as String,
      returnsPending: _parseReturnsPending(json['returns_pending']),
      lastFiledDate: _parseDate(json['last_filed_date'] as String?),
      complianceScore: (json['compliance_score'] as num?)?.toInt() ?? 0,
    );
  }

  // GstClient domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(GstClient client) {
    return {
      'id': client.id,
      'business_name': client.businessName,
      'trade_name': client.tradeName,
      'gstin': client.gstin,
      'pan': client.pan,
      'registration_type': client.registrationType.name,
      'state': client.state,
      'state_code': client.stateCode,
      'returns_pending': client.returnsPending,
      'last_filed_date': client.lastFiledDate?.toIso8601String(),
      'compliance_score': client.complianceScore,
    };
  }

  // Drift row → GstClient domain model
  static GstClient fromRow(GstClientRow row) {
    return GstClient(
      id: row.clientId,
      businessName: row.businessName,
      tradeName: row.tradeName,
      gstin: row.gstin,
      pan: row.pan,
      registrationType: _safeRegistrationType(row.registrationType),
      state: row.state,
      stateCode: row.stateCode,
      returnsPending: _parseReturnsPendingFromJson(row.returnsPending),
      lastFiledDate: row.lastFiledDate != null
          ? DateTime.tryParse(row.lastFiledDate!)
          : null,
      complianceScore: row.complianceScore,
    );
  }

  // GstClient → Drift companion (for insert/update)
  static GstClientsTableCompanion toCompanion(
    GstClient client, {
    String firmId = '',
  }) {
    return GstClientsTableCompanion(
      id: Value(client.id),
      firmId: Value(firmId),
      clientId: Value(client.id),
      businessName: Value(client.businessName),
      tradeName: Value(client.tradeName),
      gstin: Value(client.gstin),
      pan: Value(client.pan),
      registrationType: Value(client.registrationType.name),
      state: Value(client.state),
      stateCode: Value(client.stateCode),
      returnsPending: Value(jsonEncode(client.returnsPending)),
      lastFiledDate: Value(client.lastFiledDate?.toIso8601String()),
      complianceScore: Value(client.complianceScore),
      isDirty: const Value(true),
    );
  }

  static GstRegistrationType _safeRegistrationType(String name) {
    try {
      return GstRegistrationType.values.byName(name);
    } catch (_) {
      return GstRegistrationType.regular;
    }
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static List<String> _parseReturnsPending(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map((e) => e as String).toList();
    }
    return const [];
  }

  static List<String> _parseReturnsPendingFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => e as String).toList();
    } catch (_) {
      return const [];
    }
  }
}
