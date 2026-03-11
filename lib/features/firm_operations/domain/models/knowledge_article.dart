import 'package:flutter/foundation.dart';

/// Category of a knowledge base article.
enum ArticleCategory {
  sop(label: 'SOP'),
  template(label: 'Template'),
  guide(label: 'Guide'),
  circular(label: 'Circular'),
  notification(label: 'Notification');

  const ArticleCategory({required this.label});

  final String label;
}

/// Immutable model representing a knowledge base article.
@immutable
class KnowledgeArticle {
  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.isPublished,
  });

  final String id;
  final String title;
  final ArticleCategory category;
  final String content;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPublished;

  /// Returns a new [KnowledgeArticle] with the given fields replaced.
  KnowledgeArticle copyWith({
    String? id,
    String? title,
    ArticleCategory? category,
    String? content,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPublished,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeArticle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          content == other.content &&
          author == other.author &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isPublished == other.isPublished;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    content,
    author,
    createdAt,
    updatedAt,
    isPublished,
  );

  @override
  String toString() =>
      'KnowledgeArticle(id: $id, title: $title, category: ${category.label})';
}
