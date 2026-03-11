class SopDocument {
  const SopDocument({
    required this.id,
    required this.title,
    required this.module,
    required this.steps,
    required this.lastReviewedAt,
    required this.version,
    required this.isActive,
  });

  final String id;
  final String title;
  final String module;
  final List<String> steps;
  final DateTime lastReviewedAt;
  final String version;
  final bool isActive;

  SopDocument copyWith({
    String? id,
    String? title,
    String? module,
    List<String>? steps,
    DateTime? lastReviewedAt,
    String? version,
    bool? isActive,
  }) {
    return SopDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      module: module ?? this.module,
      steps: steps ?? this.steps,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
    );
  }
}
