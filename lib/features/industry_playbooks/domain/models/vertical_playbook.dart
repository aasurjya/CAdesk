/// Immutable model representing an industry-vertical tax playbook.
class VerticalPlaybook {
  const VerticalPlaybook({
    required this.id,
    required this.vertical,
    required this.icon,
    required this.description,
    required this.complianceChecklist,
    required this.typicalRisks,
    required this.activeClients,
    required this.avgRetainerValue,
    required this.winRate,
    required this.marginPercent,
  });

  /// Unique identifier.
  final String id;

  /// Vertical name (e.g. "e-commerce", "exporters", "doctors").
  final String vertical;

  /// Emoji icon for the vertical.
  final String icon;

  /// Short description of the vertical's tax profile.
  final String description;

  /// 3–4 compliance checklist items specific to this vertical.
  final List<String> complianceChecklist;

  /// 2–3 common tax risks for this vertical.
  final List<String> typicalRisks;

  /// Number of active clients in this vertical.
  final int activeClients;

  /// Average monthly retainer value in lakhs (INR).
  final double avgRetainerValue;

  /// Win rate (0.0–1.0) when pitching to this vertical.
  final double winRate;

  /// Net margin percentage (0.0–1.0) for this vertical.
  final double marginPercent;

  VerticalPlaybook copyWith({
    String? id,
    String? vertical,
    String? icon,
    String? description,
    List<String>? complianceChecklist,
    List<String>? typicalRisks,
    int? activeClients,
    double? avgRetainerValue,
    double? winRate,
    double? marginPercent,
  }) {
    return VerticalPlaybook(
      id: id ?? this.id,
      vertical: vertical ?? this.vertical,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      complianceChecklist: complianceChecklist ?? this.complianceChecklist,
      typicalRisks: typicalRisks ?? this.typicalRisks,
      activeClients: activeClients ?? this.activeClients,
      avgRetainerValue: avgRetainerValue ?? this.avgRetainerValue,
      winRate: winRate ?? this.winRate,
      marginPercent: marginPercent ?? this.marginPercent,
    );
  }
}
