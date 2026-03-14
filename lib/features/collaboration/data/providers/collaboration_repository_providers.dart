import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/collaboration/data/datasources/collaboration_local_source.dart';
import 'package:ca_app/features/collaboration/data/datasources/collaboration_remote_source.dart';
import 'package:ca_app/features/collaboration/data/repositories/collaboration_repository_impl.dart';
import 'package:ca_app/features/collaboration/data/repositories/mock_collaboration_repository.dart';
import 'package:ca_app/features/collaboration/domain/repositories/collaboration_repository.dart';

/// Provides the [CollaborationRemoteSource] (Supabase client).
final collaborationRemoteSourceProvider = Provider<CollaborationRemoteSource>((
  ref,
) {
  return CollaborationRemoteSource(Supabase.instance.client);
});

/// Provides the [CollaborationLocalSource] (in-memory cache).
final collaborationLocalSourceProvider = Provider<CollaborationLocalSource>((
  ref,
) {
  return CollaborationLocalSource();
});

/// Provides the active [CollaborationRepository].
///
/// Returns [MockCollaborationRepository] unless the `collaboration_real_repo`
/// feature flag is enabled, in which case [CollaborationRepositoryImpl] is used.
final collaborationRepositoryProvider = Provider<CollaborationRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('collaboration_real_repo') ?? false;

  if (!useReal) {
    return MockCollaborationRepository();
  }

  return CollaborationRepositoryImpl(
    remote: ref.watch(collaborationRemoteSourceProvider),
    local: ref.watch(collaborationLocalSourceProvider),
  );
});
