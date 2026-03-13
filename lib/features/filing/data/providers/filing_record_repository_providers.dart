import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/filing/data/datasources/filing_record_local_source.dart';
import 'package:ca_app/features/filing/data/datasources/filing_record_remote_source.dart';
import 'package:ca_app/features/filing/data/repositories/filing_record_repository_impl.dart';
import 'package:ca_app/features/filing/data/repositories/mock_filing_record_repository.dart';
import 'package:ca_app/features/filing/domain/repositories/filing_record_repository.dart';

final filingRecordRemoteSourceProvider =
    Provider<FilingRecordRemoteSource>((ref) {
  return FilingRecordRemoteSource(Supabase.instance.client);
});

final filingRecordLocalSourceProvider =
    Provider<FilingRecordLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FilingRecordLocalSource(db);
});

final filingRecordRepositoryProvider = Provider<FilingRecordRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('filing_real_repo') ?? false;

  if (!useReal) {
    return MockFilingRecordRepository();
  }

  return FilingRecordRepositoryImpl(
    remote: ref.watch(filingRecordRemoteSourceProvider),
    local: ref.watch(filingRecordLocalSourceProvider),
  );
});
