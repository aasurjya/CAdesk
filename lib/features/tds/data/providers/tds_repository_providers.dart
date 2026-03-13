import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/tds/data/datasources/tds_challan_local_source.dart';
import 'package:ca_app/features/tds/data/datasources/tds_challan_remote_source.dart';
import 'package:ca_app/features/tds/data/datasources/tds_return_local_source.dart';
import 'package:ca_app/features/tds/data/datasources/tds_return_remote_source.dart';
import 'package:ca_app/features/tds/data/repositories/mock_tds_challan_repository.dart';
import 'package:ca_app/features/tds/data/repositories/mock_tds_return_repository.dart';
import 'package:ca_app/features/tds/data/repositories/tds_challan_repository_impl.dart';
import 'package:ca_app/features/tds/data/repositories/tds_return_repository_impl.dart';
import 'package:ca_app/features/tds/domain/repositories/tds_challan_repository.dart';
import 'package:ca_app/features/tds/domain/repositories/tds_return_repository.dart';

final tdsReturnRemoteSourceProvider = Provider<TdsReturnRemoteSource>((ref) {
  return TdsReturnRemoteSource(Supabase.instance.client);
});

final tdsReturnLocalSourceProvider = Provider<TdsReturnLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TdsReturnLocalSource(db);
});

final tdsChallanRemoteSourceProvider = Provider<TdsChallanRemoteSource>((ref) {
  return TdsChallanRemoteSource(Supabase.instance.client);
});

final tdsChallanLocalSourceProvider = Provider<TdsChallanLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TdsChallanLocalSource(db);
});

final tdsReturnRepositoryProvider = Provider<TdsReturnRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('tds_real_repo') ?? false;

  if (!useReal) {
    return MockTdsReturnRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return TdsReturnRepositoryImpl(
    remote: ref.watch(tdsReturnRemoteSourceProvider),
    local: ref.watch(tdsReturnLocalSourceProvider),
    firmId: firmId,
  );
});

final tdsChallanRepositoryProvider = Provider<TdsChallanRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('tds_real_repo') ?? false;

  if (!useReal) {
    return MockTdsChallanRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return TdsChallanRepositoryImpl(
    remote: ref.watch(tdsChallanRemoteSourceProvider),
    local: ref.watch(tdsChallanLocalSourceProvider),
    firmId: firmId,
  );
});
