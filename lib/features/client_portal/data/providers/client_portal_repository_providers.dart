import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/client_portal/data/datasources/client_portal_local_source.dart';
import 'package:ca_app/features/client_portal/data/datasources/client_portal_remote_source.dart';
import 'package:ca_app/features/client_portal/data/repositories/client_portal_repository_impl.dart';
import 'package:ca_app/features/client_portal/data/repositories/mock_client_portal_repository.dart';
import 'package:ca_app/features/client_portal/domain/repositories/client_portal_repository.dart';

/// Provides the [ClientPortalRemoteSource] (Supabase client).
final clientPortalRemoteSourceProvider = Provider<ClientPortalRemoteSource>((
  ref,
) {
  return ClientPortalRemoteSource(Supabase.instance.client);
});

/// Provides the [ClientPortalLocalSource] (in-memory cache).
final clientPortalLocalSourceProvider = Provider<ClientPortalLocalSource>((
  ref,
) {
  return ClientPortalLocalSource();
});

/// Provides the active [ClientPortalRepository].
///
/// Returns [MockClientPortalRepository] unless the `client_portal_real_repo`
/// feature flag is enabled, in which case [ClientPortalRepositoryImpl] is used.
final clientPortalRepositoryProvider = Provider<ClientPortalRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('client_portal_real_repo') ?? false;

  if (!useReal) {
    return MockClientPortalRepository();
  }

  return ClientPortalRepositoryImpl(
    remote: ref.watch(clientPortalRemoteSourceProvider),
    local: ref.watch(clientPortalLocalSourceProvider),
  );
});
