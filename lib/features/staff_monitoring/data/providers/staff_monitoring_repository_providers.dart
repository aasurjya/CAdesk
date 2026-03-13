import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/staff_monitoring/data/datasources/staff_monitoring_local_source.dart';
import 'package:ca_app/features/staff_monitoring/data/datasources/staff_monitoring_remote_source.dart';
import 'package:ca_app/features/staff_monitoring/data/repositories/mock_staff_monitoring_repository.dart';
import 'package:ca_app/features/staff_monitoring/data/repositories/staff_monitoring_repository_impl.dart';
import 'package:ca_app/features/staff_monitoring/domain/repositories/staff_monitoring_repository.dart';

final staffMonitoringRemoteSourceProvider =
    Provider<StaffMonitoringRemoteSource>((ref) {
  return StaffMonitoringRemoteSource(Supabase.instance.client);
});

final staffMonitoringLocalSourceProvider =
    Provider<StaffMonitoringLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StaffMonitoringLocalSource(db);
});

final staffMonitoringRepositoryProvider =
    Provider<StaffMonitoringRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('staff_monitoring_real_repo') ?? false;

  if (!useReal) {
    return MockStaffMonitoringRepository();
  }

  return StaffMonitoringRepositoryImpl(
    remote: ref.watch(staffMonitoringRemoteSourceProvider),
    local: ref.watch(staffMonitoringLocalSourceProvider),
  );
});
