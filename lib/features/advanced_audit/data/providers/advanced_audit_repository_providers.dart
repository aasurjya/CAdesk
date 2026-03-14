import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/advanced_audit/data/datasources/advanced_audit_local_source.dart';
import 'package:ca_app/features/advanced_audit/data/datasources/advanced_audit_remote_source.dart';
import 'package:ca_app/features/advanced_audit/data/repositories/advanced_audit_repository_impl.dart';
import 'package:ca_app/features/advanced_audit/data/repositories/mock_advanced_audit_repository.dart';
import 'package:ca_app/features/advanced_audit/domain/repositories/advanced_audit_repository.dart';

/// Provides the [AdvancedAuditRemoteSource] (Supabase client).
final advancedAuditRemoteSourceProvider = Provider<AdvancedAuditRemoteSource>((
  ref,
) {
  return AdvancedAuditRemoteSource(Supabase.instance.client);
});

/// Provides the [AdvancedAuditLocalSource] (in-memory cache).
final advancedAuditLocalSourceProvider = Provider<AdvancedAuditLocalSource>((
  ref,
) {
  return AdvancedAuditLocalSource();
});

/// Provides the active [AdvancedAuditRepository].
///
/// Returns [MockAdvancedAuditRepository] unless the `advanced_audit_real_repo`
/// feature flag is enabled, in which case [AdvancedAuditRepositoryImpl] is used.
final advancedAuditRepositoryProvider = Provider<AdvancedAuditRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('advanced_audit_real_repo') ?? false;

  if (!useReal) {
    return MockAdvancedAuditRepository();
  }

  return AdvancedAuditRepositoryImpl(
    remote: ref.watch(advancedAuditRemoteSourceProvider),
    local: ref.watch(advancedAuditLocalSourceProvider),
  );
});
