import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/sme_cfo/data/repositories/mock_sme_cfo_repository.dart';
import 'package:ca_app/features/sme_cfo/data/repositories/sme_cfo_repository_impl.dart';
import 'package:ca_app/features/sme_cfo/domain/repositories/sme_cfo_repository.dart';

/// Provides the active [SmeCfoRepository].
///
/// Returns [MockSmeCfoRepository] unless the `sme_cfo_real_repo`
/// feature flag is enabled, in which case [SmeCfoRepositoryImpl] is used.
final smeCfoRepositoryProvider = Provider<SmeCfoRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('sme_cfo_real_repo') ?? false;

  if (!useReal) {
    return MockSmeCfoRepository();
  }

  return SmeCfoRepositoryImpl(Supabase.instance.client);
});
