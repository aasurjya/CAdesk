import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/accounts/data/datasources/accounts_local_source.dart';
import 'package:ca_app/features/accounts/data/datasources/accounts_remote_source.dart';
import 'package:ca_app/features/accounts/data/repositories/accounts_repository_impl.dart';
import 'package:ca_app/features/accounts/data/repositories/mock_accounts_repository.dart';
import 'package:ca_app/features/accounts/domain/repositories/accounts_repository.dart';

/// Provides the [AccountsRemoteSource] (Supabase client).
final accountsRemoteSourceProvider = Provider<AccountsRemoteSource>((ref) {
  return AccountsRemoteSource(Supabase.instance.client);
});

/// Provides the [AccountsLocalSource] (in-memory cache).
final accountsLocalSourceProvider = Provider<AccountsLocalSource>((ref) {
  return AccountsLocalSource();
});

/// Provides the active [AccountsRepository].
///
/// Returns [MockAccountsRepository] unless the `accounts_real_repo` feature
/// flag is enabled, in which case [AccountsRepositoryImpl] is used.
final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('accounts_real_repo') ?? false;

  if (!useReal) {
    return MockAccountsRepository();
  }

  return AccountsRepositoryImpl(
    remote: ref.watch(accountsRemoteSourceProvider),
    local: ref.watch(accountsLocalSourceProvider),
  );
});
