import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/time_tracking/data/datasources/time_tracking_local_source.dart';
import 'package:ca_app/features/time_tracking/data/datasources/time_tracking_remote_source.dart';
import 'package:ca_app/features/time_tracking/data/repositories/mock_time_tracking_repository.dart';
import 'package:ca_app/features/time_tracking/data/repositories/time_tracking_repository_impl.dart';
import 'package:ca_app/features/time_tracking/domain/repositories/time_tracking_repository.dart';

final timeTrackingRemoteSourceProvider = Provider<TimeTrackingRemoteSource>((
  ref,
) {
  return TimeTrackingRemoteSource(Supabase.instance.client);
});

final timeTrackingLocalSourceProvider = Provider<TimeTrackingLocalSource>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return TimeTrackingLocalSource(db);
});

final timeTrackingRepositoryProvider = Provider<TimeTrackingRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('time_tracking_real_repo') ?? false;

  if (!useReal) {
    return MockTimeTrackingRepository();
  }

  return TimeTrackingRepositoryImpl(
    remote: ref.watch(timeTrackingRemoteSourceProvider),
    local: ref.watch(timeTrackingLocalSourceProvider),
  );
});
