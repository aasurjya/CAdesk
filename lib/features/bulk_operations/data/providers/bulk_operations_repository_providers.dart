import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/bulk_operations/data/datasources/bulk_operations_local_source.dart';
import 'package:ca_app/features/bulk_operations/data/datasources/bulk_operations_remote_source.dart';
import 'package:ca_app/features/bulk_operations/data/repositories/bulk_operations_repository_impl.dart';
import 'package:ca_app/features/bulk_operations/data/repositories/mock_bulk_operations_repository.dart';
import 'package:ca_app/features/bulk_operations/domain/repositories/bulk_operations_repository.dart';

/// Provides the [BulkOperationsRemoteSource] (Supabase client).
final bulkOperationsRemoteSourceProvider = Provider<BulkOperationsRemoteSource>(
  (ref) {
    return BulkOperationsRemoteSource(Supabase.instance.client);
  },
);

/// Provides the [BulkOperationsLocalSource] (in-memory cache).
final bulkOperationsLocalSourceProvider = Provider<BulkOperationsLocalSource>((
  ref,
) {
  return BulkOperationsLocalSource();
});

/// Provides the active [BulkOperationsRepository].
///
/// Returns [MockBulkOperationsRepository] unless the `bulk_operations_real_repo`
/// feature flag is enabled, in which case [BulkOperationsRepositoryImpl] is used.
final bulkOperationsRepositoryProvider = Provider<BulkOperationsRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('bulk_operations_real_repo') ?? false;

  if (!useReal) {
    return MockBulkOperationsRepository();
  }

  return BulkOperationsRepositoryImpl(
    remote: ref.watch(bulkOperationsRemoteSourceProvider),
    local: ref.watch(bulkOperationsLocalSourceProvider),
  );
});
