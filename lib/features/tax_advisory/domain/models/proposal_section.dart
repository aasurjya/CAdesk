import 'package:ca_app/features/tax_advisory/domain/models/tax_opportunity.dart';

/// Immutable model representing one section inside an [AdvisoryProposalFull].
///
/// All monetary amounts are in paise (1 ₹ = 100 paise).
class ProposalSection {
  const ProposalSection({
    required this.sectionTitle,
    required this.content,
    required this.opportunities,
    required this.estimatedSaving,
  });

  /// Heading for this proposal section (e.g. "Section 80C Investments").
  final String sectionTitle;

  /// Detailed narrative content for this section.
  final String content;

  /// Opportunities covered in this section.
  final List<TaxOpportunity> opportunities;

  /// Total estimated saving across all opportunities in this section (paise).
  final int estimatedSaving;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  ProposalSection copyWith({
    String? sectionTitle,
    String? content,
    List<TaxOpportunity>? opportunities,
    int? estimatedSaving,
  }) {
    return ProposalSection(
      sectionTitle: sectionTitle ?? this.sectionTitle,
      content: content ?? this.content,
      opportunities: opportunities ?? this.opportunities,
      estimatedSaving: estimatedSaving ?? this.estimatedSaving,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalSection &&
          runtimeType == other.runtimeType &&
          sectionTitle == other.sectionTitle &&
          estimatedSaving == other.estimatedSaving;

  @override
  int get hashCode => Object.hash(sectionTitle, estimatedSaving);
}
