/// Type of HSN/SAC code.
enum HsnSacType {
  hsn(label: 'HSN'),
  sac(label: 'SAC');

  const HsnSacType({required this.label});

  final String label;
}

/// Immutable model representing an HSN (Harmonized System of Nomenclature)
/// or SAC (Services Accounting Code) entry.
class HsnSacCode {
  const HsnSacCode({
    required this.code,
    required this.description,
    required this.type,
    required this.chapter,
    required this.gstRate,
    this.cessRate = 0.0,
    this.isActive = true,
  });

  /// HSN/SAC code — 2, 4, 6, or 8 digits.
  final String code;

  /// Human-readable description of the goods or service.
  final String description;

  /// Whether this is an HSN (goods) or SAC (services) code.
  final HsnSacType type;

  /// Chapter number (1–99).
  final int chapter;

  /// Applicable GST rate: 0, 5, 12, 18, or 28.
  final double gstRate;

  /// Compensation cess rate (0 for most items).
  final double cessRate;

  /// Whether this code is currently active.
  final bool isActive;

  HsnSacCode copyWith({
    String? code,
    String? description,
    HsnSacType? type,
    int? chapter,
    double? gstRate,
    double? cessRate,
    bool? isActive,
  }) {
    return HsnSacCode(
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      chapter: chapter ?? this.chapter,
      gstRate: gstRate ?? this.gstRate,
      cessRate: cessRate ?? this.cessRate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HsnSacCode &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          type == other.type;

  @override
  int get hashCode => Object.hash(code, type);
}
