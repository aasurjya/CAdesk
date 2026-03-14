import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/tax_advisory/data/repositories/mock_tax_advisory_repository.dart';
import 'package:ca_app/features/tax_advisory/data/repositories/tax_advisory_repository_impl.dart';
import 'package:ca_app/features/tax_advisory/domain/repositories/tax_advisory_repository.dart';

/// Provides the active [TaxAdvisoryRepository].
///
/// Returns [MockTaxAdvisoryRepository] unless the `tax_advisory_real_repo`
/// feature flag is enabled, in which case [TaxAdvisoryRepositoryImpl] is used.
final taxAdvisoryRepositoryProvider = Provider<TaxAdvisoryRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('tax_advisory_real_repo') ?? false;

  if (!useReal) {
    return MockTaxAdvisoryRepository();
  }

  return const TaxAdvisoryRepositoryImpl();
});
