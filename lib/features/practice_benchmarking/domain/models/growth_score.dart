/// A growth score measuring firm performance across a strategic dimension.
class GrowthScore {
  const GrowthScore({
    required this.id,
    required this.dimension,
    required this.score,
    required this.peerAverage,
    required this.grade,
    required this.insight,
    required this.recommendations,
  });

  final String id;

  /// Revenue Growth, Client Acquisition, Service Mix, Tech Adoption,
  /// Team Efficiency, Overall
  final String dimension;

  /// Score in the range 0–100
  final double score;

  /// Peer average score in the range 0–100
  final double peerAverage;

  /// A+, A, A-, B+, B, B-, C, D
  final String grade;

  /// One-sentence actionable insight
  final String insight;

  /// 2–3 recommended actions
  final List<String> recommendations;

  /// Normalised score fraction for progress bars.
  double get scoreFraction => (score / 100).clamp(0.0, 1.0);

  /// Normalised peer-average fraction for progress bars.
  double get peerAverageFraction => (peerAverage / 100).clamp(0.0, 1.0);

  /// Whether this score beats the peer average.
  bool get isAbovePeerAverage => score > peerAverage;

  GrowthScore copyWith({
    String? id,
    String? dimension,
    double? score,
    double? peerAverage,
    String? grade,
    String? insight,
    List<String>? recommendations,
  }) {
    return GrowthScore(
      id: id ?? this.id,
      dimension: dimension ?? this.dimension,
      score: score ?? this.score,
      peerAverage: peerAverage ?? this.peerAverage,
      grade: grade ?? this.grade,
      insight: insight ?? this.insight,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is GrowthScore && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
