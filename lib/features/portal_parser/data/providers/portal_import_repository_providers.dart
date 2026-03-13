import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/portal_parser/data/datasources/portal_import_local_source.dart';
import 'package:ca_app/features/portal_parser/data/datasources/portal_import_remote_source.dart';
import 'package:ca_app/features/portal_parser/data/repositories/portal_import_repository_impl.dart';
import 'package:ca_app/features/portal_parser/data/repositories/mock_portal_import_repository.dart';
import 'package:ca_app/features/portal_parser/domain/repositories/portal_import_repository.dart';

final portalImportRemoteSourceProvider =
    Provider<PortalImportRemoteSource>((ref) {
  return PortalImportRemoteSource(Supabase.instance.client);
});

final portalImportLocalSourceProvider =
    Provider<PortalImportLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PortalImportLocalSource(db);
});

final portalImportRepositoryProvider = Provider<PortalImportRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('portal_parser_real_repo') ?? false;

  if (!useReal) {
    return MockPortalImportRepository();
  }

  return PortalImportRepositoryImpl(
    remote: ref.watch(portalImportRemoteSourceProvider),
    local: ref.watch(portalImportLocalSourceProvider),
  );
});
