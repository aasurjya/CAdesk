import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/today/data/repositories/mock_today_repository.dart';
import 'package:ca_app/features/today/data/repositories/today_repository_impl.dart';
import 'package:ca_app/features/today/domain/repositories/today_repository.dart';

/// Provides the active [TodayRepository].
///
/// Returns [MockTodayRepository] unless the `today_real_repo` feature flag
/// is enabled, in which case [TodayRepositoryImpl] is used.
final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('today_real_repo') ?? false;

  if (!useReal) {
    return MockTodayRepository();
  }

  return const TodayRepositoryImpl();
});
