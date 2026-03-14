import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/analytics/data/datasources/analytics_local_source.dart';
import 'package:ca_app/features/analytics/data/datasources/analytics_remote_source.dart';
import 'package:ca_app/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:ca_app/features/analytics/data/repositories/mock_analytics_repository.dart';
import 'package:ca_app/features/analytics/domain/repositories/analytics_repository.dart';

final analyticsRemoteSourceProvider = Provider<AnalyticsRemoteSource>((ref) {
  return AnalyticsRemoteSource(Supabase.instance.client);
});

final analyticsLocalSourceProvider = Provider<AnalyticsLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AnalyticsLocalSource(db);
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('analytics_real_repo') ?? false;

  if (!useReal) {
    return MockAnalyticsRepository();
  }

  return AnalyticsRepositoryImpl(
    remote: ref.watch(analyticsRemoteSourceProvider),
    local: ref.watch(analyticsLocalSourceProvider),
  );
});
