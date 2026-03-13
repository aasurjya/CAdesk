import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/transfer_pricing/data/datasources/tp_local_source.dart';
import 'package:ca_app/features/transfer_pricing/data/datasources/tp_remote_source.dart';
import 'package:ca_app/features/transfer_pricing/data/repositories/mock_tp_repository.dart';
import 'package:ca_app/features/transfer_pricing/data/repositories/tp_repository_impl.dart';
import 'package:ca_app/features/transfer_pricing/domain/repositories/tp_transaction_repository.dart';

final tpRemoteSourceProvider = Provider<TpRemoteSource>((ref) {
  return TpRemoteSource(Supabase.instance.client);
});

final tpLocalSourceProvider = Provider<TpLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TpLocalSource(db);
});

final tpRepositoryProvider = Provider<TpTransactionRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('transfer_pricing_real_repo') ?? false;

  if (!useReal) {
    return MockTpRepository();
  }

  return TpRepositoryImpl(
    remote: ref.watch(tpRemoteSourceProvider),
    local: ref.watch(tpLocalSourceProvider),
  );
});
