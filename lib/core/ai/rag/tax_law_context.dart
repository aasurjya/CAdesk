// ---------------------------------------------------------------------------
// FilingContext
// ---------------------------------------------------------------------------

/// Immutable context describing a client's active tax filing session.
///
/// Used by [TaxLawContext] to enrich user questions with relevant metadata
/// before they are sent to the RAG pipeline.
class FilingContext {
  const FilingContext({
    this.clientPan,
    this.assessmentYear,
    this.incomeSources = const [],
    this.activeModule,
    this.taxRegime,
  });

  /// Client's PAN (e.g. `'ABCDE1234F'`). May be null for anonymous queries.
  final String? clientPan;

  /// Assessment year in `'YYYY-YY'` format (e.g. `'2024-25'`).
  final String? assessmentYear;

  /// Active income source tags (e.g. `['salary', 'capital_gains', 'house_property']`).
  final List<String> incomeSources;

  /// Currently active form/module (e.g. `'itr1'`, `'itr2'`, `'gstr1'`).
  final String? activeModule;

  /// Tax regime: `'old'` or `'new'` (introduced by Finance Act 2020).
  final String? taxRegime;

  FilingContext copyWith({
    String? clientPan,
    String? assessmentYear,
    List<String>? incomeSources,
    String? activeModule,
    String? taxRegime,
  }) {
    return FilingContext(
      clientPan: clientPan ?? this.clientPan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      incomeSources: incomeSources ?? this.incomeSources,
      activeModule: activeModule ?? this.activeModule,
      taxRegime: taxRegime ?? this.taxRegime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingContext &&
        other.clientPan == clientPan &&
        other.assessmentYear == assessmentYear &&
        other.activeModule == activeModule;
  }

  @override
  int get hashCode => Object.hash(clientPan, assessmentYear, activeModule);

  @override
  String toString() =>
      'FilingContext(ay: $assessmentYear, '
      'module: $activeModule, sources: $incomeSources)';
}

// ---------------------------------------------------------------------------
// RagQuery
// ---------------------------------------------------------------------------

/// Immutable enriched query ready for the RAG pipeline.
class RagQuery {
  const RagQuery({
    required this.enrichedPrompt,
    required this.filterTags,
    required this.metadata,
  });

  /// The original question augmented with filing context.
  final String enrichedPrompt;

  /// Tags used to pre-filter the vector store (e.g. `['itr1', 'salary']`).
  final List<String> filterTags;

  /// Key-value metadata for logging and tracing.
  final Map<String, String> metadata;

  RagQuery copyWith({
    String? enrichedPrompt,
    List<String>? filterTags,
    Map<String, String>? metadata,
  }) {
    return RagQuery(
      enrichedPrompt: enrichedPrompt ?? this.enrichedPrompt,
      filterTags: filterTags ?? this.filterTags,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RagQuery && other.enrichedPrompt == enrichedPrompt;
  }

  @override
  int get hashCode => enrichedPrompt.hashCode;

  @override
  String toString() =>
      'RagQuery(tags: $filterTags, promptLength: ${enrichedPrompt.length})';
}

// ---------------------------------------------------------------------------
// TaxLawContext
// ---------------------------------------------------------------------------

/// Builds a context-enriched [RagQuery] for CA GPT's RAG pipeline.
///
/// Injects filing context (PAN, AY, income sources, active module, tax regime)
/// into the user question so that the retriever can return more targeted
/// law chunks and the LLM can answer with greater precision.
///
/// Usage:
/// ```dart
/// final builder = TaxLawContext();
/// final query = builder.buildQuery(
///   'Can I claim HRA under the new tax regime?',
///   FilingContext(assessmentYear: '2024-25', taxRegime: 'new'),
/// );
/// await ragPipeline.retrieve(query.enrichedPrompt);
/// ```
class TaxLawContext {
  const TaxLawContext();

  // ---------------------------------------------------------------------------
  // buildQuery
  // ---------------------------------------------------------------------------

  /// Builds a [RagQuery] by injecting [context] into [userQuestion].
  ///
  /// The enriched prompt follows a structured format so the LLM can parse
  /// context and question independently:
  ///
  /// ```
  /// [Context]
  /// Assessment Year: 2024-25
  /// Tax Regime: New
  /// Income Sources: salary, house_property
  /// Active Form: ITR-1
  ///
  /// [Question]
  /// Can I claim HRA under the new tax regime?
  /// ```
  RagQuery buildQuery(String userQuestion, FilingContext context) {
    final contextBlock = _buildContextBlock(context);
    final enrichedPrompt = contextBlock.isEmpty
        ? userQuestion
        : '$contextBlock\n[Question]\n$userQuestion';

    final filterTags = _buildFilterTags(context);
    final metadata = _buildMetadata(context);

    return RagQuery(
      enrichedPrompt: enrichedPrompt,
      filterTags: List.unmodifiable(filterTags),
      metadata: Map.unmodifiable(metadata),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  String _buildContextBlock(FilingContext context) {
    final lines = <String>[];

    if (context.assessmentYear != null) {
      lines.add('Assessment Year: ${context.assessmentYear}');
    }

    if (context.taxRegime != null) {
      final regimeLabel = context.taxRegime == 'new'
          ? 'New Regime'
          : 'Old Regime';
      lines.add('Tax Regime: $regimeLabel');
    }

    if (context.incomeSources.isNotEmpty) {
      final sourceLabels = context.incomeSources
          .map(_incomeSourceLabel)
          .join(', ');
      lines.add('Income Sources: $sourceLabels');
    }

    if (context.activeModule != null) {
      final formLabel = _formLabel(context.activeModule!);
      lines.add('Active Form: $formLabel');
    }

    if (context.clientPan != null) {
      // Include only the masked PAN for privacy (first 5 chars masked).
      final masked =
          '${context.clientPan!.substring(0, 2)}XXX${context.clientPan!.substring(5)}';
      lines.add('Client PAN: $masked');
    }

    if (lines.isEmpty) return '';
    return '[Context]\n${lines.join('\n')}\n';
  }

  List<String> _buildFilterTags(FilingContext context) {
    final tags = <String>[];

    if (context.activeModule != null) {
      tags.add(context.activeModule!.toLowerCase());
    }

    for (final source in context.incomeSources) {
      tags.add(source.toLowerCase());
    }

    if (context.taxRegime != null) {
      tags.add('regime_${context.taxRegime!.toLowerCase()}');
    }

    // Always include 'income_tax_act' for ITR-related modules
    final itrModules = {'itr1', 'itr2', 'itr3', 'itr4'};
    if (context.activeModule != null &&
        itrModules.contains(context.activeModule!.toLowerCase())) {
      tags.add('income_tax_act');
      tags.add('income_tax_rules');
    }

    if (context.activeModule != null &&
        context.activeModule!.toLowerCase().startsWith('gstr')) {
      tags.add('cgst_act');
      tags.add('igst_act');
    }

    return tags;
  }

  Map<String, String> _buildMetadata(FilingContext context) {
    return {
      if (context.assessmentYear != null) 'ay': context.assessmentYear!,
      if (context.activeModule != null) 'module': context.activeModule!,
      if (context.taxRegime != null) 'regime': context.taxRegime!,
      'income_sources': context.incomeSources.join(','),
      'query_built_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  String _incomeSourceLabel(String source) {
    const labels = {
      'salary': 'Salary',
      'house_property': 'House Property',
      'capital_gains': 'Capital Gains',
      'business': 'Business / Profession',
      'other_sources': 'Other Sources',
      'agriculture': 'Agricultural Income',
      'foreign': 'Foreign Income',
    };
    return labels[source.toLowerCase()] ?? source;
  }

  String _formLabel(String module) {
    const labels = {
      'itr1': 'ITR-1 (Sahaj)',
      'itr2': 'ITR-2',
      'itr3': 'ITR-3',
      'itr4': 'ITR-4 (Sugam)',
      'gstr1': 'GSTR-1',
      'gstr3b': 'GSTR-3B',
      'tds': 'TDS Return',
    };
    return labels[module.toLowerCase()] ?? module.toUpperCase();
  }
}
