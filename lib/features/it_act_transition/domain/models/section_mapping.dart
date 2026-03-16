/// Category of a tax section — used for grouping and filtering.
enum SectionCategory {
  taxComputation(label: 'Tax Computation'),
  deductions(label: 'Deductions (Chapter VI-A)'),
  tds(label: 'Tax Deducted at Source'),
  tcs(label: 'Tax Collected at Source'),
  assessment(label: 'Assessment & Scrutiny'),
  interest(label: 'Interest & Penalties'),
  penalty(label: 'Penalties & Prosecution'),
  capitalGains(label: 'Capital Gains'),
  exemptIncome(label: 'Exempt Income'),
  trust(label: 'Trusts & Charitable'),
  residentialStatus(label: 'Residential Status'),
  dtaa(label: 'DTAA & International'),
  transferPricing(label: 'Transfer Pricing'),
  vda(label: 'Virtual Digital Assets'),
  general(label: 'General');

  const SectionCategory({required this.label});

  final String label;
}

/// An immutable mapping between a section in the IT Act 1961 and its
/// equivalent in the IT Act 2025.
class SectionMapping {
  const SectionMapping({
    required this.section1961,
    required this.section2025,
    required this.description,
    required this.category,
    this.notes,
  });

  /// Section number/reference under the 1961 Act (e.g., "80C", "143(1)").
  final String section1961;

  /// Corresponding section under the 2025 Act (e.g., "123", "270(1)").
  final String section2025;

  /// Human-readable description of what this section covers.
  final String description;

  /// Which broad area of tax law this section belongs to.
  final SectionCategory category;

  /// Optional notes about the mapping (consolidation details, caveats, etc.).
  final String? notes;

  // ---------------------------------------------------------------------------
  // Display helpers
  // ---------------------------------------------------------------------------

  /// "Section 80C"
  String get displaySection1961 => 'Section $section1961';

  /// "Section 123"
  String get displaySection2025 => 'Section $section2025';

  /// "Section 270(1) [erstwhile Section 143(1)]"
  String get dualDisplay =>
      'Section $section2025 [erstwhile Section $section1961]';

  // ---------------------------------------------------------------------------
  // Immutable copy
  // ---------------------------------------------------------------------------

  SectionMapping copyWith({
    String? section1961,
    String? section2025,
    String? description,
    SectionCategory? category,
    String? notes,
  }) {
    return SectionMapping(
      section1961: section1961 ?? this.section1961,
      section2025: section2025 ?? this.section2025,
      description: description ?? this.description,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality & toString
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionMapping &&
          runtimeType == other.runtimeType &&
          section1961 == other.section1961 &&
          section2025 == other.section2025 &&
          description == other.description &&
          category == other.category &&
          notes == other.notes;

  @override
  int get hashCode =>
      Object.hash(section1961, section2025, description, category, notes);

  @override
  String toString() =>
      'SectionMapping($section1961 → $section2025: $description)';
}
