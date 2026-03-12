/// Recommended action for responding to a tax notice.
enum RecommendedAction {
  /// Draft and file a written response.
  respond,

  /// File an appeal to the appropriate forum.
  appeal,

  /// Pay the demand (if small or uncontestable).
  pay,

  /// No immediate action required (routine query).
  ignore,

  /// Apply for stay of demand pending appeal.
  seekStay,
}

/// Risk classification of a tax notice.
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Immutable model representing the AI triage output for a tax notice.
///
/// All monetary amounts are in **paise**.
class NoticeTriageResult {
  const NoticeTriageResult({
    required this.noticeId,
    required this.recommendedAction,
    required this.riskLevel,
    required this.keyIssues,
    required this.suggestedGrounds,
    required this.timelineAdvice,
    required this.estimatedDemand,
  });

  final String noticeId;
  final RecommendedAction recommendedAction;
  final RiskLevel riskLevel;
  final List<String> keyIssues;
  final List<String> suggestedGrounds;
  final String timelineAdvice;

  /// Estimated or actual demand amount in paise. 0 if no demand raised.
  final int estimatedDemand;

  NoticeTriageResult copyWith({
    String? noticeId,
    RecommendedAction? recommendedAction,
    RiskLevel? riskLevel,
    List<String>? keyIssues,
    List<String>? suggestedGrounds,
    String? timelineAdvice,
    int? estimatedDemand,
  }) {
    return NoticeTriageResult(
      noticeId: noticeId ?? this.noticeId,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      riskLevel: riskLevel ?? this.riskLevel,
      keyIssues: keyIssues ?? this.keyIssues,
      suggestedGrounds: suggestedGrounds ?? this.suggestedGrounds,
      timelineAdvice: timelineAdvice ?? this.timelineAdvice,
      estimatedDemand: estimatedDemand ?? this.estimatedDemand,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoticeTriageResult) return false;
    return other.noticeId == noticeId &&
        other.recommendedAction == recommendedAction &&
        other.riskLevel == riskLevel &&
        other.timelineAdvice == timelineAdvice &&
        other.estimatedDemand == estimatedDemand;
  }

  @override
  int get hashCode => Object.hash(
        noticeId,
        recommendedAction,
        riskLevel,
        timelineAdvice,
        estimatedDemand,
      );
}

