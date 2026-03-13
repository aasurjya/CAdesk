import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/income_tax/data/datasources/itr_filing_local_source.dart';
import 'package:ca_app/features/income_tax/data/datasources/itr_filing_remote_source.dart';
import 'package:ca_app/features/income_tax/data/repositories/itr_filing_repository_impl.dart';
import 'package:ca_app/features/income_tax/data/repositories/mock_itr_filing_repository.dart';
import 'package:ca_app/features/income_tax/domain/repositories/itr_filing_repository.dart';

final itrFilingRemoteSourceProvider = Provider<ItrFilingRemoteSource>((ref) {
  return ItrFilingRemoteSource(Supabase.instance.client);
});

final itrFilingLocalSourceProvider = Provider<ItrFilingLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ItrFilingLocalSource(db);
});

final itrFilingRepositoryProvider = Provider<ItrFilingRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('income_tax_real_repo') ?? false;

  if (!useReal) {
    return MockItrFilingRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return ItrFilingRepositoryImpl(
    remote: ref.watch(itrFilingRemoteSourceProvider),
    local: ref.watch(itrFilingLocalSourceProvider),
    firmId: firmId,
  );
});
