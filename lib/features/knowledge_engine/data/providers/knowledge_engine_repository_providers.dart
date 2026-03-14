import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/knowledge_engine/data/repositories/knowledge_engine_repository_impl.dart';
import 'package:ca_app/features/knowledge_engine/data/repositories/mock_knowledge_engine_repository.dart';
import 'package:ca_app/features/knowledge_engine/domain/repositories/knowledge_engine_repository.dart';

/// Provides the active [KnowledgeEngineRepository].
///
/// Returns [MockKnowledgeEngineRepository] unless the
/// `knowledge_engine_real_repo` feature flag is enabled, in which case
/// [KnowledgeEngineRepositoryImpl] (Supabase) is used.
final knowledgeEngineRepositoryProvider = Provider<KnowledgeEngineRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('knowledge_engine_real_repo') ?? false;

  if (!useReal) {
    return MockKnowledgeEngineRepository();
  }

  return KnowledgeEngineRepositoryImpl(Supabase.instance.client);
});
