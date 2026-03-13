import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/notice_resolution/domain/models/tax_notice.dart';

class TaxNoticeMapper {
  const TaxNoticeMapper._();

  // ---------------------------------------------------------------------------
  // JSON (from Supabase) → TaxNotice domain model
  // ---------------------------------------------------------------------------

  static TaxNotice fromJson(Map<String, dynamic> json) {
    return TaxNotice(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      noticeType: _safeNoticeType(json['notice_type'] as String? ?? 'other'),
      issuedDate: DateTime.parse(json['issued_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      demandAmount: (json['demand_amount'] as num?)?.toDouble(),
      status: _safeStatus(json['status'] as String? ?? 'received'),
      responseDate: _parseDate(json['response_date'] as String?),
      responseNotes: json['response_notes'] as String?,
      attachments: _parseAttachments(json['attachments']),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TaxNotice domain model → JSON (for Supabase insert/update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(TaxNotice notice) {
    return {
      'id': notice.id,
      'client_id': notice.clientId,
      'notice_type': notice.noticeType.name,
      'issued_date': notice.issuedDate.toIso8601String(),
      'due_date': notice.dueDate.toIso8601String(),
      'demand_amount': notice.demandAmount,
      'status': notice.status.name,
      'response_date': notice.responseDate?.toIso8601String(),
      'response_notes': notice.responseNotes,
      'attachments': notice.attachments,
      'created_at': notice.createdAt.toIso8601String(),
      'updated_at': notice.updatedAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → TaxNotice domain model
  // ---------------------------------------------------------------------------

  static TaxNotice fromRow(TaxNoticeRow row) {
    return TaxNotice(
      id: row.id,
      clientId: row.clientId,
      noticeType: _safeNoticeType(row.noticeType),
      issuedDate: DateTime.parse(row.issuedDate),
      dueDate: DateTime.parse(row.dueDate),
      demandAmount: row.demandAmount,
      status: _safeStatus(row.status),
      responseDate: row.responseDate != null
          ? DateTime.tryParse(row.responseDate!)
          : null,
      responseNotes: row.responseNotes,
      attachments: _parseAttachmentsFromJson(row.attachments),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // TaxNotice → Drift companion (for insert/update)
  // ---------------------------------------------------------------------------

  static TaxNoticesTableCompanion toCompanion(TaxNotice notice) {
    return TaxNoticesTableCompanion(
      id: Value(notice.id),
      clientId: Value(notice.clientId),
      noticeType: Value(notice.noticeType.name),
      issuedDate: Value(notice.issuedDate.toIso8601String()),
      dueDate: Value(notice.dueDate.toIso8601String()),
      demandAmount: Value(notice.demandAmount),
      status: Value(notice.status.name),
      responseDate: Value(notice.responseDate?.toIso8601String()),
      responseNotes: Value(notice.responseNotes),
      attachments: Value(jsonEncode(notice.attachments)),
      createdAt: Value(notice.createdAt),
      updatedAt: Value(notice.updatedAt),
      isDirty: const Value(true),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static NoticeType _safeNoticeType(String name) {
    try {
      return NoticeType.values.byName(name);
    } catch (_) {
      return NoticeType.other;
    }
  }

  static NoticeStatus _safeStatus(String name) {
    try {
      return NoticeStatus.values.byName(name);
    } catch (_) {
      return NoticeStatus.received;
    }
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static List<String> _parseAttachments(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.whereType<String>().toList();
    }
    return const [];
  }

  static List<String> _parseAttachmentsFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }
}
