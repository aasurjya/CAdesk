/// The broad legal/regulatory category an article belongs to.
enum KnowledgeCategory { incomeTax, gst, companiesAct, fema, custom, tds }

/// An immutable knowledge-base article covering a tax law provision.
///
/// Use [copyWith] to derive a modified copy without mutating the original.
class KnowledgeArticle {
  const KnowledgeArticle({
    required this.articleId,
    required this.title,
    required this.category,
    required this.content,
    required this.sections,
    required this.lastUpdated,
    required this.isLatest,
    required this.keywords,
  });

  final String articleId;
  final String title;
  final KnowledgeCategory category;

  /// Full article text.
  final String content;

  /// List of section numbers referenced, e.g. ["44AD", "44ADA"].
  final List<String> sections;

  final DateTime lastUpdated;

  /// Whether this article reflects the latest amendment.
  final bool isLatest;

  /// Search keywords for this article.
  final List<String> keywords;

  KnowledgeArticle copyWith({
    String? articleId,
    String? title,
    KnowledgeCategory? category,
    String? content,
    List<String>? sections,
    DateTime? lastUpdated,
    bool? isLatest,
    List<String>? keywords,
  }) {
    return KnowledgeArticle(
      articleId: articleId ?? this.articleId,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      sections: sections ?? this.sections,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLatest: isLatest ?? this.isLatest,
      keywords: keywords ?? this.keywords,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KnowledgeArticle) return false;
    if (other.articleId != articleId ||
        other.title != title ||
        other.category != category ||
        other.content != content ||
        other.lastUpdated != lastUpdated ||
        other.isLatest != isLatest) {
      return false;
    }
    if (other.sections.length != sections.length) return false;
    for (int i = 0; i < sections.length; i++) {
      if (other.sections[i] != sections[i]) return false;
    }
    if (other.keywords.length != keywords.length) return false;
    for (int i = 0; i < keywords.length; i++) {
      if (other.keywords[i] != keywords[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    articleId,
    title,
    category,
    content,
    Object.hashAll(sections),
    lastUpdated,
    isLatest,
    Object.hashAll(keywords),
  );
}
