import 'package:ca_app/features/ca_gpt/domain/models/tax_citation.dart';

/// An immutable answer produced by the CA GPT knowledge engine.
///
/// Use [copyWith] to derive a modified copy without mutating the original.
class TaxAnswer {
  const TaxAnswer({
    required this.queryId,
    required this.answer,
    required this.citations,
    required this.confidence,
    required this.generatedAt,
    this.caveat,
  });

  final String queryId;
  final String answer;

  /// Legal citations supporting the answer.
  final List<TaxCitation> citations;

  /// Confidence score in range 0.0–1.0.
  final double confidence;

  /// Optional disclaimer, e.g. "Please verify with the latest circular.".
  final String? caveat;

  final DateTime generatedAt;

  TaxAnswer copyWith({
    String? queryId,
    String? answer,
    List<TaxCitation>? citations,
    double? confidence,
    String? caveat,
    DateTime? generatedAt,
  }) {
    return TaxAnswer(
      queryId: queryId ?? this.queryId,
      answer: answer ?? this.answer,
      citations: citations ?? this.citations,
      confidence: confidence ?? this.confidence,
      caveat: caveat ?? this.caveat,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaxAnswer) return false;
    if (other.queryId != queryId ||
        other.answer != answer ||
        other.confidence != confidence ||
        other.caveat != caveat ||
        other.generatedAt != generatedAt) {
      return false;
    }
    if (other.citations.length != citations.length) return false;
    for (int i = 0; i < citations.length; i++) {
      if (other.citations[i] != citations[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    queryId,
    answer,
    Object.hashAll(citations),
    confidence,
    caveat,
    generatedAt,
  );
}
