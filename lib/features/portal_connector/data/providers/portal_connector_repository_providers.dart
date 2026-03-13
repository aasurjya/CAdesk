import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/portal_connector/data/datasources/portal_connector_local_source.dart';
import 'package:ca_app/features/portal_connector/data/datasources/portal_connector_remote_source.dart';
import 'package:ca_app/features/portal_connector/data/repositories/mock_portal_connector_repository.dart';
import 'package:ca_app/features/portal_connector/data/repositories/portal_connector_repository_impl.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

/// Provides the [PortalConnectorRemoteSource] backed by Supabase.
final portalConnectorRemoteSourceProvider =
    Provider<PortalConnectorRemoteSource>((ref) {
  return PortalConnectorRemoteSource(Supabase.instance.client);
});

/// Provides the [PortalConnectorLocalSource] backed by the local Drift DB.
final portalConnectorLocalSourceProvider =
    Provider<PortalConnectorLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PortalConnectorLocalSource(db);
});

/// Provides the [PortalCredentialRepository].
///
/// Uses the real [PortalConnectorRepositoryImpl] when the
/// `portal_connector_real_repo` feature flag is enabled; otherwise falls back
/// to the [MockPortalCredentialRepository] for offline/dev use.
final portalCredentialRepositoryProvider =
    Provider<PortalCredentialRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('portal_connector_real_repo') ?? false;

  if (!useReal) {
    return MockPortalCredentialRepository();
  }

  return PortalConnectorRepositoryImpl(
    local: ref.watch(portalConnectorLocalSourceProvider),
    remote: ref.watch(portalConnectorRemoteSourceProvider),
  );
});
