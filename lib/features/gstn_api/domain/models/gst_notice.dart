/// Status of a GST notice issued by the tax authority.
enum GstNoticeStatus { open, replied, closed, pendingHearing }

/// Immutable representation of a GST notice issued to a taxpayer.
class GstNotice {
  const GstNotice({
    required this.noticeId,
    required this.type,
    required this.issuedDate,
    required this.dueDate,
    required this.description,
    required this.status,
  });

  /// Unique notice identifier assigned by the GSTN portal.
  final String noticeId;

  /// Notice type, e.g. "GSTR-3A", "REG-03", "ASMT-10".
  final String type;

  final DateTime issuedDate;

  /// Date by which the taxpayer must respond.
  final DateTime dueDate;

  /// Human-readable notice summary.
  final String description;

  final GstNoticeStatus status;

  /// True when the notice is still awaiting action.
  bool get isPending =>
      status == GstNoticeStatus.open ||
      status == GstNoticeStatus.pendingHearing;

  GstNotice copyWith({
    String? noticeId,
    String? type,
    DateTime? issuedDate,
    DateTime? dueDate,
    String? description,
    GstNoticeStatus? status,
  }) {
    return GstNotice(
      noticeId: noticeId ?? this.noticeId,
      type: type ?? this.type,
      issuedDate: issuedDate ?? this.issuedDate,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstNotice &&
          runtimeType == other.runtimeType &&
          noticeId == other.noticeId &&
          type == other.type &&
          issuedDate == other.issuedDate &&
          dueDate == other.dueDate &&
          description == other.description &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(noticeId, type, issuedDate, dueDate, description, status);
}
