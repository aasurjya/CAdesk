/// Immutable model representing a productized service bundle for a vertical.
class ServiceBundle {
  const ServiceBundle({
    required this.id,
    required this.verticalId,
    required this.name,
    required this.description,
    required this.inclusions,
    required this.pricePerMonth,
    required this.turnaroundDays,
    required this.slaLabel,
    required this.isPopular,
  });

  /// Unique identifier.
  final String id;

  /// ID of the [VerticalPlaybook] this bundle belongs to.
  final String verticalId;

  /// Display name of the bundle.
  final String name;

  /// Short description of what the bundle covers.
  final String description;

  /// 3–5 specific services included in the bundle.
  final List<String> inclusions;

  /// Monthly price in INR.
  final double pricePerMonth;

  /// Standard turnaround in calendar days.
  final int turnaroundDays;

  /// Human-readable SLA label (e.g. "T+2 days").
  final String slaLabel;

  /// Whether this bundle is the most popular option in its vertical.
  final bool isPopular;

  ServiceBundle copyWith({
    String? id,
    String? verticalId,
    String? name,
    String? description,
    List<String>? inclusions,
    double? pricePerMonth,
    int? turnaroundDays,
    String? slaLabel,
    bool? isPopular,
  }) {
    return ServiceBundle(
      id: id ?? this.id,
      verticalId: verticalId ?? this.verticalId,
      name: name ?? this.name,
      description: description ?? this.description,
      inclusions: inclusions ?? this.inclusions,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      turnaroundDays: turnaroundDays ?? this.turnaroundDays,
      slaLabel: slaLabel ?? this.slaLabel,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
