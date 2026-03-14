import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/nri_tax/data/datasources/nri_tax_local_source.dart';
import 'package:ca_app/features/nri_tax/data/datasources/nri_tax_remote_source.dart';
import 'package:ca_app/features/nri_tax/data/repositories/mock_nri_tax_repository.dart';
import 'package:ca_app/features/nri_tax/data/repositories/nri_tax_repository_impl.dart';
import 'package:ca_app/features/nri_tax/domain/repositories/nri_tax_repository.dart';

final nriTaxRemoteSourceProvider = Provider<NriTaxRemoteSource>((ref) {
  return NriTaxRemoteSource(Supabase.instance.client);
});

final nriTaxLocalSourceProvider = Provider<NriTaxLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NriTaxLocalSource(db);
});

final nriTaxRepositoryProvider = Provider<NriTaxRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('nri_tax_real_repo') ?? false;

  if (!useReal) {
    return MockNriTaxRepository();
  }

  return NriTaxRepositoryImpl(
    remote: ref.watch(nriTaxRemoteSourceProvider),
    local: ref.watch(nriTaxLocalSourceProvider),
  );
});
