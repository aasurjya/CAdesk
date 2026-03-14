import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/startup_compliance/data/repositories/mock_startup_compliance_repository.dart';
import 'package:ca_app/features/startup_compliance/data/repositories/startup_compliance_repository_impl.dart';
import 'package:ca_app/features/startup_compliance/domain/repositories/startup_compliance_repository.dart';

/// Provides the active [StartupComplianceRepository].
///
/// Returns [MockStartupComplianceRepository] unless the
/// `startup_compliance_real_repo` feature flag is enabled, in which case
/// [StartupComplianceRepositoryImpl] is used.
final startupComplianceRepositoryProvider =
    Provider<StartupComplianceRepository>((ref) {
      final flags = ref.watch(featureFlagProvider);
      final useReal =
          flags.asData?.value.isEnabled('startup_compliance_real_repo') ??
          false;

      if (!useReal) {
        return MockStartupComplianceRepository();
      }

      return StartupComplianceRepositoryImpl(Supabase.instance.client);
    });
