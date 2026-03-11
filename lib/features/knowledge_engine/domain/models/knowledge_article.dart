import 'package:flutter/material.dart';

enum KnowledgeCategory {
  circulars('Circulars', Icons.announcement_rounded),
  caselaw('Case Law', Icons.gavel_rounded),
  sop('SOPs', Icons.checklist_rounded),
  templates('Templates', Icons.description_rounded),
  precedents('Precedents', Icons.history_edu_rounded),
  faqs('FAQs', Icons.quiz_rounded);

  const KnowledgeCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class KnowledgeArticle {
  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.tags,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.viewCount,
    required this.isPinned,
  });

  final String id;
  final String title;
  final KnowledgeCategory category;
  final List<String> tags;
  final String content;
  final String author;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final int viewCount;
  final bool isPinned;

  String get timeAgo {
    final now = DateTime(2026, 3, 11);
    final diff = now.difference(lastUpdatedAt);
    if (diff.inDays >= 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays >= 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    }
    return 'Today';
  }

  KnowledgeArticle copyWith({
    String? id,
    String? title,
    KnowledgeCategory? category,
    List<String>? tags,
    String? content,
    String? author,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    int? viewCount,
    bool? isPinned,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      viewCount: viewCount ?? this.viewCount,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
