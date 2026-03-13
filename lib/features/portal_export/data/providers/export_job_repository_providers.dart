import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/portal_export/data/datasources/export_job_local_source.dart';
import 'package:ca_app/features/portal_export/data/datasources/export_job_remote_source.dart';
import 'package:ca_app/features/portal_export/data/repositories/export_job_repository_impl.dart';
import 'package:ca_app/features/portal_export/data/repositories/mock_export_job_repository.dart';
import 'package:ca_app/features/portal_export/domain/repositories/export_job_repository.dart';

final exportJobRemoteSourceProvider = Provider<ExportJobRemoteSource>((ref) {
  return ExportJobRemoteSource(Supabase.instance.client);
});

final exportJobLocalSourceProvider = Provider<ExportJobLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExportJobLocalSource(db);
});

final exportJobRepositoryProvider = Provider<ExportJobRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('portal_export_real_repo') ?? false;

  if (!useReal) {
    return MockExportJobRepository();
  }

  return ExportJobRepositoryImpl(
    remote: ref.watch(exportJobRemoteSourceProvider),
    local: ref.watch(exportJobLocalSourceProvider),
  );
});
