// ---------------------------------------------------------------------------
// CitationType enum
// ---------------------------------------------------------------------------

/// The source category of a tax law citation.
enum CitationType {
  /// Section of an Act (e.g. Income Tax Act 1961, CGST Act 2017).
  act,

  /// CBDT / CBIC circular or instruction.
  circular,

  /// Official gazette notification.
  notification,

  /// Court judgement or tribunal order.
  caseDecision,
}

// ---------------------------------------------------------------------------
// TaxCitation model
// ---------------------------------------------------------------------------

/// Immutable record of a single tax law citation extracted from AI response
/// text.
class TaxCitation {
  const TaxCitation({
    required this.reference,
    required this.type,
    this.gazetteUrl,
    this.shortLabel,
  });

  /// Full human-readable reference (e.g. `'Section 80C of IT Act 1961'`).
  final String reference;

  /// Type / source category of this citation.
  final CitationType type;

  /// Direct URL to the gazette / official document, if available.
  final String? gazetteUrl;

  /// Abbreviated citation label for inline display (e.g. `'§80C'`).
  final String? shortLabel;

  TaxCitation copyWith({
    String? reference,
    CitationType? type,
    String? gazetteUrl,
    String? shortLabel,
  }) {
    return TaxCitation(
      reference: reference ?? this.reference,
      type: type ?? this.type,
      gazetteUrl: gazetteUrl ?? this.gazetteUrl,
      shortLabel: shortLabel ?? this.shortLabel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxCitation && other.reference == reference;
  }

  @override
  int get hashCode => reference.hashCode;

  @override
  String toString() => 'TaxCitation(ref: $reference, type: ${type.name})';
}

// ---------------------------------------------------------------------------
// Extraction patterns
// ---------------------------------------------------------------------------

/// Matches "Section NNN[A-Z]?" references to IT Act / GST Act / etc.
final RegExp _sectionPattern = RegExp(
  r'\b(?:section|sec\.?|s\.)\s*(\d+[A-Z]{0,2}(?:\([a-z0-9]+\))?)'
  r'(?:\s+of\s+(?:the\s+)?([A-Za-z\s&,]+(?:Act|Rules|Code|Regulation)[A-Za-z\s,0-9]*))?',
  caseSensitive: false,
);

/// Matches CBDT / CBIC circular references.
final RegExp _circularPattern = RegExp(
  r'\b(?:circular|instruction)\s+(?:no\.?\s*)?(\d+(?:/\d+)?)'
  r'(?:\s+(?:dated?|of)\s+[\w\s,0-9]+)?',
  caseSensitive: false,
);

/// Matches gazette notification references.
final RegExp _notificationPattern = RegExp(
  r'\bnotification\s+(?:no\.?\s*)?([A-Z0-9/\-]+)',
  caseSensitive: false,
);

/// Matches common Indian court / tribunal case citation formats.
final RegExp _casePattern = RegExp(
  r'\b(?:vs?\.?|versus)\s+[A-Z][a-z]+|'
  r'\(\d{4}\)\s+\d+\s+(?:ITR|SCC|CTR|ITAT|HC|SC)\b',
);

// ---------------------------------------------------------------------------
// Known section → URL mapping (extensible)
// ---------------------------------------------------------------------------

const Map<String, String> _sectionUrls = {
  '80c':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-80c.htm',
  '80d':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-80d.htm',
  '80g':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-80g.htm',
  '10(10d)':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-10.htm',
  '24':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-24.htm',
  '44ad':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-44ad.htm',
  '44ada':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-44ada.htm',
  '115bac':
      'https://incometaxindia.gov.in/Acts/Income-tax%20Act,%201961/2023/section-115bac.htm',
};

// ---------------------------------------------------------------------------
// CitationEnhancer
// ---------------------------------------------------------------------------

/// Extracts structured [TaxCitation]s from AI response text and formats
/// them as annotated hyperlinks for display.
///
/// This is a pure-Dart domain service with no Flutter or platform imports.
///
/// Usage:
/// ```dart
/// final enhancer = CitationEnhancer();
/// final citations = enhancer.extractCitations(responseText);
/// final annotated = enhancer.formatWithCitations(responseText, citations);
/// ```
class CitationEnhancer {
  const CitationEnhancer();

  // ---------------------------------------------------------------------------
  // extractCitations
  // ---------------------------------------------------------------------------

  /// Extracts all recognisable tax law citations from [responseText].
  ///
  /// Deduplicates by reference string. Returns an empty list when no citations
  /// are found.
  List<TaxCitation> extractCitations(String responseText) {
    if (responseText.trim().isEmpty) return const [];

    final seen = <String>{};
    final citations = <TaxCitation>[];

    // Section references
    for (final match in _sectionPattern.allMatches(responseText)) {
      final sectionNum = match.group(1) ?? '';
      final actName = match.group(2)?.trim() ?? 'IT Act 1961';
      final reference = 'Section $sectionNum of $actName';

      if (!seen.contains(reference)) {
        seen.add(reference);
        citations.add(
          TaxCitation(
            reference: reference,
            type: CitationType.act,
            gazetteUrl: _sectionUrls[sectionNum.toLowerCase()],
            shortLabel: '§$sectionNum',
          ),
        );
      }
    }

    // Circular references
    for (final match in _circularPattern.allMatches(responseText)) {
      final circNum = match.group(1) ?? '';
      final reference = 'Circular No. $circNum';

      if (!seen.contains(reference)) {
        seen.add(reference);
        citations.add(
          TaxCitation(
            reference: reference,
            type: CitationType.circular,
            shortLabel: 'Circ. $circNum',
          ),
        );
      }
    }

    // Notification references
    for (final match in _notificationPattern.allMatches(responseText)) {
      final notifNum = match.group(1) ?? '';
      final reference = 'Notification No. $notifNum';

      if (!seen.contains(reference)) {
        seen.add(reference);
        citations.add(
          TaxCitation(
            reference: reference,
            type: CitationType.notification,
            shortLabel: 'Notif. $notifNum',
          ),
        );
      }
    }

    // Case citations
    for (final match in _casePattern.allMatches(responseText)) {
      final reference = match.group(0)?.trim() ?? '';
      if (reference.length > 3 && !seen.contains(reference)) {
        seen.add(reference);
        citations.add(
          TaxCitation(reference: reference, type: CitationType.caseDecision),
        );
      }
    }

    return List.unmodifiable(citations);
  }

  // ---------------------------------------------------------------------------
  // formatWithCitations
  // ---------------------------------------------------------------------------

  /// Returns [text] with each recognised citation annotated as a numbered
  /// reference footnote in Markdown format.
  ///
  /// Inline citations are replaced with `[N]` markers and a `## References`
  /// section is appended at the end.
  ///
  /// Example output:
  /// ```
  /// Deduction under Section 80C [1] allows up to ₹1.5 lakh.
  ///
  /// ## References
  /// [1] Section 80C of IT Act 1961 — https://...
  /// ```
  String formatWithCitations(String text, List<TaxCitation> citations) {
    if (citations.isEmpty) return text;

    var annotated = text;
    final references = <String>[];

    for (var i = 0; i < citations.length; i++) {
      final citation = citations[i];
      final marker = '[${i + 1}]';
      final shortLabel = citation.shortLabel ?? citation.reference;

      // Replace the first occurrence of the short label in the text with
      // the marker. Fall back to appending the marker at the end of the
      // nearest sentence if the label is not literally present.
      if (annotated.contains(shortLabel)) {
        annotated = annotated.replaceFirst(shortLabel, '$shortLabel $marker');
      }

      final refLine = citation.gazetteUrl != null
          ? '$marker ${citation.reference} — ${citation.gazetteUrl}'
          : '$marker ${citation.reference}';
      references.add(refLine);
    }

    if (references.isNotEmpty) {
      annotated = '$annotated\n\n## References\n${references.join('\n')}';
    }

    return annotated;
  }

  // ---------------------------------------------------------------------------
  // citationSummary
  // ---------------------------------------------------------------------------

  /// Returns a brief plain-text summary listing citation references.
  ///
  /// Useful for accessibility tooltips or chat bubbles.
  String citationSummary(List<TaxCitation> citations) {
    if (citations.isEmpty) return '';
    final lines = citations
        .asMap()
        .entries
        .map((e) => '[${e.key + 1}] ${e.value.reference}')
        .toList();
    return lines.join('\n');
  }
}
