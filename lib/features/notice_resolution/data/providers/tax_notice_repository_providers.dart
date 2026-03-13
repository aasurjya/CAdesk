import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/notice_resolution/data/datasources/tax_notice_local_source.dart';
import 'package:ca_app/features/notice_resolution/data/datasources/tax_notice_remote_source.dart';
import 'package:ca_app/features/notice_resolution/data/repositories/mock_tax_notice_repository.dart';
import 'package:ca_app/features/notice_resolution/data/repositories/tax_notice_repository_impl.dart';
import 'package:ca_app/features/notice_resolution/domain/repositories/tax_notice_repository.dart';

final taxNoticeRemoteSourceProvider = Provider<TaxNoticeRemoteSource>((ref) {
  return TaxNoticeRemoteSource(Supabase.instance.client);
});

final taxNoticeLocalSourceProvider = Provider<TaxNoticeLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaxNoticeLocalSource(db);
});

final taxNoticeRepositoryProvider = Provider<TaxNoticeRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('notice_resolution_real_repo') ?? false;

  if (!useReal) {
    return MockTaxNoticeRepository();
  }

  return TaxNoticeRepositoryImpl(
    remote: ref.watch(taxNoticeRemoteSourceProvider),
    local: ref.watch(taxNoticeLocalSourceProvider),
  );
});
