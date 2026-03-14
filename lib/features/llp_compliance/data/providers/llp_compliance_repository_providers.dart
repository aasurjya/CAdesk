import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/llp_compliance/data/repositories/llp_compliance_repository_impl.dart';
import 'package:ca_app/features/llp_compliance/data/repositories/mock_llp_compliance_repository.dart';
import 'package:ca_app/features/llp_compliance/domain/repositories/llp_compliance_repository.dart';

/// Provides the active [LlpComplianceRepository].
///
/// Returns [MockLlpComplianceRepository] unless the `llp_compliance_real_repo`
/// feature flag is enabled, in which case [LlpComplianceRepositoryImpl]
/// (Supabase) is used.
final llpComplianceRepositoryProvider = Provider<LlpComplianceRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('llp_compliance_real_repo') ?? false;

  if (!useReal) {
    return MockLlpComplianceRepository();
  }

  return LlpComplianceRepositoryImpl(Supabase.instance.client);
});
