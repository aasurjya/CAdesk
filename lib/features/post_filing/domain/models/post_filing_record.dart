enum PostFilingActivity {
  itrVDownload('ITR-V Download'),
  eVerification('E-Verification'),
  refundClaim('Refund Claim'),
  demandResponse('Demand Response'),
  rectification('Rectification');

  const PostFilingActivity(this.label);

  final String label;
}

enum PostFilingStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  failed('Failed');

  const PostFilingStatus(this.label);

  final String label;
}

class PostFilingRecord {
  const PostFilingRecord({
    required this.id,
    required this.clientId,
    required this.filingId,
    required this.activityType,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  final String id;
  final String clientId;
  final String filingId;
  final PostFilingActivity activityType;
  final PostFilingStatus status;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;

  PostFilingRecord copyWith({
    String? id,
    String? clientId,
    String? filingId,
    PostFilingActivity? activityType,
    PostFilingStatus? status,
    DateTime? completedAt,
    String? notes,
    DateTime? createdAt,
  }) {
    return PostFilingRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      filingId: filingId ?? this.filingId,
      activityType: activityType ?? this.activityType,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostFilingRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
