import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/crypto_vda/data/datasources/crypto_vda_local_source.dart';
import 'package:ca_app/features/crypto_vda/data/datasources/crypto_vda_remote_source.dart';
import 'package:ca_app/features/crypto_vda/data/repositories/crypto_vda_repository_impl.dart';
import 'package:ca_app/features/crypto_vda/data/repositories/mock_crypto_vda_repository.dart';
import 'package:ca_app/features/crypto_vda/domain/repositories/crypto_vda_repository.dart';

/// Provides the [CryptoVdaRemoteSource] (Supabase client).
final cryptoVdaRemoteSourceProvider = Provider<CryptoVdaRemoteSource>((ref) {
  return CryptoVdaRemoteSource(Supabase.instance.client);
});

/// Provides the [CryptoVdaLocalSource] (Drift/SQLite).
final cryptoVdaLocalSourceProvider = Provider<CryptoVdaLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CryptoVdaLocalSource(db);
});

/// Provides the active [CryptoVdaRepository].
///
/// Returns [MockCryptoVdaRepository] unless the `crypto_vda_real_repo` feature
/// flag is enabled, in which case [CryptoVdaRepositoryImpl] is used.
final cryptoVdaRepositoryProvider = Provider<CryptoVdaRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('crypto_vda_real_repo') ?? false;

  if (!useReal) {
    return MockCryptoVdaRepository();
  }

  return CryptoVdaRepositoryImpl(
    remote: ref.watch(cryptoVdaRemoteSourceProvider),
    local: ref.watch(cryptoVdaLocalSourceProvider),
  );
});
