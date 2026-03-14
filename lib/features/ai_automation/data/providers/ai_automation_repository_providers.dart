import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/ai_automation/data/datasources/ai_automation_local_source.dart';
import 'package:ca_app/features/ai_automation/data/datasources/ai_automation_remote_source.dart';
import 'package:ca_app/features/ai_automation/data/repositories/ai_automation_repository_impl.dart';
import 'package:ca_app/features/ai_automation/data/repositories/mock_ai_automation_repository.dart';
import 'package:ca_app/features/ai_automation/domain/repositories/ai_automation_repository.dart';

/// Provides the [AiAutomationRemoteSource] (Supabase client).
final aiAutomationRemoteSourceProvider = Provider<AiAutomationRemoteSource>((
  ref,
) {
  return AiAutomationRemoteSource(Supabase.instance.client);
});

/// Provides the [AiAutomationLocalSource] (Drift/SQLite).
final aiAutomationLocalSourceProvider = Provider<AiAutomationLocalSource>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return AiAutomationLocalSource(db);
});

/// Provides the active [AiAutomationRepository].
///
/// Returns [MockAiAutomationRepository] unless the `ai_automation_real_repo`
/// feature flag is enabled, in which case [AiAutomationRepositoryImpl] is used.
final aiAutomationRepositoryProvider = Provider<AiAutomationRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('ai_automation_real_repo') ?? false;

  if (!useReal) {
    return MockAiAutomationRepository();
  }

  return AiAutomationRepositoryImpl(
    remote: ref.watch(aiAutomationRemoteSourceProvider),
    local: ref.watch(aiAutomationLocalSourceProvider),
  );
});
