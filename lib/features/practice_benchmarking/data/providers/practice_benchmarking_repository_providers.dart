import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/practice_benchmarking/data/repositories/mock_practice_benchmarking_repository.dart';
import 'package:ca_app/features/practice_benchmarking/data/repositories/practice_benchmarking_repository_impl.dart';
import 'package:ca_app/features/practice_benchmarking/domain/repositories/practice_benchmarking_repository.dart';

/// Provides the active [PracticeBenchmarkingRepository].
///
/// Returns [MockPracticeBenchmarkingRepository] unless the
/// `practice_benchmarking_real_repo` feature flag is enabled, in which case
/// [PracticeBenchmarkingRepositoryImpl] is used.
final practiceBenchmarkingRepositoryProvider =
    Provider<PracticeBenchmarkingRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('practice_benchmarking_real_repo') ?? false;

  if (!useReal) {
    return MockPracticeBenchmarkingRepository();
  }

  return PracticeBenchmarkingRepositoryImpl(Supabase.instance.client);
});
