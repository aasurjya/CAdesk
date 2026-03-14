import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/reconciliation/data/datasources/reconciliation_local_source.dart';
import 'package:ca_app/features/reconciliation/data/datasources/reconciliation_remote_source.dart';
import 'package:ca_app/features/reconciliation/data/repositories/mock_reconciliation_repository.dart';
import 'package:ca_app/features/reconciliation/data/repositories/reconciliation_repository_impl.dart';
import 'package:ca_app/features/reconciliation/domain/repositories/reconciliation_repository.dart';

final reconciliationRemoteSourceProvider = Provider<ReconciliationRemoteSource>(
  (ref) {
    return ReconciliationRemoteSource(Supabase.instance.client);
  },
);

final reconciliationLocalSourceProvider = Provider<ReconciliationLocalSource>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return ReconciliationLocalSource(db);
});

final reconciliationRepositoryProvider = Provider<ReconciliationRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('reconciliation_real_repo') ?? false;

  if (!useReal) {
    return MockReconciliationRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return ReconciliationRepositoryImpl(
    remote: ref.watch(reconciliationRemoteSourceProvider),
    local: ref.watch(reconciliationLocalSourceProvider),
    firmId: firmId,
  );
});
