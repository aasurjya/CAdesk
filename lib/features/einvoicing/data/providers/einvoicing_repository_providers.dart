import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/einvoicing/data/datasources/einvoicing_local_source.dart';
import 'package:ca_app/features/einvoicing/data/datasources/einvoicing_remote_source.dart';
import 'package:ca_app/features/einvoicing/data/repositories/einvoicing_repository_impl.dart';
import 'package:ca_app/features/einvoicing/data/repositories/mock_einvoicing_repository.dart';
import 'package:ca_app/features/einvoicing/domain/repositories/einvoicing_repository.dart';

/// Provides the [EinvoicingRemoteSource] (Supabase client).
final einvoicingRemoteSourceProvider = Provider<EinvoicingRemoteSource>((ref) {
  return EinvoicingRemoteSource(Supabase.instance.client);
});

/// Provides the [EinvoicingLocalSource] (Drift/SQLite).
final einvoicingLocalSourceProvider = Provider<EinvoicingLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return EinvoicingLocalSource(db);
});

/// Provides the active [EinvoicingRepository].
///
/// Returns [MockEinvoicingRepository] unless the `einvoicing_real_repo` feature
/// flag is enabled, in which case [EinvoicingRepositoryImpl] is used.
final einvoicingRepositoryProvider = Provider<EinvoicingRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('einvoicing_real_repo') ?? false;

  if (!useReal) {
    return MockEinvoicingRepository();
  }

  return EinvoicingRepositoryImpl(
    remote: ref.watch(einvoicingRemoteSourceProvider),
    local: ref.watch(einvoicingLocalSourceProvider),
  );
});
