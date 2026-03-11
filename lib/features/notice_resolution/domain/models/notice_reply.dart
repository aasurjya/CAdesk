import 'package:flutter/material.dart';

enum ReplyStatus {
  draft('Draft', Color(0xFF718096)),
  reviewed('Reviewed', Color(0xFF1B3A5C)),
  approved('Approved', Color(0xFF0D7C7C)),
  submitted('Submitted', Color(0xFF1A7A3A));

  const ReplyStatus(this.label, this.color);
  final String label;
  final Color color;
}

class NoticeReply {
  const NoticeReply({
    required this.id,
    required this.noticeId,
    required this.draftContent,
    required this.preparedBy,
    required this.preparedAt,
    required this.status,
    this.attachments = const [],
  });

  final String id;
  final String noticeId;
  final String draftContent;
  final String preparedBy;
  final DateTime preparedAt;
  final ReplyStatus status;
  final List<String> attachments;

  NoticeReply copyWith({
    String? id,
    String? noticeId,
    String? draftContent,
    String? preparedBy,
    DateTime? preparedAt,
    ReplyStatus? status,
    List<String>? attachments,
  }) {
    return NoticeReply(
      id: id ?? this.id,
      noticeId: noticeId ?? this.noticeId,
      draftContent: draftContent ?? this.draftContent,
      preparedBy: preparedBy ?? this.preparedBy,
      preparedAt: preparedAt ?? this.preparedAt,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
    );
  }
}
