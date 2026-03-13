import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/dashboard/data/datasources/dashboard_local_source.dart';
import 'package:ca_app/features/dashboard/data/datasources/dashboard_remote_source.dart';
import 'package:ca_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:ca_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:ca_app/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRemoteSourceProvider = Provider<DashboardRemoteSource>((ref) {
  return DashboardRemoteSource(Supabase.instance.client);
});

final dashboardLocalSourceProvider = Provider<DashboardLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DashboardLocalSource(db);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('dashboard_real_repo') ?? false;

  if (!useReal) {
    return MockDashboardRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return DashboardRepositoryImpl(
    remote: ref.watch(dashboardRemoteSourceProvider),
    local: ref.watch(dashboardLocalSourceProvider),
    firmId: firmId,
  );
});
