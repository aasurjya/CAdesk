import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/knowledge_article.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/sop_document.dart';
import 'package:ca_app/features/knowledge_engine/domain/repositories/knowledge_engine_repository.dart';

/// Real implementation of [KnowledgeEngineRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class KnowledgeEngineRepositoryImpl implements KnowledgeEngineRepository {
  const KnowledgeEngineRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _articlesTable = 'knowledge_articles';
  static const _sopsTable = 'sop_documents';

  // -------------------------------------------------------------------------
  // KnowledgeArticle
  // -------------------------------------------------------------------------

  @override
  Future<List<KnowledgeArticle>> getArticles() async {
    try {
      final rows = await _client.from(_articlesTable).select();
      return List.unmodifiable((rows as List).map(_articleFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<KnowledgeArticle>> getArticlesByCategory(
    KnowledgeCategory category,
  ) async {
    try {
      final rows = await _client
          .from(_articlesTable)
          .select()
          .eq('category', category.name);
      return List.unmodifiable((rows as List).map(_articleFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<KnowledgeArticle>> searchArticles(String query) async {
    try {
      final rows = await _client
          .from(_articlesTable)
          .select()
          .ilike('title', '%$query%');
      return List.unmodifiable((rows as List).map(_articleFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<KnowledgeArticle?> getArticleById(String id) async {
    try {
      final row = await _client
          .from(_articlesTable)
          .select()
          .eq('id', id)
          .single();
      return _articleFromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertArticle(KnowledgeArticle article) async {
    final row = await _client
        .from(_articlesTable)
        .insert(_articleToRow(article))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateArticle(KnowledgeArticle article) async {
    try {
      await _client
          .from(_articlesTable)
          .update(_articleToRow(article))
          .eq('id', article.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteArticle(String id) async {
    try {
      await _client.from(_articlesTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // SopDocument
  // -------------------------------------------------------------------------

  @override
  Future<List<SopDocument>> getSopDocuments() async {
    try {
      final rows = await _client.from(_sopsTable).select();
      return List.unmodifiable((rows as List).map(_sopFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<SopDocument>> getSopDocumentsByModule(String module) async {
    try {
      final rows = await _client.from(_sopsTable).select().eq('module', module);
      return List.unmodifiable((rows as List).map(_sopFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertSopDocument(SopDocument sop) async {
    final row = await _client
        .from(_sopsTable)
        .insert(_sopToRow(sop))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateSopDocument(SopDocument sop) async {
    try {
      await _client.from(_sopsTable).update(_sopToRow(sop)).eq('id', sop.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteSopDocument(String id) async {
    try {
      await _client.from(_sopsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mappers
  // -------------------------------------------------------------------------

  KnowledgeArticle _articleFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return KnowledgeArticle(
      id: m['id'] as String,
      title: m['title'] as String,
      category: KnowledgeCategory.values.firstWhere(
        (e) => e.name == m['category'],
      ),
      tags: List<String>.from(m['tags'] as List),
      content: m['content'] as String,
      author: m['author'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      lastUpdatedAt: DateTime.parse(m['last_updated_at'] as String),
      viewCount: m['view_count'] as int,
      isPinned: m['is_pinned'] as bool,
    );
  }

  Map<String, dynamic> _articleToRow(KnowledgeArticle a) => {
    'id': a.id,
    'title': a.title,
    'category': a.category.name,
    'tags': a.tags,
    'content': a.content,
    'author': a.author,
    'created_at': a.createdAt.toIso8601String(),
    'last_updated_at': a.lastUpdatedAt.toIso8601String(),
    'view_count': a.viewCount,
    'is_pinned': a.isPinned,
  };

  SopDocument _sopFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return SopDocument(
      id: m['id'] as String,
      title: m['title'] as String,
      module: m['module'] as String,
      steps: List<String>.from(m['steps'] as List),
      lastReviewedAt: DateTime.parse(m['last_reviewed_at'] as String),
      version: m['version'] as String,
      isActive: m['is_active'] as bool,
    );
  }

  Map<String, dynamic> _sopToRow(SopDocument s) => {
    'id': s.id,
    'title': s.title,
    'module': s.module,
    'steps': s.steps,
    'last_reviewed_at': s.lastReviewedAt.toIso8601String(),
    'version': s.version,
    'is_active': s.isActive,
  };
}
