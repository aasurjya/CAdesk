import 'package:flutter/material.dart';

/// Type of tax notice issued by IT / GST / TDS department.
enum NoticeType {
  section143_1(label: 'Section 143(1)', description: 'Intimation'),
  section143_2(label: 'Section 143(2)', description: 'Scrutiny Notice'),
  section148(label: 'Section 148', description: 'Income Escaping Assessment'),
  section156(label: 'Section 156', description: 'Notice of Demand'),
  gstAudit(label: 'GST Audit', description: 'GST Audit Notice'),
  gstScrutiny(label: 'GST Scrutiny', description: 'GST Scrutiny Notice'),
  tdsDefault(label: 'TDS Default', description: 'TDS Default Notice'),
  other(label: 'Other', description: 'Other Notice');

  const NoticeType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Status of a Tax Notice response workflow.
enum NoticeStatus {
  received(label: 'Received', color: Color(0xFFD4890E)),
  inReview(label: 'In Review', color: Color(0xFF1565C0)),
  responseFiled(label: 'Response Filed', color: Color(0xFF6A1B9A)),
  disposed(label: 'Disposed', color: Color(0xFF1A7A3A)),
  appeal(label: 'Appeal', color: Color(0xFFC62828));

  const NoticeStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Immutable model representing a tax / GST / TDS notice and its
/// resolution workflow.
@immutable
class TaxNotice {
  const TaxNotice({
    required this.id,
    required this.clientId,
    required this.noticeType,
    required this.issuedDate,
    required this.dueDate,
    required this.status,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.demandAmount,
    this.responseDate,
    this.responseNotes,
  });

  final String id;
  final String clientId;

  final NoticeType noticeType;

  /// Date the notice was issued by the department.
  final DateTime issuedDate;

  /// Response / compliance due date.
  final DateTime dueDate;

  /// Demand amount in INR (if applicable).
  final double? demandAmount;

  final NoticeStatus status;

  /// Date on which response was filed.
  final DateTime? responseDate;

  /// Notes or summary of the response filed.
  final String? responseNotes;

  /// List of attachment file paths / URLs.
  final List<String> attachments;

  final DateTime createdAt;
  final DateTime updatedAt;

  TaxNotice copyWith({
    String? id,
    String? clientId,
    NoticeType? noticeType,
    DateTime? issuedDate,
    DateTime? dueDate,
    double? demandAmount,
    NoticeStatus? status,
    DateTime? responseDate,
    String? responseNotes,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxNotice(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      noticeType: noticeType ?? this.noticeType,
      issuedDate: issuedDate ?? this.issuedDate,
      dueDate: dueDate ?? this.dueDate,
      demandAmount: demandAmount ?? this.demandAmount,
      status: status ?? this.status,
      responseDate: responseDate ?? this.responseDate,
      responseNotes: responseNotes ?? this.responseNotes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxNotice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          noticeType == other.noticeType &&
          issuedDate == other.issuedDate &&
          dueDate == other.dueDate &&
          demandAmount == other.demandAmount &&
          status == other.status &&
          responseDate == other.responseDate &&
          responseNotes == other.responseNotes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    noticeType,
    issuedDate,
    dueDate,
    demandAmount,
    status,
    responseDate,
    responseNotes,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'TaxNotice(id: $id, clientId: $clientId, '
      'type: ${noticeType.label}, status: ${status.label}, '
      'due: $dueDate)';
}
