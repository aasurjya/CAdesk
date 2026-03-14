import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/lead_funnel/data/repositories/lead_funnel_repository_impl.dart';
import 'package:ca_app/features/lead_funnel/data/repositories/mock_lead_funnel_repository.dart';
import 'package:ca_app/features/lead_funnel/domain/repositories/lead_funnel_repository.dart';

/// Provides the active [LeadFunnelRepository].
///
/// Returns [MockLeadFunnelRepository] unless the `lead_funnel_real_repo`
/// feature flag is enabled, in which case [LeadFunnelRepositoryImpl]
/// (Supabase) is used.
final leadFunnelRepositoryProvider = Provider<LeadFunnelRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('lead_funnel_real_repo') ?? false;

  if (!useReal) {
    return MockLeadFunnelRepository();
  }

  return LeadFunnelRepositoryImpl(Supabase.instance.client);
});
