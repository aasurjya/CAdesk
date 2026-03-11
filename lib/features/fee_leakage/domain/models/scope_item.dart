class ScopeItem {
  const ScopeItem({
    required this.id,
    required this.engagementId,
    required this.description,
    required this.isInScope,
    required this.addedAt,
    required this.billedExtra,
  });

  final String id;
  final String engagementId;
  final String description;
  final bool isInScope;
  final DateTime addedAt;
  final bool billedExtra;

  ScopeItem copyWith({
    String? id,
    String? engagementId,
    String? description,
    bool? isInScope,
    DateTime? addedAt,
    bool? billedExtra,
  }) {
    return ScopeItem(
      id: id ?? this.id,
      engagementId: engagementId ?? this.engagementId,
      description: description ?? this.description,
      isInScope: isInScope ?? this.isInScope,
      addedAt: addedAt ?? this.addedAt,
      billedExtra: billedExtra ?? this.billedExtra,
    );
  }
}
