import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/ai/providers/ai_gateway_provider.dart';
import 'package:ca_app/core/ai/rag/indexer/embedding_indexer.dart';
import 'package:ca_app/core/ai/rag/pipeline/context_formatter.dart';
import 'package:ca_app/core/ai/rag/pipeline/rag_pipeline.dart';
import 'package:ca_app/core/ai/rag/retriever/hybrid_retriever.dart';
import 'package:ca_app/core/ai/rag/retriever/local_keyword_retriever.dart';
import 'package:ca_app/core/ai/rag/retriever/supabase_vector_retriever.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';

/// Provides the [HybridRetriever] combining vector and keyword search.
final hybridRetrieverProvider = Provider<HybridRetriever>((ref) {
  final gateway = ref.watch(aiGatewayProvider);

  return HybridRetriever(
    vectorRetriever: SupabaseVectorRetriever(gateway: gateway),
    keywordRetriever: const LocalKeywordRetriever(),
  );
});

/// Provides the [RagPipeline] for retrieval-augmented generation.
///
/// Falls back to keyword-only search when `ai_rag_enabled` is off.
final ragPipelineProvider = Provider<RagPipeline>((ref) {
  final gateway = ref.watch(aiGatewayProvider);
  final flags = ref.watch(featureFlagProvider).asData?.value;
  final ragEnabled = flags?.isEnabled('ai_rag_enabled') ?? false;

  if (!ragEnabled) {
    // Keyword-only fallback
    return RagPipeline(
      gateway: gateway,
      retriever: HybridRetriever(
        vectorRetriever: const LocalKeywordRetriever(),
        keywordRetriever: const LocalKeywordRetriever(),
        vectorWeight: 0.0,
        keywordWeight: 1.0,
      ),
    );
  }

  return RagPipeline(
    gateway: gateway,
    retriever: ref.watch(hybridRetrieverProvider),
  );
});

/// Provides the [EmbeddingIndexer] for document indexing.
final embeddingIndexerProvider = Provider<EmbeddingIndexer>((ref) {
  final gateway = ref.watch(aiGatewayProvider);
  return EmbeddingIndexer(gateway: gateway);
});

/// Provides the [ContextFormatter] singleton.
final contextFormatterProvider = Provider<ContextFormatter>(
  (_) => const ContextFormatter(),
);
