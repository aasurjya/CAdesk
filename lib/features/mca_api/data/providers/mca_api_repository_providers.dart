import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/core/network/api_client.dart';
import 'package:ca_app/features/mca_api/data/mock_mca_repository.dart';
import 'package:ca_app/features/mca_api/data/repositories/mca_api_repository_impl.dart';
import 'package:ca_app/features/mca_api/domain/repositories/mca_repository.dart';
import 'package:ca_app/features/portal_connector/data/providers/portal_connector_repository_providers.dart';

/// Provides the active [McaRepository].
///
/// Returns [MockMcaRepository] unless the `mca_api_real_repo` feature flag
/// is enabled. When the flag is enabled, [McaApiRepositoryImpl] is used with
/// live [Dio] and [PortalCredentialRepository] injected; the flag value is also
/// passed into the impl so it can decide whether to propagate errors or fall
/// back to mock data internally.
final mcaApiRepositoryProvider = Provider<McaRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('mca_api_real_repo') ?? false;

  if (!useReal) {
    return const MockMcaRepository();
  }

  return McaApiRepositoryImpl(
    dio: ref.watch(apiClientProvider),
    credentialRepository: ref.watch(portalCredentialRepositoryProvider),
    featureFlagEnabled: true,
  );
});
