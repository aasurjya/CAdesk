import 'package:ca_app/features/knowledge_engine/domain/models/knowledge_article.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/sop_document.dart';

/// Abstract contract for knowledge engine data operations.
///
/// Covers knowledge articles (circulars, case law, templates, etc.)
/// and SOP documents.
abstract class KnowledgeEngineRepository {
  // -------------------------------------------------------------------------
  // KnowledgeArticle operations
  // -------------------------------------------------------------------------

  /// Retrieve all knowledge articles.
  Future<List<KnowledgeArticle>> getArticles();

  /// Retrieve articles filtered by [category].
  Future<List<KnowledgeArticle>> getArticlesByCategory(
    KnowledgeCategory category,
  );

  /// Full-text search across article titles, tags, and content.
  Future<List<KnowledgeArticle>> searchArticles(String query);

  /// Retrieve a single article by [id]. Returns null if not found.
  Future<KnowledgeArticle?> getArticleById(String id);

  /// Insert a new [KnowledgeArticle] and return its ID.
  Future<String> insertArticle(KnowledgeArticle article);

  /// Update an existing [KnowledgeArticle]. Returns true on success.
  Future<bool> updateArticle(KnowledgeArticle article);

  /// Delete the article identified by [id]. Returns true on success.
  Future<bool> deleteArticle(String id);

  // -------------------------------------------------------------------------
  // SopDocument operations
  // -------------------------------------------------------------------------

  /// Retrieve all SOP documents.
  Future<List<SopDocument>> getSopDocuments();

  /// Retrieve SOP documents for a specific [module].
  Future<List<SopDocument>> getSopDocumentsByModule(String module);

  /// Insert a new [SopDocument] and return its ID.
  Future<String> insertSopDocument(SopDocument sop);

  /// Update an existing [SopDocument]. Returns true on success.
  Future<bool> updateSopDocument(SopDocument sop);

  /// Delete the SOP document identified by [id]. Returns true on success.
  Future<bool> deleteSopDocument(String id);
}
