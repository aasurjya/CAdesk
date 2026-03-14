import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/industry_playbooks/data/repositories/industry_playbooks_repository_impl.dart';
import 'package:ca_app/features/industry_playbooks/data/repositories/mock_industry_playbooks_repository.dart';
import 'package:ca_app/features/industry_playbooks/domain/repositories/industry_playbooks_repository.dart';

/// Provides the active [IndustryPlaybooksRepository].
///
/// Returns [MockIndustryPlaybooksRepository] unless the
/// `industry_playbooks_real_repo` feature flag is enabled, in which case
/// [IndustryPlaybooksRepositoryImpl] (Supabase) is used.
final industryPlaybooksRepositoryProvider =
    Provider<IndustryPlaybooksRepository>((ref) {
      final flags = ref.watch(featureFlagProvider);
      final useReal =
          flags.asData?.value.isEnabled('industry_playbooks_real_repo') ??
          false;

      if (!useReal) {
        return MockIndustryPlaybooksRepository();
      }

      return IndustryPlaybooksRepositoryImpl(Supabase.instance.client);
    });
